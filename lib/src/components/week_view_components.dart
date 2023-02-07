// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../style/header_style.dart';
import '../typedefs.dart';
import 'common_components.dart';

class WeekPageHeader extends CalendarPageHeader {
  const WeekPageHeader({
    Key? key,
    VoidCallback? onNextDay,
    AsyncCallback? onTitleTapped,
    VoidCallback? onPreviousDay,
    required DateTime startDate,
    required DateTime endDate,
    Color? iconColor,
    Color? backgroundColor,
    StringProvider? headerStringBuilder,
    HeaderStyle headerStyle = const HeaderStyle(),
  }) : super(
          key: key,
          date: startDate,
          secondaryDate: endDate,
          onNextDay: onNextDay,
          onPreviousDay: onPreviousDay,
          onTitleTapped: onTitleTapped,
          // ignore_for_file: deprecated_member_use_from_same_package
          iconColor: iconColor,
          backgroundColor: backgroundColor,
          dateStringBuilder:
              headerStringBuilder ?? WeekPageHeader._weekStringBuilder,
          headerStyle: headerStyle,
        );
  static String _weekStringBuilder(DateTime date, {DateTime? secondaryDate}) {
    if (secondaryDate==null || secondaryDate.isAtSameMomentAs(date)) {
      return "${date.day}/${date.month}/${date.year}";
    } else {
      return "${date.day}/${date.month}/${date.year} - "
          "${secondaryDate.day}/${secondaryDate.month}/${secondaryDate.year}";
    }
  }
}
