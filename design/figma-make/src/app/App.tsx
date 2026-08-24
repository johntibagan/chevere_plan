import { useState } from "react";
import {
  Home, Compass, Plus, Map, Route, Bell, LogOut,
  MapPin, DollarSign, Heart, Share2, ArrowLeft,
  ChevronRight, MoreVertical, Eye, Lock, Search,
  SlidersHorizontal, X, Check, AlertCircle,
  Users, Tag, TrendingUp, Navigation, Camera,
  Link2, GripVertical, Wrench, Star, ChevronDown,
  Coffee, Bed, Trees, Palette, Music, ShoppingBag,
  Calendar, Zap, CheckCircle, Shield, Globe, Pencil,
  FileText, AlertTriangle
} from "lucide-react";

// ─── TOKENS ───────────────────────────────────────────────────────
const C = {
  bg:         "#0B0D15",
  surface:    "#141A24",
  surfaceEl:  "#1C2333",
  sidebar:    "#0E1120",
  fg:         "#F0F4FF",
  muted:      "#8E93AC",
  mutedDk:    "#5A607A",
  primary:    "#FFBB33",
  soft:       "#FF8C42",
  accent:     "#FF5252",
  success:    "#00D68F",   // PUBLIC
  purple:     "#8B7FFF",   // PRIVATE
  border:     "rgba(255,255,255,0.06)",
} as const;

// ─── CATEGORIES ───────────────────────────────────────────────────
const CATS = [
  { id:"gastro", label:"Gastronomía",     icon:Coffee,      color:"#FF8C42", bg:"#FF8C4218" },
  { id:"aloj",   label:"Alojamiento",     icon:Bed,         color:"#8B7FFF", bg:"#8B7FFF18" },
  { id:"nat",    label:"Naturaleza",      icon:Trees,       color:"#00D68F", bg:"#00D68F18" },
  { id:"cult",   label:"Cultura",         icon:Palette,     color:"#E84393", bg:"#E8439318" },
  { id:"ent",    label:"Entretenimiento", icon:Music,       color:"#FFBB33", bg:"#FFBB3318" },
  { id:"comp",   label:"Compras",         icon:ShoppingBag, color:"#00C9A7", bg:"#00C9A718" },
  { id:"even",   label:"Eventos",         icon:Calendar,    color:"#FF5252", bg:"#FF525218" },
  { id:"serv",   label:"Servicios",       icon:Globe,       color:"#4A90D9", bg:"#4A90D918" },
];
const catOf = (id: string) => CATS.find(c => c.id === id) ?? CATS[0];

// ─── DATA ──────────────────────────────────────────────────────────
type PlaceStatus = "complete" | "draft" | "pending";
const PLACES = [
  { id:1, name:"El Cielo",            city:"Medellín",  hood:"El Poblado",   cat:"gastro", price:"$$$",  img:"https://images.unsplash.com/photo-1759375341361-00f9054cd5bb?w=600&h=400&fit=crop&auto=format",  isPublic:true,  isMine:true,  fav:false, src:"instagram", saved:"hace 2 días",    visited:false, addr:"Calle 7 #43E-100",        desc:"Alta cocina colombiana. Experiencias gastronómicas únicas del chef Juan Manuel Barrientos.", status:"complete"  as PlaceStatus, isLinked:false, isCatalog:false },
  { id:2, name:"Café Quindío",        city:"Salento",   hood:"Calle Real",   cat:"gastro", price:"$",    img:undefined,  isPublic:true,  isMine:true,  fav:true,  src:"tiktok",    saved:"hace 1 semana",  visited:true,  addr:"Calle Real #4-10",        desc:"Café de origen con variedades únicas del Eje Cafetero. Ambiente colonial.",                    status:"complete"  as PlaceStatus, isLinked:false, isCatalog:false },
  { id:3, name:"Hacienda Bambusa",    city:"Quimbaya",  hood:"El Laurel",    cat:"aloj",   price:"$$$$", img:"https://images.unsplash.com/photo-1582642250536-419cfaaef741?w=600&h=400&fit=crop&auto=format",  isPublic:false, isMine:true,  fav:false, src:undefined,   saved:"hace 3 días",    visited:false, addr:"Km 4 vía Quimbaya",       desc:"Finca boutique rodeada de guaduales y cafetales. Piscina con vista a la montaña.",           status:"complete"  as PlaceStatus, isLinked:false, isCatalog:false },
  { id:4, name:"Cañón del Chicamocha",city:"San Gil",   hood:"Santander",    cat:"nat",    price:"$$",   img:"https://images.unsplash.com/photo-1764815538777-8eb62197eabd?w=600&h=400&fit=crop&auto=format",  isPublic:true,  isMine:false, fav:false, src:undefined,   saved:"hace 5 días",    visited:false, addr:"Parque del Chicamocha",   desc:"Teleférico, parapente y deportes extremos. Uno de los cañones más grandes.",                  status:"complete"  as PlaceStatus, isLinked:false, isCatalog:true  },
  { id:5, name:"La Pepita Burger",    city:"Bogotá",    hood:"Chapinero",    cat:"gastro", price:"$$",   img:undefined,  isPublic:false, isMine:true,  fav:true,  src:"tiktok",    saved:"hace 1 día",     visited:false, addr:"Cll 72 #10-34",           desc:"Hamburguesas gourmet con papas bravas y salsas artesanales.",                                 status:"draft"     as PlaceStatus, isLinked:false, isCatalog:false },
  { id:6, name:"Castillo San Felipe", city:"Cartagena", hood:"La Manga",     cat:"cult",   price:"$",    img:undefined,  isPublic:true,  isMine:true,  fav:false, src:"instagram", saved:"hace 2 semanas", visited:true,  addr:"Carrera 17 #36-3",        desc:"Fortaleza colonial española siglo XVII. Patrimonio UNESCO.",                                  status:"complete"  as PlaceStatus, isLinked:false, isCatalog:true  },
  { id:7, name:"Andrés DC",           city:"Bogotá",    hood:"Centro",       cat:"ent",    price:"$$$",  img:undefined,  isPublic:true,  isMine:false, fav:false, src:undefined,   saved:"hace 4 días",    visited:false, addr:"Av. El Dorado #93B-54",   desc:"Icónico restaurante-bar con música en vivo y shows nocturnos.",                               status:"complete"  as PlaceStatus, isLinked:true,  isCatalog:false },
  { id:8, name:"Pueblito Paisa",      city:"Medellín",  hood:"Nutibara",     cat:"cult",   price:"libre",img:undefined,  isPublic:true,  isMine:true,  fav:false, src:undefined,   saved:"hace 1 mes",     visited:true,  addr:"Cerro Nutibara",          desc:"Réplica de pueblo antioqueño con vista panorámica de Medellín. Entrada libre.",               status:"complete"  as PlaceStatus, isLinked:false, isCatalog:true  },
];

const PLANS = [
  { id:1, title:"Villa de Leyva en finde",   zone:"Villa de Leyva, Boyacá",  date:"Sáb 10–Dom 11 ago", stops:5, budget:"$320.000", status:"upcoming", img:undefined,
    itinerary:[
      { name:"Plaza Mayor",             time:"9:00 AM",  dur:"1h 30min", cat:"cult",   visited:true  },
      { name:"Mercado Artesanal",       time:"10:30 AM", dur:"1h",       cat:"comp",   visited:true  },
      { name:"La Cocina de mi Abuela",  time:"12:30 PM", dur:"1h 30min", cat:"gastro", visited:false },
      { name:"Pozos Azules",            time:"2:30 PM",  dur:"2h",       cat:"nat",    visited:false },
      { name:"El Mesón de los Virreyes",time:"7:00 PM",  dur:"2h",       cat:"gastro", visited:false },
    ],
  },
  { id:2, title:"Cartagena Ciudad Amurallada", zone:"Cartagena, Bolívar",  date:"Vie 16–Lun 19 ago", stops:4, budget:"$480.000", status:"draft", img:undefined,
    itinerary:[
      { name:"Castillo San Felipe", time:"8:00 AM",  dur:"2h",       cat:"cult",   visited:false },
      { name:"Ciudad Amurallada",   time:"11:00 AM", dur:"2h",       cat:"cult",   visited:false },
      { name:"La Vitrola",          time:"1:30 PM",  dur:"1h 30min", cat:"gastro", visited:false },
      { name:"El Laguito Playa",    time:"4:00 PM",  dur:"3h",       cat:"nat",    visited:false },
    ],
  },
];

// ─── TYPES ────────────────────────────────────────────────────────
type Screen = "login"|"inicio"|"explorar"|"planes"|"rutas"|"save-place"|"category-picker"|"site-detail"|"create-plan"|"plan-builder"|"plan-detail"|"admin"|"admin-reports"|"en-construccion";
type TabId  = "inicio"|"explorar"|"planes"|"rutas";

interface EnCData { title: string; desc: string; }

// ─── SMALL COMPONENTS ─────────────────────────────────────────────
const DefaultCover = ({ catId, className = "" }: { catId: string; className?: string }) => {
  const c = catOf(catId);
  const Icon = c.icon;
  return (
    <div className={`flex items-center justify-center ${className}`}
         style={{ background:`linear-gradient(135deg, ${C.surface} 0%, ${C.surfaceEl} 100%)` }}>
      <div className="flex flex-col items-center gap-1.5 opacity-25">
        <Icon size={28} style={{ color:c.color }}/>
      </div>
    </div>
  );
};

const SiteCover = ({ img, catId, alt, className = "" }: { img?:string; catId:string; alt:string; className?:string }) =>
  img
    ? <img src={img} alt={alt} className={`object-cover ${className}`}/>
    : <DefaultCover catId={catId} className={className}/>;

const CatBadge = ({ id, small=false }: { id:string; small?:boolean }) => {
  const c = catOf(id);
  const Icon = c.icon;
  return (
    <span className={`inline-flex items-center gap-1 rounded-full font-semibold leading-none ${small?"text-[9px] px-1.5 py-[3px]":"text-[11px] px-2.5 py-1"}`}
          style={{ background:c.bg, color:c.color }}>
      <Icon size={small?8:10}/>{c.label}
    </span>
  );
};

const SrcBadge = ({ src }: { src?:string }) => {
  if (!src) return null;
  const styles: Record<string,string> = { instagram:"bg-gradient-to-r from-[#833ab4] via-[#fd1d1d] to-[#fcb045]", tiktok:"bg-black border border-[#69C9D0]/40", facebook:"bg-[#1877F2]", maps:"bg-[#4285F4]" };
  const labels: Record<string,string> = { instagram:"IG", tiktok:"TK", facebook:"FB", maps:"GM" };
  return <span className={`text-[9px] font-extrabold text-white px-1.5 py-[2px] rounded-[4px] ${styles[src]??"bg-[#444]"}`}>{labels[src]??src.slice(0,2).toUpperCase()}</span>;
};

