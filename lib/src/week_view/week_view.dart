// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';

import '../../calendar_view.dart';
import '../../util/custom_painters.dart';
import '../../util/my_sliver_sticky_header.dart';
import '../../util/notification_relayer.dart';
import '../../util/overflow_scroll.dart';
import '../calendar_constants.dart';
import '../calendar_controller_provider.dart';
import '../calendar_event_data.dart';
import '../components/components.dart';
import '../components/event_scroll_notifier.dart';
import '../components/safe_area_wrapper.dart';
import '../constants.dart';
import '../enumerations.dart';
import '../event_arrangers/event_arrangers.dart';
import '../event_controller.dart';
import '../extensions.dart';
import '../modals.dart';
import '../style/header_style.dart';
import '../typedefs.dart';
import '_internal_week_view_page.dart';


/// [Widget] to display week view.
class WeekView<T extends Object?> extends StatefulWidget {
  /// Builder to build tile for events.
  final EventTileBuilder<T>? eventTileBuilder;

  /// Builder for timeline.
  final DateWidgetBuilder? timeLineBuilder;

  /// Header builder for week page header.
  final WeekPageHeaderBuilder? weekPageHeaderBuilder;

  /// This function will generate dateString int the calendar header.
  /// Useful for I18n
  final StringProvider? headerStringBuilder;

  /// This function will generate the TimeString in the timeline.
  /// Useful for I18n
  final StringProvider? timeLineStringBuilder;

  /// This function will generate WeekDayString in the weekday.
  /// Useful for I18n
  final String Function(int)? weekDayStringBuilder;

  /// This function will generate WeekDayDateString in the weekday.
  /// Useful for I18n
  final String Function(int)? weekDayDateStringBuilder;

  /// Arrange events.
  final EventArranger<T>? eventArranger;

  /// Called whenever user changes week.
  final CalendarPageChangeCallBack? onPageChange;

  /// Minimum day to display in week view.
  ///
  /// In calendar first date of the week that contains this data will be
  /// minimum date.
  ///
  /// ex, If minDay is 16th March, 2022 then week containing this date will have
  /// dates from 14th to 20th (Monday to Sunday). adn 14th date will
  /// be the actual minimum date.
  final DateTime? minDay;

  /// Maximum day to display in week view.
  ///
  /// In calendar last date of the week that contains this data will be
  /// maximum date.
  ///
  /// ex, If maxDay is 16th March, 2022 then week containing this date will have
  /// dates from 14th to 20th (Monday to Sunday). adn 20th date will
  /// be the actual maximum date.
  final DateTime? maxDay;

  /// Initial week to display in week view.
  final DateTime? initialDay;

  /// Settings for hour indicator settings.
  final HourIndicatorSettings? hourIndicatorSettings;

  /// Settings for live time indicator settings.
  final HourIndicatorSettings? liveTimeIndicatorSettings;

  /// duration for page transition while changing the week.
  final Duration pageTransitionDuration;

  /// Transition curve for transition.
  final Curve pageTransitionCurve;

  /// Controller for Week view thia will refresh view when user adds or removes
  /// event from controller.
  final EventController<T>? controller;

  /// Defines height occupied by one minute of time span. This parameter will
  /// be used to calculate total height of Week view.
  final double heightPerMinute;

  /// Width of time line.
  final double timeLineWidth;

  /// Flag to show live time indicator in all day or only [initialDay]
  final bool showLiveTimeLineInAllDays;

  /// Offset of time line
  final double timeLineOffset;

  /// Builder to build week day.
  final DateWidgetBuilder? weekDayBuilder;

  /// Builder to build week number.
  final WeekNumberBuilder? weekNumberBuilder;

  /// Background color of week view page.
  final Color? backgroundColor;

  /// Scroll offset of week view page.
  final double scrollOffset;

  /// Called when user taps on event tile.
  final CellTapCallback<T>? onEventTap;

  /// in 24hr format
  final int startingHour;

