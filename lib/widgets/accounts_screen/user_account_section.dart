import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_storage/get_storage.dart';

class UserAccountSection extends StatefulWidget {
  const UserAccountSection({super.key});

  @override
  _UserAccountSectionState createState() => _UserAccountSectionState();
}

class _UserAccountSectionState extends State<UserAccountSection> {
  final GetStorage _storage = GetStorage();
  String _avatarImage = 'assets/avatars/Avatar5.jpeg'; // Default avatar
  String _userName = "Loading...";
  String _companyName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadCachedAvatar(); // 🔹 Load locally stored avatar first
    _fetchUserData(); // 🔹 Fetch user data from Firestore
  }

  void _loadCachedAvatar() {
    String? savedAvatar = _storage.read("avatar");
    if (savedAvatar != null) {
      setState(() {
        _avatarImage = savedAvatar;
      });
    }
  }

  Future<void> _fetchUserData() async {
    String? userId = _storage.read("uid"); // ✅ Get UID from local storage

    if (userId == null) {
      setState(() {
        _userName = "User not found";
        _companyName = "N/A";
      });
      return;
    }

    try {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print("Firestore: No user found with ID: $userId");
        setState(() {
          _userName = "No User Data";
          _companyName = "N/A";
        });
        return;
      }

      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;

      if (data == null) {
        print("Firestore: User data is null");
        setState(() {
          _userName = "No User Data";
          _companyName = "N/A";
        });
        return;
      }

      print("Firestore Data: $data"); // ✅ Debugging

      // 🔹 Use default avatar if missing
      String avatarPath = data['avatar'] ?? 'assets/avatars/Avatar5.jpeg';

      // 🔹 Save avatar locally to prevent redundant Firebase calls
      _storage.write("avatar", avatarPath);

      setState(() {
        _userName = data['fullName'] ?? "No Name";
        _companyName = data['companyId'] ?? "No Company";
        _avatarImage = avatarPath;
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void _showAvatarDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(child: const Text("Choose Avatar")),
          content: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _avatarOption('assets/avatars/Avatar1.jpeg'),
                _avatarOption('assets/avatars/Avatar2.jpeg'),
                _avatarOption('assets/avatars/Avatar3.jpeg'),
                _avatarOption('assets/avatars/Avatar4.jpeg'),
                _avatarOption('assets/avatars/Avatar5.jpeg'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _avatarOption(String avatarPath) {
    return GestureDetector(
      onTap: () {
        _updateUserAvatar(avatarPath); // ✅ Update Firestore & UI
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: CircleAvatar(
          radius: 36,
          backgroundImage: AssetImage(avatarPath),
        ),
      ),
    );
  }

  Future<void> _updateUserAvatar(String newAvatar) async {
    String? userId = _storage.read("uid");

    if (userId == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        "avatar": newAvatar,
      });

      // 🔹 Save locally to prevent redundant database calls
      _storage.write("avatar", newAvatar);

      setState(() {
        _avatarImage = newAvatar;
      });
    } catch (e) {
      print("Error updating avatar: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showAvatarDialog,
            child: CircleAvatar(
              radius: 36,
              backgroundImage: AssetImage(_avatarImage),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                _companyName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
