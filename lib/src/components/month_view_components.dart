// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../calendar_event_data.dart';
import '../constants.dart';
import '../extensions.dart';
import '../style/header_style.dart';
import '../typedefs.dart';
import 'common_components.dart';

class CircularCell extends StatelessWidget {
  /// Date of cell.
  final DateTime date;

  /// List of Events for current date.
  final List<CalendarEventData> events;

  /// Defines if [date] is [DateTime.now] or not.
  final bool shouldHighlight;

  /// Background color of circle around date title.
  final Color? backgroundColor;

  /// Title color when title is highlighted.
  final Color? highlightedTitleColor;

  /// Color of cell title.
  final Color? titleColor;

  /// This class will defines how cell will be displayed.
  /// To get proper view user [CircularCell] with 1 [MonthView.cellAspectRatio].
  const CircularCell({
    Key? key,
    required this.date,
    this.events = const [],
    this.shouldHighlight = false,
    this.backgroundColor = Colors.blue,
    this.highlightedTitleColor,
    this.titleColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = this.backgroundColor ?? Theme.of(context).splashColor.withOpacity(1);
    final titleColor = shouldHighlight
        ? highlightedTitleColor
            ?? (ThemeData.estimateBrightnessForColor(backgroundColor)==Brightness.light
                ? Colors.black : Colors.white)
        : this.titleColor;
    return Center(
      child: CircleAvatar(
        backgroundColor: shouldHighlight ? backgroundColor : Colors.transparent,
        child: Text(
          "${date.day}",
          style: TextStyle(
            fontSize: 20,
            color: titleColor,
          ),
        ),
      ),
    );
  }
}

class FilledCell<T extends Object?> extends StatelessWidget {
  /// Date of current cell.
  final DateTime date;

  /// List of events on for current date.
  final List<CalendarEventData<T>> events;

  /// defines date string for current cell.
  final StringProvider? dateStringBuilder;

  /// Defines if cell should be highlighted or not.
  /// If true it will display date title in a circle.
  final bool shouldHighlight;

  /// Defines background color of cell.
  final Color? backgroundColor;

  /// Defines highlight color.
  final Color? highlightColor;

  /// Color for event tile.
  final Color tileColor;

  /// Called when user taps on any event tile.
  final TileTapCallback<T>? onTileTap;

  /// defines that [date] is in current month or not.
  final bool isInMonth;

  /// defines radius of highlighted date.
  final double highlightRadius;

  /// color of cell title
  final Color? titleColor;

  /// color of highlighted cell title
  final Color? highlightedTitleColor;

  /// This class will defines how cell will be displayed.
  /// This widget will display all the events as tile below date title.
  const FilledCell({
    Key? key,
    required this.date,
    required this.events,
    this.isInMonth = false,
    this.shouldHighlight = false,
    this.backgroundColor,
    this.highlightColor,
    this.onTileTap,
    this.tileColor = Colors.blue,
    this.highlightRadius = 11,
    this.titleColor,
    this.highlightedTitleColor,
    this.dateStringBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final backgroundColor = this.backgroundColor ?? Theme.of(context).cardColor;
    final highlightColor = this.highlightColor ?? Theme.of(context).splashColor.withOpacity(1);
    final titleColor = shouldHighlight
        ? highlightedTitleColor
            ?? (ThemeData.estimateBrightnessForColor(highlightColor)==Brightness.light
                ? Colors.black : Colors.white)
        : this.titleColor ?? Theme.of(context).textTheme.bodyText1!.color!;
    return Column(
      children: [
        SizedBox(
          height: 5.0,
        ),
        CircleAvatar(
          radius: highlightRadius,
          backgroundColor:
              shouldHighlight ? highlightColor : Colors.transparent,
          child: Text(
            dateStringBuilder?.call(date) ?? "${date.day}",
            style: TextStyle(
              color: shouldHighlight
                  ? titleColor
                  : isInMonth
                      ? titleColor
                      : titleColor.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
        ),
        if (events.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 5.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                events.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
                  child: Material(
                    color: Color.alphaBlend(
                      events[index].color.withOpacity(0.15),
                      Theme.of(context).cardColor,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                    clipBehavior: Clip.hardEdge,
                    elevation: 3,
                    child: InkWell(
                      onTap: onTileTap==null ? null : () =>
                          onTileTap?.call(events[index], events[index].date),
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 5,
                              color: events[index].color,
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(2, 2, 3, 3),
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (events[index].title.isNotEmpty)
                                      Text(
                                        events[index].title,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    if (events[index].description.isNotEmpty)
                                      Text(
                                        events[index].description,
                                        overflow: TextOverflow.clip,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class MonthPageHeader extends CalendarPageHeader {
  /// A header widget to display on month view.
  const MonthPageHeader({
    Key? key,
    VoidCallback? onNextMonth,
    AsyncCallback? onTitleTapped,
    VoidCallback? onPreviousMonth,
    Color? iconColor,
    Color? backgroundColor,
    StringProvider? dateStringBuilder,
    required DateTime date,
    HeaderStyle headerStyle = const HeaderStyle(),
  }) : super(
          key: key,
          date: date,
          onNextDay: onNextMonth,
          onPreviousDay: onPreviousMonth,
          onTitleTapped: onTitleTapped,
          // ignore_for_file: deprecated_member_use_from_same_package
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          dateStringBuilder:
              dateStringBuilder ?? MonthPageHeader._monthStringBuilder,
          headerStyle: headerStyle,
        );
  static String _monthStringBuilder(DateTime date, {DateTime? secondaryDate}) =>
      DateFormat(DateFormat.YEAR_MONTH).format(date);
      // "${date.month} - ${date.year}";
}

class WeekDayTile extends StatelessWidget {
  /// Index of week day.
  final int dayIndex;

  /// display week day
  final String Function(int)? weekDayStringBuilder;

  /// Background color of single week day tile.
  final Color? backgroundColor;

  /// Should display border or not.
  final bool displayBorder;

  /// Style for week day string.
  final TextStyle? textStyle;

  /// Title for week day in month view.
  const WeekDayTile({
    Key? key,
    required this.dayIndex,
    this.backgroundColor,
    this.displayBorder = true,
    this.textStyle,
    this.weekDayStringBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.only(bottom: 10.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        border: !displayBorder ? null : Border.all(
          color: DividerTheme.of(context).color ?? Theme.of(context).dividerColor,
          width: 0.5,
        ),
      ),
      child: Text(
        weekDayStringBuilder?.call(dayIndex) ?? Constants.weekTitles[dayIndex],
        style: textStyle ?? Theme.of(context).textTheme.subtitle1!.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
