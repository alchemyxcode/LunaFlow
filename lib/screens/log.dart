// LunaFlow - Log Screen
// Copyright (C) 2026 alchemyxcode
// Licensed under GNU General Public License v3.0

import 'package:flutter/material.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Today'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 64, color: Color(0xFF7B4F9E)),
            SizedBox(height: 16),
            Text(
              'Cycle & symptom logging',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('Coming soon — Issue #2 & #3'),
          ],
        ),
      ),
    );
  }
}
