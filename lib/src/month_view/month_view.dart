// Copyright (c) 2021 Simform Solutions. All rights reserved.
// Use of this source code is governed by a MIT-style license
// that can be found in the LICENSE file.

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../calendar_view.dart';
import '../../util/custom_painters.dart';
import '../../util/my_sliver_sticky_header.dart';
import '../calendar_constants.dart';
import '../calendar_controller_provider.dart';
import '../calendar_event_data.dart';
import '../components/components.dart';
import '../components/safe_area_wrapper.dart';
import '../constants.dart';
import '../enumerations.dart';
import '../event_controller.dart';
import '../extensions.dart';
import '../style/header_style.dart';
import '../typedefs.dart';

class MonthView<T extends Object?> extends StatefulWidget {
  /// A function that returns a [Widget] that determines appearance of
  /// each cell in month calendar.
  final CellBuilder<T>? cellBuilder;

  /// Builds month page title.
  ///
  /// Used default title builder if null.
  final DateWidgetBuilder? headerBuilder;

  /// This function will generate DateString in the calendar header.
  /// Useful for I18n
  final StringProvider? headerStringBuilder;

  /// This function will generate DayString in month view cell.
  /// Useful for I18n
  final StringProvider? dateStringBuilder;

  /// This function will generate WeeDayString in weekday view.
  /// Useful for I18n
  /// Ex : ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
  final String Function(int)? weekDayStringBuilder;

  /// Called when user changes month.
  final CalendarPageChangeCallBack? onPageChange;

  /// This function will be called when user taps on month view cell.
  final CellTapCallback<T>? onCellTap;

  /// This function will be called when user will tap on a single event
  /// tile inside a cell.
  ///
  /// This function will only work if [cellBuilder] is null.
  final TileTapCallback<T>? onEventTap;

  /// Builds the name of the weeks.
  ///
  /// Used default week builder if null.
  ///
  /// Here day will range from 0 to 6 starting from Monday to Sunday.
  final WeekDayBuilder? weekDayBuilder;

  /// Determines the lower boundary user can scroll.
  ///
  /// If not provided [CalendarConstants.epochDate] is default.
  final DateTime? minMonth;

  /// Determines upper boundary user can scroll.
  ///
  /// If not provided [CalendarConstants.maxDate] is default.
  final DateTime? maxMonth;

  /// Defines initial display month.
  ///
  /// If not provided [DateTime.now] is default date.
  final DateTime? initialMonth;

  /// Defines whether to show default borders or not.
  ///
  /// Default value is true
  ///
  /// Use [borderSize] to define width of the border and
  /// [borderColor] to define color of the border.
  final bool showBorder;

  /// Defines width of default border
  ///
  /// Default value is [Colors.blue]
  ///
  /// It will take affect only if [showBorder] is set.
  final Color? borderColor;

  /// Page transition duration used when user try to change page using
  /// [MonthView.nextPage] or [MonthView.previousPage]
  final Duration pageTransitionDuration;

  /// Page transition curve used when user try to change page using
  /// [MonthView.nextPage] or [MonthView.previousPage]
  final Curve pageTransitionCurve;

  /// A required parameters that controls events for month view.
  ///
  /// This will auto update month view when user adds events in controller.
  /// This controller will store all the events. And returns events
  /// for particular day.
  ///
  /// If [controller] is null it will take controller from
  /// [CalendarControllerProvider.controller].
  final EventController<T>? controller;

  /// Defines width of default border
  ///
  /// Default value is 1
  ///
  /// It will take affect only if [showBorder] is set.
  final double borderSize;

  /// Defines the minimum height of a cell.
  final double? minCellHeight;

  /// Defines wether the cell will expand beyond the minimum height
  /// if the contents don't fit
  final bool expandCells;

  /// If not null and the width of context is less than minWidth,
  /// a horizontal scrollable will be created
  final double? minWidth;

