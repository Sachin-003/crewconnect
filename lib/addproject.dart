import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class addProject extends StatefulWidget {
  const addProject({super.key});

  @override
  State<addProject> createState() => _addProjectState();
}

class _addProjectState extends State<addProject> {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _selectedCategory;
  String _currentDate = '';
  String _currentUserName = '';
  var uuid = const Uuid();
  final _titlecontroller = TextEditingController();
  final _gitcontroller = TextEditingController();
  final _teamsizecontroller = TextEditingController();
  @override
  void initState() {
    super.initState();
    getUserName();
  }

  void getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot UserDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (UserDoc.exists) {
        setState(() {
          _currentUserName = UserDoc['username'];
        });
      }

    }
  }
  void _updateDate() {
    final DateTime now = DateTime.now();
    setState(() {
      _currentDate = '${now.day}:${now.month}:${now.year}';
    });
  }
  
  Future addProject() async{
    _updateDate();
    User? user = _auth.currentUser;
    String projectId = uuid.v1();
    await FirebaseFirestore.instance.collection('projects').doc(projectId).set({

      'title' : _titlecontroller.text.trim(),
      'github':_gitcontroller.text.trim(),
      'teamsize':int.parse(_teamsizecontroller.text.trim()),
      'category':_selectedCategory,
      'created_at':_currentDate,
      'created_by':user!.uid,

    }
    );

    await FirebaseFirestore.instance.collection('users').doc(user.uid).collection('projectscollection').doc(projectId).set(
      {
        'title' : _titlecontroller.text.trim(),
        'project_id' : projectId,
      }
    );
    await FirebaseFirestore.instance.collection('projects').doc(projectId).collection('contributors').doc(user.uid).set(
      {
        'uid' : user.uid,
        'username':_currentUserName,
      }
    );



  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.deepPurple[200],
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: Column(

                children: [

                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height/4,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[200],
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(80),
                        bottomRight: Radius.circular(80),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: const Text(
                            "Find your team. Upload your project....",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          child: const Text(
                            'Project Title',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              controller: _titlecontroller,
                              decoration: InputDecoration(
                                hintText: "Enter the Title",
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.only(left: 10,right: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          child: const Text(
                            'Github link',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              controller: _gitcontroller,
                              decoration: InputDecoration(
                                hintText: "Github link of project",
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.only(left: 10,right: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          child: const Text(
                            'Team Size',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            child: TextField(
                              controller: _teamsizecontroller,
                              decoration: InputDecoration(
                                hintText: "No. of teammates required",
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.only(left: 10,right: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          child: const Text(
                            'Category',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10),
                            width: MediaQuery.of(context).size.width,
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              hint: const Text('Choose project category'),
                              items: ['Development', 'Robotics', 'AI','Embedded'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              },
                              decoration: InputDecoration(

                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.only(left: 10,right: 10),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.white, width: 1.0),
                                  borderRadius: BorderRadius.circular(60),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: addProject,
                child: Container(
                  margin: const EdgeInsets.all(15),
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[300],
                    borderRadius: const BorderRadius.all(
                      Radius.circular(40),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Create Project',
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
        ),
      ),
    );
  }
}
