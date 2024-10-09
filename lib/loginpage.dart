import 'package:flutter/material.dart';
import 'home.dart';
import 'signuppage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _emailcontroller = TextEditingController();
  final _passwordcontroller = TextEditingController();

  Future LoginUser() async{

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailcontroller.text.trim(),
      password: _passwordcontroller.text.trim(),
    );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const home()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
    print('Wrong password provided for that user.');
    }
  }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: 450,
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                  bottomRight: Radius.circular(80),
                ),

              ),
              child: Column(

                children: <Widget>[

                  SizedBox(

                    height: (MediaQuery.of(context).size.height)/4,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(

                      child: const Text(
                        "Log in to CrewConnect...",
                        style: TextStyle(
                          fontSize: 35,

                          fontWeight: FontWeight.bold,


                        ),
                      ),


                    ),
                  ),



                ],

              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height/16,
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: TextField(
                controller: _emailcontroller,
                decoration: InputDecoration(
              
                  hintText: "User ID",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
              
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16.0),
              
                ),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(left: 10,right: 10),
              child: TextField(
                controller: _passwordcontroller,
                decoration: InputDecoration(

                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),

                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16.0),

                ),
              ),
            ),

            GestureDetector(

              onTap: LoginUser,

              child: Container(
                
                height: 60,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Log in",

                    textAlign: TextAlign.center,
                    style: TextStyle(

                      fontWeight: FontWeight.bold,

                      fontSize: 24,
                    ),
                  ),
                ),
                
              ),
            ),

            Row(

              mainAxisAlignment: MainAxisAlignment.center,

              children: <Widget>[

                Container(
                  child:const Text(
                    "Create an account ?",
                    textAlign: TextAlign.center,
                    style: TextStyle(

                      color: Colors.black45,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                GestureDetector(

                  onTap: (){

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const signupPage()),
                    );

                  },

                  child: Container(
                    child:Text(
                      "Sign Up",
                      textAlign: TextAlign.center,
                      style: TextStyle(

                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