const StatusPill = ({ status }: { status:string }) => {
  const map: Record<string,{label:string;bg:string;color:string}> = {
    upcoming: { label:"Próximo",  bg:`${C.primary}22`, color:C.primary  },
    draft:    { label:"Borrador", bg:`${C.mutedDk}20`, color:C.muted    },
    complete: { label:"Completo", bg:`${C.success}18`, color:C.success  },
    pending:  { label:"Pendiente",bg:`${C.soft}20`,    color:C.soft     },
  };
  const s = map[status] ?? map.draft;
  return <span className="text-[10px] font-bold px-2 py-[3px] rounded-full" style={{ background:s.bg, color:s.color }}>{s.label}</span>;
};

const VisIcon = ({ isPublic }: { isPublic:boolean }) =>
  isPublic
    ? <Eye size={12} style={{ color:C.success }}/>
    : <Lock size={12} style={{ color:C.purple }}/>;

const HeartBtn = ({ fav, onToggle }: { fav:boolean; onToggle:(e:React.MouseEvent)=>void }) => (
  <button onClick={onToggle} className="bg-black/40 backdrop-blur-sm rounded-full p-1.5 flex-shrink-0">
    <Heart size={13} className={fav ? "fill-[#FF5252] text-[#FF5252]" : "text-white"}/>
  </button>
);

const AppBar = ({ title, onBack, actions }: { title:string; onBack:()=>void; actions?: React.ReactNode }) => (
  <div className="flex items-center gap-2 px-4 pt-4 pb-3 flex-shrink-0" style={{ background:C.bg }}>
    <button onClick={onBack} className="rounded-full p-2 flex-shrink-0" style={{ background:C.surface }}><ArrowLeft size={18} style={{ color:C.muted }}/></button>
    <p className="flex-1 text-[17px] font-extrabold truncate" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>{title}</p>
    {actions}
  </div>
);

const TabHeader = ({ title, subtitle }: { title:string; subtitle?:string }) => (
  <div className="px-4 pt-5 pb-1 flex-shrink-0">
    <h1 className="text-[22px] font-extrabold" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>{title}</h1>
    {subtitle && <p className="text-[12px] mt-0.5" style={{ color:C.muted }}>{subtitle}</p>}
  </div>
);

// ─── EN CONSTRUCCIÓN ──────────────────────────────────────────────
const EnConstruccion = ({ data, onBack }: { data:EnCData; onBack:()=>void }) => (
  <div className="flex flex-col h-full items-center justify-center px-8" style={{ background:C.bg }}>
    <button onClick={onBack} className="absolute top-5 left-4 rounded-full p-2" style={{ background:C.surface }}><ArrowLeft size={18} style={{ color:C.muted }}/></button>
    <div className="w-20 h-20 rounded-full flex items-center justify-center mb-5" style={{ background:`${C.mutedDk}18` }}>
      <Wrench size={34} style={{ color:C.mutedDk }}/>
    </div>
    <p className="text-[18px] font-extrabold text-center mb-2" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>{data.title}</p>
    <p className="text-[13px] text-center leading-relaxed mb-6" style={{ color:C.muted }}>{data.desc}</p>
    <button className="px-6 py-2.5 rounded-xl text-[13px] font-semibold" style={{ background:C.surface, border:`1px solid ${C.border}`, color:C.muted }}>
      Avisame cuando esté listo
    </button>
  </div>
);

// ─── LOGIN PAGE ───────────────────────────────────────────────────
const LoginPage = ({ onLogin }: { onLogin:()=>void }) => {
  const [legal, setLegal] = useState(false);
  return (
    <div className="flex flex-col h-full items-center justify-center px-6" style={{ background:C.bg }}>
      <div className="w-[72px] h-[72px] rounded-[20px] flex items-center justify-center mb-5"
           style={{ background:`linear-gradient(135deg, ${C.primary} 0%, ${C.soft} 100%)` }}>
        <MapPin size={34} className="text-black" strokeWidth={2.5}/>
      </div>
      <h1 className="text-[28px] font-extrabold mb-1" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>Chevere Plan</h1>
      <p className="text-[14px] text-center mb-8" style={{ color:C.muted }}>Guarda, organiza y descubre los mejores planes de Colombia</p>

      <div className="w-full flex flex-col gap-4">
        <label className="flex items-start gap-3 cursor-pointer">
          <button onClick={() => setLegal(v => !v)}
            className="w-5 h-5 rounded-md flex-shrink-0 flex items-center justify-center mt-0.5 transition-all"
            style={{ background: legal ? C.primary : C.surface, border:`1.5px solid ${legal ? C.primary : C.border}` }}>
            {legal && <Check size={12} className="text-black" strokeWidth={3}/>}
          </button>
          <span className="text-[12px] leading-relaxed" style={{ color:C.muted }}>
            Acepto los{" "}
            <span className="underline" style={{ color:C.primary }}>Términos de Uso</span>
            {" "}y la{" "}
            <span className="underline" style={{ color:C.primary }}>Política de Datos</span>
          </span>
        </label>

        <button
          onClick={legal ? onLogin : undefined}
          disabled={!legal}
          className="w-full flex items-center justify-center gap-3 py-3.5 rounded-xl font-semibold text-[14px] transition-all"
          style={{ background: legal ? "#FFFFFF" : C.surface, color: legal ? "#1a1a1a" : C.mutedDk, border:`1px solid ${legal ? "transparent" : C.border}`, opacity: legal ? 1 : 0.5 }}>
          <svg width="18" height="18" viewBox="0 0 18 18"><path fill="#4285F4" d="M17.64 9.2c0-.637-.057-1.251-.164-1.84H9v3.481h4.844a4.14 4.14 0 01-1.796 2.716v2.259h2.908c1.702-1.567 2.684-3.875 2.684-6.615z"/><path fill="#34A853" d="M9 18c2.43 0 4.467-.806 5.956-2.18l-2.908-2.259c-.806.54-1.837.86-3.048.86-2.344 0-4.328-1.584-5.036-3.711H.957v2.332A8.997 8.997 0 009 18z"/><path fill="#FBBC05" d="M3.964 10.71A5.41 5.41 0 013.682 9c0-.593.102-1.17.282-1.71V4.958H.957A8.996 8.996 0 000 9c0 1.452.348 2.827.957 4.042l3.007-2.332z"/><path fill="#EA4335" d="M9 3.58c1.321 0 2.508.454 3.44 1.345l2.582-2.58C13.463.891 11.426 0 9 0A8.997 8.997 0 00.957 4.958L3.964 7.29C4.672 5.163 6.656 3.58 9 3.58z"/></svg>
          Continuar con Google
        </button>
      </div>
    </div>
  );
};

// ─── BOTTOM NAV ───────────────────────────────────────────────────
const BottomNav = ({ active, onChange, onSave }: { active:TabId; onChange:(t:TabId)=>void; onSave:()=>void }) => {
  const L: { id:TabId; Icon:typeof Home; lbl:string }[] = [{ id:"inicio", Icon:Home, lbl:"Inicio" },{ id:"explorar", Icon:Compass, lbl:"Explorar" }];
  const R: { id:TabId; Icon:typeof Map;  lbl:string }[] = [{ id:"planes",  Icon:Map,  lbl:"Planes"  },{ id:"rutas",    Icon:Route, lbl:"Rutas"    }];
  return (
    <div className="absolute bottom-0 left-0 right-0 flex items-center justify-around px-2 pt-2 pb-4" style={{ background:C.sidebar, borderTop:`1px solid ${C.border}` }}>
      {L.map(({ id,Icon,lbl }) => (
        <button key={id} onClick={() => onChange(id)} className="flex flex-col items-center gap-0.5 flex-1 py-1">
          <Icon size={20} style={{ color: active===id ? C.primary : C.mutedDk }}/>
          <span className="text-[10px] font-semibold" style={{ color: active===id ? C.primary : C.mutedDk }}>{lbl}</span>
        </button>
      ))}
      <button onClick={onSave} className="w-14 h-14 -mt-5 rounded-full flex items-center justify-center"
              style={{ background:`linear-gradient(135deg,${C.primary} 0%,${C.soft} 100%)`, boxShadow:`0 4px 22px ${C.primary}44` }}>
        <Plus size={24} className="text-black" strokeWidth={2.5}/>
      </button>
      {R.map(({ id,Icon,lbl }) => (
        <button key={id} onClick={() => onChange(id)} className="flex flex-col items-center gap-0.5 flex-1 py-1">
          <Icon size={20} style={{ color: active===id ? C.primary : C.mutedDk }}/>
          <span className="text-[10px] font-semibold" style={{ color: active===id ? C.primary : C.mutedDk }}>{lbl}</span>
        </button>
      ))}
    </div>
  );
};

