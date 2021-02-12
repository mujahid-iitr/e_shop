import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();
  final TextEditingController _passwordEditingController =
      TextEditingController();
  final TextEditingController _cPasswordEditingController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String userImageUrl = "";
  File _imageFile;

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width,
        _screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            InkWell(
              onTap: () => _selectAndPickImage(),
              child: CircleAvatar(
                  radius: _screenWidth * 0.15,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      _imageFile == null ? null : FileImage(_imageFile),
                  child: _imageFile == null
                      ? Icon(
                          Icons.add_photo_alternate,
                          size: _screenWidth * 0.15,
                          color: Colors.grey,
                        )
                      : null),
            ),
            SizedBox(
              height: 80.0,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: _nameEditingController,
                    data: Icons.person,
                    hintText: "Name",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _emailEditingController,
                    data: Icons.email,
                    hintText: "Emal",
                    isObsecure: false,
                  ),
                  CustomTextField(
                    controller: _passwordEditingController,
                    data: Icons.lock,
                    hintText: "Password",
                    isObsecure: true,
                  ),
                  CustomTextField(
                    controller: _cPasswordEditingController,
                    data: Icons.lock,
                    hintText: "Confirm Password",
                    isObsecure: true,
                  ),
                ],
              ),
            ),
            RaisedButton(
              onPressed: () {
                uploadAndSaveImage();
              },
              color: Colors.pink,
              child: Text(
                "Sign up",
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 4,
              width: _screenWidth * .8,
              color: Colors.pink,
            ),
            SizedBox(
              height: 15.0,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectAndPickImage() async {
    _imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
  }

  Future<void> uploadAndSaveImage() async {
    if (_imageFile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: "Please select an Image",
            );
          });
    } else {
      _passwordEditingController.text == _cPasswordEditingController.text
          ? _emailEditingController.text.isNotEmpty &&
                  _passwordEditingController.text.isNotEmpty &&
                  _cPasswordEditingController.text.isNotEmpty &&
                  _nameEditingController.text.isNotEmpty
              ? uploadToStorage()
              : displayDialog("Please fill up the registration complete form")
          : displayDialog("Password do not match");
    }
  }

  uploadToStorage() async {
    showDialog(
        context: context,
        builder: (c) {
          return LoadingAlertDialog(
            message: "Registering , please wait...",
          );
        });
    String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(imageFileName);
    StorageUploadTask storageUploadTask = storageReference.putFile(_imageFile);
    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;
    await taskSnapshot.ref.getDownloadURL().then((urlImage) {
      userImageUrl = urlImage;
      _registerUser();
    });
  }

  displayDialog(String msg) {
    showDialog(
        context: context,
        builder: (c) {
          return ErrorAlertDialog(message: msg);
        });
  }

  FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  void _registerUser() async {
    FirebaseUser firebaseUser;
    await firebaseAuth
        .createUserWithEmailAndPassword(
      email: _emailEditingController.text.trim(),
      password: _passwordEditingController.text.trim(),
    )
        .then((auth) {
      firebaseUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(
              message: error.message.toString(),
            );
          });
    });
    if (firebaseUser != null) {
      saveUserInfoToFireBase(firebaseUser).then((value) {
        Navigator.pop(context);
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);
      });
    }
  }

  Future saveUserInfoToFireBase(FirebaseUser firebaseUser) async {
    Firestore.instance.collection("users").document(firebaseUser.uid).setData({
      EcommerceApp.userUID: firebaseUser.uid,
      EcommerceApp.userEmail: firebaseUser.email,
      EcommerceApp.userName: _nameEditingController.text.trim(),
      EcommerceApp.userAvatarUrl: userImageUrl,
      EcommerceApp.userCartList: ["garbageValue"]
    });
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userUID, firebaseUser.uid);
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userEmail, firebaseUser.email);
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userName, _nameEditingController.text.trim());
    await EcommerceApp.sharedPreferences
        .setString(EcommerceApp.userAvatarUrl, userImageUrl);
    await EcommerceApp.sharedPreferences
        .setStringList(EcommerceApp.userCartList, ["garbageValue"]);
  }
}
