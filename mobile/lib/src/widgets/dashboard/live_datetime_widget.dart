// widgets/dashboard/live_datetime_widget.dart
// A live date and time widget that displays the current date and time,
// supporting both Gregorian and Ethiopian calendars with localization.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/utils/date_utils.dart';
import 'package:andalus_smart_pos/src/providers/calendar_provider.dart';
import 'package:andalus_smart_pos/src/providers/language_provider.dart';
import 'package:andalus_smart_pos/src/utils/ethiopian_calendar.dart';
import 'package:intl/intl.dart';

class LiveDateTimeWidget extends ConsumerStatefulWidget {
  const LiveDateTimeWidget({super.key});

  @override
  ConsumerState<LiveDateTimeWidget> createState() => _LiveDateTimeWidgetState();
}

class _LiveDateTimeWidgetState extends ConsumerState<LiveDateTimeWidget> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _getEthiopianDate() {
    final ethDate = EthiopianCalendar.gregorianToEthiopian(_currentTime);
    final isAmharic = ref.read(languageProvider).languageCode == 'am';
    return EthiopianCalendar.formatDate(ethDate, isAmharic ? 'am' : 'en');
  }

  String _getCalendarLabel() {
    final calendarSettings = ref.read(calendarProvider);
    final isAmharic = ref.read(languageProvider).languageCode == 'am';

    if (calendarSettings.calendarType == CalendarType.ethiopian) {
      return isAmharic ? 'ኢትዮጵያዊ ቀን መቁጠሪያ' : 'Ethiopian Calendar';
    } else {
      return isAmharic ? 'ግሪጎርያን ቀን መቁጠሪያ' : 'Gregorian Calendar';
    }
  }

  @override
  Widget build(BuildContext context) {
    final calendarSettings = ref.read(calendarProvider);
    final isAmharic = ref.read(languageProvider).languageCode == 'am';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCalendarLabel(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  calendarSettings.calendarType == CalendarType.ethiopian
                      ? _getEthiopianDate()
                      : AppDateUtils.getCurrentFullDate(context, ref),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm:ss').format(_currentTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                        fontFamily: 'RobotoMono',
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              calendarSettings.calendarType == CalendarType.ethiopian
                  ? 'ETH'
                  : 'GREG',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