// ─── INICIO TAB ───────────────────────────────────────────────────
const InicioTab = ({ onSite, onAdmin, onMemory }: { onSite:(p:typeof PLACES[0])=>void; onAdmin:()=>void; onMemory:()=>void }) => {
  const [favs, setFavs] = useState<number[]>(PLACES.filter(p => p.fav).map(p => p.id));
  const drafts = PLACES.filter(p => p.status === "draft" && p.isMine);
  const isStaff = true;
  return (
    <div className="flex flex-col h-full" style={{ background:C.bg }}>
      {/* Header */}
      <div className="flex items-center justify-between px-4 pt-5 pb-3 flex-shrink-0">
        <div>
          <p className="text-[11px]" style={{ color:C.mutedDk }}>Buenos días ☀️</p>
          <h1 className="text-[22px] font-extrabold" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>Chevere Plan</h1>
        </div>
        <div className="flex items-center gap-2">
          <button onClick={onMemory} className="relative rounded-full p-2.5" style={{ background:C.surface }}>
            <Bell size={18} style={{ color:C.muted }}/>
            <div className="absolute top-1.5 right-1.5 w-1.5 h-1.5 rounded-full" style={{ background:C.accent }}/>
          </button>
          {isStaff
            ? <button onClick={onAdmin} className="w-9 h-9 rounded-full flex items-center justify-center text-sm font-extrabold" style={{ background:`${C.primary}22`, color:C.primary, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>A</button>
            : <button className="rounded-full p-2.5" style={{ background:C.surface }}><LogOut size={16} style={{ color:C.muted }}/></button>
          }
        </div>
      </div>

      <div className="flex-1 overflow-y-auto pb-20">
        {/* Recuerdo cercano */}
        <div className="mx-4 mb-4 rounded-2xl overflow-hidden" style={{ background:`linear-gradient(135deg,${C.primary} 0%,${C.soft} 100%)` }}>
          <div className="p-3.5 flex items-center gap-3">
            <div className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0" style={{ background:"rgba(0,0,0,0.15)" }}><Zap size={20} className="text-black"/></div>
            <div className="flex-1">
              <p className="text-[10px] font-bold uppercase tracking-wider" style={{ color:"rgba(0,0,0,0.5)" }}>Recuerdo cercano</p>
              <p className="text-[13px] font-bold text-black">Café Quindío está a 200m</p>
              <p className="text-[10px]" style={{ color:"rgba(0,0,0,0.55)" }}>¡Lo guardaste hace 1 semana!</p>
            </div>
            <ChevronRight size={16} className="text-black/40"/>
          </div>
        </div>

        {/* Borradores banner */}
        {drafts.length > 0 && (
          <div className="mx-4 mb-4 rounded-xl p-3 flex items-center gap-3" style={{ background:`${C.soft}12`, border:`1px solid ${C.soft}30` }}>
            <AlertTriangle size={16} style={{ color:C.soft }}/>
            <div className="flex-1">
              <p className="text-[12px] font-semibold" style={{ color:C.soft }}>Tenés {drafts.length} guardado{drafts.length>1?"s":""} sin completar</p>
              <p className="text-[10px]" style={{ color:C.muted }}>Completalo para poder compartirlo</p>
            </div>
            <ChevronRight size={14} style={{ color:C.soft }}/>
          </div>
        )}

        {/* Recientes carrusel */}
        <div className="mb-5">
          <div className="flex items-center justify-between px-4 mb-2.5">
            <p className="text-[13px] font-extrabold" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>Guardados recientes</p>
            <button className="text-[11px] font-semibold flex items-center gap-0.5" style={{ color:C.primary }}>Ver todos<ChevronRight size={12}/></button>
          </div>
          <div className="flex gap-3 px-4 overflow-x-auto pb-2" style={{ scrollbarWidth:"none" }}>
            {PLACES.filter(p => p.isMine).slice(0,6).map(p => (
              <div key={p.id} onClick={() => onSite(p)} className="cursor-pointer flex-shrink-0 w-36">
                <div className="relative h-44 rounded-2xl overflow-hidden mb-1.5" style={{ background:C.surface }}>
                  <SiteCover img={p.img} catId={p.cat} alt={p.name} className="w-full h-full"/>
                  <div className="absolute inset-0" style={{ background:"linear-gradient(to top,rgba(0,0,0,0.75) 0%,transparent 55%)" }}/>
                  <div className="absolute top-2 left-2 flex gap-1 items-center">
                    <SrcBadge src={p.src}/>
                    {p.status === "draft" && <span className="text-[9px] font-bold px-1.5 py-[2px] rounded" style={{ background:`${C.soft}22`, color:C.soft }}>Borrador</span>}
                  </div>
                  <button onClick={e => { e.stopPropagation(); setFavs(v => v.includes(p.id) ? v.filter(x => x!==p.id) : [...v,p.id]); }}
                    className="absolute top-2 right-2 rounded-full p-1.5" style={{ background:"rgba(0,0,0,0.45)" }}>
                    <Heart size={12} className={favs.includes(p.id) ? "fill-[#FF5252] text-[#FF5252]" : "text-white"}/>
                  </button>
                  <div className="absolute bottom-2 left-2 right-2">
                    <div className="flex items-center gap-1 mb-0.5">
                      <VisIcon isPublic={p.isPublic}/>
                    </div>
                    <p className="text-[11px] font-bold text-white truncate">{p.name}</p>
                    <p className="text-[9px]" style={{ color:"rgba(255,255,255,0.55)" }}>{p.city}</p>
                  </div>
                </div>
                <CatBadge id={p.cat} small/>
              </div>
            ))}
          </div>
        </div>

        {/* Populares cerca */}
        <div className="mb-5">
          <div className="flex items-center justify-between px-4 mb-2.5">
            <p className="text-[13px] font-extrabold" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>Populares cerca</p>
            <button className="text-[11px] font-semibold flex items-center gap-0.5" style={{ color:C.primary }}>Explorar<ChevronRight size={12}/></button>
          </div>
          <div className="px-4 grid grid-cols-2 gap-2.5">
            {PLACES.filter(p => p.isPublic).slice(0,4).map(p => (
              <div key={p.id} onClick={() => onSite(p)} className="rounded-2xl overflow-hidden cursor-pointer active:scale-[0.97] transition-transform"
                   style={{ background:C.surface, border:`1px solid ${C.border}` }}>
                <div className="relative h-[100px]" style={{ background:C.surfaceEl }}>
                  <SiteCover img={p.img} catId={p.cat} alt={p.name} className="w-full h-full"/>
                  <div className="absolute inset-0" style={{ background:"linear-gradient(to top,rgba(0,0,0,0.65) 0%,transparent 60%)" }}/>
                  <button onClick={e => { e.stopPropagation(); setFavs(v => v.includes(p.id) ? v.filter(x => x!==p.id) : [...v,p.id]); }}
                    className="absolute top-1.5 right-1.5 rounded-full p-1.5" style={{ background:"rgba(0,0,0,0.45)" }}>
                    <Heart size={11} className={favs.includes(p.id) ? "fill-[#FF5252] text-[#FF5252]" : "text-white"}/>
                  </button>
                  {/* Visibility stripe */}
                  <div className="absolute left-0 top-0 bottom-0 w-[3px] rounded-l-2xl" style={{ background: p.isPublic ? C.success : C.purple }}/>
                  <div className="absolute bottom-1.5 left-2.5 flex items-center gap-1">
                    <MapPin size={9} style={{ color:C.primary }}/><span className="text-[10px] font-medium text-white">{p.city}</span>
                  </div>
                </div>
                <div className="p-2.5">
                  <p className="font-bold text-[12px] truncate mb-0.5" style={{ color:C.fg }}>{p.name}</p>
                  <div className="flex items-center justify-between">
                    <CatBadge id={p.cat} small/>
                    <span className="text-[10px] font-bold" style={{ color:C.primary }}>{p.price}</span>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Acciones rápidas */}
        <div className="px-4">
          <p className="text-[13px] font-extrabold mb-3" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>Acciones rápidas</p>
          <div className="grid grid-cols-3 gap-2">
            {[{ Icon:MapPin, label:"Cerca de mí", color:"#FF5252" },{ Icon:TrendingUp, label:"Más guardados", color:C.primary },{ Icon:Tag, label:"Por categoría", color:"#8B7FFF" }].map(a => (
              <button key={a.label} className="flex flex-col items-center gap-2 p-3 rounded-xl" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
                <div className="w-10 h-10 rounded-full flex items-center justify-center" style={{ background:`${a.color}18` }}><a.Icon size={18} style={{ color:a.color }}/></div>
                <span className="text-[10px] font-semibold text-center leading-tight" style={{ color:C.muted }}>{a.label}</span>
              </button>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
};

// ─── EXPLORAR TAB ─────────────────────────────────────────────────
const ExplorarTab = ({ onSite }: { onSite:(p:typeof PLACES[0])=>void }) => {
  const [q, setQ] = useState("");
  const [cat, setCat] = useState<string|null>(null);
  const [list, setList] = useState(false);
  const [favs, setFavs] = useState<number[]>(PLACES.filter(p => p.fav).map(p => p.id));

  const results = PLACES.filter(p => {
    const mq = !q || p.name.toLowerCase().includes(q.toLowerCase()) || p.city.toLowerCase().includes(q.toLowerCase());
    return (!cat || p.cat === cat) && mq;
  });

  const tagLabel = (p: typeof PLACES[0]) => p.isMine ? "Tuyo" : p.isLinked ? "Vinculado" : p.isCatalog ? "Catálogo" : null;

  return (
    <div className="flex flex-col h-full" style={{ background:C.bg }}>
      <div className="px-4 pt-5 pb-3 flex-shrink-0">
        <h1 className="text-[22px] font-extrabold mb-3" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>Explorar</h1>
        <div className="flex gap-2">
          <div className="flex-1 flex items-center gap-2 px-3 py-2.5 rounded-xl" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
            <Search size={15} style={{ color:C.mutedDk }} className="flex-shrink-0"/>
            <input value={q} onChange={e => setQ(e.target.value)} placeholder="Busca lugares, ciudades..."
                   className="flex-1 bg-transparent text-[13px] outline-none" style={{ color:C.fg }}
                   // placeholder color via CSS trick:
                   onFocus={e => e.target.style.caretColor=C.primary}/>
          </div>
          <button className="w-11 flex items-center justify-center rounded-xl" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
            <SlidersHorizontal size={16} style={{ color:C.muted }}/>
          </button>
        </div>
      </div>

      <div className="flex gap-1.5 px-4 pb-3 overflow-x-auto flex-shrink-0" style={{ scrollbarWidth:"none" }}>
        <button onClick={() => setCat(null)} className="flex-shrink-0 text-[11px] font-bold px-3 py-1.5 rounded-full transition-all"
                style={{ background: !cat ? C.primary : C.surface, color: !cat ? "#000" : C.muted }}>Todos</button>
        {CATS.map(c => {
          const Icon = c.icon;
          return (
            <button key={c.id} onClick={() => setCat(cat===c.id ? null : c.id)}
              className="flex-shrink-0 flex items-center gap-1.5 text-[11px] font-bold px-3 py-1.5 rounded-full transition-all"
              style={{ background: cat===c.id ? c.color+"22" : C.surface, color: cat===c.id ? c.color : C.muted, border:`1px solid ${cat===c.id ? c.color+"44" : C.border}` }}>
              <Icon size={10}/>{c.label}
            </button>
          );
        })}
      </div>

      <div className="flex items-center justify-between px-4 mb-3 flex-shrink-0">
        <p className="text-[11px]" style={{ color:C.mutedDk }}>{results.length} resultados</p>
        <div className="flex gap-0.5 rounded-lg p-0.5" style={{ background:C.surface }}>
          {[false,true].map(isL => (
            <button key={String(isL)} onClick={() => setList(isL)} className="p-1.5 rounded" style={{ background: list===isL ? C.surfaceEl : "transparent" }}>
              {isL
                ? <svg className="w-3.5 h-3.5" fill={list ? C.primary : C.mutedDk} viewBox="0 0 16 16"><rect x="0" y="1" width="16" height="3" rx="1"/><rect x="0" y="7" width="16" height="3" rx="1"/><rect x="0" y="13" width="16" height="3" rx="1"/></svg>
                : <svg className="w-3.5 h-3.5" fill={!list ? C.primary : C.mutedDk} viewBox="0 0 16 16"><rect x="0" y="0" width="6" height="6" rx="1"/><rect x="10" y="0" width="6" height="6" rx="1"/><rect x="0" y="10" width="6" height="6" rx="1"/><rect x="10" y="10" width="6" height="6" rx="1"/></svg>
              }
            </button>
          ))}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-4 pb-20">
        {!list
          ? <div className="grid grid-cols-2 gap-2.5">
              {results.map(p => (
                <div key={p.id} onClick={() => onSite(p)} className="rounded-2xl overflow-hidden cursor-pointer active:scale-[0.97] transition-transform relative"
                     style={{ background:C.surface, border:`1px solid ${C.border}` }}>
                  <div className="absolute left-0 top-0 bottom-0 w-[3px] rounded-l-2xl z-10" style={{ background: p.isPublic ? C.success : C.purple }}/>
                  <div className="relative h-[100px]" style={{ background:C.surfaceEl }}>
                    <SiteCover img={p.img} catId={p.cat} alt={p.name} className="w-full h-full"/>
                    <div className="absolute inset-0" style={{ background:"linear-gradient(to top,rgba(0,0,0,0.65) 0%,transparent 60%)" }}/>
                    <button onClick={e => { e.stopPropagation(); setFavs(v => v.includes(p.id)?v.filter(x=>x!==p.id):[...v,p.id]); }} className="absolute top-1.5 right-1.5 rounded-full p-1.5" style={{ background:"rgba(0,0,0,0.4)" }}>
                      <Heart size={11} className={favs.includes(p.id)?"fill-[#FF5252] text-[#FF5252]":"text-white"}/>
                    </button>
                    {p.src && <div className="absolute top-1.5 left-3"><SrcBadge src={p.src}/></div>}
                  </div>
                  <div className="p-2.5">
                    <div className="flex items-center gap-1 mb-0.5">
                      <VisIcon isPublic={p.isPublic}/>
                      {tagLabel(p) && <span className="text-[9px] font-bold" style={{ color: p.isMine ? C.primary : C.muted }}>{tagLabel(p)}</span>}
                    </div>
                    <p className="font-bold text-[12px] truncate mb-1.5" style={{ color:C.fg }}>{p.name}</p>
                    <div className="flex items-center justify-between"><CatBadge id={p.cat} small/><span className="text-[10px] font-bold" style={{ color:C.primary }}>{p.price}</span></div>
                  </div>
                </div>
              ))}
            </div>
          : <div className="flex flex-col gap-2">
              {results.map(p => (
                <div key={p.id} onClick={() => onSite(p)} className="flex gap-3 p-2.5 rounded-xl cursor-pointer active:scale-[0.98] transition-transform relative overflow-hidden"
                     style={{ background:C.surface, border:`1px solid ${C.border}` }}>
                  <div className="absolute left-0 top-0 bottom-0 w-[3px]" style={{ background: p.isPublic ? C.success : C.purple }}/>
                  <div className="w-20 h-20 rounded-lg overflow-hidden flex-shrink-0 ml-1" style={{ background:C.surfaceEl }}>
                    <SiteCover img={p.img} catId={p.cat} alt={p.name} className="w-full h-full"/>
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-1.5 mb-0.5">
                      <VisIcon isPublic={p.isPublic}/>
                      {tagLabel(p) && <span className="text-[9px] font-bold" style={{ color: p.isMine ? C.primary : C.muted }}>{tagLabel(p)}</span>}
                      {p.src && <SrcBadge src={p.src}/>}
                    </div>
                    <p className="font-bold text-[13px] truncate" style={{ color:C.fg }}>{p.name}</p>
                    <p className="text-[10px] mb-1.5" style={{ color:C.muted }}>{p.city} · {p.hood}</p>
                    <div className="flex items-center justify-between"><CatBadge id={p.cat} small/><span className="text-[10px] font-bold" style={{ color:C.primary }}>{p.price}</span></div>
                  </div>
                  <ChevronRight size={14} style={{ color:C.mutedDk }} className="self-center flex-shrink-0"/>
                </div>
              ))}
            </div>
        }
      </div>
    </div>
  );
};

// ─── PLANES TAB ───────────────────────────────────────────────────
const PlanesTab = ({ onPlan, onCreate }: { onPlan:(pl:typeof PLANS[0])=>void; onCreate:()=>void }) => (
  <div className="flex flex-col h-full" style={{ background:C.bg }}>
    <TabHeader title="Planes" subtitle="Tus itinerarios guardados"/>
    <div className="flex-1 overflow-y-auto px-4 pb-20 pt-4">
      {/* Create CTA */}
      <button onClick={onCreate} className="w-full mb-4 rounded-2xl p-4 text-left active:scale-[0.98] transition-transform" style={{ background:`linear-gradient(135deg,${C.surface} 0%,${C.surfaceEl} 100%)`, border:`1px solid ${C.primary}28` }}>
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background:`${C.primary}18` }}><Plus size={20} style={{ color:C.primary }}/></div>
          <div className="flex-1">
            <p className="text-[13px] font-bold" style={{ color:C.fg }}>Crear un plan</p>
            <p className="text-[11px]" style={{ color:C.muted }}>Título, zona, paradas y presupuesto</p>
          </div>
          <ChevronRight size={16} style={{ color:C.primary }}/>
        </div>
      </button>

      <p className="text-[11px] font-bold uppercase tracking-wider mb-3" style={{ color:C.mutedDk }}>Mis planes guardados</p>
      <div className="flex flex-col gap-3">
        {PLANS.map(pl => (
          <div key={pl.id} onClick={() => onPlan(pl)} className="rounded-2xl overflow-hidden cursor-pointer active:scale-[0.98] transition-transform" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
            <div className="relative h-24" style={{ background:C.surfaceEl }}>
              <SiteCover img={pl.img} catId={pl.itinerary[0]?.cat ?? "gastro"} alt={pl.title} className="w-full h-full"/>
              <div className="absolute inset-0" style={{ background:"linear-gradient(to top,rgba(0,0,0,0.8) 0%,transparent 60%)" }}/>
              <div className="absolute top-2 right-2"><StatusPill status={pl.status}/></div>
              <p className="absolute bottom-2 left-3 font-bold text-[14px] text-white">{pl.title}</p>
            </div>
            <div className="px-3 py-2.5 flex gap-3 text-[11px]" style={{ color:C.muted }}>
              <span className="flex items-center gap-1"><MapPin size={10} style={{ color:C.accent }}/>{pl.zone.split(",")[0]}</span>
              <span className="flex items-center gap-1"><TrendingUp size={10} style={{ color:C.primary }}/>{pl.stops} paradas</span>
              <span className="flex items-center gap-1"><DollarSign size={10} style={{ color:C.success }}/>{pl.budget}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  </div>
);

// ─── RUTAS TAB ────────────────────────────────────────────────────
const RutasTab = ({ onPlan }: { onPlan:(pl:typeof PLANS[0])=>void }) => {
  const visited = PLACES.filter(p => p.visited);
  return (
    <div className="flex flex-col h-full" style={{ background:C.bg }}>
      <TabHeader title="Mis Rutas" subtitle="Historial de paradas visitadas"/>
      <div className="flex-1 overflow-y-auto px-4 pb-20 pt-4">
        <div className="flex gap-2 mb-5">
          {[["23","Visitados",C.primary],["7","Ciudades",C.success],["5","Planes",C.purple]].map(([v,l,color]) => (
            <div key={l} className="flex-1 rounded-xl p-3 text-center" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
              <p className="text-[20px] font-extrabold" style={{ color:color, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>{v}</p>
              <p className="text-[9px] mt-0.5 leading-tight" style={{ color:C.mutedDk }}>{l}</p>
            </div>
          ))}
        </div>
        <p className="text-[11px] font-bold uppercase tracking-wider mb-3" style={{ color:C.mutedDk }}>Historial</p>
        <div className="relative">
          <div className="absolute left-4 top-0 bottom-0 w-px" style={{ background:C.border }}/>
          {PLACES.map(p => (
            <div key={p.id} className="flex items-center gap-3 pb-2.5 relative">
              <div className={`w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 z-10 ${p.visited?"border-2":"border"}`}
                   style={{ background: p.visited ? `${C.success}15` : C.surface, borderColor: p.visited ? `${C.success}40` : C.border }}>
                {p.visited ? <Check size={13} style={{ color:C.success }}/> : <div className="w-1.5 h-1.5 rounded-full" style={{ background:C.surfaceEl }}/>}
              </div>
              <div className={`flex-1 flex items-center gap-2.5 p-2.5 rounded-xl ${!p.visited?"opacity-30":""}`}
                   style={{ background:C.surface, border:`1px solid ${C.border}` }}>
                <div className="w-10 h-10 rounded-lg overflow-hidden flex-shrink-0" style={{ background:C.surfaceEl }}>
                  <SiteCover img={p.img} catId={p.cat} alt="" className="w-full h-full"/>
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[12px] font-semibold truncate" style={{ color:C.fg }}>{p.name}</p>
                  <p className="text-[10px]" style={{ color:C.mutedDk }}>{p.city} · {p.saved}</p>
                </div>
                <CatBadge id={p.cat} small/>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

// ─── SAVE PLACE PAGE ──────────────────────────────────────────────
const SavePlacePage = ({ onBack, onCategories }: { onBack:()=>void; onCategories:()=>void }) => {
  const [name, setName] = useState("");
  const [isPublic, setIsPublic] = useState(false);
  const [exactPoint, setExactPoint] = useState(true);
  const [sections, setSections] = useState<string[]>([]);
  const [step, setStep] = useState<"form"|"done">("form");
  const allSections = ["Detalles","Enlaces","Categorías","Fotos","Lugar físico"];
  const remaining = allSections.filter(s => !sections.includes(s));

  if (step === "done") return (
    <div className="flex flex-col h-full items-center justify-center px-6" style={{ background:C.bg }}>
      <div className="w-20 h-20 rounded-full flex items-center justify-center mb-5" style={{ background:`${C.success}15` }}>
        <CheckCircle size={40} style={{ color:C.success }}/>
      </div>
      <p className="text-[18px] font-extrabold mb-1.5 text-center" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>¡Guardado!</p>
      <p className="text-[13px] text-center mb-6" style={{ color:C.muted }}>{isPublic ? "Visible para la comunidad" : "Solo visible para vos"}</p>
      <button onClick={onBack} className="w-full py-3.5 rounded-xl font-bold text-black" style={{ background:C.primary }}>Listo</button>
    </div>
  );

  return (
    <div className="flex flex-col h-full" style={{ background:C.bg }}>
      <AppBar title="Guardar lugar" onBack={onBack}
        actions={<button onClick={() => name.trim() && setStep("done")} className="px-3 py-1.5 rounded-lg text-[13px] font-bold transition-all" style={{ background: name.trim() ? C.primary : C.surface, color: name.trim() ? "#000" : C.mutedDk }}>Guardar</button>}/>

      <div className="flex-1 overflow-y-auto px-4 pb-8">
        {/* Ubicación */}
        <div className="mb-4 rounded-2xl overflow-hidden" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
          <div className="flex items-center gap-2 px-3 py-2.5 border-b" style={{ borderColor:C.border }}>
            <Search size={15} style={{ color:C.mutedDk }} className="flex-shrink-0"/>
            <input placeholder="Buscar ubicación o pegar link de Maps..." className="flex-1 bg-transparent text-[13px] outline-none" style={{ color:C.fg }}/>
            <button className="text-[10px] font-bold px-2 py-1 rounded-lg" style={{ background:C.surfaceEl, color:C.muted }}>Pegar</button>
          </div>
          <div className="h-28 flex items-center justify-center" style={{ background:C.surfaceEl }}>
            <div className="text-center">
              <MapPin size={22} style={{ color:C.mutedDk }} className="mx-auto mb-1"/>
              <p className="text-[11px]" style={{ color:C.mutedDk }}>Toca para elegir en el mapa</p>
            </div>
          </div>
          <div className="flex items-center justify-between px-3 py-2.5">
            <span className="text-[12px]" style={{ color:C.muted }}>Punto exacto en el mapa</span>
            <button onClick={() => setExactPoint(v => !v)} className={`w-11 h-6 rounded-full relative transition-all ${exactPoint?"":"opacity-50"}`} style={{ background: exactPoint ? C.primary : C.surfaceEl }}>
              <div className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow-sm transition-all ${exactPoint?"left-5":"left-0.5"}`}/>
            </button>
          </div>
        </div>

        {/* Nombre */}
        <div className="mb-4">
          <label className="text-[11px] font-bold uppercase tracking-wider block mb-1.5" style={{ color:C.mutedDk }}>Nombre <span style={{ color:"#FF8C00" }}>*</span></label>
          <div className="flex items-center gap-2 px-3 py-3 rounded-xl" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
            <input value={name} onChange={e => setName(e.target.value)} placeholder="¿Cómo se llama el lugar?" className="flex-1 bg-transparent text-[13px] outline-none" style={{ color:C.fg }}/>
          </div>
        </div>

        {/* Público */}
        <div className="flex items-center justify-between p-3.5 rounded-xl mb-5" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
          <div className="flex items-center gap-2">
            {isPublic ? <Eye size={16} style={{ color:C.success }}/> : <Lock size={16} style={{ color:C.purple }}/>}
            <div>
              <p className="text-[13px] font-semibold" style={{ color:C.fg }}>Público</p>
              <p className="text-[10px]" style={{ color:C.mutedDk }}>{isPublic ? "Visible para todos" : "Solo para vos"}</p>
            </div>
          </div>
          <button onClick={() => setIsPublic(v => !v)} disabled={!exactPoint}
            className={`w-12 h-6 rounded-full relative transition-all ${!exactPoint?"opacity-30":""}`}
            style={{ background: isPublic ? C.primary : C.surfaceEl }}>
            <div className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow-sm transition-all ${isPublic?"left-6":"left-0.5"}`}/>
          </button>
        </div>

        {/* Secciones extra */}
        {sections.includes("Categorías") && (
          <div className="mb-4">
            <label className="text-[11px] font-bold uppercase tracking-wider block mb-1.5" style={{ color:C.mutedDk }}>Categorías</label>
            <button onClick={onCategories} className="w-full flex items-center justify-between px-3 py-3 rounded-xl" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
              <span className="text-[13px]" style={{ color:C.mutedDk }}>Elegir categorías...</span>
              <ChevronRight size={14} style={{ color:C.mutedDk }}/>
            </button>
          </div>
        )}
        {sections.includes("Fotos") && (
          <div className="mb-4">
            <label className="text-[11px] font-bold uppercase tracking-wider block mb-1.5" style={{ color:C.mutedDk }}>Fotos (máx. 15)</label>
            <button className="w-full h-20 flex flex-col items-center justify-center gap-1.5 rounded-xl" style={{ background:C.surface, border:`1px dashed ${C.border}` }}>
              <Camera size={18} style={{ color:C.mutedDk }}/><span className="text-[11px]" style={{ color:C.mutedDk }}>Agregar fotos</span>
            </button>
          </div>
        )}
        {sections.includes("Enlaces") && (
          <div className="mb-4">
            <label className="text-[11px] font-bold uppercase tracking-wider block mb-1.5" style={{ color:C.mutedDk }}>Enlace de origen (privado)</label>
            <div className="flex items-center gap-2 px-3 py-3 rounded-xl" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
              <Link2 size={14} style={{ color:C.mutedDk }} className="flex-shrink-0"/>
              <input placeholder="Link original (Instagram, TikTok...)" className="flex-1 bg-transparent text-[13px] outline-none" style={{ color:C.fg }}/>
            </div>
            <p className="text-[10px] mt-1 px-1" style={{ color:C.mutedDk }}>Solo visible para vos · nunca público</p>
          </div>
        )}

        {/* Añadir sección */}
        {remaining.length > 0 && (
          <div>
            <p className="text-[11px] font-bold uppercase tracking-wider mb-2" style={{ color:C.mutedDk }}>Añadir sección</p>
            <div className="flex flex-wrap gap-2">
              {remaining.map(s => (
                <button key={s} onClick={() => setSections(v => [...v,s])}
                  className="flex items-center gap-1.5 px-3 py-2 rounded-full text-[11px] font-semibold"
                  style={{ background:C.surface, border:`1px solid ${C.border}`, color:C.muted }}>
                  <Plus size={10}/>{s}
                </button>
              ))}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

// ─── CATEGORY PICKER ──────────────────────────────────────────────
const CategoryPickerPage = ({ onBack, onDone }: { onBack:()=>void; onDone:(ids:string[])=>void }) => {
  const [q, setQ] = useState("");
  const [sel, setSel] = useState<string[]>([]);
  const keywords: Record<string,string[]> = { gastro:["restaurante","comida","comer","café"], aloj:["hotel","hostal","finca","dormir"], nat:["naturaleza","senderismo","montaña","río"], cult:["museo","historia","arte","plaza"] };
  const filtered = CATS.filter(c => !q || c.label.toLowerCase().includes(q.toLowerCase()) || (keywords[c.id]??[]).some(k => k.includes(q.toLowerCase())));
  const toggle = (id:string) => setSel(v => v.includes(id) ? v.filter(x=>x!==id) : [...v,id]);

  return (
    <div className="flex flex-col h-full" style={{ background:C.bg }}>
      <AppBar title="Elegir categorías" onBack={onBack}
        actions={sel.length>0 && <button onClick={() => onDone(sel)} className="px-3 py-1.5 rounded-lg text-[13px] font-bold" style={{ background:C.primary, color:"#000" }}>Listo ({sel.length})</button>}/>
      <div className="px-4 pb-3 flex-shrink-0">
        <div className="flex items-center gap-2 px-3 py-2.5 rounded-xl" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
          <Search size={14} style={{ color:C.mutedDk }} className="flex-shrink-0"/>
          <input value={q} onChange={e => setQ(e.target.value)} placeholder="Buscar o escribir: nadar, caminar, comer..." className="flex-1 bg-transparent text-[13px] outline-none" style={{ color:C.fg }}/>
          {q && <button onClick={() => setQ("")}><X size={13} style={{ color:C.mutedDk }}/></button>}
        </div>
        {q && (
          <div className="flex flex-wrap gap-1.5 mt-2">
            {["restaurante","natural","arte","dormir","comer","aventura"].filter(k => k.includes(q.toLowerCase())).map(k => (
              <button key={k} onClick={() => setQ(k)} className="text-[11px] px-2.5 py-1 rounded-full" style={{ background:C.surfaceEl, color:C.muted }}>{k}</button>
            ))}
          </div>
        )}
      </div>
      <div className="flex-1 overflow-y-auto px-4 pb-6">
        {filtered.map(c => {
          const Icon = c.icon;
          const active = sel.includes(c.id);
          return (
            <button key={c.id} onClick={() => toggle(c.id)} className="w-full flex items-center gap-3 p-3 rounded-xl mb-2 transition-all"
                    style={{ background: active ? c.color+"18" : C.surface, border:`1px solid ${active ? c.color+"44" : C.border}` }}>
              <div className="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0" style={{ background:c.bg }}><Icon size={18} style={{ color:c.color }}/></div>
              <div className="flex-1 text-left">
                <p className="text-[13px] font-semibold" style={{ color: active ? c.color : C.fg }}>{c.label}</p>
                <p className="text-[10px]" style={{ color:C.mutedDk }}>{(keywords[c.id]??[]).slice(0,3).join(", ")}</p>
              </div>
              {active && <Check size={16} style={{ color:c.color }}/>}
            </button>
          );
        })}
      </div>
    </div>
  );
};

// ─── SITE DETAIL PAGE ─────────────────────────────────────────────
const SiteDetailPage = ({ p, onBack, onEnC }: { p:typeof PLACES[0]; onBack:()=>void; onEnC:(d:EnCData)=>void }) => {
  const [tab, setTab] = useState<"info"|"reviews"|"mas">("info");
  const [fav, setFav] = useState(p.fav);
  const tabs = [{ id:"info", label:"Info" },{ id:"reviews", label:"Reseñas" },{ id:"mas", label:"Más" }];
  return (
    <div className="flex flex-col h-full overflow-hidden" style={{ background:C.bg }}>
      {/* AppBar */}
      <div className="flex items-center gap-2 px-4 pt-4 pb-2 flex-shrink-0" style={{ background:C.bg }}>
        <button onClick={onBack} className="rounded-full p-2 flex-shrink-0" style={{ background:C.surface }}><ArrowLeft size={18} style={{ color:C.muted }}/></button>
        <p className="flex-1 text-[16px] font-extrabold truncate" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>{p.name}</p>
        <button onClick={() => setFav(v => !v)} className="rounded-full p-2" style={{ background:C.surface }}>
          <Heart size={17} className={fav ? "fill-[#FF5252] text-[#FF5252]" : ""} style={{ color: fav ? C.accent : C.muted }}/>
        </button>
        <button className="rounded-full p-2" style={{ background:C.surface }}><MoreVertical size={17} style={{ color:C.muted }}/></button>
      </div>
      {/* Hero */}
      <div className="relative h-48 flex-shrink-0" style={{ background:C.surfaceEl }}>
        <SiteCover img={p.img} catId={p.cat} alt={p.name} className="w-full h-full"/>
        <div className="absolute inset-0" style={{ background:"linear-gradient(to top,rgba(11,13,21,0.9) 0%,transparent 55%)" }}/>
        <div className="absolute left-0 top-0 bottom-0 w-[4px]" style={{ background: p.isPublic ? C.success : C.purple }}/>
        <div className="absolute bottom-3 left-4 flex items-center gap-1.5">
          <VisIcon isPublic={p.isPublic}/>
          {p.src && <SrcBadge src={p.src}/>}
          {p.isCatalog && <span className="text-[9px] font-bold px-1.5 py-[2px] rounded" style={{ background:`${C.muted}18`, color:C.muted }}>Catálogo</span>}
        </div>
        <span className="absolute bottom-3 right-4 text-[13px] font-bold" style={{ color:C.primary }}>{p.price}</span>
      </div>
      {/* Tab bar */}
      <div className="flex border-b flex-shrink-0" style={{ borderColor:C.border, background:C.bg }}>
        {tabs.map(t => (
          <button key={t.id} onClick={() => setTab(t.id as typeof tab)}
            className="flex-1 py-2.5 text-[12px] font-semibold transition-all"
            style={{ color: tab===t.id ? C.primary : C.mutedDk, borderBottom: tab===t.id ? `2px solid ${C.primary}` : "2px solid transparent" }}>
            {t.label}
          </button>
        ))}
      </div>
      {/* Tab content */}
      <div className="flex-1 overflow-y-auto pb-20">
        {tab === "info" && (
          <div className="px-4 pt-4">
            <h2 className="text-[18px] font-extrabold mb-1" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>{p.name}</h2>
            <div className="flex items-center gap-1.5 mb-3"><MapPin size={13} style={{ color:C.accent }}/><span className="text-[12px]" style={{ color:C.muted }}>{p.addr}, {p.city}</span></div>
            <div className="flex flex-wrap gap-1.5 mb-4"><CatBadge id={p.cat}/></div>
            <div className="rounded-xl p-3.5 mb-4" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
              <p className="text-[13px] leading-relaxed" style={{ color:C.muted }}>{p.desc}</p>
            </div>
            <button onClick={() => onEnC({ title:"Cómo llegar desde aquí", desc:"La navegación directa desde la ficha estará disponible pronto. Por ahora podés agregarlo a un plan y usar Llevar a Maps desde allí." })}
              className="w-full flex items-center justify-between p-3 rounded-xl mb-4" style={{ background:C.surface, border:`1px solid ${C.border}`, opacity:0.55 }}>
              <div className="flex items-center gap-2"><Navigation size={15} style={{ color:C.mutedDk }}/><span className="text-[12px] font-semibold" style={{ color:C.muted }}>Cómo llegar</span></div>
              <span className="text-[10px] font-bold px-2 py-0.5 rounded-full" style={{ background:C.surfaceEl, color:C.mutedDk }}>Próximamente</span>
            </button>
            <p className="text-[11px] font-bold uppercase tracking-wider mb-2" style={{ color:C.mutedDk }}>Fotos del lugar</p>
            <div className="flex gap-2 mb-4">
              {[0,1,2].map(i => <div key={i} className="w-24 h-24 rounded-xl overflow-hidden flex-shrink-0" style={{ background:C.surfaceEl }}><SiteCover img={p.img} catId={p.cat} alt="" className="w-full h-full"/></div>)}
            </div>
          </div>
        )}
        {tab === "reviews" && (
          <div className="px-4 pt-4">
            <div className="flex items-center gap-3 mb-4 p-3 rounded-xl" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
              <div className="text-center">
                <p className="text-[28px] font-extrabold" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>4.2</p>
                <div className="flex gap-0.5">{[1,2,3,4,5].map(s => <Star key={s} size={10} className={s<=4?"fill-[#FFBB33] text-[#FFBB33]":"text-[#5A607A]"}/>)}</div>
              </div>
              <div className="flex-1">{[5,4,3,2,1].map(s => <div key={s} className="flex items-center gap-1.5 mb-1"><span className="text-[10px] w-2" style={{ color:C.mutedDk }}>{s}</span><div className="flex-1 h-1.5 rounded-full" style={{ background:C.surfaceEl }}><div className="h-full rounded-full" style={{ width:`${[70,20,5,3,2][5-s]}%`, background:C.primary }}/></div></div>)}</div>
            </div>
            {[{ u:"Carolina M.", r:"Gran experiencia. El ambiente es increíble y la comida supera las expectativas.", score:5, priv:false },{ u:"Andrés T.", r:"Visita obligada si vas a Medellín. Vale cada peso.", score:4, priv:false }].map((r,i) => (
              <div key={i} className="p-3 rounded-xl mb-2" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
                <div className="flex items-center justify-between mb-1">
                  <div className="flex items-center gap-2">
                    <div className="w-7 h-7 rounded-full flex items-center justify-center text-[11px] font-bold" style={{ background:`${C.primary}22`, color:C.primary }}>{r.u.charAt(0)}</div>
                    <span className="text-[12px] font-semibold" style={{ color:C.fg }}>{r.u}</span>
                  </div>
                  <div className="flex gap-0.5">{[1,2,3,4,5].map(s => <Star key={s} size={9} className={s<=r.score?"fill-[#FFBB33] text-[#FFBB33]":"text-[#5A607A]"}/>)}</div>
                </div>
                <p className="text-[12px] leading-relaxed" style={{ color:C.muted }}>{r.r}</p>
              </div>
            ))}
          </div>
        )}
        {tab === "mas" && (
          <div className="px-4 pt-4">
            {[{ label:"Creado por", val:"@usuario · hace 3 meses" },{ label:"También guardado por", val:"12 personas" },{ label:"Origen", val:p.isCatalog?"Catálogo oficial":p.isLinked?"Vinculado a público":"Guardado propio" }].map(r => (
              <div key={r.label} className="flex items-center justify-between py-3 border-b" style={{ borderColor:C.border }}>
                <span className="text-[12px]" style={{ color:C.muted }}>{r.label}</span>
                <span className="text-[12px] font-semibold" style={{ color:C.fg }}>{r.val}</span>
              </div>
            ))}
          </div>
        )}
      </div>
      {/* Bottom action */}
      <div className="absolute bottom-0 left-0 right-0 px-4 pb-4 pt-2" style={{ background:C.bg, borderTop:`1px solid ${C.border}` }}>
        <button className="w-full py-3 rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 text-black" style={{ background:C.primary }}>
          <Plus size={16}/> Agregar a un plan
        </button>
      </div>
    </div>
  );
};

// ─── CREATE PLAN ──────────────────────────────────────────────────
const CreatePlanPage = ({ onBack, onBuild, onEnC }: { onBack:()=>void; onBuild:()=>void; onEnC:(d:EnCData)=>void }) => {
  const [title, setTitle] = useState("");
  const [zone, setZone] = useState("");
  const [incPublic, setIncPublic] = useState(false);
  const [budget, setBudget] = useState("");
  return (
    <div className="flex flex-col h-full" style={{ background:C.bg }}>
      <AppBar title="Nuevo plan" onBack={onBack}/>
      <div className="flex-1 overflow-y-auto px-4 pb-8 pt-2">
        <button onClick={() => onEnC({ title:"Armame un plan para mañana", desc:"La generación de planes con IA estará disponible pronto. Podés crear tu plan manualmente eligiendo los lugares que ya guardaste." })}
          className="w-full flex items-center gap-3 p-3.5 rounded-2xl mb-5 opacity-50" style={{ background:C.surfaceEl, border:`1px dashed ${C.border}` }}>
          <div className="w-9 h-9 rounded-xl flex items-center justify-center flex-shrink-0" style={{ background:`${C.mutedDk}15` }}><Wrench size={17} style={{ color:C.mutedDk }}/></div>
          <div className="flex-1 text-left">
            <p className="text-[12px] font-semibold" style={{ color:C.mutedDk }}>Armame un plan con IA</p>
            <p className="text-[10px]" style={{ color:C.mutedDk }}>Próximamente</p>
          </div>
        </button>

        {[{ lbl:"Título del plan", val:title, set:setTitle, ph:"Ej: Villa de Leyva en finde" },{ lbl:"Zona o ciudad", val:zone, set:setZone, ph:"Ej: Villa de Leyva, Boyacá" }].map(f => (
          <div key={f.lbl} className="mb-4">
            <label className="text-[11px] font-bold uppercase tracking-wider block mb-1.5" style={{ color:C.mutedDk }}>{f.lbl}</label>
            <div className="flex items-center px-3 py-3 rounded-xl" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
              <input value={f.val} onChange={e => f.set(e.target.value)} placeholder={f.ph} className="flex-1 bg-transparent text-[13px] outline-none" style={{ color:C.fg }}/>
            </div>
          </div>
        ))}

        <div className="flex items-center justify-between p-3.5 rounded-xl mb-4" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
          <div>
            <p className="text-[13px] font-semibold" style={{ color:C.fg }}>Incluir públicos de otros</p>
            <p className="text-[10px]" style={{ color:C.mutedDk }}>Amplía las opciones de tu plan</p>
          </div>
          <button onClick={() => setIncPublic(v => !v)} className="w-12 h-6 rounded-full relative transition-all" style={{ background: incPublic ? C.primary : C.surfaceEl }}>
            <div className={`absolute top-0.5 w-5 h-5 rounded-full bg-white shadow-sm transition-all ${incPublic?"left-6":"left-0.5"}`}/>
          </button>
        </div>

        <div className="mb-5">
          <label className="text-[11px] font-bold uppercase tracking-wider block mb-1.5" style={{ color:C.mutedDk }}>Tope de presupuesto</label>
          <div className="flex items-center px-3 py-3 rounded-xl" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
            <span className="text-[13px] mr-2" style={{ color:C.mutedDk }}>$</span>
            <input value={budget} onChange={e => setBudget(e.target.value)} placeholder="0" type="number" className="flex-1 bg-transparent text-[13px] outline-none" style={{ color:C.fg }}/>
            <span className="text-[11px]" style={{ color:C.mutedDk }}>COP</span>
          </div>
        </div>

        <button onClick={() => title.trim() && zone.trim() && onBuild()} disabled={!title.trim() || !zone.trim()}
          className="w-full py-3.5 rounded-xl font-bold text-[14px] transition-all"
          style={{ background: (title.trim() && zone.trim()) ? C.primary : C.surface, color: (title.trim() && zone.trim()) ? "#000" : C.mutedDk }}>
          Siguiente: armar paradas →
        </button>
      </div>
    </div>
  );
};

// ─── PLAN BUILDER ─────────────────────────────────────────────────
const PlanBuilderPage = ({ onBack, onDone }: { onBack:()=>void; onDone:()=>void }) => {
  const [tab, setTab] = useState<"search"|"results"|"added">("search");
  const [q, setQ] = useState("");
  const [added, setAdded] = useState([PLACES[0], PLACES[1], PLACES[2]]);
  const results = PLACES.filter(p => p.name.toLowerCase().includes(q.toLowerCase()));

  return (
    <div className="flex flex-col h-full" style={{ background:C.bg }}>
      <AppBar title="Armar paradas" onBack={onBack}
        actions={<button onClick={onDone} className="px-3 py-1.5 rounded-lg text-[13px] font-bold" style={{ background:C.primary, color:"#000" }}>Guardar</button>}/>
      {/* Internal tabs */}
      <div className="flex px-4 gap-1 mb-3 flex-shrink-0">
        {[{ id:"search",label:"Buscar" },{ id:"results",label:"Resultados" },{ id:"added",label:`Añadidos (${added.length})` }].map(t => (
          <button key={t.id} onClick={() => setTab(t.id as typeof tab)}
            className="px-3 py-1.5 rounded-full text-[11px] font-bold transition-all"
            style={{ background: tab===t.id ? C.primary : C.surface, color: tab===t.id ? "#000" : C.muted }}>
            {t.label}
          </button>
        ))}
      </div>

      {tab === "search" && (
        <div className="px-4 flex-1">
          <div className="flex items-center gap-2 px-3 py-2.5 rounded-xl mb-3" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
            <Search size={15} style={{ color:C.mutedDk }} className="flex-shrink-0"/>
            <input value={q} onChange={e => { setQ(e.target.value); setTab("results"); }} placeholder="Buscar en tus guardados..." className="flex-1 bg-transparent text-[13px] outline-none" style={{ color:C.fg }}/>
          </div>
          <p className="text-[11px] font-bold uppercase tracking-wider mb-2" style={{ color:C.mutedDk }}>Sugeridos para este plan</p>
          {PLACES.slice(0,4).map(p => (
            <div key={p.id} className="flex items-center gap-3 p-2.5 rounded-xl mb-2 cursor-pointer"
                 style={{ background:C.surface, border:`1px solid ${C.border}` }}>
              <div className="w-11 h-11 rounded-lg overflow-hidden flex-shrink-0" style={{ background:C.surfaceEl }}>
                <SiteCover img={p.img} catId={p.cat} alt={p.name} className="w-full h-full"/>
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-[12px] font-semibold truncate" style={{ color:C.fg }}>{p.name}</p>
                <p className="text-[10px]" style={{ color:C.mutedDk }}>{p.city} · {p.price}</p>
              </div>
              <button onClick={() => !added.find(a=>a.id===p.id) && setAdded(v=>[...v,p])}
                className="w-7 h-7 rounded-full flex items-center justify-center" style={{ background: added.find(a=>a.id===p.id) ? `${C.success}20` : `${C.primary}20` }}>
                {added.find(a=>a.id===p.id) ? <Check size={13} style={{ color:C.success }}/> : <Plus size={13} style={{ color:C.primary }}/>}
              </button>
            </div>
          ))}
        </div>
      )}

      {tab === "results" && (
        <div className="flex-1 overflow-y-auto px-4">
          {results.map(p => (
            <div key={p.id} className="flex items-center gap-3 p-2.5 rounded-xl mb-2 cursor-pointer" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
              <div className="w-11 h-11 rounded-lg overflow-hidden flex-shrink-0" style={{ background:C.surfaceEl }}><SiteCover img={p.img} catId={p.cat} alt={p.name} className="w-full h-full"/></div>
              <div className="flex-1 min-w-0"><p className="text-[12px] font-semibold truncate" style={{ color:C.fg }}>{p.name}</p><p className="text-[10px]" style={{ color:C.mutedDk }}>{p.city}</p></div>
              <button onClick={() => !added.find(a=>a.id===p.id) && setAdded(v=>[...v,p])} className="w-7 h-7 rounded-full flex items-center justify-center" style={{ background: added.find(a=>a.id===p.id) ? `${C.success}20` : `${C.primary}20` }}>
                {added.find(a=>a.id===p.id) ? <Check size={13} style={{ color:C.success }}/> : <Plus size={13} style={{ color:C.primary }}/>}
              </button>
            </div>
          ))}
        </div>
      )}

      {tab === "added" && (
        <div className="flex-1 overflow-y-auto px-4">
          {added.length === 0 && <p className="text-center py-8 text-[13px]" style={{ color:C.mutedDk }}>Aún no añadiste paradas</p>}
          {added.map((p, i) => {
            const cat = catOf(p.cat);
            const Icon = cat.icon;
            return (
              <div key={p.id} className="flex gap-3 items-center mb-2">
                <GripVertical size={16} style={{ color:C.mutedDk }} className="cursor-grab flex-shrink-0"/>
                <span className="text-[11px] font-bold w-5 text-center" style={{ color:C.mutedDk }}>{i+1}</span>
                <div className="flex-1 flex items-center gap-2.5 p-2.5 rounded-xl" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
                  <div className="w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0" style={{ background:cat.bg }}><Icon size={16} style={{ color:cat.color }}/></div>
                  <div className="flex-1 min-w-0">
                    <p className="text-[12px] font-semibold truncate" style={{ color:C.fg }}>{p.name}</p>
                    <p className="text-[10px]" style={{ color:C.mutedDk }}>{p.city}</p>
                  </div>
                  <button onClick={() => setAdded(v => v.filter(a=>a.id!==p.id))}><X size={14} style={{ color:C.mutedDk }}/></button>
                </div>
              </div>
            );
          })}
          <p className="text-[10px] text-center mt-2" style={{ color:C.mutedDk }}>Arrastrá para reordenar</p>
        </div>
      )}
    </div>
  );
};

// ─── PLAN DETAIL PAGE ─────────────────────────────────────────────
const PlanDetailPage = ({ pl, onBack, onSite, onBuilder, onEnC }: { pl:typeof PLANS[0]; onBack:()=>void; onSite:(p:typeof PLACES[0])=>void; onBuilder:()=>void; onEnC:(d:EnCData)=>void }) => (
  <div className="flex flex-col h-full overflow-hidden" style={{ background:C.bg }}>
    {/* Hero 176px */}
    <div className="relative flex-shrink-0" style={{ height:176, background:C.surfaceEl }}>
      <SiteCover img={pl.img} catId={pl.itinerary[0]?.cat ?? "gastro"} alt={pl.title} className="w-full h-full"/>
      <div className="absolute inset-0" style={{ background:"rgba(0,0,0,0.54)" }}/>
      <button onClick={onBack} className="absolute top-4 left-4 rounded-full p-2" style={{ background:"rgba(0,0,0,0.55)" }}><ArrowLeft size={18} className="text-white"/></button>
      <button className="absolute top-4 right-4 rounded-full p-2" style={{ background:"rgba(0,0,0,0.55)" }}><MoreVertical size={17} className="text-white"/></button>
      <div className="absolute bottom-3 left-4 right-4">
        <h1 className="text-[20px] font-extrabold text-white" style={{ fontFamily:"'Plus Jakarta Sans',sans-serif" }}>{pl.title}</h1>
        <span className="text-[12px] font-semibold" style={{ color:C.primary }}>{pl.zone}</span>
      </div>
    </div>
    {/* 3 stats */}
    <div className="flex gap-2 px-4 py-3 flex-shrink-0" style={{ borderBottom:`1px solid ${C.border}` }}>
      {[{ label:"Paradas", val:String(pl.stops), color:C.accent },{ label:"Presupuesto", val:pl.budget, color:C.success },{ label:"Estado", val:pl.status==="upcoming"?"Próximo":"Borrador", color:C.primary }].map(s => (
        <div key={s.label} className="flex-1 rounded-xl p-2.5 text-center" style={{ background:C.surface }}>
          <p className="text-[15px] font-extrabold" style={{ color:s.color, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>{s.val}</p>
          <p className="text-[9px] mt-0.5" style={{ color:C.mutedDk }}>{s.label}</p>
        </div>
      ))}
    </div>
    {/* Itinerary */}
    <div className="flex-1 overflow-y-auto px-4 pt-4 pb-28">
      <p className="text-[11px] font-extrabold uppercase tracking-wider mb-3" style={{ color:C.mutedDk }}>Itinerario</p>
      {pl.itinerary.map((stop, i) => {
        const cat = catOf(stop.cat);
        const Icon = cat.icon;
        return (
          <div key={i} className="flex gap-3">
            <div className="flex flex-col items-center">
              <div className="w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0" style={{ background:cat.bg, border:`1.5px solid ${cat.color}35` }}>
                {stop.visited ? <Check size={16} style={{ color:C.success }}/> : <Icon size={16} style={{ color:cat.color }}/>}
              </div>
              {i < pl.itinerary.length-1 && (
                <>
                  <div className="w-px my-1" style={{ height:12, background:C.border }}/>
                  {/* Transport placeholder between stops */}
                  <div className="text-[10px] px-1.5 py-0.5 rounded-full mb-1" style={{ background:`${C.mutedDk}18`, color:C.mutedDk }}>🚶?</div>
                  <div className="w-px my-1" style={{ height:12, background:C.border }}/>
                </>
              )}
            </div>
            <div className="flex-1 pb-3">
              <div className="flex items-start justify-between mb-0.5">
                <p className="font-bold text-[13px]" style={{ color: stop.visited ? C.success : C.fg }}>{stop.name}</p>
                {stop.visited && <Check size={14} style={{ color:C.success }}/>}
              </div>
              <p className="text-[10px]" style={{ color:C.mutedDk }}>{stop.time} · {stop.dur}</p>
            </div>
          </div>
        );
      })}
      <button onClick={() => onEnC({ title:"Transporte entre paradas", desc:"El cálculo del transporte sugerido entre paradas estará disponible próximamente. Mientras tanto, podés consultar rutas manualmente en Google Maps." })}
        className="w-full flex items-center justify-between p-3 rounded-xl mt-2 opacity-45" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
        <div className="flex items-center gap-2"><Navigation size={14} style={{ color:C.mutedDk }}/><span className="text-[12px]" style={{ color:C.muted }}>Transporte sugerido</span></div>
        <span className="text-[10px] font-bold px-2 py-0.5 rounded-full" style={{ background:C.surfaceEl, color:C.mutedDk }}>Próximamente</span>
      </button>
    </div>
    {/* Bottom bar: Llevar a Maps + Share + FAB */}
    <div className="absolute bottom-0 left-0 right-0 px-4 pb-4 pt-2 flex gap-2 items-center" style={{ background:C.bg, borderTop:`1px solid ${C.border}` }}>
      <button className="flex-1 py-3 rounded-xl font-bold text-[14px] flex items-center justify-center gap-2 text-black" style={{ background:C.primary }}>
        <Navigation size={16}/> Llevar a Maps
      </button>
      <button className="w-12 h-12 rounded-xl flex items-center justify-center" style={{ background:C.surface, border:`1px solid ${C.border}` }}><Share2 size={16} style={{ color:C.muted }}/></button>
      <button onClick={onBuilder} className="w-12 h-12 rounded-xl flex items-center justify-center" style={{ background:`${C.primary}20`, border:`1px solid ${C.primary}44` }}><Plus size={18} style={{ color:C.primary }}/></button>
    </div>
  </div>
);

// ─── ADMIN PAGE ───────────────────────────────────────────────────
const AdminPage = ({ onBack, onReports }: { onBack:()=>void; onReports:()=>void }) => {
  const stats = [{ lbl:"Usuarios",val:"1.842",color:C.primary,Icon:Users },{ lbl:"Lugares",val:"6.291",color:C.success,Icon:MapPin },{ lbl:"Planes",val:"3.107",color:C.purple,Icon:Route },{ lbl:"Reportes",val:"23",color:C.accent,Icon:AlertCircle }];
  return (
    <div className="flex flex-col h-full" style={{ background:C.bg }}>
      <AppBar title="Panel administrador" onBack={onBack} actions={<button onClick={onReports} className="rounded-full p-2" style={{ background:C.surface }}><FileText size={16} style={{ color:C.muted }}/></button>}/>
      <div className="flex-1 overflow-y-auto px-4 pt-2 pb-6">
        <div className="grid grid-cols-2 gap-2.5 mb-5">
          {stats.map(s => (
            <div key={s.lbl} className="rounded-xl p-3.5" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
              <div className="flex items-center justify-between mb-2"><div className="w-8 h-8 rounded-lg flex items-center justify-center" style={{ background:`${s.color}18` }}><s.Icon size={15} style={{ color:s.color }}/></div><span className="text-[10px] font-semibold" style={{ color:C.success }}>+8%</span></div>
              <p className="text-[20px] font-extrabold" style={{ color:C.fg, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>{s.val}</p>
              <p className="text-[10px] mt-0.5" style={{ color:C.mutedDk }}>{s.lbl}</p>
            </div>
          ))}
        </div>
        <p className="text-[11px] font-bold uppercase tracking-wider mb-3" style={{ color:C.mutedDk }}>Categorías</p>
        <div className="rounded-xl overflow-hidden mb-4" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
          {CATS.map((c,i) => {
            const Icon = c.icon;
            return (
              <div key={c.id} className="flex items-center gap-3 p-3 border-b" style={{ borderColor:i<CATS.length-1?C.border:"transparent" }}>
                <div className="w-9 h-9 rounded-full flex items-center justify-center" style={{ background:c.bg }}><Icon size={15} style={{ color:c.color }}/></div>
                <div className="flex-1"><p className="text-[12px] font-semibold" style={{ color:C.fg }}>{c.label}</p><p className="text-[10px]" style={{ color:C.mutedDk }}>Activa · {[892,543,421,312,228,167,198,234][i]} lugares</p></div>
                <button className="text-[10px] px-2 py-1 rounded-lg" style={{ background:C.surfaceEl, color:C.muted }}>Editar</button>
              </div>
            );
          })}
        </div>
        <p className="text-[11px] font-bold uppercase tracking-wider mb-3" style={{ color:C.mutedDk }}>Top ciudades</p>
        <div className="rounded-xl overflow-hidden" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
          {[["Bogotá",1842],["Medellín",1321],["Cartagena",891],["Cali",673],["Salento",412]].map(([city,n],i,arr) => (
            <div key={city} className="flex items-center justify-between p-3 border-b" style={{ borderColor:i<arr.length-1?C.border:"transparent" }}>
              <span className="text-[12px] flex items-center gap-1.5" style={{ color:C.muted }}><MapPin size={10} style={{ color:C.accent }}/>{city}</span>
              <span className="text-[12px] font-bold" style={{ color:C.primary }}>{(n as number).toLocaleString("es-CO")}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};

// ─── ADMIN REPORTS ────────────────────────────────────────────────
const AdminReportsPage = ({ onBack }: { onBack:()=>void }) => {
  const reports = [
    { type:"Foto inapropiada",  place:"Bar La Rumba · Medellín",  date:"Hoy",        status:"abierto"   },
    { type:"Lugar duplicado",   place:"El Cielo vs Sky Restaurant",date:"Ayer",       status:"revisando" },
    { type:"Precio desactualizado",place:"Hacienda Bambusa",      date:"hace 2 días", status:"resuelto"  },
    { type:"Sitio deprecado",   place:"Café 90 · Bogotá",         date:"hace 3 días", status:"resuelto"  },
  ];
  const color = (s:string) => s==="abierto" ? C.accent : s==="revisando" ? C.primary : C.success;
  return (
    <div className="flex flex-col h-full" style={{ background:C.bg }}>
      <AppBar title="Reportes abiertos" onBack={onBack}/>
      <div className="flex-1 overflow-y-auto px-4 pt-2 pb-6">
        <div className="flex gap-2 mb-4">
          {[["3","Abiertos",C.accent],["1","Revisando",C.primary],["12","Resueltos",C.success]].map(([v,l,c]) => (
            <div key={l} className="flex-1 rounded-xl p-2.5 text-center" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
              <p className="text-[18px] font-extrabold" style={{ color:c, fontFamily:"'Plus Jakarta Sans',sans-serif" }}>{v}</p>
              <p className="text-[9px]" style={{ color:C.mutedDk }}>{l}</p>
            </div>
          ))}
        </div>
        {reports.map((r,i) => (
          <div key={i} className="flex gap-3 p-3 rounded-xl mb-2" style={{ background:C.surface, border:`1px solid ${C.border}` }}>
            <div className="w-1.5 self-stretch rounded-full flex-shrink-0" style={{ background:color(r.status) }}/>
            <div className="flex-1">
              <p className="text-[12px] font-semibold" style={{ color:C.fg }}>{r.type}</p>
              <p className="text-[10px]" style={{ color:C.muted }}>{r.place}</p>
              <p className="text-[9px] mt-0.5" style={{ color:C.mutedDk }}>{r.date}</p>
            </div>
            <span className="text-[9px] font-bold px-1.5 py-0.5 rounded-full self-start" style={{ background:`${color(r.status)}18`, color:color(r.status) }}>{r.status}</span>
          </div>
        ))}
      </div>
    </div>
  );
};

// ─── APP ROOT ─────────────────────────────────────────────────────
export default function App() {
  const [loggedIn, setLoggedIn]   = useState(false);
  const [tab,      setTab]        = useState<TabId>("inicio");
  const [screen,   setScreen]     = useState<Screen>("inicio");
  const [stack,    setStack]      = useState<Screen[]>([]);
  const [site,     setSite]       = useState<typeof PLACES[0]|null>(null);
  const [plan,     setPlan]       = useState<typeof PLANS[0]|null>(null);
  const [enCData,  setEnCData]    = useState<EnCData|null>(null);

  const push = (s: Screen) => { setStack(v => [...v, screen]); setScreen(s); };
  const back = () => {
    if (stack.length > 0) { setScreen(stack[stack.length-1]); setStack(v => v.slice(0,-1)); }
    else { setScreen(tab); }
  };
  const goTab = (t: TabId) => { setTab(t); setScreen(t); setStack([]); };
  const goSite = (p: typeof PLACES[0]) => { setSite(p); push("site-detail"); };
  const goPlan = (p: typeof PLANS[0])  => { setPlan(p); push("plan-detail"); };
  const goEnC  = (d: EnCData) => { setEnCData(d); push("en-construccion"); };

  const showNav = (["inicio","explorar","planes","rutas"] as Screen[]).includes(screen);

  if (!loggedIn) return (
    <div className="size-full bg-[#060810] flex items-center justify-center overflow-hidden">
      <div className="relative w-full md:w-[390px] bg-[#0B0D15] overflow-hidden"
           style={{ height:"100svh", maxHeight:"844px", boxShadow:"0 0 0 8px #0D1020, 0 0 0 10px rgba(255,255,255,0.06), 0 40px 100px rgba(0,0,0,0.9)", borderRadius:"clamp(0px,calc((100vw - 390px) / 2 * 10),44px)" }}>
        <LoginPage onLogin={() => setLoggedIn(true)}/>
      </div>
    </div>
  );

  return (
    <div className="size-full bg-[#060810] flex items-center justify-center overflow-hidden">
      <div className="hidden md:block fixed inset-0 pointer-events-none">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 rounded-full blur-[150px] opacity-[0.06]" style={{ background:C.primary }}/>
      </div>

      <div className="relative w-full md:w-[390px] bg-[#0B0D15] overflow-hidden"
           style={{ height:"100svh", maxHeight:"844px", boxShadow:"0 0 0 8px #0D1020, 0 0 0 10px rgba(255,255,255,0.06), 0 40px 100px rgba(0,0,0,0.9)", borderRadius:"clamp(0px,calc((100vw - 390px) / 2 * 10),44px)" }}>
        {/* Status bar */}
        <div className="hidden md:flex items-center justify-between px-6 pt-3 pb-1 flex-shrink-0">
          <span className="text-[11px] font-bold" style={{ color:C.fg }}>9:41</span>
          <div className="flex items-center gap-2">
            <div className="flex gap-[2px] items-end">{[10,14,18].map(h => <div key={h} className="w-[3px] rounded-sm" style={{ height:h, background:C.fg }}/>)}</div>
            <div className="w-5 h-2.5 rounded-sm border p-px" style={{ borderColor:`${C.fg}50` }}><div className="w-[70%] h-full rounded-sm" style={{ background:C.fg }}/></div>
          </div>
        </div>

        <div className="flex flex-col overflow-hidden" style={{ height:"calc(100% - 28px)" }}>
          {screen === "inicio"          && <InicioTab onSite={goSite} onAdmin={() => push("admin")} onMemory={() => {}}/>}
          {screen === "explorar"        && <ExplorarTab onSite={goSite}/>}
          {screen === "planes"          && <PlanesTab onPlan={goPlan} onCreate={() => push("create-plan")}/>}
          {screen === "rutas"           && <RutasTab onPlan={goPlan}/>}
          {screen === "save-place"      && <SavePlacePage onBack={back} onCategories={() => push("category-picker")}/>}
          {screen === "category-picker" && <CategoryPickerPage onBack={back} onDone={back}/>}
          {screen === "site-detail"     && site  && <SiteDetailPage p={site} onBack={back} onEnC={goEnC}/>}
          {screen === "create-plan"     && <CreatePlanPage onBack={back} onBuild={() => push("plan-builder")} onEnC={goEnC}/>}
          {screen === "plan-builder"    && <PlanBuilderPage onBack={back} onDone={back}/>}
          {screen === "plan-detail"     && plan  && <PlanDetailPage pl={plan} onBack={back} onSite={goSite} onBuilder={() => push("plan-builder")} onEnC={goEnC}/>}
          {screen === "admin"           && <AdminPage onBack={back} onReports={() => push("admin-reports")}/>}
          {screen === "admin-reports"   && <AdminReportsPage onBack={back}/>}
          {screen === "en-construccion" && enCData && <EnConstruccion data={enCData} onBack={back}/>}
        </div>

        {showNav && <BottomNav active={tab} onChange={goTab} onSave={() => push("save-place")}/>}
      </div>

      <p className="hidden md:block absolute bottom-4 text-[11px]" style={{ color:"#2A2F44" }}>
        Chevere Plan · MVP Colombia · Prototipo interactivo
      </p>
    </div>
  );
}