  /// This method will be called when user long press on calendar.
  final DatePressCallback? onDateLongPress;

  ///   /// Defines the day from which the week starts.
  ///
  /// Default value is [WeekDays.monday].
  final WeekDays startDay;

  /// Style for MontView header.
  final HeaderStyle headerStyle;

  /// Main [Widget] to display month view.
  const MonthView({
    Key? key,
    this.showBorder = true,
    this.borderColor,
    this.cellBuilder,
    this.minMonth,
    this.maxMonth,
    this.controller,
    this.initialMonth,
    this.borderSize = 1,
    this.headerBuilder,
    this.weekDayBuilder,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.pageTransitionCurve = Curves.ease,
    this.onPageChange,
    this.onCellTap,
    this.onEventTap,
    this.onDateLongPress,
    this.startDay = WeekDays.monday,
    this.headerStringBuilder,
    this.dateStringBuilder,
    this.weekDayStringBuilder,
    this.headerStyle = const HeaderStyle(),
    this.minWidth = 800,
    this.expandCells = true,
    this.minCellHeight = 128,
  }) : super(key: key);

  @override
  MonthViewState<T> createState() => MonthViewState<T>();
}

/// State of month view.
class MonthViewState<T extends Object?> extends State<MonthView<T>> {
  late DateTime _minDate;
  late DateTime _maxDate;

  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier(0);
  int get _currentIndex => _currentIndexNotifier.value;
  set _currentIndex(int value) {
    _previousIndex = _currentIndex;
    _currentIndexNotifier.value = value;
  }
  int? _previousIndex;

  DateTime get _currentDate =>
      DateTime(_minDate.year, _minDate.month + _currentIndex);
  // (widget.initialMonth ?? DateTime.now()).withoutTime;

  int _totalMonths = 0;

  late CellBuilder<T> _cellBuilder;

  late WeekDayBuilder _weekBuilder;

  late DateWidgetBuilder _headerBuilder;

  EventController<T>? _controller;

  late VoidCallback _reloadCallback;

