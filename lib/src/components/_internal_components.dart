// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../calendar_event_data.dart';
import '../constants.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../extensions.dart';
import '../modals.dart';
import '../painters.dart';
import '../typedefs.dart';
import 'event_scroll_notifier.dart';

/// Widget to display tile line according to current time.
class LiveTimeIndicator extends StatefulWidget {

  /// Height of total display area indicator will be displayed
  /// within this height.
  final double height;

  /// Width of time line use to calculate offset of indicator.
  final double timeLineWidth;

  /// settings for time line. Defines color, extra offset,
  /// and height of indicator.
  final HourIndicatorSettings liveTimeIndicatorSettings;

  /// Defines height occupied by one minute.
  final double heightPerMinute;

  /// in 24hr format
  final int startingHour;

  /// Widget to display tile line according to current time.
  const LiveTimeIndicator({
    Key? key,
    required this.height,
    required this.timeLineWidth,
    required this.liveTimeIndicatorSettings,
    required this.startingHour,
    required this.heightPerMinute,
  }) : super(key: key);

  @override
  _LiveTimeIndicatorState createState() => _LiveTimeIndicatorState();
}

class _LiveTimeIndicatorState extends State<LiveTimeIndicator> {
  late Timer _timer;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();

    _currentDate = DateTime.now();
    _timer = Timer(Duration(seconds: 1), setTimer);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Creates an recursive call that runs every 1 seconds.
  /// This will rebuild TimeLineIndicator every second. This will allow us
  /// to indicate live time in Week and Day view.
  void setTimer() {
    if (mounted) {
      setState(() {
        _currentDate = DateTime.now();
        _timer = Timer(Duration(seconds: 1), setTimer);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var minutes = _currentDate.getTotalMinutes - widget.startingHour*60;
    if (minutes < 0) minutes = (24-60) + minutes;
    return CustomPaint(
      size: Size(999999999, widget.height),
      painter: CurrentTimeLinePainter(
        color: widget.liveTimeIndicatorSettings.color,
        height: widget.liveTimeIndicatorSettings.height,
        offset: Offset(
          widget.timeLineWidth + widget.liveTimeIndicatorSettings.offset,
          minutes * widget.heightPerMinute,
        ),
      ),
    );
  }
}

/// Time line to display time at left side of day or week view.
class TimeLine extends StatelessWidget {
  /// Width of timeline
  final double timeLineWidth;

  /// Height for one hour.
  final double hourHeight;

  /// Total height of timeline.
  final double height;

  /// Offset for time line
  final double timeLineOffset;

  /// This will display time string in timeline.
  final DateWidgetBuilder timeLineBuilder;

  static DateTime get _date => DateTime.now();

  /// in 24hr format
  final int startingHour;

  /// Time line to display time at left side of day or week view.
  const TimeLine({
    Key? key,
    required this.timeLineWidth,
    required this.hourHeight,
    required this.height,
    required this.timeLineOffset,
    required this.timeLineBuilder,
    required this.startingHour,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      key: ValueKey(hourHeight),
      constraints: BoxConstraints(
        maxWidth: timeLineWidth,
        minWidth: timeLineWidth,
        maxHeight: height,
        minHeight: height,
      ),
      child: Stack(
        children: List.generate(Constants.hoursADay, (index) {
          var i = index + startingHour;
          if (i>24) i-=24;
          if (index==0) {
            return SizedBox.shrink();
          }
          return Positioned(
            top: hourHeight * index - timeLineOffset,
            left: 0,
            right: 0,
            bottom: height - (hourHeight * (index + 1)) + timeLineOffset,
            child: Container(
              height: hourHeight,
              width: timeLineWidth,
              child: timeLineBuilder.call(
                DateTime(
                  _date.year,
                  _date.month,
                  _date.day,
                  i,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A widget that display event tiles in day/week view.
class EventGenerator<T extends Object?> extends StatelessWidget {
  /// Height of display area
  final double height;

  /// List of events to display.
  final List<CalendarEventData<T>> events;

  /// Defines height of single minute in day/week view page.
  final double heightPerMinute;

  /// Defines how to arrange events.
  final EventArranger<T> eventArranger;

  /// Defines how event tile will be displayed.
  final EventTileBuilder<T> eventTileBuilder;

  /// Defines date for which events will be displayed in given display area.
  final DateTime date;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onTileTap;

  final EventScrollConfiguration scrollNotifier;

  /// in 24hr format
  final int startingHour;

  /// A widget that display event tiles in day/week view.
  const EventGenerator({
    Key? key,
    required this.height,
    required this.events,
    required this.heightPerMinute,
    required this.eventArranger,
    required this.eventTileBuilder,
    required this.date,
    required this.onTileTap,
    required this.scrollNotifier,
    required this.startingHour,
  }) : super(key: key);

  /// Arrange events and returns list of [Widget] that displays event
  /// tile on display area. This method uses [eventArranger] to get position
  /// of events and [eventTileBuilder] to display events.
  List<Widget> _generateEvents(BuildContext context) {
    final events = eventArranger.arrange(
      events: this.events,
      height: height,
      heightPerMinute: heightPerMinute,
      startingHour: startingHour,
    );

    return List.generate(events.length, (index) {
      return Positioned(
        left: 0, right: 0,
        top: events[index].top,
        bottom: events[index].bottom,
        child: Row(
          children: [
            if (events[index].left > 0)
              Flexible(flex: events[index].left.round(), child: Container(),),
            Flexible(
              flex: (events[index].right-events[index].left).round(),
              fit: FlexFit.tight,
              child: Material(
                color: Color.alphaBlend(
                  events[index].events.first.color.withOpacity(0.15),
                  Theme.of(context).cardColor,
                ),
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.circular(6.0),
                elevation: 3,
                child: InkWell(
                  onTap: () => onTileTap?.call(events[index].events, date),
                  child: Builder(builder: (context) {
                    if (scrollNotifier.shouldScroll &&
                        events[index]
                            .events
                            .any((element) => element == scrollNotifier.event)) {
                      _scrollToEvent(context);
                    }
                    return eventTileBuilder(
                      date,
                      events[index].events,
                      Rect.fromLTWH( // boundary is never used
                          events[index].left,
                          events[index].top,
                          events[index].right,
                          height - events[index].bottom - events[index].top),
                      events[index].startDuration,
                      events[index].endDuration,
                    );
                  }),
                ),
              ),
            ),
            if (events[index].columns - events[index].right > 0)
              Flexible(flex: (events[index].columns - events[index].right).round(), child: Container(),),
          ],
        ),
      );
    });
  }

  void _scrollToEvent(BuildContext context) {
    final duration = scrollNotifier.duration ?? Duration.zero;
    final curve = scrollNotifier.curve ?? Curves.ease;

    scrollNotifier.resetScrollEvent();

    ambiguate(WidgetsBinding.instance)?.addPostFrameCallback((timeStamp) async {
      try {
        await Scrollable.ensureVisible(
          context,
          duration: duration,
          curve: curve,
          alignment: 0.5,
        );
      } finally {
        scrollNotifier.completeScroll();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _generateEvents(context),
    );
  }
}

/// A widget that allow to long press on calendar.
class PressDetector extends StatelessWidget {
  /// Height of display area
  final double height;

  /// Defines height of single minute in day/week view page.
  final double heightPerMinute;

  /// Defines date for which events will be displayed in given display area.
  final DateTime date;

  /// Called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Called when user taps on day view page.
  ///
  /// This callback will have a date parameter which
  /// will provide the time span on which user has tapped.
  ///
  /// Ex, User Taps on Date page with date 11/01/2022 and time span is 1PM to 2PM.
  /// then DateTime object will be  DateTime(2022,01,11,1,0)
  final DateTapCallback? onDateTap;

  /// Defines size of the slots that provides long press callback on area
  /// where events are not available.
  final MinuteSlotSize minuteSlotSize;

  /// in 24hr format
  final int startingHour;

  /// A widget that display event tiles in day/week view.
  const PressDetector({
    Key? key,
    required this.height,
    required this.heightPerMinute,
    required this.date,
    required this.onDateLongPress,
    required this.onDateTap,
    required this.minuteSlotSize,
    required this.startingHour,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final heightPerSlot = minuteSlotSize.minutes * heightPerMinute;
    final slots = (Constants.hoursADay * 60) ~/ minuteSlotSize.minutes;

    return Stack(
      children: List.generate(slots, (i) {
        var minutes = minuteSlotSize.minutes * i + startingHour * 60;
        if (minutes > 24*60) minutes -= 24*60;
        return Positioned(
          top: heightPerSlot * i,
          left: 0,
          right: 0,
          bottom: height - (heightPerSlot * (i + 1)),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              mouseCursor: SystemMouseCursors.basic,
              onTap: () => onDateTap?.call(
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                  0,
                  minutes,
                ),
              ),
              onLongPress: () => onDateLongPress?.call(
                DateTime(
                  date.year,
                  date.month,
                  date.day,
                  0,
                  minutes,
                ),
              ),
              child: SizedBox(height: heightPerSlot),
            ),
          ),
        );
      }),
    );
  }
}
