import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/student_pages/profilePageCustomWidget/bottom_screen..dart';
import 'package:frontend/utils/colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  ApiService apiService = ApiService();
  String userID = "";

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      setState(() {
        userID = preferences.getString("userId") ?? "";
      });
      print("Student Data Loaded: $userID ");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: apiService.fecthStudentDetails(userID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.beat(color: kMainColor, size: 50),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text("No Data Found"));
          } else {
            final student = snapshot.data!["data"];
            final userDetails = student["userDetails"];

            print("============================ ${student.toString()}");
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kMainColor, kMainDarkBlue],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(0),
                        bottomRight: Radius.circular(80),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 1,
                          spreadRadius: 1,
                          color: kMainColor,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Student Profile",
                                    style: TextStyle(
                                      color: kMainWhiteColor,
                                      fontSize: 33,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            title: Text(
                                              "Logout",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: kMainWhiteColor,
                                              ),
                                            ),
                                            content: Text(
                                              "You Want Really LogingOut this Profile ?",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: kMainWhiteColor,
                                              ),
                                            ),
                                            backgroundColor: kMainColor,
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text(
                                                  "No",
                                                  style: TextStyle(
                                                    color: kMainWhiteColor,
                                                  ),
                                                ),
                                              ),

                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (context) =>
                                                              LoginPage(),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  "Yes",
                                                  style: TextStyle(
                                                    color: kMainWhiteColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.logout_rounded,
                                      color: kMainWhiteColor,
                                      weight: 2,
                                      size: 25,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              children: [
                                ClipRect(
                                  child: Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: kMainWhiteColor,
                                      borderRadius: BorderRadius.circular(60),
                                      border: Border.all(
                                        color: kMainWhiteColor,
                                        width: 4,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        "${ApiService.ip}uploads/${student["profileImage"]}",
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${userDetails['firstName']}",
                                      style: TextStyle(
                                        fontSize: 40,
                                        color: kMainWhiteColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "${userDetails['lastName']}",
                                      style: TextStyle(
                                        fontSize: 35,
                                        color: kMainWhiteColor,
                                        fontWeight: FontWeight.w400,
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
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Student  Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,

                              builder: (context) {
                                return Align(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(100),
                                            bottomRight: Radius.circular(100),
                                          ),
                                          gradient: LinearGradient(
                                            colors: [kMainColor, kMainDarkBlue],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: kMainColor.withOpacity(
                                                0.3,
                                              ),
                                              blurRadius: 10,
                                              spreadRadius: 3,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            "Edit Profile",
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.w500,
                                              color: kMainWhiteColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      BottomSheetFormProfileUpdate(
                                        Image: student["profileImage"],
                                        firstName: userDetails['firstName'],
                                        age: student['age'].toString(),
                                        lastName: userDetails['lastName'],
                                        email: userDetails['email'],
                                        gender: student['gender'],
                                        stream: student['stream'],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            "Edit",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: kMainColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 440,
                          decoration: BoxDecoration(
                            color: kMainWhiteColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: kMainColor.withOpacity(0.3),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),

                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.lock, color: kMainColor),
                                title: Text(
                                  "Student Id ",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text("${student['userID']}"),
                              ),
                              ListTile(
                                leading: Icon(Icons.email, color: kMainColor),
                                title: Text(
                                  "Email",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text("${userDetails['email']}"),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.person_2_outlined,
                                  color: kMainColor,
                                ),
                                title: Text(
                                  "Gender",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text("${student['gender']}"),
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.date_range_outlined,
                                  color: kMainColor,
                                ),
                                title: Text(
                                  "Age",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text("${student['age']}"),
                              ),
                              ListTile(
                                leading: Icon(Icons.stream, color: kMainColor),
                                title: Text(
                                  "Stream",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text("${student['stream']}"),
                              ),
                              ListTile(
                                leading:
                                    userDetails['isVerified'] == true
                                        ? Icon(
                                          Icons.verified,
                                          color: kMainColor,
                                        )
                                        : Icon(
                                          Icons.verified,
                                          color: kMainColor,
                                        ),
                                title: Text(
                                  "Verification Status",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),

                                subtitle:
                                    userDetails['isVerified'] == true
                                        ? Text(
                                          "Verifeid",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        )
                                        : Text(
                                          "Not Verifeid",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: kMainPinkColor,
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Add more fields as needed
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