  @override
  void initState() {
    super.initState();

    _reloadCallback = _reload;

    _setDateRange();

    _regulateCurrentDate();

    _assignBuilders();

    _currentIndex = _minDate.getMonthDifference(widget.initialMonth??DateTime.now()) - 1;
    _currentIndexNotifier.addListener(() {
      widget.onPageChange?.call(_currentDate, _currentIndex);
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (newController != _controller) {
      _controller = newController;

      _controller!
        // Removes existing callback.
        ..removeListener(_reloadCallback)

        // Reloads the view if there is any change in controller or
        // user adds new events.
        ..addListener(_reloadCallback);
    }
  }

  @override
  void didUpdateWidget(MonthView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update controller.
    final newController = widget.controller ??
        CalendarControllerProvider.of<T>(context).controller;

    if (newController != _controller) {
      _controller?.removeListener(_reloadCallback);
      _controller = newController;
      _controller?.addListener(_reloadCallback);
    }

    // Update date range.
    if (widget.minMonth != oldWidget.minMonth ||
        widget.maxMonth != oldWidget.maxMonth) {
      _setDateRange();
      _regulateCurrentDate();
    }

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
    final date = _currentDate;
    final weekDays = date.datesOfWeek(start: widget.startDay);
    return SliverStickyHeader.builder(
      // sticky: widget.enableStickyHeaders,
      // stickOffset: widget.stickyOffset,
      builder: (context, state) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                _headerBuilder(date),
                Row(
                  children: List.generate(
                    7,
                        (index) => Expanded(
                      child: _weekBuilder(weekDays[index].weekday - 1),
                    ),
                  ),
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
        );
      },
      sliver: SliverToBoxAdapter( // TODO performance: maybe we could build SliverGridView and avoid always laying out all the rows
        child: Container(
          color: DividerTheme.of(context).color ?? Theme.of(context).dividerColor, // hack to reduce the impact of space between cells, caused by flutter low fidelity
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
            child: _MonthPageBuilder<T>(
              key: ValueKey(date.toIso8601String()),
              onCellTap: widget.onCellTap,
              onDateLongPress: widget.onDateLongPress,
              controller: controller,
              borderColor: widget.borderColor,
              borderSize: widget.borderSize,
              cellBuilder: _cellBuilder,
              date: date,
              showBorder: widget.showBorder,
              startDay: widget.startDay,
              minWidth: widget.minWidth,
              expandCells: widget.expandCells,
              minCellHeight: widget.minCellHeight,
            ),
          ),
        ),
      ),
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

  void _reload() {
    if (mounted) {
      setState(() {});
    }
  }

  void _assignBuilders() {
    // Initialize cell builder. Assign default if widget.cellBuilder is null.
    _cellBuilder = widget.cellBuilder ?? _defaultCellBuilder;

    // Initialize week builder. Assign default if widget.weekBuilder is null.
    // This widget will come under header this will display week days.
    _weekBuilder = widget.weekDayBuilder ?? _defaultWeekDayBuilder;

    // Initialize header builder. Assign default if widget.headerBuilder
    // is null.
    //
    // This widget will be displayed on top of the page.
    // from where user can see month and change month.
    _headerBuilder = widget.headerBuilder ?? _defaultHeaderBuilder;
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
    // make sure that _currentDate is between _minDate and _maxDate.
    DateTime? newDate;
    if (_currentDate.isBefore(_minDate)) {
      newDate = _minDate;
    } else if (_currentDate.isAfter(_maxDate)) {
      newDate = _maxDate;
    }
    if (newDate!=null) {
      // Calculate the current index of page view.
      _currentIndex = _minDate.getMonthDifference(newDate) - 1;
    }
  }

  /// Sets the minimum and maximum dates for current view.
  void _setDateRange() {
    // Initialize minimum date.
    _minDate = (widget.minMonth ?? CalendarConstants.epochDate).withoutTime;

    // Initialize maximum date.
    _maxDate = (widget.maxMonth ?? CalendarConstants.maxDate).withoutTime;

    assert(
      _minDate.isBefore(_maxDate),
      "Minimum date should be less than maximum date.\n"
      "Provided minimum date: $_minDate, maximum date: $_maxDate",
    );

    // Get number of months between _minDate and _maxDate.
    // This number will be number of page in page view.
    _totalMonths = _maxDate.getMonthDifference(_minDate);
  }

  /// Default month view header builder
  Widget _defaultHeaderBuilder(DateTime date) {
    return MonthPageHeader(
      onTitleTapped: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: _minDate,
          lastDate: _maxDate,
        );

        if (selectedDate == null) return;
        jumpToMonth(selectedDate);
      },
      onPreviousMonth: _currentIndex==0 ? null : previousPage,
      onNextMonth: _currentIndex==_totalMonths-1 ? null : nextPage,
      date: date,
      dateStringBuilder: widget.headerStringBuilder,
      headerStyle: widget.headerStyle,
    );
  }

  /// Default builder for week line.
  Widget _defaultWeekDayBuilder(int index) {
    return WeekDayTile(
      dayIndex: index,
      weekDayStringBuilder: widget.weekDayStringBuilder,
    );
  }

  /// Default cell builder. Used when [widget.cellBuilder] is null
  Widget _defaultCellBuilder(
      date, List<CalendarEventData<T>> events, isToday, isInMonth) {
    return FilledCell<T>(
      date: date,
      shouldHighlight: isToday,
      // backgroundColor: isInMonth ? white : offWhite,
      events: events,
      onTileTap: widget.onEventTap,
      dateStringBuilder: widget.dateStringBuilder,
    );
  }

  /// Animate to next page
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [MonthView.pageTransitionDuration] and [MonthView.pageTransitionCurve]
  /// respectively.
  void nextPage({Duration? duration, Curve? curve}) {
    _currentIndex++;
  }

