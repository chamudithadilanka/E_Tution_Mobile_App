import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/utils/colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExamResult extends StatefulWidget {
  final String classId;
  const ExamResult({super.key, required this.classId});

  @override
  State<ExamResult> createState() => _ExamResultState();
}

class _ExamResultState extends State<ExamResult> {
  String studentId = "";
  ApiService apiService = ApiService();

  Future<void> loadData() async {
    final SharedPreferences pres = await SharedPreferences.getInstance();
    try {
      setState(() {
        studentId = pres.getString("userId") ?? "";
      });
      print("Student id " + studentId);
    } catch (e) {
      throw Exception('Error $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Exam Result")),
      body: FutureBuilder(
        future: apiService.fetchAssignmentMarks(studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.beat(color: kMainColor, size: 50),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.hasError}"));
            print(snapshot.hasData);
            return Center(child: Text("${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No Availabale Result"));
          } else {
            final result = snapshot.data;
            return ListView.builder(
              itemCount: result!.length,
              itemBuilder: (context, index) {
                final item = result[index];
                final assignment = item["assignmentId"];
                final classId = assignment?["classId"];
                final title = assignment?["title"] ?? "No title";
                final mark = item["mark"]?.toString() ?? "N/A";
                final grade = item["markGrade"] ?? "";

                if (classId == widget.classId) {
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      title: Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("Marks: $mark | Grade: $grade"),
                    ),
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
