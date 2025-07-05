import 'package:flutter/material.dart';

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Access Denied")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // ⬅ Prevents the column from taking full height
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Access expired",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text("Please contact administrator"),
            SizedBox(height: 20),
          ],
        ),
      )
    );
  }
}