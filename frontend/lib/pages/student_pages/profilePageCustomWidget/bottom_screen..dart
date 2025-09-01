import 'dart:io';
import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/utils/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomSheetFormProfileUpdate extends StatefulWidget {
  final String Image;
  final String firstName;
  final String lastName;
  final String email;
  final String gender;
  final String age;
  final String stream;

  const BottomSheetFormProfileUpdate({
    super.key,
    required this.Image,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.gender,
    required this.age,
    required this.stream,
  });

  @override
  State<BottomSheetFormProfileUpdate> createState() =>
      _BottomSheetFormProfileUpdateState();
}

class _BottomSheetFormProfileUpdateState
    extends State<BottomSheetFormProfileUpdate> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  //  final TextEditingController phoneController = TextEditingController();
  final TextEditingController streamController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  //variables image file
  File? profileImage;
  ApiService apiService = ApiService();
  String userId = '';
  String profileImageLocals = '';
  String gender = 'Male';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loaUserData();
    firstnameController.text = widget.firstName;
    lastNameController.text = widget.lastName;
    emailController.text = widget.email;
    ageController.text = widget.age;
    streamController.text = widget.stream;
  }

  Future<void> _loaUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userId = prefs.getString('userId') ?? '';
        profileImageLocals = prefs.getString('profileImage') ?? "";
      });

      print(
        "User ID: $userId"
        " Profile Image: $profileImageLocals",
      );
    } catch (e) {
      throw Exception("Failed to load user data: $e");
    }
  }

  Future<void> _selectImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
      print("image update path" + pickedFile.path);
    }
  }

  Future<void> updateProfile() async {
    try {
      if (_formKey.currentState!.validate()) {
        final result = await apiService.updateStudentDetails(
          userId: userId,
          firstName: firstnameController.text,
          lastName: lastNameController.text,
          email: emailController.text,
          gender: gender,
          age: int.tryParse(ageController.text) ?? 0,
          stream: streamController.text,
          profileImageFile: profileImage,
        );
        print({
          "userId": userId,
          "firstName": firstnameController.text,
          "lastName": lastNameController.text,
          "email": emailController.text,
          "gender": gender,
          "age": ageController.text,
          "stream": streamController.text,
        });
        if (result['success']) {
          print('Profile updated successfully');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully')),
          );
          Navigator.pop(context);
        } else {
          print('Failed to update profile: ${result['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${result['message']}'),
            ),
          );
        }
      }
    } catch (e) {
      throw Exception("Failed to update profile: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(100),
            ),
            child: CircleAvatar(
              radius: 80,
              backgroundImage:
                  profileImage != null
                      ? FileImage(profileImage!)
                      : NetworkImage("${ApiService.ip}uploads/${widget.Image}"),
            ),
          ),
          SizedBox(height: 15),
          Container(
            width: 260,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kMainColor, kMainDarkBlue]),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: kMainWhiteColor.withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(width: 30),
                Icon(Icons.camera_alt, color: kMainWhiteColor),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: _selectImage,
                  child: Center(
                    child: Text(
                      'Change Profile Image',
                      style: TextStyle(
                        color: kMainWhiteColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              height: 420,
              decoration: BoxDecoration(
                color: kMainWhiteColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    SizedBox(height: 5),
                    TextFormField(
                      controller: firstnameController,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                          ),
                        ),
                        fillColor: kMainColor.withOpacity(0.2),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: lastNameController,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                          ),
                        ),
                        fillColor: kMainColor.withOpacity(0.2),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Enter Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                          ),
                        ),
                        fillColor: kMainColor.withOpacity(0.2),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: ageController,
                      decoration: InputDecoration(
                        labelText: 'Enter Age',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                          ),
                        ),
                        fillColor: kMainColor.withOpacity(0.2),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      controller: streamController,
                      decoration: InputDecoration(
                        labelText: 'Enter Grade',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                          ),
                        ),
                        fillColor: kMainColor.withOpacity(0.2),
                        filled: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: gender,
                      items:
                          ["Male", "Female", "Other"]
                              .map(
                                (g) =>
                                    DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                      onChanged: (value) => setState(() => gender = value!),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: kMainColor.withOpacity(0.2),
                          ),
                        ),
                        fillColor: kMainColor.withOpacity(0.2),
                        filled: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Container(
            width: 260,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kMainColor, kMainDarkBlue]),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(width: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: updateProfile,
                  child: Center(
                    child: Text(
                      'Update Your Profile',
                      style: TextStyle(
                        color: kMainWhiteColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
