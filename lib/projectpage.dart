import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: const Text(
            'Your Projects',
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: userID.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .collection('projectscollection')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 200,
              color: Colors.deepPurple[50],
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Projects Found'));
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('projects').doc(data['project_id']).get(),
                builder: (context, projectSnapshot) {
                  if (projectSnapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 200,
                      color: Colors.deepPurple[50],
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (projectSnapshot.hasError) {
                    return const Center(child: Text('Error loading project data'));
                  }
                  if (!projectSnapshot.hasData || !projectSnapshot.data!.exists) {
                    return const Center(child: Text('Project data not found'));
                  }
                  Map<String, dynamic> projectData = projectSnapshot.data!.data()! as Map<String, dynamic>;

                  // Fetch the username using the created_by UID
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(projectData['created_by']).get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (userSnapshot.hasError) {
                        return const Center(child: Text('Error loading user data'));
                      }
                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return const Center(child: Text('User data not found'));
                      }
                      Map<String, dynamic> userData = userSnapshot.data!.data()! as Map<String, dynamic>;
                      String username = userData['username'] ?? 'No username';

                      return Container(
                        height: 150,
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[50],
                          borderRadius: const BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.code,
                                    color: Colors.deepPurple,
                                    size: 28,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      data['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.flutter_dash,
                                    color: Colors.deepPurple,
                                    size: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      username,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
