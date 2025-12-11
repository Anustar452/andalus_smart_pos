// widgets/common/date_range_picker.dart
// A date range picker widget that supports both Gregorian and Ethiopian calendars,
// allowing users to select a date range with proper formatting and validation.åå
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:andalus_smart_pos/src/providers/calendar_provider.dart';
import 'package:andalus_smart_pos/src/utils/ethiopian_calendar.dart';

class ProfessionalDateRangePicker extends ConsumerWidget {
  final DateTimeRange? initialDateRange;
  final Function(DateTimeRange) onDateRangeSelected;
  final String? title;

  const ProfessionalDateRangePicker({
    super.key,
    this.initialDateRange,
    required this.onDateRangeSelected,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calendarSettings = ref.watch(calendarProvider);

    Future<void> _selectDateRange(BuildContext context) async {
      final DateTimeRange? picked = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        currentDate: DateTime.now(),
        saveText: 'Apply',
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).colorScheme.primary,
                onPrimary: Colors.white,
                surface: Theme.of(context).cardColor,
                onSurface: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null) {
        onDateRangeSelected(picked);
      }
    }

    String _formatSingleDate(DateTime date, CalendarType calendarType) {
      if (calendarType == CalendarType.ethiopian) {
        final ethDate = EthiopianCalendar.gregorianToEthiopian(date);
        return '${ethDate.day}/${ethDate.month}/${ethDate.year}';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    }

    String _formatDateRange(DateTimeRange range) {
      final start =
          _formatSingleDate(range.start, calendarSettings.calendarType);
      final end = _formatSingleDate(range.end, calendarSettings.calendarType);
      return '$start - $end';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              initialDateRange != null
                  ? _formatDateRange(initialDateRange!)
                  : 'Select Date Range',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: const Icon(Icons.arrow_drop_down),
            onTap: () => _selectDateRange(context),
          ),
        ),
      ],
    );
  }
}
