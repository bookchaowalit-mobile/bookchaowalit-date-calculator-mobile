import 'package:flutter/material.dart';

import '../logic/date_math.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.today});

  /// Injectable "today" for deterministic tests.
  final DateTime? today;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _start;
  late DateTime _end;
  late DateTime _base;
  final _offsetController = TextEditingController(text: '30');

  @override
  void initState() {
    super.initState();
    final now = widget.today ?? DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _start = today;
    _end = addDays(today, 30);
    _base = today;
  }

  @override
  void dispose() {
    _offsetController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pick(DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final diff = difference(_start, _end);
    final offset = parseDayOffset(_offsetController.text);

    return Scaffold(
      appBar: AppBar(title: const Text('Date Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Days between dates', style: textTheme.titleMedium),
          _DateTile(
            label: 'Start',
            date: _start,
            onTap: () async {
              final picked = await _pick(_start);
              if (picked != null) setState(() => _start = picked);
            },
          ),
          _DateTile(
            label: 'End',
            date: _end,
            onTap: () async {
              final picked = await _pick(_end);
              if (picked != null) setState(() => _end = picked);
            },
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${diff.totalDays} days',
                    key: const Key('total-days'),
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text('${diff.weeks} weeks and ${diff.remainderDays} days'),
                  Text(diff.calendarLabel),
                  Text('${diff.businessDays} business days (Mon–Fri)'),
                  if (diff.isNegative)
                    const Text('The end date is before the start date.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Add or subtract days', style: textTheme.titleMedium),
          _DateTile(
            label: 'From',
            date: _base,
            onTap: () async {
              final picked = await _pick(_base);
              if (picked != null) setState(() => _base = picked);
            },
          ),
          TextField(
            key: const Key('offset-input'),
            controller: _offsetController,
            keyboardType: const TextInputType.numberWithOptions(signed: true),
            decoration: InputDecoration(
              labelText: 'Days (use a minus sign to subtract)',
              border: const OutlineInputBorder(),
              errorText: offset == null
                  ? 'Enter a whole number between -$maxDayOffset '
                      'and $maxDayOffset'
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          if (offset != null)
            Semantics(
              liveRegion: true,
              label: 'Result date',
              child: Text(
                formatDate(addDays(_base, offset)),
                key: const Key('offset-result'),
                style: textTheme.titleLarge,
              ),
            ),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event),
      title: Text(label),
      subtitle: Text(formatDate(date)),
      trailing: const Icon(Icons.edit_calendar),
      onTap: onTap,
    );
  }
}