  /// Show weekends or not
  ///
  /// Default value is true.
  ///
  /// If it is false week view will remove weekends from week
  /// even if weekends are added in [weekDays].
  ///
  /// ex, if [showWeekends] is false and [weekDays] are monday, tuesday,
  /// saturday and sunday, only monday and tuesday will be visible in week view.
  final bool showWeekends;

  /// Defines which days should be displayed in one week.
  ///
  /// By default all the days will be visible.
  /// Sequence will be monday to sunday.
  ///
  /// Duplicate values will be removed from list.
  ///
  /// ex, if there are two mondays in list it will display only one.
  final List<WeekDays>? weekDays;

  /// This method will be called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  /// Called when user taps on day view page.
  ///
  /// This callback will have a date parameter which
  /// will provide the time span on which user has tapped.
  ///
  /// Ex, User Taps on Date page with date 11/01/2022 and time span is 1PM to 2PM.
  /// then DateTime object will be  DateTime(2022,01,11,1,0)
  final DateTapCallback? onDateTap;

  /// Defines the day from which the week starts.
  ///
  /// Default value is [WeekDays.monday].
  final WeekDays startDay;

  /// Defines size of the slots that provides long press callback on area
  /// where events are not there.
  final MinuteSlotSize minuteSlotSize;

  /// Style for WeekView header.
  final HeaderStyle headerStyle;

  /// Option for SafeArea.
  final SafeAreaOption safeAreaOption;

  /// Display full day event builder.
  final FullDayEventBuilder<T>? fullDayEventBuilder;

  /// If not null and the width of context is less than minWidth,
  /// a horizontal scrollable will be created
  final double? minWidthPerDay;

  final EventWidgetBuilder<T>? eventWidgetBuilder;

  /// Main widget for week view.
  const WeekView({
    Key? key,
    this.controller,
    this.eventTileBuilder,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.ease,
    this.heightPerMinute = 1,
    this.timeLineOffset = 0,
    this.showLiveTimeLineInAllDays = false,
    this.minDay,
    this.maxDay,
    this.initialDay,
    this.hourIndicatorSettings,
    this.timeLineBuilder,
    this.timeLineWidth = 64,
    this.liveTimeIndicatorSettings,
    this.onPageChange,
    this.weekPageHeaderBuilder,
    this.eventArranger,
    this.weekDayBuilder,
    this.weekNumberBuilder,
    this.backgroundColor,
    this.scrollOffset = 0.0,
    this.onEventTap,
    this.onDateLongPress,
    this.onDateTap,
    this.weekDays = WeekDays.values,
    this.showWeekends = true,
    this.startDay = WeekDays.monday,
    this.minuteSlotSize = MinuteSlotSize.minutes60,
    this.headerStringBuilder,
    this.timeLineStringBuilder,
    this.weekDayStringBuilder,
    this.weekDayDateStringBuilder,
    this.headerStyle = const HeaderStyle(),
    this.safeAreaOption = const SafeAreaOption(),
    this.fullDayEventBuilder,
    this.startingHour = 7,
    this.minWidthPerDay = 96,
    this.eventWidgetBuilder,
  })  : assert((timeLineOffset) >= 0,
            "timeLineOffset must be greater than or equal to 0"),
        assert(timeLineWidth > 0,
            "Time line width must be greater than 0."),
        assert(
            heightPerMinute > 0, "Height per minute must be greater than 0."),
        super(key: key);

  @override
  WeekViewState<T> createState() => WeekViewState<T>();
}

class WeekViewState<T extends Object?> extends State<WeekView<T>> {
  late double _height;
  late double _timeLineWidth;
  late double _hourHeight;
  late DateTime _maxDate;
  late DateTime _minDate;
  late int _totalWeeks;
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier(0);
  int get _currentIndex => _currentIndexNotifier.value;
  set _currentIndex(int value) {
    _previousIndex = _currentIndex;
    _currentIndexNotifier.value = value;
  }
  int? _previousIndex;

