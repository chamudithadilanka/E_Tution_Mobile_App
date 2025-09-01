import express from "express";
import assingmentMarks from "../models/assingmentMarks.mjs";


const assignmentsMark = express.Router();

assignmentsMark.post("/create", async (req, res) => {
  try {
    const { assignmentId, feedback,markGrade,mark, teacherId, studentId, classId } = req.body;

    // Validation (you can add more rules)
    if (!assignmentId || !mark || !feedback || !markGrade || !teacherId || !studentId || !classId) {
      return res.status(400).json({ success: false, message: "All fields are required" });
    }

    // Create a new assignment mark document
    const newMark = new assingmentMarks({
      assignmentId,
      mark,
      feedback, 
      markGrade,
      teacherId,
      studentId,
      classId,
    });

    // Save to database
    await newMark.save();

    res.status(201).json({
      success: true,
      message: "Assignment mark added successfully",
      data: newMark,
    });
  } catch (error) {
    console.error("Error adding assignment mark:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


assignmentsMark.get("/student/:studentId", async (req, res) => {
  try {
    const { studentId } = req.params;

    const marks = await assingmentMarks.find({ studentId })
      .populate("assignmentId")
      .populate("teacherId")
      .populate("classId");

    res.status(200).json({
      success: true,
      data: marks,
    });
  } catch (error) {
    console.error("Error fetching student marks:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});

assignmentsMark.get("/student/:userId", async (req, res) => {
  try {
    const { userId } = req.params;

    // Fetch all attendance records for this user
    const records = await Attendance.find({ studentId: userId });

    if (records.length === 0) {
      return res.status(404).json({
        success: false,
        message: "No attendance records found for this student",
      });
    }

    // Count each type
    const presentCount = records.filter(r => r.status === "Present").length;
    const absentCount  = records.filter(r => r.status === "Absent").length;
    const lateCount    = records.filter(r => r.status === "Late").length;

    const total = records.length;

    // Calculate percentages
    const presentPercentage = ((presentCount / total) * 100).toFixed(2);
    const absentPercentage  = ((absentCount / total) * 100).toFixed(2);
    const latePercentage    = ((lateCount / total) * 100).toFixed(2);

    res.status(200).json({
      success: true,
      studentId: userId,
      totalRecords: total,
      counts: {
        present: presentCount,
        absent: absentCount,
        late: lateCount,
      },
      percentages: {
        present: presentPercentage,
        absent: absentPercentage,
        late: latePercentage,
      },
    });
  } catch (error) {
    console.error("Error fetching attendance percentages:", error);
    res.status(500).json({ success: false, message: "Server error" });
  }
});


export default assignmentsMark;