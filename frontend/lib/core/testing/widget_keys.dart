import 'package:flutter/foundation.dart';

/// Keys estables para Patrol / widget tests. No usar copy i18n como finder.
abstract final class WidgetKeys {
  static const homeShell = Key('home_shell');
  static const homeFabSave = Key('home_fab_save');
  static const homeTabInicio = Key('home_tab_0');
  static const homeTabExplorar = Key('home_tab_1');
  static const homeTabPlanes = Key('home_tab_2');
  static const homeTabRutas = Key('home_tab_3');
  static const loginGoogle = Key('login_google_button');
  static const bootstrapError = Key('bootstrap_error');

  static Key homeSaveCard(String saveId) => Key('home_save_card_$saveId');
  static Key homeSaveStatus(String saveId, String status) =>
      Key('home_save_status_${saveId}_$status');

  static const savePlacePage = Key('save_place_page');
  static const saveNameField = Key('save_name_field');
  static const saveMapsField = Key('save_maps_field');
  static const saveSubmit = Key('save_submit');
  static const savePublicSwitch = Key('save_public_switch');
  static const saveExactPinSwitch = Key('save_exact_pin_switch');
  static const saveOpenMap = Key('save_open_map');
  static const saveLinksSection = Key('save_links_section');
  static const saveHasPin = Key('save_has_pin');
  static const saveNoPin = Key('save_no_pin');
  static const saveExtraDetails = Key('save_extra_details');
  static const saveExtraLinks = Key('save_extra_links');
  static const saveExtraCategories = Key('save_extra_categories');
  static const saveExtraPhoto = Key('save_extra_photo');
  static const saveExtraPhysical = Key('save_extra_physical');

  static const dupeKeepEditing = Key('dupe_keep_editing');
  static const dupeSaveAnyway = Key('dupe_save_anyway');
  static const dupeJournal = Key('dupe_journal');
  static const dupeReview = Key('dupe_review');
  static const privacyBlockDialog = Key('privacy_block_dialog');

  static const locationPicker = Key('location_picker');
  static const locationConfirm = Key('location_confirm');
  static const locationUseAppBar = Key('location_use_appbar');
  static const locationMyGps = Key('location_my_gps');

  static const siteDetailPage = Key('site_detail_page');
  static const siteDetailEdit = Key('site_detail_edit');
  static const siteOriginOwn = Key('site_origin_own');
  static const siteOriginLinked = Key('site_origin_linked');
  static const siteOriginCatalog = Key('site_origin_catalog');

  static const reviewEditor = Key('review_editor');
  static const reviewBody = Key('review_body');
  static const reviewPublicSwitch = Key('review_public_switch');
  static const reviewSubmit = Key('review_submit');
  static Key reviewStar(int n) => Key('review_star_$n');

  static const searchQuery = Key('search_query');
  static const searchIncludePublic = Key('search_include_public');
  static const searchResults = Key('search_results');

  static const plansList = Key('plans_list');
  static const plansCreateCta = Key('plans_create_cta');
  static Key planCard(String planId) => Key('plan_card_$planId');

  static const createPlanPage = Key('create_plan_page');
  static const createPlanTitle = Key('create_plan_title');
  static const createPlanZone = Key('create_plan_zone');
  static const createPlanBudget = Key('create_plan_budget');
  static const createPlanIncludePublic = Key('create_plan_include_public');
  static const createPlanNext = Key('create_plan_next');

  static const planBuilder = Key('plan_builder');
  static const planBuilderSearch = Key('plan_builder_search');
  static const planBuilderIncludePublic = Key('plan_builder_include_public');
  static const planTimeline = Key('plan_timeline');
  static const planReorderHandle = Key('plan_reorder_handle');

  static const planDetail = Key('plan_detail');
  static const planDetailMore = Key('plan_detail_more');
  static const planDetailAdd = Key('plan_detail_add');
  static const planStatStops = Key('plan_stat_stops');
  static const planStatBudget = Key('plan_stat_budget');
  static const planDeleteConfirm = Key('plan_delete_confirm');
  static const planMenuDelete = Key('plan_menu_delete');
  static const planMenuEdit = Key('plan_menu_edit');

  static const routesPage = Key('routes_page');
  static const routesEmpty = Key('routes_empty');
  static const routesStatVisited = Key('routes_stat_visited');
  static const routesStatCities = Key('routes_stat_cities');
  static const routesStatPlans = Key('routes_stat_plans');
  static Key routesItem(String stopId) => Key('routes_item_$stopId');
  static const adminPage = Key('admin_page');
}
