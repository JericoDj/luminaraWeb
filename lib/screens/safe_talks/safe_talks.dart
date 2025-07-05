import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/rendering.dart';
import 'package:profanity_filter/profanity_filter.dart';

import '../../utils/constants/colors.dart';
import '../../utils/storage/user_storage.dart';

class SafeSpaceScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const SafeSpaceScreen({Key? key, this.onBackToHome}) : super(key: key);

  @override
  _SafeSpaceScreenState createState() => _SafeSpaceScreenState();
}

class _SafeSpaceScreenState extends State<SafeSpaceScreen> {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _hasAgreedToEULA = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProfanityFilter _profanityFilter = ProfanityFilter.filterAdditionally([
    'tanga', 'gago', 'ulol', 'putangina', 'bwisit', 'lintik', 'bobo', 'siraulo',
    'tarantado', 'leche', 'punyeta', 'hayop', 'dede', 'mamatay', 'death', 'die',
    'kill', 'pussy', 'fuck', 'fucking', 'asshole', 'bitch', 'whore', 'slut',
    'shit', 'crap', 'dick', 'cock', 'nipple', 'nudes', 'patay', 'patayin', 'pakyu',
    'pakyu', 'hindot', 'kantot', 'libog', 'jakol', 'jakulan', 'burat', 'pekpek',
    'titi', 'tite', 'inutil', 'lapastangan', 'maniac', 'molest', 'rape', 'sumbong',
    'sampalin', 'sapakin', 'sampal', 'bugbog', 'baril', 'barilin', 'bomb', 'terorista',
    'terorismo', 'terrorist', 'terrorism', 'drugs', 'droga', 'adik', 'adiktus',
    'snort', 'sniff', 'high', 'malibog', 'malandi', 'malaswa', 'hubad', 'huthot',
    'sipsip', 'suso', 'pwet', 'pwet', 'ipis', 'hayop ka', 'animal ka', 'demonic',
    'satanic', 'satanas', 'demonyo', 'peste', 'gunggong', 'hindot ka', 'putcha',
    'kupal', 'yawa', 'yawa ka', 'pisti', 'pisot', 'supot', 'abnoy', 'abnormal',
    'ugok', 'buwisit', 'walang hiya', 'walang kwenta', 'walang silbi', 'tangina mo', 'tirahin', 'fucker', 'pornstar', 'puta','idiot'
  ]);

  final UserStorage _userStorage = UserStorage(); // Instantiate UserStorage here



  List<Map<String, dynamic>> _approvedPosts = [];
  List<Map<String, dynamic>> _pendingPosts = [];
  List<Map<String, dynamic>> _myPosts = [];
  @override
  void initState() {
    super.initState();

    _fetchPosts();

    _showKeepItCleanDialog();
  }

  void _fetchPosts() async {
    final String? username = _userStorage.getUsername();
    final String? currentUserId = _auth.currentUser?.uid;
    if (username == null || currentUserId == null) return;

    // Fetch blocked user IDs
    final blockedSnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .get();

    final blockedUserIds = blockedSnapshot.docs.map((doc) => doc.id).toSet();

    _firestore
        .collection('safeSpace')
        .doc('posts')
        .collection('userPosts')
        .snapshots()
        .listen((snapshot) {
      List<Map<String, dynamic>> approved = [];
      List<Map<String, dynamic>> pending = [];
      List<Map<String, dynamic>> myPosts = [];

      for (var doc in snapshot.docs) {
        var postData = doc.data();
        postData['id'] = doc.id;
        postData['comments'] ??= [];

        if (blockedUserIds.contains(postData["userId"])) continue;

        // Only add user's own pending posts
        if (postData["status"] == "pending" && postData["userId"] == currentUserId) {
          pending.add(postData);
        } else if (postData["status"] == "approved") {
          approved.add(postData);
        }

        if (postData["userId"] == currentUserId) {
          myPosts.add(postData);
        }
      }

      setState(() {
        _approvedPosts = approved;
        _pendingPosts = pending;
        _myPosts = myPosts;
      });
    });
  }



  // ────────────────────────────────────────────────
  // 📌 SUBMIT A NEW POST
  // ────────────────────────────────────────────────
  void _submitPost(String content) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // 🚫 Check for bad words
    if (_profanityFilter.hasProfanity(content)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Your post contains inappropriate language. Please revise it."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Don't proceed with posting
    }

    String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    String? username = _userStorage.getUsername();
    if (username == null || username.isEmpty) {
      username = "Anonymous";
    }

    Map<String, dynamic> post = {
      "userId": uid,
      "username": username,
      "time": now,
      "content": content,
      "likes": [],
      "comments": [],
      "status": "pending",
    };

