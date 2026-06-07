// LunaFlow - Calendar Screen
// Copyright (C) 2026 alchemyxcode
// Licensed under GNU General Public License v3.0

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/database_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _periodDays = {};
  Map<DateTime, Map<String, dynamic>> _logDays = {};
  Map<String, dynamic>? _selectedDayLog;
  List<String>? _selectedDaySymptoms;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final cycles = await DatabaseService.instance.getAllCycles();
      final logs = await DatabaseService.instance.getAllLogs();

      final Map<DateTime, List<String>> periodDays = {};
      final Map<DateTime, Map<String, dynamic>> logDays = {};

      for (final cycle in cycles) {
        final startDate = DateTime.parse(cycle['start_date']);
        final normalized = _normalizeDate(startDate);
        periodDays[normalized] = ['period'];
      }

      for (final log in logs) {
        final logDate = DateTime.parse(log['date']);
        final normalized = _normalizeDate(logDate);
        logDays[normalized] = log;
      }

      setState(() {
        _periodDays = periodDays;
        _logDays = logDays;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    final normalized = _normalizeDate(selectedDay);
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedDayLog = _logDays[normalized];
      _selectedDaySymptoms = null;
    });

    if (_selectedDayLog != null) {
      final symptoms = await DatabaseService.instance
          .getSymptomsForLog(_selectedDayLog!['id'] as int);
      setState(() {
        _selectedDaySymptoms = symptoms;
      });
    }
  }

  Widget _buildDayDetail() {
    if (_selectedDay == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Tap a day to see details'),
        ),
      );
    }

    final normalized = _normalizeDate(_selectedDay!);
    final isPeriodDay = _periodDays.containsKey(normalized);
    final log = _selectedDayLog;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (isPeriodDay) ...[
              const Row(
                children: [
                  Icon(Icons.water_drop, color: Color(0xFF7B4F9E), size: 16),
                  SizedBox(width: 8),
                  Text('Period logged'),
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (log != null) ...[
              if (log['flow_intensity'] != null)
                _detailRow('Flow', log['flow_intensity']),
              if (log['flow_colour'] != null)
                _detailRow('Colour', log['flow_colour']),
              if (log['mood'] != null)
                _detailRow('Mood', log['mood']),
              if (log['libido'] != null)
                _detailRow('Sex Drive', log['libido']),
              if (log['energy_level'] != null)
                _detailRow('Energy', '${log['energy_level']}/5'),
              if (log['sleep_hours'] != null)
                _detailRow('Sleep', '${log['sleep_hours']}h'),
              if (_selectedDaySymptoms != null &&
                  _selectedDaySymptoms!.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Text('Symptoms:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: _selectedDaySymptoms!
                      .map((s) => Chip(
                            label: Text(s, style: const TextStyle(fontSize: 12)),
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
              ],
              if (log['notes'] != null && log['notes'].isNotEmpty)
                _detailRow('Notes', log['notes']),
            ] else if (!isPeriodDay) ...[
              const Text('No entry for this day'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime(2020),
                    lastDay: DateTime(2030),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
                    onDaySelected: _onDaySelected,
                    calendarStyle: CalendarStyle(
                      selectedDecoration: const BoxDecoration(
                        color: Color(0xFF7B4F9E),
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: const Color(0xFF7B4F9E).withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: const BoxDecoration(
                        color: Color(0xFF7B4F9E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        final normalized = _normalizeDate(day);
                        final isPeriod = _periodDays.containsKey(normalized);
                        final hasLog = _logDays.containsKey(normalized);

                        if (isPeriod) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF7B4F9E),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${day.day}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }

                        if (hasLog) {
                          return Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF7B4F9E),
                                width: 1.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('${day.day}'),
                            ),
                          );
                        }

                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Color(0xFF7B4F9E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('Period'),
                        const SizedBox(width: 16),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF7B4F9E),
                              width: 1.5,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text('Log entry'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildDayDetail(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
