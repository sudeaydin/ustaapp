import 'package:flutter/material.dart';

class TripDateSelector extends StatefulWidget {
  final Function(DateTime?, DateTime?)? onDatesSelected;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const TripDateSelector({
    Key? key,
    this.onDatesSelected,
    this.initialStartDate,
    this.initialEndDate,
  }) : super(key: key);

  @override
  State<TripDateSelector> createState() => _TripDateSelectorState();
}

class _TripDateSelectorState extends State<TripDateSelector> {
  int selectedTab = 0;
  DateTime? startDate;
  DateTime? endDate;

  final List<String> tabs = ['Dates', 'Months', 'Flexible'];
  final List<String> weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate;
    endDate = widget.initialEndDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12.0),
            width: 40.0,
            height: 4.0,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          const SizedBox(height: 20.0),
          // Title
          const Text(
            "When's your trip?",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20.0),
          // Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: tabs.asMap().entries.map((entry) {
                int index = entry.key;
                String tab = entry.value;
                bool isSelected = index == selectedTab;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: 2.0,
                          ),
                        ),
                      ),
                      child: Text(
                        tab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20.0),
          // Content based on selected tab
          if (selectedTab == 0) _buildDatesContent(),
          if (selectedTab == 1) _buildMonthsContent(),
          if (selectedTab == 2) _buildFlexibleContent(),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _buildDatesContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // Week days header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: weekDays.map((day) => 
              Container(
                width: 40.0,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              )
            ).toList(),
          ),
          const SizedBox(height: 12.0),
          // Calendar Grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    int daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    int firstWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        for (int week = 0; week < 6; week++)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int day = 0; day < 7; day++)
                _buildCalendarDay(week, day, firstWeekday, daysInMonth, now),
            ],
          ),
      ],
    );
  }

  Widget _buildCalendarDay(int week, int day, int firstWeekday, int daysInMonth, DateTime now) {
    int dayNumber = week * 7 + day - firstWeekday + 1;
    bool isValidDay = dayNumber > 0 && dayNumber <= daysInMonth;
    bool isToday = isValidDay && dayNumber == now.day;

    return Container(
      width: 40.0,
      height: 40.0,
      margin: const EdgeInsets.all(2.0),
      child: isValidDay
          ? GestureDetector(
              onTap: () {
                DateTime selectedDate = DateTime(now.year, now.month, dayNumber);
                setState(() {
                  if (startDate == null || (startDate != null && endDate != null)) {
                    startDate = selectedDate;
                    endDate = null;
                  } else if (selectedDate.isAfter(startDate!)) {
                    endDate = selectedDate;
                  } else {
                    startDate = selectedDate;
                    endDate = null;
                  }
                });
                widget.onDatesSelected?.call(startDate, endDate);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _getDayColor(DateTime(now.year, now.month, dayNumber)),
                  shape: BoxShape.circle,
                  border: isToday ? Border.all(color: Colors.black, width: 1.0) : null,
                ),
                child: Center(
                  child: Text(
                    dayNumber.toString(),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: _getDayTextColor(DateTime(now.year, now.month, dayNumber)),
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  Color _getDayColor(DateTime date) {
    if (startDate != null && date.isAtSameMomentAs(startDate!)) {
      return Colors.black;
    }
    if (endDate != null && date.isAtSameMomentAs(endDate!)) {
      return Colors.black;
    }
    if (startDate != null && endDate != null &&
        date.isAfter(startDate!) && date.isBefore(endDate!)) {
      return Colors.grey[200]!;
    }
    return Colors.transparent;
  }

  Color _getDayTextColor(DateTime date) {
    if ((startDate != null && date.isAtSameMomentAs(startDate!)) ||
        (endDate != null && date.isAtSameMomentAs(endDate!))) {
      return Colors.white;
    }
    return Colors.black;
  }

  Widget _buildMonthsContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Text(
        'Months view coming soon...',
        style: TextStyle(fontSize: 16.0, color: Colors.grey),
      ),
    );
  }

  Widget _buildFlexibleContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: const Text(
        'Flexible dates coming soon...',
        style: TextStyle(fontSize: 16.0, color: Colors.grey),
      ),
    );
  }
}