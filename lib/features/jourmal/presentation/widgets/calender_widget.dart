import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gratitude_diary/core/theme/apptheme.dart';
import 'package:gratitude_diary/services/notifiers/calender_notifiers.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalenderWidget extends ConsumerWidget {
  const CalenderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calenderDataState = ref.watch(calenderNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Builder(builder: (context) {
        if (calenderDataState is CalenderDataLoading ||
            calenderDataState is CalenderDataInitial) {
          return const Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (calenderDataState is CalenderDataError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(calenderDataState.message),
            ),
          );
        } else if (calenderDataState is CalenderDataLoaded) {
          return TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 30)),
            focusedDay: DateTime.now(),
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                final text = DateFormat.E().format(day);
                return Center(
                  child: Text(
                    text,
                    style: AppTheme.theme.textTheme.bodySmall,
                  ),
                );
              },
              defaultBuilder: (context, day, focusedDay) {
                return Center(
                  child: Text(
                    day.day.toString(),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppTheme.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.all(10.0),
                  child: Text(
                    day.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Container(
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppTheme.mainColor,
                    shape: BoxShape.circle,
                  ),
                  margin: const EdgeInsets.all(10.0),
                  child: Text(
                    day.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
              markerBuilder: (context, day, events) {
                if (calenderDataState.datesWithEntries
                    .contains(DateFormat('yyyy-MM-dd').format(day))) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.mainColor,
                      shape: BoxShape.circle,
                    ),
                    margin: const EdgeInsets.all(2.0),
                    width: 5.0,
                    height: 5.0,
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          );
        }

        return const SizedBox();
      }),
    );
  }
}