  /// Animate to previous page
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [MonthView.pageTransitionDuration] and [MonthView.pageTransitionCurve]
  /// respectively.
  void previousPage({Duration? duration, Curve? curve}) {
    _currentIndex--;
  }

  /// Jumps to page number [page]
  void jumpToPage(int page) {
    _currentIndex = page;
  }

  /// Animate to page number [page].
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [MonthView.pageTransitionDuration] and [MonthView.pageTransitionCurve]
  /// respectively.
  Future<void> animateToPage(int page,
      {Duration? duration, Curve? curve}) async {
    _currentIndex = page;
  }

  /// Returns current page number.
  int get currentPage => _currentIndex;

  /// Jumps to page which gives month calendar for [month]
  void jumpToMonth(DateTime month) {
    if (month.isBefore(_minDate) || month.isAfter(_maxDate)) {
      throw "Invalid date selected.";
    }
    _currentIndex = _minDate.getMonthDifference(month) - 1;
  }

  /// Animate to page which gives month calendar for [month].
  ///
  /// Arguments [duration] and [curve] will override default values provided
  /// as [MonthView.pageTransitionDuration] and [MonthView.pageTransitionCurve]
  /// respectively.
  Future<void> animateToMonth(DateTime month,
      {Duration? duration, Curve? curve}) async {
    if (month.isBefore(_minDate) || month.isAfter(_maxDate)) {
      throw "Invalid date selected.";
    }
    _currentIndex = _minDate.getMonthDifference(month) - 1;
  }

  /// Returns the current visible date in month view.
  DateTime get currentDate => DateTime(_currentDate.year, _currentDate.month);
}

/// A single month page.
class _MonthPageBuilder<T> extends StatelessWidget {
  final bool showBorder;
  final double borderSize;
  final Color? borderColor;
  final CellBuilder<T> cellBuilder;
  final DateTime date;
  final EventController<T> controller;
  final CellTapCallback<T>? onCellTap;
  final DatePressCallback? onDateLongPress;
  final WeekDays startDay;
  final double? minWidth;
  final bool expandCells;
  final double? minCellHeight;

  const _MonthPageBuilder({
    Key? key,
    required this.showBorder,
    required this.borderSize,
    required this.borderColor,
    required this.cellBuilder,
    required this.date,
    required this.controller,
    required this.onCellTap,
    required this.onDateLongPress,
    required this.startDay,
    required this.minWidth,
    required this.expandCells,
    required this.minCellHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final monthDays = date.datesOfMonths(startDay: startDay);
    final month = DateTime(date.year, date.month, 1);
    final startDiff = month.weekday - 1;
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final neededDayCount = startDiff+daysInMonth;
    final neededWeekCount = ((neededDayCount)/7).ceil();
    // final neededItemCount = neededWeekCount * 7;
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      itemCount: neededWeekCount,
      shrinkWrap: true,
      itemBuilder: (context, week) {
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: List.generate(7, (day) {
              final index = week*7 + day;
              final events = controller.getEventsOnDay(monthDays[index]);
              return Expanded(
                child: InkWell(
                  onTap: onCellTap==null ? null
                      : () => onCellTap?.call(events, monthDays[index]),
                  onLongPress: onDateLongPress==null ? null
                      : () => onDateLongPress?.call(monthDays[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      border: showBorder
                          ? Border.all(
                        color: DividerTheme.of(context).color ?? Theme.of(context).dividerColor,
                        width: borderSize,
                      )
                          : null,
                    ),
                    constraints: minCellHeight==null ? null : BoxConstraints(
                      minHeight: 128,
                    ),
                    child: cellBuilder(
                      monthDays[index],
                      events,
                      monthDays[index].compareWithoutTime(DateTime.now()),
                      monthDays[index].month == date.month,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
