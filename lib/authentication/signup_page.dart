// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodtrack/firebase_options.dart';
import 'package:foodtrack/helper/ui_helper.dart';
import 'package:foodtrack/helper/widgets/consts.dart';
import 'package:foodtrack/helper/widgets/form_button.dart';
import 'package:foodtrack/helper/widgets/form_container.dart';
import 'package:foodtrack/models/user_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FoodTrack',
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  File? imageFile;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FoodTrack',
          style: GoogleFonts.playfairDisplay(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: titleColor, // Update to match LoginPage
          ),
        ),
        backgroundColor: appBarColor, // Consistent app bar color
        centerTitle: true,
        shadowColor: appBarShadowColor,
        elevation: 5,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          color: backgroundScreenColor, // Consistent background color
          child: ListView(
            children: [
              const SizedBox(height: 10),
              CupertinoButton(
                onPressed: showPhotoOptions,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  child: (imageFile == null)
                      ? const Icon(
                          Icons.person,
                          size: 80,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const Text(
                "Tap to change profile picture",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FormContainerWidget(
                labelText: 'Name',
                hintText: 'Enter your name',
                inputType: TextInputType.name,
                icon: Icons.person,
                controller: fullNameController,
              ),
              FormContainerWidget(
                labelText: 'Email',
                hintText: 'Enter your email',
                inputType: TextInputType.emailAddress,
                icon: Icons.email,
                controller: emailController,
              ),
              FormContainerWidget(
                labelText: 'Password',
                hintText: 'Enter your password',
                inputType: TextInputType.visiblePassword,
                icon: Icons.lock,
                controller: passwordController,
                isPasswordField: true,
              ),
              FormContainerWidget(
                labelText: 'Confirm Password',
                hintText: 'Confirm your password',
                inputType: TextInputType.visiblePassword,
                icon: Icons.lock,
                controller: confirmPasswordController,
                isPasswordField: true,
              ),
              const SizedBox(height: 10),
              FormButtonWidget(
                text: 'Sign Up',
                backgroundColor: Colors.purpleAccent,
                textColor: txtColor, // Consistent text color
                onPressed: checkValues,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showPhotoOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choose Profile Picture"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a Photo"),
                onTap: () {
                  Navigator.pop(context);
                  selectImages(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text("Upload from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  selectImages(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void selectImages(ImageSource img) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: img);
    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressQuality: 20,
    );

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void checkValues() {
    String fname = fullNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (fname.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      UIHelper.toast("Please fill all the fields!", Toast.LENGTH_SHORT,
          ToastGravity.BOTTOM);
    } else if (password != confirmPassword) {
      UIHelper.toast(
          "Passwords do not match!", Toast.LENGTH_SHORT, ToastGravity.BOTTOM);
    } else if (imageFile == null) {
      UIHelper.toast(
          "Please insert your image!", Toast.LENGTH_SHORT, ToastGravity.BOTTOM);
    } else {
      signUp(email, password);
    }
  }

  void signUp(String email, String password) async {
    UIHelper.showLoadingDialog(context, "Creating Account...");
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      uploadData(userCredential.user!);
    } catch (e) {
      Navigator.pop(context);
      UIHelper.toast(
          "Error creating account: $e", Toast.LENGTH_LONG, ToastGravity.BOTTOM);
    }
  }

  void uploadData(User firebaseUser) async {
    UIHelper.showLoadingDialog(context, "Uploading Data...");
    try {
      UploadTask uploadTask = FirebaseStorage.instance
          .ref("profilepictures")
          .child(firebaseUser.uid)
          .putFile(imageFile!);

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();
      String fname = fullNameController.text.trim();

      UserModel userModel = UserModel(
        uid: firebaseUser.uid,
        name: fname,
        profilepic: imageUrl,
      );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(firebaseUser.uid)
          .set(userModel.toMap())
          .then((value) {
        UIHelper.toast(
            "Data Uploaded...", Toast.LENGTH_LONG, ToastGravity.BOTTOM);
        Navigator.popUntil(context, (route) => route.isFirst);
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(userModel: userModel, firebaseUser: firebaseUser)));
      });
    } catch (e) {
      Navigator.pop(context);
      UIHelper.toast(
          "Error uploading data: $e", Toast.LENGTH_LONG, ToastGravity.BOTTOM);
    }
  }
}
