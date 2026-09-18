import 'package:drp_date_picker/drp_date_picker.dart';
import 'package:flutter/material.dart';

void main() => runApp(const DrpExampleApp());

class DrpExampleApp extends StatelessWidget {
  const DrpExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'drp_date_picker demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB3352B)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// Sample holidays (BS canonical dates).
final List<DrpHoliday> sampleHolidays = [
  const DrpHoliday(date: BsDate(2082, 1, 1), title: 'Nepali New Year'),
  const DrpHoliday(date: BsDate(2082, 2, 15), title: 'Ropain Jayanti'),
  const DrpHoliday(date: BsDate(2082, 7, 10), title: 'Vijaya Dashami'),
  const DrpHoliday(date: BsDate(2082, 10, 15), title: 'Tihar'),
];

// General calendar events (typed), used alongside holidays.
final List<DrpCalendarEvent> sampleEvents = [
  const DrpCalendarEvent(
    date: BsDate(2082, 2, 15),
    title: 'Office closed',
    type: DrpEventType.event,
  ),
  const DrpCalendarEvent(
    date: BsDate(2082, 2, 28),
    title: 'Salary day',
    type: DrpEventType.deadline,
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('drp_date_picker')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionTitle('Basic BS picker'),
          DrpDatePicker(
            type: DrpPickerType.bs,
            onChanged: (d) => _log('BS', d),
          ),
          const SizedBox(height: 20),

          const _SectionTitle('English (AD) first, with events + holidays'),
          DrpDatePicker(
            type: DrpPickerType.ad,
            events: sampleEvents,
            holidays: sampleHolidays,
            onChanged: (d) => _log('AD', d),
          ),
          const SizedBox(height: 20),

          const _SectionTitle('Devanagari digits + inline'),
          DrpDatePicker(
            digits: DrpDigits.devanagari,
            popupMode: DrpPopupMode.inline,
            holidays: sampleHolidays,
            onChanged: (d) => _log('Devanagari', d),
          ),
          const SizedBox(height: 20),

          const _SectionTitle('Min / max constraints'),
          DrpDatePicker(
            minDate: const BsDate(2082, 2, 1),
            maxDate: const BsDate(2082, 2, 28),
            onChanged: (d) => _log('Constrained', d),
          ),
          const SizedBox(height: 20),

          const _SectionTitle('Form integration'),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DrpDatePickerTextFormField(
                  label: 'Delivery date',
                  validator: (v) => v == null ? 'Please select a date' : null,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Form is valid!')),
                      );
                    }
                  },
                  child: const Text('Validate form'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _log(String label, DrpDate? d) {
    if (d == null) {
      debugPrint('$label: cleared');
      return;
    }
    debugPrint('$label -> BS ${d.bs.iso} | AD ${d.ad.iso}');
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
