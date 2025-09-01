import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/api/api_service.dart';
import '../../../models/qr_attendance_model.dart';

class FetchQrCodeStudentAttendance extends StatefulWidget {
  final String classId;
  const FetchQrCodeStudentAttendance({super.key, required this.classId});

  @override
  State<FetchQrCodeStudentAttendance> createState() => _FetchQrCodeStudentAttendanceState();
}

class _FetchQrCodeStudentAttendanceState extends State<FetchQrCodeStudentAttendance> {
  ApiService apiService = ApiService();
  late Future<List<AttendanceRecord>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = apiService.fetchClassAttendance(widget.classId);
  }

  Future<void> _refreshData() async {
    setState(() {
      _attendanceFuture = apiService.fetchClassAttendance(widget.classId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Attendance'),
        backgroundColor: Colors.white,
        foregroundColor: Colors. black,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<AttendanceRecord>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading attendance records...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No QR attendance records found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final attendanceRecords = snapshot.data!;
          final uniqueStudents = _getUniqueStudents(attendanceRecords);

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: Column(
              children: [
                _buildSummaryCard(attendanceRecords, uniqueStudents),
                Expanded(
                  child: ListView.builder(
                    itemCount: attendanceRecords.length,
                    itemBuilder: (context, index) {
                      final record = attendanceRecords[index];
                      return _buildAttendanceCard(record);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(List<AttendanceRecord> records, int uniqueStudents) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSummaryItem('Total Records', records.length.toString()),
                // _buildSummaryItem('Unique Students', uniqueStudents.toString()),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSummaryItem(
                  'Latest',
                  _getLatestDate(records).toString().split(' ')[0],
                ),
                // _buildSummaryItem(
                //   'First',
                //   _getEarliestDate(records).toString().split(' ')[0],
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(AttendanceRecord record) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Text(
            record.student.firstName[0],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          record.student.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Session: ${record.sessionId.substring(0, 8)}...',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              'Date: ${_formatDate(record.markedAt)}',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              'Time: ${_formatTime(record.markedAt)}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code, size: 20, color: Colors.green),
            const SizedBox(height: 2),
            Text(
              _formatTimeAgo(record.markedAt),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          _showAttendanceDetails(record);
        },
      ),
    );
  }

  void _showAttendanceDetails(AttendanceRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attendance Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Student', record.student.fullName),
              _buildDetailRow('Email', record.student.email),
              _buildDetailRow('Class', record.classInfo.className),
              _buildDetailRow('Subject', record.classInfo.subject),
              _buildDetailRow('Session ID', record.sessionId),
              _buildDetailRow('Date', _formatDate(record.markedAt)),
              _buildDetailRow('Time', _formatTime(record.markedAt)),
              _buildDetailRow('Marked', _formatTimeAgo(record.markedAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  int _getUniqueStudents(List<AttendanceRecord> records) {
    final uniqueIds = <String>{};
    for (var record in records) {
      uniqueIds.add(record.student.id);
    }
    return uniqueIds.length;
  }

  DateTime _getLatestDate(List<AttendanceRecord> records) {
    return records.map((r) => r.markedAt).reduce(
          (a, b) => a.isAfter(b) ? a : b,
    );
  }

  DateTime _getEarliestDate(List<AttendanceRecord> records) {
    return records.map((r) => r.markedAt).reduce(
          (a, b) => a.isBefore(b) ? a : b,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}