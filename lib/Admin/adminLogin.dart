import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Authentication/authenication.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:flutter/material.dart';

class AdminSignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: new BoxDecoration(
            gradient: new LinearGradient(colors: [Colors.pink, Colors.lightGreenAccent], begin: const FractionalOffset(0.0, 0.0), end: const FractionalOffset(1.0, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),
          ),
        ),
        title: Text(
          "e-Shop",
          style: TextStyle(fontSize: 55, color: Colors.white, fontFamily: "Signatra"),
        ),
        centerTitle: true,
      ),
      body: AdminSignInScreen(),
    );
  }
}

class AdminSignInScreen extends StatefulWidget {
  @override
  _AdminSignInScreenState createState() => _AdminSignInScreenState();
}

class _AdminSignInScreenState extends State<AdminSignInScreen> {
  final TextEditingController _adminIdTextEditingController = TextEditingController();
  final TextEditingController _passwordEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width, _screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(colors: [Colors.pink, Colors.lightGreenAccent], begin: const FractionalOffset(0.0, 0.0), end: const FractionalOffset(1.0, 0.0), stops: [0.0, 1.0], tileMode: TileMode.clamp),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                "images/admin.png",
                height: 240,
                width: 240,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Admin",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _adminIdTextEditingController,
                    data: Icons.person,
                    hintText: "Id",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordEditingController,
                    data: Icons.lock,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  RaisedButton(
                    onPressed: () {
                      _adminIdTextEditingController.text.isNotEmpty && _passwordEditingController.text.isNotEmpty
                          ? loginAdmin()
                          : showDialog(
                              context: context,
                              builder: (c) {
                                return ErrorAlertDialog(
                                  message: "Please enter Id and Password",
                                );
                              });
                    },
                    color: Colors.pink,
                    child: Text(
                      "Sign In",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    height: 4,
                    width: _screenWidth * .8,
                    color: Colors.pink,
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  FlatButton.icon(
                    onPressed: () => {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AuthenticScreen())),
                    },
                    icon: Icon(
                      Icons.nature_people,
                      color: Colors.pink,
                    ),
                    label: Text(
                      "I'm not Admin",
                      style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 50.0,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  loginAdmin() {
    Firestore.instance.collection("admins").getDocuments().then((snapshot) {
      snapshot.documents.forEach((reult) {
        if (reult.data["id"] != _adminIdTextEditingController.text.trim()) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Your id is not correct")));
        } else if (reult.data["password"] != _passwordEditingController.text.trim()) {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Your password is not correct")));
        } else {
          Scaffold.of(context).showSnackBar(SnackBar(content: Text("Welcome dear Admin" + reult.data["name"])));
          setState(() {
            _adminIdTextEditingController.text = "";
            _passwordEditingController.text = "";
          });
          Route route = MaterialPageRoute(builder: (c) => UploadPage());
          Navigator.pushReplacement(context, route);
        }
      });
    });
  }
}
