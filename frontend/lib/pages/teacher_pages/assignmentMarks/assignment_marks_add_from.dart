import 'dart:convert';

import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssignmentMarkAddForm extends StatefulWidget {
  final String assingmentId;
  final String studentId;
  final String classId;
  const AssignmentMarkAddForm({
    super.key,
    required this.assingmentId,
    required this.studentId,
    required this.classId,
  });

  @override
  State<AssignmentMarkAddForm> createState() => _AssignmentMarkAddFormState();
}

class _AssignmentMarkAddFormState extends State<AssignmentMarkAddForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController addMarksController = TextEditingController();
  final TextEditingController feedbackController = TextEditingController();
  final TextEditingController gradeMarkController = TextEditingController();
  ApiService apiService = ApiService();
  String teacherId = "";

  Future<void> _loadTeacherData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        teacherId = prefs.getString('userId') ?? '';
      });
    } catch (e) {
      print("error $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadTeacherData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 1.0,
                height: MediaQuery.of(context).size.height * 0.15,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [kMainColor, kMainDarkBlue]),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50),
                      Text(
                        "Add Assingment Marks",
                        style: TextStyle(
                          color: kMainWhiteColor,
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: addMarksController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Add MArk";
                        }
                        return null;
                      },

                      decoration: InputDecoration(
                        labelText: "Enter marks (0-100)",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: kMainColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: kMainColor),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: feedbackController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter FeedBack";
                        }
                        return null;
                      },

                      decoration: InputDecoration(
                        labelText: "Enter FeedBack",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: kMainColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: kMainColor),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: gradeMarkController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Enter Grade Mark";
                        }
                        return null;
                      },

                      decoration: InputDecoration(
                        labelText: "Enter Grade mark",
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: kMainColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: kMainColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [kMainColor, kMainDarkBlue],
                      begin: Alignment.bottomLeft,
                      end: Alignment.topCenter,
                    ),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        double marks =
                            double.tryParse(addMarksController.text) ?? 0.0;
                        apiService.createAssiignmentMark(
                          assignmentId: widget.assingmentId,
                          mark: marks,
                          feedback: feedbackController.text,
                          markGrade: gradeMarkController.text,
                          teacherId: teacherId,
                          studentId: widget.studentId,
                          classId: widget.classId,
                        );
                        print(
                          "${widget.assingmentId} $marks"
                          "teacherId: $teacherId,"
                          "studentId: ${widget.studentId}"
                          "classId: ${widget.classId}",
                        );
                      }
                    },
                    child: Text(
                      "Add Mark",
                      style: TextStyle(fontSize: 20, color: kMainWhiteColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
