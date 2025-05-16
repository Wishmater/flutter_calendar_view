// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../style/header_style.dart';
import '../typedefs.dart';

class CalendarPageHeader extends StatefulWidget {
  /// When user taps on right arrow.
  final VoidCallback? onNextDay;

  /// When user taps on left arrow.
  final VoidCallback? onPreviousDay;

  /// When user taps on title.
  final AsyncCallback? onTitleTapped;

  /// Date of month/day.
  final DateTime date;

  /// Secondary date. This date will be used when we need to define a
  /// range of dates.
  /// [date] can be starting date and [secondaryDate] can be end date.
  final DateTime? secondaryDate;

  /// Provides string to display as title.
  final StringProvider dateStringBuilder;

  // TODO: Need to remove after next release
  /// background color of header.
  @Deprecated("Use Header Style to provide background")
  final Color? backgroundColor;

  // TODO: Need to remove after next release
  /// Color of icons at both sides of header.
  @Deprecated("Use Header Style to provide icon color")
  final Color? iconColor;

  /// Style for Calendar's header
  final HeaderStyle headerStyle;

  /// Common header for month and day view In this header user can define format
  /// in which date will be displayed by providing [dateStringBuilder] function.
  const CalendarPageHeader({
    Key? key,
    required this.date,
    required this.dateStringBuilder,
    this.onNextDay,
    this.onTitleTapped,
    this.onPreviousDay,
    this.secondaryDate,
    @Deprecated("Use Header Style to provide background")
        this.backgroundColor,
    @Deprecated("Use Header Style to provide icon color")
        this.iconColor,
    this.headerStyle = const HeaderStyle(),
  }) : super(key: key);

  @override
  State<CalendarPageHeader> createState() => _CalendarPageHeaderState();

}


class _CalendarPageHeaderState extends State<CalendarPageHeader> {

  DateTime? previousDate;

  @override
  void didUpdateWidget(covariant CalendarPageHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.date!=oldWidget.date) {
      previousDate = oldWidget.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.headerStyle.headerMargin,
      padding: widget.headerStyle.headerPadding,
      decoration:
          // ignore_for_file: deprecated_member_use_from_same_package
          widget.headerStyle.decoration ?? BoxDecoration(
              color: widget.backgroundColor ?? Theme.of(context).cardColor),
      clipBehavior: Clip.antiAlias,
      child: Material(
        type: MaterialType.transparency,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          // crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.headerStyle.leftIconVisible)
              IconButton(
                onPressed: widget.onPreviousDay,
                padding: widget.headerStyle.leftIconPadding,
                icon: widget.headerStyle.leftIcon ??
                    Icon(
                      Icons.chevron_left,
                      size: 30,
                      color: widget.iconColor,
                    ),
              ),
            Expanded(
              child: PageTransitionSwitcher(
                reverse: previousDate!=null && previousDate!.isAfter(widget.date),
                transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                  return SharedAxisTransition(
                    animation: primaryAnimation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    fillColor: Colors.transparent,
                    child: child,
                  );
                },
                child: InkWell(
                  key: ValueKey(widget.date),
                  onTap: widget.onTitleTapped,
                  child: Container(
                    constraints: BoxConstraints(minWidth: 256, minHeight: 36),
                    alignment: Alignment.center,
                    child: Text(
                      widget.dateStringBuilder(widget.date, secondaryDate: widget.secondaryDate),
                      textAlign: widget.headerStyle.titleAlign,
                      style: widget.headerStyle.headerTextStyle ?? Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
              ),
            ),
            if (widget.headerStyle.rightIconVisible)
              IconButton(
                onPressed: widget.onNextDay,
                padding: widget.headerStyle.rightIconPadding,
                icon: widget.headerStyle.rightIcon ??
                    Icon(
                      Icons.chevron_right,
                      size: 30,
                      color: widget.iconColor,
                    ),
              ),
          ],
        ),
      ),
    );
  }

}
