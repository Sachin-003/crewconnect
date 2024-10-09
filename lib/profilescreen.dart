import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginpage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override

  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int totalProjects = 0;
  @override
  void initState() {
    super.initState();
    fetchTotalProjects();
  }


  Future<Map<String, dynamic>?> _fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      return userDoc.data() as Map<String, dynamic>?;
    }
    return null;
  }
  void _logout() async {
    await _auth.signOut();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void fetchTotalProjects() async {
    User? user = _auth.currentUser;
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user!.uid).collection('projectscollection').get();
    setState(() {
      totalProjects = snapshot.size;
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchUserData(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No user data found'));
          } else {
            var userData = snapshot.data!;
            return Stack(
              children: <Widget>[
                SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(bottom: 30),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[200],
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(30),
                            bottomLeft: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Container(
                                margin: const EdgeInsets.all(10),
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.4),
                                      width: 4,
                                    ),
                                  ),
                                  child: const CircleAvatar(
                                    radius: 50,
                                    backgroundImage: AssetImage('./images/Robotics.jpg'), // Use your asset image
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                userData['username'], // Display the username fetched from Firestore
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      const Text(
                                        'Followers',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        userData['followers'].toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      const Text(
                                        'Followings',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        userData['followings'].toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: <Widget>[
                                      const Text(
                                        'Projects',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),

                                      Text(

                                        totalProjects.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 25),
                        child: Row(
                          children: [
                            Text(
                              "Email",
                              style: TextStyle(
                                color: Colors.deepPurple[200],
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                userData['email'],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.deepPurple[200],
                        thickness: 1,
                        indent: 10,
                        endIndent: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 25),
                        child: Row(
                          children: [
                            Text(
                              "Contact",
                              style: TextStyle(
                                color: Colors.deepPurple[200],
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                userData['contact'],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.deepPurple[200],
                        thickness: 1,
                        indent: 10,
                        endIndent: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 25),
                        child: Row(
                          children: [
                            Text(
                              "Gender",
                              style: TextStyle(
                                color: Colors.deepPurple[200],
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                userData['gender'],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.deepPurple[200],
                        thickness: 1,
                        indent: 10,
                        endIndent: 10,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 10, right: 10, top: 25),
                        child: Row(
                          children: [
                            Text(
                              "D.O.B.",
                              style: TextStyle(
                                color: Colors.deepPurple[200],
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                userData['dob'],
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.deepPurple[200],
                        thickness: 1,
                        indent: 10,
                        endIndent: 10,
                      ),
                      // Additional space to ensure the bottom container is not hidden by the keyboard
                      const SizedBox(height: 150),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: _logout,
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[200],
                        borderRadius: const BorderRadius.all(
                          Radius.circular(40),
                        ),
                      ),
                      child: const Center(
                          child: Text(
                              'Log out',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
