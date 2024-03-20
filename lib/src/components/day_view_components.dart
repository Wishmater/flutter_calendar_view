// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../calendar_view.dart';
import '../calendar_event_data.dart';
import '../constants.dart';
import '../extensions.dart';
import '../style/header_style.dart';
import '../typedefs.dart';
import 'common_components.dart';

/// This class defines default tile to display in day view.
class RoundedEventTile extends StatelessWidget {
  /// Title of the tile.
  final String title;

  /// Description of the tile.
  final String description;

  /// Background color of tile.
  /// Default color is [Colors.blue]
  final Color? backgroundColor;

  /// Background color of tile.
  /// Default color is [Colors.blue]
  final Color? accentColor;

  /// If same tile can have multiple events.
  /// In most cases this value will be 1 less than total events.
  final int totalEvents;

  /// Padding of the tile. Default padding is [EdgeInsets.zero]
  final EdgeInsets padding;

  /// Margin of the tile. Default margin is [EdgeInsets.zero]
  final EdgeInsets margin;

  /// Border radius of tile.
  final BorderRadius borderRadius;

  /// Style for title
  final TextStyle? titleStyle;

  /// Style for description
  final TextStyle? descriptionStyle;

  /// This is default tile to display in day view.
  const RoundedEventTile({
    Key? key,
    required this.title,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.description = "",
    this.borderRadius = BorderRadius.zero,
    this.totalEvents = 1,
    this.backgroundColor,
    this.titleStyle,
    this.descriptionStyle,
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      child: Row(
        children: [
          if (accentColor!=null)
            Container(
              width: 6,
              color: accentColor,
            ),
          Expanded(
            child: Padding(
              padding: padding,
              child: OverflowBox(
                alignment: Alignment.topCenter,
                maxHeight: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: titleStyle ??
                            TextStyle(
                              fontSize: 20,
                              color: backgroundColor?.accent,
                            ),
                        softWrap: true,
                        overflow: TextOverflow.fade,
                      ),
                    if (description.isNotEmpty)
                      Text(
                        description,
                        style: descriptionStyle ??
                            TextStyle(
                              fontSize: 17,
                              color: backgroundColor?.accent.withAlpha(200),
                            ),
                      ),
                    if (totalEvents > 1)
                      Text(
                        "+${totalEvents - 1} more",
                        style: (descriptionStyle ??
                                TextStyle(
                                  color: backgroundColor?.accent.withAlpha(200),
                                ))
                            .copyWith(fontSize: 17),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A header widget to display on day view.
class DayPageHeader extends CalendarPageHeader {
  /// A header widget to display on day view.
  const DayPageHeader({
    Key? key,
    VoidCallback? onNextDay,
    AsyncCallback? onTitleTapped,
    VoidCallback? onPreviousDay,
    Color iconColor = Constants.black,
    Color backgroundColor = Constants.headerBackground,
    StringProvider? dateStringBuilder,
    required DateTime date,
    HeaderStyle headerStyle = const HeaderStyle(),
  }) : super(
          key: key,
          date: date,
          // ignore_for_file: deprecated_member_use_from_same_package
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          onNextDay: onNextDay,
          onPreviousDay: onPreviousDay,
          onTitleTapped: onTitleTapped,
          dateStringBuilder:
              dateStringBuilder ?? DayPageHeader._dayStringBuilder,
          headerStyle: headerStyle,
        );
  static String _dayStringBuilder(DateTime date, {DateTime? secondaryDate}) =>
      "${date.day} - ${date.month} - ${date.year}";
}

class DefaultTimeLineMark extends StatelessWidget {
  /// Defines time to display
  final DateTime date;

  /// StringProvider for time string
  final StringProvider? timeStringBuilder;

  /// Text style for time string.
  final TextStyle? markingStyle;

  /// Time marker for timeline used in week and day view.
  const DefaultTimeLineMark({
    Key? key,
    required this.date,
    this.markingStyle,
    this.timeStringBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final timeString = (timeStringBuilder != null)
        ? timeStringBuilder!(date)
        : "${((date.hour - 1) % 12) + 1} ${date.hour ~/ 12 == 0 ? "am" : "pm"}";
    return Transform.translate(
      offset: Offset(0, -7.5),
      child: Padding(
        padding: const EdgeInsets.only(right: 7.0),
        child: Text(
          timeString,
          textAlign: TextAlign.right,
          style: markingStyle ??
              TextStyle(
                fontSize: 15.0,
              ),
        ),
      ),
    );
  }
}

/// This class is defined default view of full day event
class FullDayEventView<T> extends StatelessWidget {
  const FullDayEventView({
    Key? key,
    this.boxConstraints,
    required this.events,
    this.padding,
    this.itemView,
    this.titleStyle,
    this.descriptionStyle,
    this.onEventTap,
    required this.date,
    this.eventWidgetBuilder,
  }) : super(key: key);

  /// Constraints for view
  final BoxConstraints? boxConstraints;

  /// Define List of Event to display
  final List<CalendarEventData<T>> events;

  /// Define Padding of view
  final EdgeInsets? padding;

  /// Define custom Item view of Event.
  final Widget Function(CalendarEventData<T>? event)? itemView;

  /// Style for title
  final TextStyle? titleStyle;

  /// Style for description
  final TextStyle? descriptionStyle;

  /// Called when user taps on event tile.
  final TileTapCallback<T>? onEventTap;

  /// Defines date for which events will be displayed.
  final DateTime date;

  final EventWidgetBuilder<T>? eventWidgetBuilder;

  @override
  Widget build(BuildContext context) {
    Widget result = ListView.builder(
      itemCount: events.length,
      padding: padding,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (itemView!=null) {
          return itemView?.call(events[index]);
        } else if (eventWidgetBuilder!=null) {
          return eventWidgetBuilder!(context, events[index],
                (context) => buildEventWidget(context, events[index]),
          );
        } else {
          return buildEventWidget(context, events[index]);
        }
      },
    );
    if (boxConstraints!=null) {
      result = ConstrainedBox(
        constraints: boxConstraints!,
        child: result,
      );
    }
    return result;
  }

  Widget buildEventWidget(BuildContext context, CalendarEventData<T> event) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 3.0),
      child: Material(
        color: Color.alphaBlend(
          (event.backgroundColor??event.color).withOpacity(0.1),
          Theme.of(context).cardColor,
        ),
        borderRadius: BorderRadius.circular(4.0),
        clipBehavior: Clip.hardEdge,
        elevation: 3,
        child: InkWell(
          onTap: onEventTap==null ? null : () => onEventTap?.call(event, date),
          child: IntrinsicHeight(
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 5,
                      color: event.color,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(2, 2, 3, 3),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.title.isNotEmpty)
                              Text(
                                event.title,
                                style: titleStyle ??
                                    TextStyle(
                                      fontSize: 20,
                                    ),
                                softWrap: true,
                                overflow: TextOverflow.fade,
                              ),
                            if (event.description.isNotEmpty)
                              Text(
                                event.description,
                                style: descriptionStyle ??
                                    TextStyle(
                                      fontSize: 17,
                                    ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: event.color,
      ),
      alignment: Alignment.centerLeft,
    );
  }

}