  DateTime get _currentWeek => _minDate.add(Duration(days: _currentIndex
      * (widget.weekDays==null ? 1 : DateTime.daysPerWeek)));
  DateTime get _currentStartDate => widget.weekDays==null
      ? _currentWeek
      : _currentWeek.firstDayOfWeek(start: widget.startDay);
  DateTime get _currentEndDate => widget.weekDays==null
      ? _currentWeek
      : _currentWeek.lastDayOfWeek(start: widget.startDay);

  late EventArranger<T> _eventArranger;

  late HourIndicatorSettings _hourIndicatorSettings;
  late HourIndicatorSettings _liveTimeIndicatorSettings;

  late DateWidgetBuilder _timeLineBuilder;
  late EventTileBuilder<T> _eventTileBuilder;
  late WeekPageHeaderBuilder _weekHeaderBuilder;
  late DateWidgetBuilder _weekDayBuilder;
  late WeekNumberBuilder _weekNumberBuilder;
  late FullDayEventBuilder<T> _fullDayEventBuilder;

  late int _totalDaysInWeek;

  late VoidCallback _reloadCallback;

  EventController<T>? _controller;

  late List<WeekDays>? _weekDays;

  final _scrollConfiguration = EventScrollConfiguration();

  late final LinkedScrollControllerGroup overflowScrollControllerGroup;
  late final ScrollController overflowScrollController1;
  final overflowScrollController2Map = <int, ScrollController>{};

  @override
  void initState() {
    super.initState();

    overflowScrollControllerGroup = LinkedScrollControllerGroup();
    overflowScrollController1 = overflowScrollControllerGroup.addAndGet();

    _reloadCallback = _reload;

    _setWeekDays();
    _setDateRange();

    jumpToWeek(widget.initialDay ?? DateTime.now());
    _currentIndexNotifier.addListener(() {
      widget.onPageChange?.call(_currentWeek, _currentIndex);
      setState(() {});
    });

    _regulateCurrentDate();

    _calculateHeights();
    _eventArranger = widget.eventArranger ?? SideEventArranger<T>();

    _assignBuilders();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (_controller != newController) {
      _controller = newController;

      _controller!
        // Removes existing callback.
        ..removeListener(_reloadCallback)

        // Reloads the view if there is any change in controller or
        // user adds new events.
        ..addListener(_reloadCallback);
    }

    _updateViewDimensions();
  }

  @override
  void didUpdateWidget(WeekView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller.
    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (newController != _controller) {
      _controller?.removeListener(_reloadCallback);
      _controller = newController;
      _controller?.addListener(_reloadCallback);
    }

    _setWeekDays();

    // Update date range.
    if (widget.minDay != oldWidget.minDay ||
        widget.maxDay != oldWidget.maxDay) {
      _setDateRange();
      _regulateCurrentDate();
    }

    _eventArranger = widget.eventArranger ?? SideEventArranger<T>();

    // Update heights.
    _calculateHeights();

    _updateViewDimensions();

    // Update builders and callbacks
    _assignBuilders();
  }

