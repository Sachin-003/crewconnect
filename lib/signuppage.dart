import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:proddyfi/home.dart';

class signupPage extends StatefulWidget {
  const signupPage({super.key});

  @override
  State<signupPage> createState() => _signupPageState();
}

class _signupPageState extends State<signupPage> {
  final _usernamecontroller = TextEditingController();
  final _emailcontroller = TextEditingController();
  final _contactcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future SignUp() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailcontroller.text.trim(),
        password: _passwordcontroller.text.trim(),
      );


      await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
        'username': _usernamecontroller.text.trim(),
        'email': _emailcontroller.text.trim(),
        'contact': _contactcontroller.text.trim(),
        'gender': _selectedGender,
        'dob': _selectedDate?.toIso8601String(),
        'followers': 0,
        'followings': 0,
        'projects': 0,
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const home()),
      );


    } on FirebaseAuthException catch (e) {
      print('Error: $e');
    }
  }

  void Printuser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('User is signed in: ${user.email}');
    } else {
      print('No user is signed in.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8, left: 8, bottom: 30, right: 8),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(60),
                  bottomRight: Radius.circular(60),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Center(
                    child: Container(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(

                          fontSize: 35,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Full Name",
                      style: TextStyle(

                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: _usernamecontroller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your fullname",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Email",
                      style: TextStyle(

                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: _emailcontroller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Mobile No.",
                      style: TextStyle(

                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: _contactcontroller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your mobile no.",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Password",
                      style: TextStyle(

                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      controller: _passwordcontroller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Enter your password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    child: const Text(
                      "Gender",
                      style: TextStyle(

                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      hint: const Text('Select your gender'),
                      items: ['Male', 'Female', 'Other'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedGender = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(5),

                        child: const Text(
                          "D.O.B.",
                          style: TextStyle(

                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Container(

                        child: IconButton(
                          color: Colors.black,
                          icon: const Icon(Icons.calendar_month_sharp),
                          onPressed:()=> _selectDate(context),

                        ),

                      ),
                      Container(
                        margin: const EdgeInsets.all(5),

                        child: Text(
                          _selectedDate == null
                              ? 'No date selected!'
                              : '${_selectedDate!.toLocal()}'.split(' ')[0],
                          style: const TextStyle(

                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),

                ],
              ),
            ),
            Container(
              height: 60,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: const BorderRadius.all(Radius.circular(20)),
              ),
              child: GestureDetector(
                onTap: SignUp,
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Sign Up",
                    textAlign: TextAlign.center,
                    style: TextStyle(

                      color: Colors.black,
                      fontSize: 24,
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
