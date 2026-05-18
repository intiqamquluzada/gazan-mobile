import 'package:flutter/material.dart';

/// Single source of truth for iconography.
///
/// Every screen references [AppIcons] instead of `Icons.*` directly so the
/// icon family stays visually consistent and can be swapped to a dedicated
/// line set (Lucide / Phosphor) in one place without touching screens.
///
/// We standardise on the Material Symbols **rounded** family: one weight,
/// one corner style, no mix of filled/outlined — the inconsistency was a
/// big part of why the old UI read as unfinished.
class AppIcons {
  const AppIcons._();

  // ── Navigation ─────────────────────────────────────────────────────
  static const IconData home = Icons.explore_outlined;
  static const IconData homeActive = Icons.explore_rounded;
  static const IconData cards = Icons.style_outlined;
  static const IconData cardsActive = Icons.style_rounded;
  static const IconData qr = Icons.qr_code_scanner_rounded;
  static const IconData profile = Icons.person_outline_rounded;
  static const IconData profileActive = Icons.person_rounded;
  static const IconData dashboard = Icons.grid_view_outlined;
  static const IconData dashboardActive = Icons.grid_view_rounded;
  static const IconData customers = Icons.groups_outlined;
  static const IconData customersActive = Icons.groups_rounded;
  static const IconData programs = Icons.loyalty_outlined;
  static const IconData programsActive = Icons.loyalty_rounded;

  // ── Common actions ─────────────────────────────────────────────────
  static const IconData back = Icons.arrow_back_ios_new_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
  static const IconData chevron = Icons.chevron_right_rounded;
  static const IconData close = Icons.close_rounded;
  static const IconData check = Icons.check_rounded;
  static const IconData add = Icons.add_rounded;
  static const IconData remove = Icons.remove_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.tune_rounded;
  static const IconData share = Icons.ios_share_rounded;
  static const IconData edit = Icons.edit_outlined;
  static const IconData more = Icons.more_horiz_rounded;
  static const IconData refresh = Icons.refresh_rounded;

  // ── Glyphs ─────────────────────────────────────────────────────────
  static const IconData bell = Icons.notifications_none_rounded;
  static const IconData heart = Icons.favorite_border_rounded;
  static const IconData heartActive = Icons.favorite_rounded;
  static const IconData star = Icons.star_rounded;
  static const IconData location = Icons.location_on_outlined;
  static const IconData clock = Icons.schedule_rounded;
  static const IconData gift = Icons.redeem_rounded;
  static const IconData token = Icons.toll_rounded;
  static const IconData verified = Icons.verified_rounded;
  static const IconData info = Icons.info_outline_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData success = Icons.check_circle_rounded;
  static const IconData emptyBox = Icons.inbox_outlined;
  static const IconData searchOff = Icons.search_off_rounded;
  static const IconData camera = Icons.photo_camera_rounded;
  static const IconData mail = Icons.alternate_email_rounded;
  static const IconData lock = Icons.lock_outline_rounded;
  static const IconData eye = Icons.visibility_outlined;
  static const IconData eyeOff = Icons.visibility_off_outlined;
  static const IconData phone = Icons.phone_outlined;
  static const IconData person = Icons.person_outline_rounded;

  // ── Profile / settings ─────────────────────────────────────────────
  static const IconData settings = Icons.settings_outlined;
  static const IconData language = Icons.translate_rounded;
  static const IconData theme = Icons.dark_mode_outlined;
  static const IconData help = Icons.help_outline_rounded;
  static const IconData security = Icons.shield_outlined;
  static const IconData logout = Icons.logout_rounded;
  static const IconData about = Icons.info_outline_rounded;

  // ── Business categories ────────────────────────────────────────────
  static const IconData cafe = Icons.local_cafe_rounded;
  static const IconData restaurant = Icons.restaurant_rounded;
  static const IconData beauty = Icons.spa_rounded;
  static const IconData carWash = Icons.local_car_wash_rounded;
  static const IconData fitness = Icons.fitness_center_rounded;
  static const IconData bakery = Icons.bakery_dining_rounded;
  static const IconData barber = Icons.content_cut_rounded;
  static const IconData store = Icons.storefront_rounded;
}
