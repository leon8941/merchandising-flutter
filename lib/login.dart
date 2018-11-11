import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'const.dart';
import 'main.dart';

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "New List",
      home: LoginScreen(title: "Chat Messages"),
      theme: new ThemeData(
        primaryColor: Colors.deepPurpleAccent
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  LoginScreenState createState() => new LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  SharedPreferences sharedPreferences;

  bool isLoading = false;
  bool isLoggedIn = false;
  FirebaseUser currentUser;

  void initState() {
    super.initState();
  }

  void isSignedIn() async {
    this.setState(() {
      isLoading = true;
    });

    //Navigate to Home page here

    this.setState(() {
      isLoading = false;
    });
  }

  Future<Null> handleSignIn() async {
    sharedPreferences = await SharedPreferences.getInstance();

    this.setState(() {
      isLoading = true;
    });

    GoogleSignInAccount googleUser = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    FirebaseUser firebaseUser = await firebaseAuth.signInWithGoogle(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    print("firebaseAuth results: ");
    print(firebaseUser);

    if (firebaseUser != null) {
      final QuerySnapshot results = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: firebaseUser.uid)
        .getDocuments();
      
      final List<DocumentSnapshot> documents = results.documents;

      print("DocumentSnapshot documents: ");
      print(documents);

      if(documents.length == 0){
        Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .setData({
            'id': firebaseUser.uid,
            'nickname': firebaseUser.displayName,
            'photoUrl': firebaseUser.photoUrl,
          });

          //Persist data to local storage
          await sharedPreferences.setString('id', firebaseUser.uid);
          await sharedPreferences.setString('displayName', firebaseUser.displayName);
          await sharedPreferences.setString('photoUrl', firebaseUser.photoUrl);
      }
      else{
          //Persist data to local storage
          await sharedPreferences.setString('id', documents[0]['id']);
          await sharedPreferences.setString('displayName', documents[0]['nickname']);
          await sharedPreferences.setString('photoUrl', documents[0]['photoUrl']);
      }

      Fluttertoast.showToast(msg: "Sign in success");

      this.setState(() {
        isLoading = false;
      });

      var mainPageRoute = MaterialPageRoute(
        builder: (context) => MyHomePage(currentUserId: sharedPreferences.getString('id'))
      );

      Navigator.push(context, mainPageRoute);
    }
    else {
      Fluttertoast.showToast(msg: "Sign in fail");
      this.setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          title: Text(
            widget.title,
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: <Widget>[
            Center(
              child: FlatButton(
                  onPressed: handleSignIn,
                  child: Text(
                    'SIGN IN WITH GOOGLE',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  color: Color(0xffdd4b39),
                  highlightColor: Color(0xffff7f7f),
                  splashColor: Colors.transparent,
                  textColor: Colors.white,
                  padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)),
            ),

            // Loading
            Positioned(
              child: isLoading
                  ? Container(
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                        ),
                      ),
                      color: Colors.white.withOpacity(0.8),
                    )
                  : Container(),
            ),
          ],
        )
    );
  }
}