import 'package:flutter/material.dart';

class CustomerSupportQueueScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Static number of people waiting in the queue
    int numberOfPeopleInQueue = 5; // You can adjust this static number as needed

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Support Queue"),
        backgroundColor: Colors.greenAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 30),
            const Text(
              "You are now lined up in the queue.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "There are currently $numberOfPeopleInQueue people ahead of you.",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              "Our support team will be with you shortly. Please remain on this screen while waiting for assistance.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Go back to the previous screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text(
                "Cancel Request",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
