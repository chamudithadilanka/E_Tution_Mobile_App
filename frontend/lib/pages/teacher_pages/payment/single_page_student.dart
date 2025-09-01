import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';
import 'package:frontend/models/payment.dart';
import 'package:frontend/utils/colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

class SinglePageStudent extends StatefulWidget {
  final String studentId;
  final String studentFullName;
  final String studentProfileImage;
  final String studentEmail;
  final String classId;

  const SinglePageStudent({
    super.key,
    required this.studentId,
    required this.studentFullName,
    required this.studentProfileImage,
    required this.studentEmail,
    required this.classId,
  });

  @override
  State<SinglePageStudent> createState() => _SinglePageStudentState();
}

class _SinglePageStudentState extends State<SinglePageStudent> {
  ApiService apiService = ApiService();
  bool isDownload = false;
  String imageUrl = "";
  double _downloadProgress = 0.0;
  List<String> statusList = ["pending", "approved", "rejected"];
  String? selectedStatus = "pending";
  late Future<List<PaymentSlip>> _paymentSlipFuter;
  String? comment = "";
  List<GlobalKey<FormState>> formKeys = [];
  List<String?> selectedStatuses = [];
  List<TextEditingController> commentControllers = [];

  @override
  void initState() {
    super.initState();
    _paymentSlipFuter = apiService
        .fetchPaymentSlipsByStudentId(widget.studentId)
        .then((slips) {
          // Initialize for each payment slip
          commentControllers =
              slips
                  .map(
                    (slip) =>
                        TextEditingController(text: slip.teacherComment ?? ""),
                  )
                  .toList();
          formKeys = slips.map((_) => GlobalKey<FormState>()).toList();
          selectedStatuses =
              slips.map((slip) => slip.status ?? "pending").toList();
          return slips;
        });
  }

