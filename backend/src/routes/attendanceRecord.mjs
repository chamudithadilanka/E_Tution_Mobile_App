import express from 'express';
import AttendanceRecord from '../models/attendanceRecord.mjs';
import attendanceSession from '../models/attendanceSession.mjs';

const attendanceRecordRouter = express.Router();


attendanceRecordRouter.use(express.json());

attendanceRecordRouter.post('/mark-attendance', async (req, res) => {
  const { studentId, qrToken } = req.body;

  try {
    const session = await attendanceSession.findOne({ sessionToken: qrToken });

    if (!session || session.expiresAt < new Date()) {
      return res.status(400).json({ success: false, message: 'Invalid or expired QR token' });
    }

    const alreadyMarked = await AttendanceRecord.findOne({
      studentId,
      sessionId: session._id
    });

    if (alreadyMarked) {
      return res.status(400).json({ success: false, message: 'Attendance already marked' });
    }

    const record = new AttendanceRecord({
      studentId,
      classId: session.classId,
      sessionId: session._id
    });

    await record.save();

    res.json({ success: true, message: 'Attendance marked successfully' });
  } catch (error) {
    console.error('Error marking attendance:', error.message);
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});


attendanceRecordRouter.get('/class/:classId/students', async (req, res) => {
  const { classId } = req.params;

  try {
    // 1️⃣ Find all attendance records for this class
    const students = await AttendanceRecord.find({ classId })
      .populate("studentId")  // populate student details
      .populate("classId");   // optionally populate class details

    res.status(200).json({
      success: true,
      classId,
      totalStudents: students.length,
      data: students
    });
  } catch (error) {
    console.error('Error fetching students for class attendance:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch students',
      error: error.message
    });
  }
});



export default attendanceRecordRouter;
