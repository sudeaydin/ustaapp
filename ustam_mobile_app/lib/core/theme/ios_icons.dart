import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// iOS SF Symbols style icons mapping
/// Maps common Material icons to iOS-style Cupertino icons
class iOSIcons {
  // Search & Navigation
  static const IconData search = CupertinoIcons.search;
  static const IconData searchOff = CupertinoIcons.clear;
  static const IconData close = CupertinoIcons.xmark;
  static const IconData refresh = CupertinoIcons.refresh;
  static const IconData tune = CupertinoIcons.slider_horizontal_3;
  
  // Location & Map
  static const IconData locationOn = CupertinoIcons.location_fill;
  static const IconData map = CupertinoIcons.map;
  
  // User & Profile
  static const IconData person = CupertinoIcons.person_fill;
  static const IconData personOutline = CupertinoIcons.person;
  static const IconData verified = CupertinoIcons.checkmark_seal_fill;
  
  // Communication
  static const IconData message = CupertinoIcons.chat_bubble_fill;
  static const IconData messageOutline = CupertinoIcons.chat_bubble;
  static const IconData phone = CupertinoIcons.phone_fill;
  static const IconData email = CupertinoIcons.mail_solid;
  
  // Reviews & Rating
  static const IconData star = CupertinoIcons.star_fill;
  static const IconData starOutline = CupertinoIcons.star;
  static const IconData rateReview = CupertinoIcons.chat_bubble_text_fill;
  
  // Navigation
  static const IconData home = CupertinoIcons.house_fill;
  static const IconData homeOutline = CupertinoIcons.house;
  static const IconData calendar = CupertinoIcons.calendar;
  static const IconData calendarFill = CupertinoIcons.calendar_today;
  static const IconData notifications = CupertinoIcons.bell_fill;
  static const IconData notificationsOutline = CupertinoIcons.bell;
  
  // Actions
  static const IconData add = CupertinoIcons.add;
  static const IconData edit = CupertinoIcons.pencil;
  static const IconData delete = CupertinoIcons.trash_fill;
  static const IconData share = CupertinoIcons.share;
  static const IconData favorite = CupertinoIcons.heart_fill;
  static const IconData favoriteOutline = CupertinoIcons.heart;
  
  // Status & Info
  static const IconData info = CupertinoIcons.info_circle_fill;
  static const IconData warning = CupertinoIcons.exclamationmark_triangle_fill;
  static const IconData error = CupertinoIcons.xmark_circle_fill;
  static const IconData success = CupertinoIcons.checkmark_circle_fill;
  
  // Work & Business
  static const IconData work = CupertinoIcons.briefcase_fill;
  static const IconData workOutline = CupertinoIcons.briefcase;
  static const IconData money = CupertinoIcons.money_dollar_circle_fill;
  static const IconData time = CupertinoIcons.clock_fill;
  static const IconData schedule = CupertinoIcons.time;
  
  // Settings & More
  static const IconData settings = CupertinoIcons.settings_solid;
  static const IconData settingsOutline = CupertinoIcons.settings;
  static const IconData more = CupertinoIcons.ellipsis;
  static const IconData moreVertical = CupertinoIcons.ellipsis_vertical;
  
  // Arrows & Navigation
  static const IconData arrowBack = CupertinoIcons.back;
  static const IconData arrowForward = CupertinoIcons.forward;
  static const IconData arrowUp = CupertinoIcons.up_arrow;
  static const IconData arrowDown = CupertinoIcons.down_arrow;
  
  // Media
  static const IconData camera = CupertinoIcons.camera_fill;
  static const IconData photo = CupertinoIcons.photo_fill;
  static const IconData video = CupertinoIcons.video_camera_solid;
  
  /// Helper method to get iOS-style icon with proper sizing
  static Widget icon(
    IconData iconData, {
    double? size,
    Color? color,
    String? semanticLabel,
  }) {
    return Icon(
      iconData,
      size: size ?? 24,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}