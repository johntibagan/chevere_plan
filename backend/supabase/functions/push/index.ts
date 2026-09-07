import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { SignJWT, importPKCS8 } from "npm:jose@5";

/**
 * Webhook on public.notifications INSERT → FCM HTTP v1.
 * Deploy: verify_jwt = false (Database Webhook usa service role / secret).
 * Secret: FIREBASE_SERVICE_ACCOUNT_JSON = JSON completo de la service account.
 */

interface NotificationRow {
  id: string;
  user_id: string;
  title: string | null;
  body: string;
  data?: Record<string, unknown> | null;
}

interface WebhookPayload {
  type: "INSERT" | "UPDATE" | "DELETE";
  table: string;
  schema: string;
  record: NotificationRow;
  old_record: NotificationRow | null;
}

interface ServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}

function parseServiceAccount(): ServiceAccount {
  const raw = Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON");
  if (!raw?.trim()) {
    throw new Error("Missing FIREBASE_SERVICE_ACCOUNT_JSON secret");
  }
  const sa = JSON.parse(raw) as ServiceAccount;
  if (!sa.project_id || !sa.client_email || !sa.private_key) {
    throw new Error("FIREBASE_SERVICE_ACCOUNT_JSON incomplete");
  }
  return sa;
}

async function getFcmAccessToken(sa: ServiceAccount): Promise<string> {
  // Service account JSON often stores PEM with literal \n escapes.
  const pem = sa.private_key.includes("\\n")
    ? sa.private_key.replaceAll("\\n", "\n")
    : sa.private_key;
  const key = await importPKCS8(pem, "RS256");
  const assertion = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256" })
    .setIssuer(sa.client_email)
    .setSubject(sa.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt()
    .setExpirationTime("1h")
    .sign(key);

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  const tokenJson = await tokenRes.json();
  if (!tokenRes.ok || !tokenJson.access_token) {
    throw new Error(`OAuth token failed: ${JSON.stringify(tokenJson)}`);
  }
  return tokenJson.access_token as string;
}

async function sendFcm(
  accessToken: string,
  projectId: string,
  deviceToken: string,
  notification: NotificationRow,
): Promise<{ ok: true; result: unknown } | { ok: false; unregistered: true } | { ok: false; error: string }> {
  const title = (notification.title ?? "").trim() || "Chevere Plan";
  const dataPayload: Record<string, string> = {
    notification_id: notification.id,
  };
  const raw = notification.data;
  if (raw && typeof raw === "object") {
    for (const [k, v] of Object.entries(raw)) {
      if (v == null) continue;
      dataPayload[k] = typeof v === "string" ? v : JSON.stringify(v);
    }
  }

  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token: deviceToken,
          notification: {
            title,
            body: notification.body,
          },
          data: dataPayload,
        },
      }),
    },
  );
  const body = await res.json();
  if (res.ok) {
    return { ok: true, result: body };
  }

  const errCode =
    body?.error?.details?.[0]?.errorCode ??
    body?.error?.status ??
    body?.error?.message;
  // Token caducado / app reinstalada / build distinto.
  if (
    res.status === 404 ||
    errCode === "UNREGISTERED" ||
    errCode === "NOT_FOUND" ||
    String(body?.error?.message ?? "").includes("NotRegistered")
  ) {
    return { ok: false, unregistered: true };
  }
  return { ok: false, error: JSON.stringify(body) };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204 });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    if (!supabaseUrl || !serviceKey) {
      return jsonResponse({ error: "Missing Supabase env" }, 500);
    }

    // Webhook Dashboard: header Authorization = Bearer <service_role>.
    const auth = req.headers.get("Authorization") ?? "";
    if (auth !== `Bearer ${serviceKey}`) {
      return jsonResponse({ error: "Unauthorized" }, 401);
    }

    const payload = (await req.json()) as WebhookPayload;
    if (payload.type !== "INSERT" || payload.table !== "notifications") {
      return jsonResponse({ ok: true, skipped: true });
    }

    const record = payload.record;
    if (!record?.user_id || !record.body?.trim()) {
      return jsonResponse({ error: "Invalid notification row" }, 400);
    }

    const admin = createClient(supabaseUrl, serviceKey);
    const { data: tokens, error } = await admin
      .from("user_fcm_tokens")
      .select("token")
      .eq("user_id", record.user_id);

    if (error) {
      return jsonResponse({ error: error.message }, 500);
    }
    if (!tokens?.length) {
      return jsonResponse({ ok: true, sent: 0, reason: "no_tokens" });
    }

    const sa = parseServiceAccount();
    const accessToken = await getFcmAccessToken(sa);
    let sent = 0;
    let removed = 0;
    const errors: string[] = [];

    for (const row of tokens) {
      const outcome = await sendFcm(
        accessToken,
        sa.project_id,
        row.token,
        record,
      );
      if (outcome.ok) {
        sent += 1;
        continue;
      }
      if ("unregistered" in outcome && outcome.unregistered) {
        const { error: delErr } = await admin
          .from("user_fcm_tokens")
          .delete()
          .eq("token", row.token);
        if (delErr) {
          errors.push(`delete ${row.token.slice(0, 12)}…: ${delErr.message}`);
        } else {
          removed += 1;
        }
        continue;
      }
      errors.push(outcome.error);
    }

    // Un token inválido no tumba el webhook: 200 con detalle.
    return jsonResponse({
      ok: errors.length === 0,
      sent,
      removed_unregistered: removed,
      errors: errors.length ? errors : undefined,
    });
  } catch (e) {
    const message = e instanceof Error ? e.message : String(e);
    console.error("push function error", message);
    return jsonResponse({ error: message }, 500);
  }
});