  @override
  void dispose() {
    _controller?.removeListener(_reloadCallback);
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dates = _weekDays==null
        ? [_currentWeek]
        : _currentWeek.datesOfWeek(start: widget.startDay);
    final filteredDates = _weekDays==null
        ? dates
        : InternalWeekViewPage.filteredDate(dates, _weekDays!);
    final overflowRelayController = NotificationRelayController(
          (n) => n is ScrollNotification || n is ScrollMetricsNotification,
    );
    final key = ValueKey(_hourHeight.toString() + dates[0].toString());
    overflowScrollController2Map[_currentIndex] ??= overflowScrollControllerGroup.addAndGet();
    final overflowScrollController2 = overflowScrollController2Map[_currentIndex]!;

    final resultBuilder = (context) => ValueListenableBuilder(
      valueListenable: _scrollConfiguration,
      key: key,
      builder: (_, __, ___) => InternalWeekViewPage<T>(
        height: _height,
        weekDayBuilder: _weekDayBuilder,
        weekNumberBuilder: _weekNumberBuilder,
        liveTimeIndicatorSettings: _liveTimeIndicatorSettings,
        timeLineBuilder: _timeLineBuilder,
        onTileTap: widget.onEventTap,
        onDateLongPress: widget.onDateLongPress,
        onDateTap: widget.onDateTap,
        eventTileBuilder: _eventTileBuilder,
        heightPerMinute: widget.heightPerMinute,
        hourIndicatorSettings: _hourIndicatorSettings,
        dates: dates,
        showLiveLine: widget.showLiveTimeLineInAllDays ||
            _showLiveTimeIndicator(dates),
        timeLineOffset: widget.timeLineOffset,
        timeLineWidth: _timeLineWidth,
        verticalLineOffset: 0,
        showVerticalLine: true,
        controller: controller,
        hourHeight: _hourHeight,
        eventArranger: _eventArranger,
        weekDays: _weekDays,
        minuteSlotSize: widget.minuteSlotSize,
        scrollConfiguration: _scrollConfiguration,
        fullDayEventBuilder: _fullDayEventBuilder,
        startingHour: widget.startingHour,
        eventWidgetBuilder: widget.eventWidgetBuilder,
      ),
    );
    Widget result;
    final minWidth = widget.minWidthPerDay==null
        ? null
        : widget.timeLineWidth + widget.minWidthPerDay!*(widget.weekDays?.length??7);
    if (minWidth!=null) {
      result = NotificationRelayListener(
        key: key,
        consumeRelayedNotifications: true,
        controller: overflowRelayController,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return OverflowScroll(
                scrollController: overflowScrollController2,
                autoscrollSpeed: null,
                consumeScrollNotifications: false,
                opacityGradientSize: 0,
                child: SizedBox(
                  width: max(minWidth, constraints.maxWidth),
                  child: resultBuilder(context),
                ),
              );
            },
          ),
        ),
      );
    } else {
      result = resultBuilder(context);
    }
    result = _buildHorizontalSwipeGestureDetector(context, result);
    result = SliverToBoxAdapter( // TODO performance: maybe we could build SliverGridView and avoid always laying out all the rows
      child: ColoredBox(
        color: widget.backgroundColor ?? Theme.of(context).dividerColor,
        child: PageTransitionSwitcher(
          reverse: _previousIndex!=null && _previousIndex!>_currentIndex,
          layoutBuilder: (entries) {
            return Stack(
              alignment: Alignment.topCenter,
              children: entries,
            );
          },
          transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
            return SharedAxisTransition(
              animation: primaryAnimation,
              secondaryAnimation: secondaryAnimation,
              transitionType: SharedAxisTransitionType.horizontal,
              fillColor: Theme.of(context).cardColor,
              child: child,
            );
          },
          child: result,
        ),
      ),
    );
    if (minWidth!=null) {
      result = SliverStickyHeader(
        footer: true,
        stickOffset: 12,
        header: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < minWidth) {
              return Scrollbar(
                controller: overflowScrollController1,
                child: SizedBox(
                  height: 12,
                  child: NotificationRelayer(
                    controller: overflowRelayController,
                    child: Container(),
                  ),
                ),
              );
            } else {
              return SizedBox.shrink();
            }
          },
        ),
        sliver: result,
      );
    }
    final weekdays = _weekDays==null ? null : Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: _timeLineWidth + _hourIndicatorSettings.offset,
            child: _weekNumberBuilder.call(filteredDates[0]),
          ),
          ...List.generate(
            filteredDates.length,
                (index) => Expanded(
              child: _weekDayBuilder(
                filteredDates[index],
              ),
            ),
          )
        ],
      ),
    );
    return SliverStickyHeader.builder(
      // sticky: widget.enableStickyHeaders,
      // stickOffset: widget.stickyOffset,
      builder: (context, state) {
        return _buildHorizontalSwipeGestureDetector(context,
          ColoredBox(
            color: widget.backgroundColor ?? Theme.of(context).cardColor,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Column(
                  children: [
                    _weekHeaderBuilder(_currentStartDate, _currentEndDate),
                    if (weekdays!=null)
                      if (minWidth==null)
                        weekdays
                      else
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return OverflowScroll(
                              scrollController: overflowScrollController1,
                              autoscrollSpeed: null,
                              consumeScrollNotifications: false,
                              opacityGradientSize: 0,
                              child: SizedBox(
                                width: max(minWidth, constraints.maxWidth),
                                child: weekdays,
                              ),
                            );
                          },
                        ),
                  ],
                ),
                AnimatedPositioned(
                  left: 0, right: 0, bottom: -2,
                  height: state.isPinned ? 2 : 0,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  child: const CustomPaint(
                    painter: SimpleShadowPainter(
                      direction: SimpleShadowPainter.down,
                      shadowOpacity: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      sliver: result,
    );
  }

  Widget _buildHorizontalSwipeGestureDetector(BuildContext context, Widget child) {
    return GestureDetector(
      key: child.key,
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity!=null && details.primaryVelocity! > 0) {
          previousPage(); // User swiped Left
        } else if (details.primaryVelocity!=null && details.primaryVelocity! < 0) {
          nextPage(); // User swiped Right
        }
      },
      child: child,
    );
  }

  /// Returns [EventController] associated with this Widget.
  ///
  /// This will throw [AssertionError] if controller is called before its
  /// initialization is complete.
  EventController<T> get controller {
    if (_controller == null) {
      throw "EventController is not initialized yet.";
    }

    return _controller!;
  }

  /// Reloads page.
  void _reload() {
    if (mounted) {
      setState(() {});
    }
  }

  void _setWeekDays() {
    _weekDays = widget.weekDays?.toSet().toList();
    if (_weekDays!=null) {
      if (!widget.showWeekends) {
        _weekDays!
          ..remove(WeekDays.saturday)
          ..remove(WeekDays.sunday);
      }
      assert(
      _weekDays!.isNotEmpty,
      "weekDays can not be empty.\n"
          "Make sure you are providing weekdays in initialization of "
          "WeekView. or showWeekends is true if you are providing only "
          "saturday or sunday in weekDays.");
      _totalDaysInWeek = _weekDays!.length;
    }
  }

  void _updateViewDimensions() {

    _timeLineWidth = widget.timeLineWidth;

    _liveTimeIndicatorSettings = widget.liveTimeIndicatorSettings ??
        HourIndicatorSettings(
          color: Theme.of(context).textTheme.bodyText1!.color!,
          height: widget.heightPerMinute,
          offset: 5,
        );

    assert(_liveTimeIndicatorSettings.height < _hourHeight,
        "liveTimeIndicator height must be less than minuteHeight * 60");

    _hourIndicatorSettings = widget.hourIndicatorSettings ??
        HourIndicatorSettings(
          height: widget.heightPerMinute,
          color: Theme.of(context).dividerTheme.color ?? Theme.of(context).dividerColor,
          offset: 5,
        );

    assert(_hourIndicatorSettings.height < _hourHeight,
        "hourIndicator height must be less than minuteHeight * 60");

  }

  void _calculateHeights() {
    _hourHeight = widget.heightPerMinute * 60;
    _height = _hourHeight * Constants.hoursADay;
  }

  void _assignBuilders() {
    _timeLineBuilder = widget.timeLineBuilder ?? _defaultTimeLineBuilder;
    _eventTileBuilder = widget.eventTileBuilder ?? _defaultEventTileBuilder;
    _weekHeaderBuilder =
        widget.weekPageHeaderBuilder ?? _defaultWeekPageHeaderBuilder;
    _weekDayBuilder = widget.weekDayBuilder ?? _defaultWeekDayBuilder;
    _weekNumberBuilder = widget.weekNumberBuilder ?? _defaultWeekNumberBuilder;
    _fullDayEventBuilder =
        widget.fullDayEventBuilder ?? _defaultFullDayEventBuilder;
  }

  Widget _defaultFullDayEventBuilder(
      List<CalendarEventData<T>> events, DateTime dateTime) {
    return FullDayEventView<T>(
      events: events,
      date: dateTime,
      onEventTap: (event, date) {
        widget.onEventTap?.call([event], date);
      },
      titleStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
      descriptionStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      eventWidgetBuilder: widget.eventWidgetBuilder,
    );
  }

  /// Sets the current date of this month.
  ///
  /// This method is used in initState and onUpdateWidget methods to
  /// regulate current date in Month view.
  ///
  /// If maximum and minimum dates are change then first call _setDateRange
  /// and then _regulateCurrentDate method.
  ///
  void _regulateCurrentDate() {

    DateTime? newWeek;
    if (_currentWeek.isBefore(_minDate)) {
      newWeek = _minDate;
    } else if (_currentWeek.isAfter(_maxDate)) {
      newWeek = _maxDate;
    }
    if (newWeek!=null) {
      jumpToWeek(newWeek);
    }

  }

  /// Sets the minimum and maximum dates for current view.
  void _setDateRange() {
    _minDate = (widget.minDay ?? CalendarConstants.epochDate)
        .firstDayOfWeek(start: widget.startDay)
        .withoutTime;

    _maxDate = (widget.maxDay ?? CalendarConstants.maxDate)
        .lastDayOfWeek(start: widget.startDay)
        .withoutTime;

    assert(
      _minDate.isBefore(_maxDate),
      "Minimum date must be less than maximum date.\n"
      "Provided minimum date: $_minDate, maximum date: $_maxDate",
    );

    _totalWeeks = widget.weekDays==null
        ? _minDate.getDayDifference(_maxDate) + 1
        : _minDate.getWeekDifference(_maxDate, start: widget.startDay) + 1;
  }

  /// Default builder for week line.
  Widget _defaultWeekDayBuilder(DateTime date) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(widget.weekDayStringBuilder?.call(date.weekday - 1) ??
            Constants.weekTitles[date.weekday - 1],
          style: Theme.of(context).textTheme.subtitle2,
        ),
        Text(widget.weekDayDateStringBuilder?.call(date.day) ??
            date.day.toString(),
          style: Theme.of(context).textTheme.subtitle1,
        ),
      ],
    );
  }

  /// Default builder for week number.
  Widget _defaultWeekNumberBuilder(DateTime date) {
    final daysToAdd = DateTime.thursday - date.weekday;
    final thursday = daysToAdd > 0
        ? date.add(Duration(days: daysToAdd))
        : date.subtract(Duration(days: daysToAdd.abs()));
    final weekNumber =
        (thursday.difference(DateTime(thursday.year)).inDays / 7).floor() + 1;
    return Center(
      child: Text("$weekNumber"),
    );
  }

  /// Default timeline builder this builder will be used if
  /// [widget.eventTileBuilder] is null
  ///
  Widget _defaultTimeLineBuilder(DateTime date) {
    final timeLineString = widget.timeLineStringBuilder?.call(date) ??
        "${((date.hour - 1) % 12) + 1} ${date.hour ~/ 12 == 0 ? "am" : "pm"}";
    return Transform.translate(
      offset: Offset(0, -7.5),
      child: Padding(
        padding: const EdgeInsets.only(right: 7.0),
        child: Text(
          timeLineString,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }

  /// Default timeline builder. This builder will be used if
  /// [widget.eventTileBuilder] is null
  /// no arguments are used, but events ???
  Widget _defaultEventTileBuilder(
      DateTime date,
      List<CalendarEventData<T>> events,
      Rect boundary, /// not used
      DateTime startDuration,
      DateTime endDuration) {
    if (events.isNotEmpty) {
      return RoundedEventTile(
        // borderRadius: BorderRadius.circular(6.0),
        title: events[0].title,
        description: events[0].description,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        descriptionStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        totalEvents: events.length,
        padding: EdgeInsets.fromLTRB(4, 6, 6, 6),
        accentColor: events[0].color,
        // backgroundColor: events[0].color,
      );
    } else {
      return Container();
    }
  }

  /// Default view header builder. This builder will be used if
  /// [widget.dayTitleBuilder] is null.
  Widget _defaultWeekPageHeaderBuilder(DateTime startDate, DateTime endDate) {
    return WeekPageHeader(
      startDate: _currentStartDate,
      endDate: _currentEndDate,
      onNextDay: _currentIndex==_totalWeeks-1 ? null : nextPage,
      onPreviousDay: _currentIndex==0 ? null : previousPage,
      onTitleTapped: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: startDate,
          firstDate: _minDate,
          lastDate: _maxDate,
        );

        if (selectedDate == null) return;
        jumpToWeek(selectedDate);
      },
      headerStringBuilder: widget.headerStringBuilder ?? (widget.weekDays==null
          ? (date, {secondaryDate}) {
              final weekday = widget.weekDayStringBuilder?.call(date.weekday - 1)
                  ?? Constants.weekTitles[date.weekday - 1];
              return "$weekday ${date.day}/${date.month}/${date.year}";
            }
          : null),
      headerStyle: widget.headerStyle,
    );
  }

  /// Animate to next page
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  void nextPage({Duration? duration, Curve? curve}) {
    _currentIndex++;
  }

  /// Animate to previous page
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  void previousPage({Duration? duration, Curve? curve}) {
    _currentIndex--;
  }

  /// Jumps to page number [page]
  ///
  ///
  void jumpToPage(int page) => _currentIndex = page;

  /// Animate to page number [page].
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  Future<void> animateToPage(int page,
      {Duration? duration, Curve? curve}) async {
    _currentIndex = page;
  }

  /// Returns current page number.
  int get currentPage => _currentIndex;

  /// Jumps to page which gives day calendar for [week]
  void jumpToWeek(DateTime week) {
    if (week.isBefore(_minDate) || week.isAfter(_maxDate)) {
      throw "Invalid date selected.";
    }
    _currentIndex = widget.weekDays==null
        ? _minDate.getDayDifference(week)
        : _minDate.getWeekDifference(week, start: widget.startDay);
  }

  /// Animate to page which gives day calendar for [week].
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [WeekView.pageTransitionDuration] and [WeekView.pageTransitionCurve]
  /// respectively.
  Future<void> animateToWeek(DateTime week,
      {Duration? duration, Curve? curve}) async {
    jumpToWeek(week);
  }

  /// Returns the current visible week's first date.
  DateTime get currentDate => DateTime(
      _currentStartDate.year, _currentStartDate.month, _currentStartDate.day);

  /// Jumps to page which contains given events and make event
  /// tile visible to user.
  ///
  Future<void> jumpToEvent(CalendarEventData<T> event) async {
    jumpToWeek(event.date);

    await _scrollConfiguration.setScrollEvent(
      event: event,
      duration: Duration.zero,
      curve: Curves.ease,
    );
  }

  /// Animate to page which contains given events and make event
  /// tile visible to user.
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [DayView.pageTransitionDuration] and [DayView.pageTransitionCurve]
  /// respectively.
  ///
  /// Actual duration will be 2 times the given duration.
  ///
  /// Ex, If provided duration is 200 milliseconds then this function will take
  /// 200 milliseconds for animate to page then 200 milliseconds for
  /// scroll to event tile.
  ///
  ///
  Future<void> animateToEvent(CalendarEventData<T> event,
      {Duration? duration, Curve? curve}) async {
    await animateToWeek(event.date, duration: duration, curve: curve);
    await _scrollConfiguration.setScrollEvent(
      event: event,
      duration: duration ?? widget.pageTransitionDuration,
      curve: curve ?? widget.pageTransitionCurve,
    );
  }

  /// check if any dates contains current date or not.
  /// Returns true if it does else false.
  bool _showLiveTimeIndicator(List<DateTime> dates) =>
      dates.any((date) => date.compareWithoutTime(DateTime.now()));
}