  Future<void> _downloadImage() async {
    var status = await Permission.storage.request();

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Storage permission is required to download images'),
        ),
      );
      return;
    }

    setState(() {
      isDownload = true;
    });

    try {
      final dir = await getDownloadsDirectory();
      if (dir == null) {
        throw Exception("Could not get downloads directory");
      }
      final savePath =
          '${dir.path}/downloaded_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final dio = Dio();
      await dio.download(
        imageUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image downloaded successfully to $savePath')),
      );
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isDownload = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Single Student Payment Page")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _studentInfoSection(),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "Monthly Payment Resit List",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: kMainBlackColor,
              ),
            ),
          ),

          Expanded(child: futureWidget()),
        ],
      ),
    );
  }

  Widget _studentInfoSection() {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 1.0,
          height: MediaQuery.of(context).size.height * 0.2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kMainColor, kMainDarkBlue],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(100)),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade400,
                spreadRadius: 1,
                offset: Offset(0, 1),
                blurRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 30,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade400,
                              spreadRadius: 1.5,
                              offset: Offset(0, 1),
                              blurRadius: 5,
                            ),
                          ],
                          border: Border.all(color: kMainWhiteColor, width: 3),
                          borderRadius: BorderRadius.circular(150),
                          color: kMainWhiteColor,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(150),
                          child: Image.network("${widget.studentProfileImage}"),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.studentFullName}",
                              style: TextStyle(
                                color: kMainWhiteColor,
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Text(
                              "Student ID : ${widget.studentId}",
                              style: TextStyle(
                                color: kMainWhiteColor,
                                fontSize: 10,
                              ),
                            ),

                            Text(
                              "Email : ${widget.studentEmail}",
                              style: TextStyle(
                                color: kMainWhiteColor,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget futureWidget() {
    return FutureBuilder<List<PaymentSlip>>(
      future: _paymentSlipFuter,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.beat(color: kMainColor, size: 50),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No payment slips found"));
        }
        final _formKey = GlobalKey<FormState>();
        // Filter payment slips by classId first
        final filteredSlips =
            snapshot.data!
                .where((slip) => slip.classId == widget.classId)
                .toList();

        if (filteredSlips.isEmpty) {
          return const Center(
            child: Text("No payment slips found for this class"),
          );
        }

        return ListView.builder(
          itemCount: filteredSlips.length,
          itemBuilder: (context, index) {
            final paymentSlip = filteredSlips[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [kMainColor, kMainDarkBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomLeft,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Month ${paymentSlip.month}",
                            style: TextStyle(
                              color: kMainWhiteColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 23,
                            ),
                          ),

                          Text(
                            "Receipt ID : ${paymentSlip.id}",
                            style: TextStyle(
                              color: kMainWhiteColor,
                              fontSize: 10,
                            ),
                          ),
                          Divider(color: kMainWhiteColor),
                          SizedBox(height: 20),
                          Image.network(
                            "${ApiService.ip}${paymentSlip.slipFile}",
                            width: 400,
                            height: 200,
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          SizedBox(height: 300),
                          Container(
                            width: MediaQuery.of(context).size.width * 1.0,
                            height: MediaQuery.of(context).size.height * 0.1,
                            decoration: BoxDecoration(
                              color: kMainWhiteColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [kMainColor, kMainDarkBlue],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 4,
                                          color: kMainBlackColor.withOpacity(
                                            0.1,
                                          ),
                                          spreadRadius: 1,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                      ),
                                      onPressed: () {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          LoadingAnimationWidget.beat(
                                            color: kMainColor,
                                            size: 50,
                                          );
                                        } else {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) => Scaffold(
                                                    body: PhotoView(
                                                      imageProvider: NetworkImage(
                                                        "${ApiService.ip}${paymentSlip.slipFile}",
                                                      ),
                                                    ),
                                                  ),
                                            ),
                                          );
                                        }
                                      },
                                      child: Center(
                                        child: Text(
                                          "Preview",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: kMainWhiteColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 120,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [kMainColor, kMainDarkBlue],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 4,
                                          color: kMainBlackColor.withOpacity(
                                            0.1,
                                          ),
                                          spreadRadius: 1,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                      ),
                                      onPressed: () {
                                        _downloadImage();
                                        setState(() {
                                          imageUrl =
                                              "${ApiService.ip}${paymentSlip.slipFile}";
                                        });
                                      },
                                      child: Center(
                                        child: Text(
                                          "Download",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: kMainWhiteColor,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Form(
                            key: formKeys[index],
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Select Status : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: kMainWhiteColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 120,
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      fillColor: kMainColor.withOpacity(0.2),
                                      filled: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: kMainWhiteColor,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: kMainWhiteColor,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                          color: kMainColor,
                                        ),
                                      ),
                                    ),
                                    value: selectedStatuses[index],
                                    items:
                                        statusList.map((String item) {
                                          return DropdownMenuItem(
                                            value: item,
                                            child: Text(item),
                                          );
                                        }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedStatuses[index] = newValue;
                                      });
                                    },
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Give Comment : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: kMainWhiteColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: commentControllers[index],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please Enter Comment";
                                    }
                                    return null;
                                  },
                                  onSaved: (value) {
                                    comment = value!;
                                  },
                                  style: TextStyle(color: kMainWhiteColor),
                                  maxLines: 4,
                                  decoration: InputDecoration(
                                    label: Center(
                                      child: Text(
                                        "Enter Your Comment",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: kMainWhiteColor.withOpacity(
                                            0.8,
                                          ),
                                        ),
                                      ),
                                    ),

                                    fillColor: kMainNavSelected.withOpacity(
                                      0.2,
                                    ),
                                    filled: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: kMainWhiteColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: kMainWhiteColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(color: kMainColor),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                Container(
                                  width: double.infinity,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      colors: [kMainDarkBlue, kMainColor],
                                      begin: Alignment.topLeft,
                                      end: AlignmentDirectional.bottomEnd,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        blurRadius: 1,
                                        color: Colors.black12.withOpacity(0.2),
                                        offset: Offset(0, 1),
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    onPressed: () async {
                                      // Made this async
                                      if (formKeys[index].currentState!
                                          .validate()) {
                                        try {
                                          // Await the API call
                                          await apiService.updatePaymentStatus(
                                            paymentSlip.id!,
                                            selectedStatuses[index]!,
                                            commentControllers[index].text,
                                          );

                                          // Only refresh after successful update
                                          setState(() {
                                            _paymentSlipFuter = apiService
                                                .fetchPaymentSlipsByStudentId(
                                                  widget.studentId,
                                                );
                                          });

                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Status updated successfully',
                                              ),
                                            ),
                                          );
                                        } catch (e) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error: ${e.toString()}',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: Center(
                                      child: Text(
                                        "SUBMIT",
                                        style: TextStyle(
                                          color: kMainWhiteColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // Column(
                      //   children: [
                      //     SizedBox(height: 340),
                      //     Text(
                      //       "Amount ${paymentSlip.amount}",
                      //       style: TextStyle(
                      //         color: kMainWhiteColor,
                      //         fontWeight: FontWeight.w700,
                      //         fontSize: 20,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
