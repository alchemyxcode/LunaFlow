// LunaFlow - Insights Screen
// Copyright (C) 2026 alchemyxcode
// Licensed under GNU General Public License v3.0

import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 64, color: Color(0xFF7B4F9E)),
            SizedBox(height: 16),
            Text(
              'AI health insights',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text('Coming soon — Issue #8 & #9'),
          ],
        ),
      ),
    );
  }
}
