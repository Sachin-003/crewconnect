import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  String? userID;

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

  Future<String> findUserNameFromID(String userid) async {
    DocumentSnapshot userData =
    await FirebaseFirestore.instance.collection('users').doc(userid).get();
    if (userData.exists) {
      return userData.get('username');
    } else {
      throw Exception('User not found');
    }
  }

  Stream<DocumentSnapshot> getProjectStream(String projectID) {
    return FirebaseFirestore.instance
        .collection('projects')
        .doc(projectID)
        .snapshots();
  }

  void acceptRequest(String ProjectId , String SenderId)async{
    
    DocumentSnapshot projectData  = await FirebaseFirestore.instance.collection('projects').doc(ProjectId).get();
    String projectTitle = projectData.get('title');
    DocumentSnapshot senderData = await FirebaseFirestore.instance.collection('users').doc(SenderId).get();
    String senderName = senderData.get('username');

    await FirebaseFirestore.instance.collection('users').doc(SenderId).collection('projectscollection').doc(ProjectId).set(
      {
        'project_id' : ProjectId,
        'title' : projectTitle,
      }
    );
    
    await FirebaseFirestore.instance.collection('projects').doc(ProjectId).collection('contributors').doc(SenderId).set(
      {
        'uid' : SenderId,
        'username' : senderName,
      }
    );


  }

  void deleteRequest(String notificationId)async{
    try{
      await FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete();
    }
    catch(e){
      print("Error deleting request");
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.deepPurple,
          ),
        ),
      ),
      body: userID == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId', isEqualTo: userID)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Notifications Found'));
          }

          List<QueryDocumentSnapshot> notifications = snapshot.data!.docs;


          return ListView(
            children: notifications.map((doc) {
              var notification = doc.data() as Map<String, dynamic>;
              String notificationId = doc.id;
              return FutureBuilder<String>(
                future: findUserNameFromID(notification['senderId']),
                builder: (context, usernameSnapshot) {
                  if (usernameSnapshot.hasError) {
                    return const ListTile(
                      title: Text('Error loading sender details'),
                    );
                  }
                  if (usernameSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const ListTile(
                      title: Center(child: CircularProgressIndicator()),
                    );
                  }

                  String senderName = usernameSnapshot.data ?? 'Unknown';


                  return StreamBuilder<DocumentSnapshot>(
                    stream: getProjectStream(notification['projectId']),
                    builder: (context, projectSnapshot) {
                      if (projectSnapshot.hasError) {
                        return const ListTile(
                          title: Text('Error loading project details'),
                        );
                      }
                      if (projectSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const ListTile(
                          title: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (!projectSnapshot.hasData ||
                          !projectSnapshot.data!.exists) {
                        return const ListTile(
                          title: Text('Project not found'),
                        );
                      }

                      var projectData = projectSnapshot.data!.data() as Map<String, dynamic>;

                      return Container(
                        margin: const EdgeInsets.all(8),
                        child: ListTile(
                          title: Text(projectData['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple[400],
                          ),
                          ),
                          subtitle: Text(
                              'Join request from: $senderName',
                            style: TextStyle(
                              color: Colors.deepPurple[400],
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.deepPurple[400]),
                                onPressed: () {
                                  // Handle the approval logic here
                                  acceptRequest(notification['projectId'], notification['senderId']);
                                  deleteRequest(notificationId);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.deepPurple[400]),
                                onPressed: () {
                                  // Handle the rejection logic here
                                  deleteRequest(notificationId);
                                  
                                },
                              ),
                            ],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          tileColor: Colors.deepPurple[100],
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
