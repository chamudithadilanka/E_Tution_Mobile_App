import mongoose from "mongoose";

const assignmentMarksSchema = new mongoose.Schema({
  assignmentId: {
    type: mongoose.Schema.Types.ObjectId,  // Reference to Assignment collection
    ref: "Assignment",
    required: true,
  },
  mark: {
    type: Number,
    required: true,
  },
  feedback:{
    type:String,
    required:true,

  },
  markGrade:{
    type:String,
    required:true,
  },

  teacherId: {
    type: mongoose.Schema.Types.ObjectId,  // Reference to Teacher collection
    ref: "User", // or "Teacher" if you have a separate model
    required: true,
  },
  studentId: {
    type: mongoose.Schema.Types.ObjectId,  // Reference to Student collection
    ref: "User", // or "Student" if you have a separate model
    required: true,
  },
  classId: {
    type: mongoose.Schema.Types.ObjectId,  // Reference to Class collection
    ref: "Class",
    required: true,
  },
}, { timestamps: true }); // adds createdAt & updatedAt automatically

export default mongoose.model("AssignmentMark", assignmentMarksSchema);
