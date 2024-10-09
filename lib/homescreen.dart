import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proddyfi/profilescreen.dart';
import 'package:change_case/change_case.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> category = ['Development', 'AI', 'Embedded', 'Robotics'];
  String userID = "";

  @override
  void initState() {
    super.initState();
    getUserID();
  }

  void getUserID() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userID = user.uid;
      });
    }
  }

  // Stream to fetch projects excluding user
  Stream<List<DocumentSnapshot>> fetchProjectsExcludingUserStream(String userId) async* {
    final QuerySnapshot projectsSnapshot = await FirebaseFirestore.instance.collection('projects').get();
    List<DocumentSnapshot> filteredProjects = [];

    for (var project in projectsSnapshot.docs) {
      QuerySnapshot contributorsSnapshot = await project.reference.collection('contributors').get();
      bool isContributor = contributorsSnapshot.docs.any((doc) => doc.id == userId);
      if (!isContributor) {
        filteredProjects.add(project);
      }
    }

    yield filteredProjects;
  }

  // Check if request already exists
  Stream<QuerySnapshot> getNotificationsStream(String projectID, String senderID, String receiverID) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('projectId', isEqualTo: projectID)
        .where('senderId', isEqualTo: senderID)
        .where('receiverId', isEqualTo: receiverID)
        .snapshots();
  }

  // Send a join request
  void sendJoinRequest(String projectId, String creatorId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('notifications').add({
        'type': 'join_request',
        'senderId': user.uid,
        'receiverId': creatorId,
        'projectId': projectId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Header Section
            Container(
              padding: const EdgeInsets.only(
                bottom: 30,
              ),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const ProfileScreen()),
                            );
                          },
                          icon: const Icon(Icons.account_circle_rounded),
                          color: Colors.black,
                          iconSize: 35,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            'CrewConnect',
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 12,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      "Make your own crew..",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            // Category Section
            Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                "Find by Category",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  for (String cate in category)
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(80),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 7), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Image.asset('images/$cate.jpg'),
                          ),
                          Container(
                            margin: const EdgeInsets.all(8),
                            child: Text(
                              cate,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            // Projects Section
            Container(
              margin: const EdgeInsets.all(10),
              child: Text(
                "All Projects",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ),
            StreamBuilder<List<DocumentSnapshot>>(
              stream: fetchProjectsExcludingUserStream(userID),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 200,
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Projects Found'));
                }

                return ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: snapshot.data!.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    String projectID = document.id ?? 'No Project found';
                    String title = data['title'] ?? 'No Title';
                    String creatorId = data['created_by'] ?? 'Error finding creator';

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(creatorId).get(),
                      builder: (context, creatorSnapshot) {
                        if (creatorSnapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 200,
                            color: Colors.deepPurple[50],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        if (creatorSnapshot.hasError) {
                          return const Center(child: Text('Error loading project data'));
                        }
                        if (!creatorSnapshot.hasData || !creatorSnapshot.data!.exists) {
                          return const Center(child: Text('Project data not found'));
                        }
                        Map<String, dynamic> creatorData = creatorSnapshot.data!.data()! as Map<String, dynamic>;
                        String creatorName = creatorData['username'] ?? 'No username';
                        return Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.yellow,

                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    child: IconButton(

                                      icon: Icon(
                                        Icons.code,

                                      ),
                                      onPressed: (){

                                      },
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Container(
                                    child: IconButton(

                                      icon: Icon(
                                        Icons.create,

                                      ),
                                      onPressed: (){

                                      },
                                    ),
                                  ),
                                  Container(
                                    child: Text(creatorName.toCapitalCase(),
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                    ),

                                  ),
                                ],
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: getNotificationsStream(projectID, userID, creatorId),
                                builder: (context, notificationSnapshot) {
                                  if (notificationSnapshot.connectionState == ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  }

                                  if (notificationSnapshot.hasData && notificationSnapshot.data!.docs.isNotEmpty) {
                                    // If the request already exists, show "Pending"
                                    return Container(
                                      padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.black, // Use a different color for the "Pending" state
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Pending',
                                        style: TextStyle(
                                          color: Colors.yellow,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // If no request exists, show "Join"
                                    return GestureDetector(
                                      onTap: () {
                                        sendJoinRequest(projectID, creatorId);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                                        margin: const EdgeInsets.only(top: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Text(
                                          'Join',
                                          style: TextStyle(
                                            color: Colors.yellow,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              )
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
