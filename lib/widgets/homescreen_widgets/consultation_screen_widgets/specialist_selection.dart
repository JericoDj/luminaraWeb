import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';

class SpecialistSelection extends StatelessWidget {
  final String? selectedService;
  final Function(String) onSelectService;

  const SpecialistSelection({
    Key? key,
    required this.selectedService,
    required this.onSelectService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: GestureDetector(
        onTap: () async {
          final service = await _showServicePicker(context);
          if (service != null) {
            onSelectService(service);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: selectedService == null
                  ? [Colors.black45, Colors.black54]
                  : [MyColors.color1, MyColors.color2],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedService ?? "Select Service",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selectedService == null
                        ? Colors.black45.withAlpha(180)
                        : Colors.black87,
                  ),
                ),
                if (selectedService != null) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      _showServiceDetails(
                        context,
                        selectedService!,
                        _getServiceDescription(selectedService!),
                        _getServiceImage(selectedService!),
                      );
                    },
                    child: Tooltip(
                      message: "Show details",
                      child: const Icon(Icons.info_outline, color: MyColors.color1, size: 22),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<String?> _showServicePicker(BuildContext context) async {
    final List<String> _specialists = [
      "Counseling/Coaching",
      "Psychological Consultation/\nPsychotherapy",//
      "Psychiatric Consultation",
      "Couple Therapy/Counseling",//
      "Family Counselling",
      "Psychological Assessment",
    ];

    return showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListView.builder(
          itemCount: _specialists.length,
          itemBuilder: (context, index) => Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text(
                _specialists[index],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: GestureDetector(
                onTap: () {
                  _showServiceDetails(
                    context,
                    _specialists[index],
                    _getServiceDescription(_specialists[index]),
                    _getServiceImage(_specialists[index]),
                  );
                },
                child: Tooltip(
                  message: "Show details",
                  child: const Icon(Icons.info_outline, color: MyColors.color1, size: 18),
                ),
              ),
              onTap: () => Navigator.of(context).pop(_specialists[index]),
            ),
          ),
        ),
      ),
    );
  }

  String _getServiceDescription(String service) {
    const Map<String, String> _serviceDetails = {
      "Counseling/Coaching":
      "a 40- min to 1-hour session with a counselor/coach facilitating supportive process that helps individuals explore and resolve emotional, psychological, personal or professional concerns",

      "Psychological Consultation/\nPsychotherapy":
      "a 40-min to 1-hour session with a psychologist where you can freely express and discuss your mental health concerns, thoughts and emotions. Recommendations or therapeutic goals will be provided.",

      "Psychiatric Consultation":
      "A psychiatric consultation is a professional session by a psychiatrist to evaluate a person’s mental health, provide a diagnosis, and recommend treatment such as medication, therapy, further testing",

      "Couple Therapy/Counseling":
      "An intervention to help couples build a healthy relationship and resolve conflicts affecting their relationship satisfaction.",

      "Family Counselling":
      "a therapeutic session that involves working with families to address issues affecting their relationships, improve communication, and promote healthier family dynamics",


      "Psychological Assessment":
      "Use of integrative tools such as testing, interviews, and observation, or other assessment tools to understand the client's concerns depending on their needs (e.g., school, employment, diagnosis, legal requirements, emotional support animals).",

    };

    return _serviceDetails[service] ?? "No description available.";
  }

  String _getServiceImage(String service) {
    const Map<String, String> _serviceImages = {
      "Counseling/Coaching": "assets/images/homescreen/Psychotherapy.jpg",

      "Psychological Consultation/\nPsychotherapy": "assets/images/homescreen/Counselling.jpg",

      "Psychiatric Consultation": "assets/images/homescreen/Consultation.jpg",

      "Couple Therapy/Counseling": "assets/images/homescreen/CoupleTherapy.jpg",

      "Family Counselling": "assets/images/homescreen/Counselling.jpg",

      "Psychological Assessment": "assets/images/homescreen/Psychotherapy.jpg",
    };

    return _serviceImages[service] ?? "assets/images/default.png";
  }

  void _showServiceDetails(BuildContext context, String service, String description, String imagePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Column(
          children: [
            Text(
              service,
              style: TextStyle(color: MyColors.color1, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 250,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 80, color: Colors.grey),
              ),
            ),
          ],
        ),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Close", style: TextStyle(color: MyColors.color1, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