    try {
      DocumentReference docRef = await _firestore
          .collection('safeSpace')
          .doc('posts')
          .collection('userPosts')
          .add(post);

      print('Post submitted successfully with ID: ${docRef.id}');
    } catch (e) {
      print('Error submitting post: $e');
    }
  }




  // ────────────────────────────────────────────────
// 📌 LIKE A POST
// ────────────────────────────────────────────────
  void _likePost(String postId, List<dynamic> currentLikes) async {
    String? uid = _auth.currentUser?.uid; // Get the UID of the logged-in user
    if (uid == null) return; // If no UID, exit early

    DocumentReference postRef = _firestore
        .collection('safeSpace')
        .doc('posts')
        .collection('userPosts')
        .doc(postId);

    if (currentLikes.contains(uid)) {
      // If the user has already liked, remove their UID
      await postRef.update({
        "likes": FieldValue.arrayRemove([uid]) // Remove the UID from likes array
      });
    } else {
      // If the user hasn't liked, add their UID
      await postRef.update({
        "likes": FieldValue.arrayUnion([uid]) // Add the UID to likes array
      });
    }
  }


  void _showKeepItCleanDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _buildKeepItCleanDialog(context),
      );
    });
  }

  Widget _buildKeepItCleanDialog(BuildContext context) {
    bool hasAgreedToEULA = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text(
            "Welcome to Safe Community!",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: MyColors.color1,
              fontSize: 20,
            ),
          ),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.60,
            child: Column(
              children: [
                Text(
                  textAlign: TextAlign.start,
                  "All together, let's create a warm and supportive mental health community.\n\n"
                      "Share your thoughts, helpful quotes, and motivational words to help inspire and luminara fellow community members. "
                      "Let's cultivate a space where we can all feel safe, heard, and understood.\n",
                  style: TextStyle(fontSize: 14),
                ),
                Container(
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: ScrollbarTheme(
                    data: ScrollbarThemeData(
                      thumbColor: MaterialStateProperty.all(MyColors.color2),
                      thickness: MaterialStateProperty.all(6),
                      radius: const Radius.circular(10),
                    ),
                    child: Scrollbar(
                      thumbVisibility: true,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Community Rules:",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: MyColors.color1,
                                ),
                              ),
                              const SizedBox(height: 10),
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                  children: [
                                    TextSpan(
                                      text: "1. Respect Everyone: ",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: "No cursing, malicious words, or hurtful language...\n\n"),
                                    TextSpan(
                                      text: "2. Be Supportive: ",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: "Offer advice with empathy...\n\n"),
                                    TextSpan(
                                      text: "3. Stay Positive: ",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: "Share uplifting content...\n\n"),
                                    TextSpan(
                                      text: "4. Privacy Matters: ",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: "Don't share personal info...\n\n"),
                                    TextSpan(
                                      text: "5. Be Mindful of Triggers: ",
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: "Be considerate of others’ emotions...\n\n"),
                                  ],
                                ),
                              ),
                              const Text(
                                "Let's keep this space a sanctuary where everyone can express themselves freely and safely. Thank you for being a part of Safe Talk!",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: hasAgreedToEULA,
                      onChanged: (value) {
                        setState(() {
                          hasAgreedToEULA = value ?? false;
                        });
                      },
                      activeColor: MyColors.color2,           // Color of the checkbox when checked
                      checkColor: Colors.white,               // Color of the tick inside the checkbox
                      fillColor: MaterialStateProperty.resolveWith<Color>(
                            (states) {
                          if (states.contains(MaterialState.selected)) {
                            return MyColors.color2;           // Filled background color when checked
                          }
                          return Colors.grey.shade300;        // Background when unchecked
                        },
                      ),
                    ),

                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showEulaDialog(context),
                        child: Text(
                          "I agree to the EULA and Community Guidelines.",
                          style: TextStyle(
                            fontSize: 13,
                            color: MyColors.color1, // optional: make it look tappable
                            decoration: TextDecoration.underline, // optional: underline for clarity
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  widget.onBackToHome?.call();
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Back to Home",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: hasAgreedToEULA ? () => Navigator.pop(context) : null,
                child: Container(
                  decoration: BoxDecoration(
                    color: hasAgreedToEULA ? MyColors.color2 : Colors.grey.shade400,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "Agree",
                      style: TextStyle(
                        fontSize: 16,
                        color: MyColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEulaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          title: Text(
            "EULA & Community Guidelines",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MyColors.color1,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "End User License Agreement (EULA):\n",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "By using Luminara, you agree not to post or promote any abusive, harmful, or objectionable content. "
                      "You are responsible for the content you share and must comply with community rules. "
                      "We reserve the right to remove content and suspend users who violate our terms.\n",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 10),
                Text(
                  "Community Guidelines:\n",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "1. Be respectful.\n"
                      "2. Avoid sharing personal data of others.\n"
                      "3. Use uplifting and constructive language.\n"
                      "4. Report any abusive behavior immediately.\n"
                      "5. Remember this is a safe space for everyone.\n",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: MyColors.color2,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    "Close",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

          ],
        );
      },
    );
  }






  void _cancelPendingPost(String postId) async {
    try {
      await _firestore
          .collection('safeSpace')
          .doc('posts')
          .collection('userPosts')
          .doc(postId)
          .delete();

      print("Pending post deleted: $postId");
    } catch (e) {
      print("Error deleting pending post: $e");
    }
  }

  void _deleteMyPost(String postId) async {
    try {
      await _firestore
          .collection('safeSpace')
          .doc('posts')
          .collection('userPosts')
          .doc(postId)
          .delete();

      print("Post deleted: $postId");
    } catch (e) {
      print("Error deleting post: $e");
    }
  }




  void openCommentsModal(int index, bool isPending, bool isMyPost) {
    String? username = _userStorage.getUsername(); // Get username from local storage
    if (username == null) return;

    // 🔹 Get correct list of comments
    List<dynamic> comments = isMyPost
        ? _myPosts[index]["comments"] ?? []
        : isPending
        ? _pendingPosts[index]["comments"] ?? []
        : _approvedPosts[index]["comments"] ?? [];

    TextEditingController commentController = TextEditingController();
    int _visibleComments = 7;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🔹 Title and Close Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Comments",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),

                  // 🔹 Comments List
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                            _visibleComments < comments.length) {
                          setState(() {
                            _visibleComments += 7;
                          });
                        }
                        return true;
                      },
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _visibleComments <= comments.length
                            ? _visibleComments + 1
                            : comments.length + 1,
                        itemBuilder: (context, index) {
                          if (index >= comments.length) {
                            return _visibleComments < comments.length
                                ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _visibleComments += 7;
                                    });
                                  },
                                  child: Text(
                                    "Load more",
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                              ),
                            )
                                : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  "End of comments",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            );
                          }

                          // 🔹 Display comment
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage('assets/avatars/Avatar1.jpeg'),
                            ),
                            title: Text(comments[index]["username"] ?? "Unknown"), // Use username
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comments[index]["comment"] ?? ""),
                                Text(
                                  comments[index]["time"] ?? "",
                                  style: TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == "Report") {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Comment reported.")),
                                  );
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(value: "Report", child: Text("Report Comment")),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // 🔹 Input Field for New Comment
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: "Add a comment...",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),

                        // 🔹 Add Comment Button
                        IconButton(
                          icon: Icon(Icons.send, color: MyColors.color2),
                          onPressed: () {
                            String commentText = commentController.text.trim();

                            if (commentText.isEmpty) return;

                            // 🚫 Profanity check
                            if (_profanityFilter.hasProfanity(commentText)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  behavior: SnackBarBehavior.floating,

                                  margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                  content: Text("Your comment contains inappropriate language. Please revise it."),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                              return;
                            }

                            // ✅ Only proceed if clean
                            _addComment(
                              postId: _approvedPosts[index]["id"],
                              comment: commentText,
                            );

                            setState(() {
                              comments.insert(0, {
                                "username": username,
                                "time": DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
                                "comment": commentText,
                              });
                            });

                            commentController.clear();
                          },
                        )



                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }


  void _addComment({required String postId, required String comment}) async {
    String? username = _userStorage.getUsername(); // Get username from local storage
    if (username == null) return;

    // 🚫 Check for profanity before proceeding
    if (_profanityFilter.hasProfanity(comment)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Your comment contains inappropriate language. Please revise it."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    Map<String, dynamic> newComment = {
      "username": username, // Use username instead of uid
      "time": now,
      "comment": comment,
    };

    try {
      await _firestore
          .collection('safeSpace')
          .doc('posts')
          .collection('userPosts')
          .doc(postId)
          .update({
        "comments": FieldValue.arrayUnion([newComment]),
      });

      print("Comment added: $comment");
    } catch (e) {
      print("Error adding comment: $e");
    }
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const SizedBox(height: 10),

              const TabBar(
                labelColor: MyColors.color1,
                unselectedLabelColor: Colors.black54,
                indicatorColor: MyColors.color2,
                tabs: [
                  Tab(text: "Feed"),
                  Tab(text: "My Posts"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildPostFeed(),
                    _buildMyPostsFeed(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildPostFeed() {
    return ListView(
      children: [
        _buildPostInput(),
        ..._pendingPosts.map((post) => buildPostItem(post, true, false)),
        ..._approvedPosts.map((post) => buildPostItem(post, false, false)),
      ],
    );
  }

  Widget _buildMyPostsFeed() {
    return ListView(
      children: [
        ..._myPosts.map((post) => buildPostItem(
          post,
          post["status"] == "pending", // 🔹 Properly checking "status" instead of "pending"
          true,
        )),
      ],
    );
  }

  Widget _buildPostInput() {
    TextEditingController _postController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          const CircleAvatar(backgroundImage: AssetImage('assets/avatars/Avatar5.jpeg')),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _postController,
              decoration: const InputDecoration(
                hintText: "What's new?",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.send, color: MyColors.color2),
            onPressed: () {
              if (_postController.text.isNotEmpty) {
                _submitPost(_postController.text);
                _postController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildPostItem(Map<String, dynamic> post, bool pending, bool isMyPost) {
    String? username = post["username"]; // Use username from the post data

    // 🔹 Ensure "likes" is always a list
    List<dynamic> likes = (post["likes"] is List) ? post["likes"] : [];

    bool hasLiked = likes.contains(username); // ✅ Check if user has already liked using username

    return Card(
      elevation: 10,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: pending ? Colors.grey.shade300 : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: const CircleAvatar(backgroundImage: AssetImage('assets/avatars/Avatar1.jpeg')),
                title: Text(username ?? "Anonymous"), // Display username instead of uid
                subtitle: Text(post["time"] ?? "Unknown time"),
                trailing: (post["userId"] != _auth.currentUser?.uid)
                    ? PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == "ReportPost") {
                      _reportPost(
                        post["id"],
                        post["content"],
                        post["userId"],
                        post["username"],
                      );
                    } else if (value == "ReportUser") {
                      _reportUser(post["userId"], post["username"]);
                    } else if (value == "BlockUser") {
                      _blockUser(post["userId"], post["username"]);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "ReportPost", child: Text("Report Post")),
                    const PopupMenuItem(value: "ReportUser", child: Text("Report User")),
                    const PopupMenuItem(value: "BlockUser", child: Text("Block User")),
                  ],
                )
                    : null,

              ),
              Text(post["content"] ?? ""),
              if (pending)
                const Text("Pending Approval", style: TextStyle(color: Colors.redAccent)),
              const SizedBox(height: 10),
              Row(
                children: [
                  // 🔹 Like Button with Toggle Feature
                  IconButton(
                    icon: Icon(
                      hasLiked ? Icons.favorite : Icons.favorite_border,
                      color: hasLiked ? Colors.red : null, // ✅ Highlight if liked
                    ),
                    onPressed: () => _likePost(post["id"] ?? "", likes),
                  ),
                  Text(likes.length.toString()), // ✅ Show total likes

                  // 🔹 Comments Section
                  IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () => openCommentsModal(
                      isMyPost ? _myPosts.indexOf(post) : pending ? _pendingPosts.indexOf(post) : _approvedPosts.indexOf(post),
                      pending,
                      isMyPost,
                    ),
                  ),
                  Text((post["comments"] ?? []).length.toString()),

                  // 🔹 Delete (if it's my post)
                  if (isMyPost)
                    TextButton(
                      onPressed: () => _deleteMyPost(post["id"]),
                      child: const Text("Delete"),
                    ),

                  // 🔹 Cancel (only for pending posts)
                  if (pending && isMyPost)
                    TextButton(
                      onPressed: () => _cancelPendingPost(post["id"]),
                      child: const Text("Cancel"),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _blockUser(String? userIdToBlock, String? usernameToBlock) async {
    String? currentUserId = _auth.currentUser?.uid;

    if (currentUserId == null || userIdToBlock == null || usernameToBlock == null) return;

    try {
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blockedUsers')
          .doc(userIdToBlock)
          .set({
        "blockedUserId": userIdToBlock,
        "blockedUsername": usernameToBlock,
        "blockedAt": now,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User has been blocked."),
          backgroundColor: Colors.deepOrange,
        ),
      );

      _fetchPosts(); // ✅ Refresh post list to hide blocked user's content

    } catch (e) {
      print("Error blocking user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to block user."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }


  void _reportPost(String? postId, String? content, String? userId, String? username) async {
    if (postId == null || content == null || userId == null || username == null) return;

    try {
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final reporterUsername = _userStorage.getUsername() ?? 'Anonymous';

      await _firestore.collection('reports').doc('posts').collection('postReports').add({
        'reportedPostId': postId,
        'reportedContent': content,
        'reportedUserId': userId,
        'reportedUsername': username,
        'reportedAt': now,
        'reporter': reporterUsername,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Post reported successfully."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    } catch (e) {
      print("Error reporting post: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to report post."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }


  void _reportUser(String? userId, String? username) async {
    if (userId == null || username == null) return;

    try {
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final reporterUsername = _userStorage.getUsername() ?? 'Anonymous';

      await _firestore.collection('reports').doc('users').collection('userReports').add({
        'reportedUserId': userId,
        'reportedUsername': username,
        'reportedAt': now,
        'reporter': reporterUsername,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User reported successfully."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
    } catch (e) {
      print("Error reporting user: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to report user."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

}
