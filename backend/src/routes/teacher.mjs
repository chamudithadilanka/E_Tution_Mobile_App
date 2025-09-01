
// import express from "express";
// import User from "../models/user.mjs";
// import TeacherDetails from "../models/teacher.mjs";


// const teacherRouter = express.Router();

// teacherRouter.get('/',async (req,res)=>{
//     try{
//         const teacher = await User.find({role:"teacher"});
//         res.json(teacher);

//     }catch(error){
//         res.status(500).json({ error: err.message });
//     }
// });

// export default teacherRouter;

import express from "express";
import User from "../models/user.mjs";
import Teacher from "../models/teacher.mjs";
import fs from "fs/promises";
import path from "path";

const teacherRouter = express.Router();

const UPLOADS_DIR = path.join('C:\\Users\\msi\\Desktop\\project_final\\backend\\uploads');

// // POST: Create Teacher Profile
// teacherRouter.post("/details", async (req, res) => {
//   const { userID, gender, age, qualifications, subjects, gradesTaught, bio, profileImageBase64 } = req.body;

//   if (!userID) {
//     return res.status(400).json({ success: false, error: "User ID is required" });
//   }

//   try {
//     const userExists = await User.exists({ _id: userID });
//     if (!userExists) {
//       return res.status(404).json({ success: false, error: "User not found" });
//     }

//     const teacherExists = await Teacher.exists({ userID });
//     if (teacherExists) {
//       return res.status(409).json({ success: false, error: "Teacher profile already exists" });
//     }

//     let profileImage = null;

//     if (profileImageBase64) {
//       const matches = profileImageBase64.match(/^data:image\/(jpeg|jpg|png);base64,(.+)$/i);
//       if (!matches) {
//         return res.status(400).json({
//           success: false,
//           error: "Invalid image format. Only JPEG/JPG/PNG allowed"
//         });
//       }

//       const ext = matches[1];
//       const base64Data = matches[2];
//       const buffer = Buffer.from(base64Data, "base64");

//       if (buffer.length > 5 * 1024 * 1024) {
//         return res.status(413).json({
//           success: false,
//           error: "Image too large. Maximum size is 5MB"
//         });
//       }

//       try {
//         await fs.access(UPLOADS_DIR);
//       } catch {
//         await fs.mkdir(UPLOADS_DIR, { recursive: true });
//       }

//       profileImage = `teacher_${Date.now()}.${ext}`;
//       await fs.writeFile(path.join(UPLOADS_DIR, profileImage), buffer);
//     }

//     const teacher = await Teacher.create({
//       userID,
//       profileImage,
//       gender,
//       age: parseInt(age),
//       qualifications,
//       subjects,
//       gradesTaught,
//       bio
//     });

//     return res.status(201).json({
//       success: true,
//       message: "Teacher profile created successfully",
//       data: {
//         ...teacher.toObject(),
//         profileImageUrl: profileImage
//           ? `${req.protocol}://${req.get('host')}/uploads/${profileImage}`
//           : null
//       }
//     });

//   } catch (err) {
//     console.error("Teacher creation error:", err);
//     res.status(500).json({
//       success: false,
//       error: "Internal server error",
//       details: err.message
//     });
//   }
// });






// POST: Create Teacher Profile
teacherRouter.post("/details", async (req, res) => {
  const { userID, gender, age, qualifications, subjects, gradesTaught, bio, profileImageBase64 } = req.body;

  if (!userID) {
    return res.status(400).json({ success: false, error: "User ID is required" });
  }

  try {
    const userExists = await User.exists({ _id: userID });
    if (!userExists) {
      return res.status(404).json({ success: false, error: "User not found" });
    }

    const teacherExists = await Teacher.exists({ userID });
    if (teacherExists) {
      return res.status(409).json({ success: false, error: "Teacher profile already exists" });
    }

    let profileImage = null;

    // If profile image is provided, handle base64 upload
    if (profileImageBase64) {
      const matches = profileImageBase64.match(/^data:image\/(jpeg|jpg|png);base64,(.+)$/i);
      if (!matches) {
        return res.status(400).json({
          success: false,
          error: "Invalid image format. Only JPEG/JPG/PNG allowed"
        });
      }

      const ext = matches[1]; // Get the image extension (jpeg, jpg, or png)
      const base64Data = matches[2]; // Base64 encoded image data
      const buffer = Buffer.from(base64Data, "base64");

      if (buffer.length > 5 * 1024 * 1024) {
        return res.status(413).json({
          success: false,
          error: "Image too large. Maximum size is 5MB"
        });
      }

      // Ensure the uploads directory exists
      try {
        await fs.access(UPLOADS_DIR);
      } catch {
        await fs.mkdir(UPLOADS_DIR, { recursive: true });
      }

      profileImage = `teacher_${Date.now()}.${ext}`;
      // Save the image to the uploads directory
      await fs.writeFile(path.join(UPLOADS_DIR, profileImage), buffer);
    }

    // Create the teacher profile in the database
    const teacher = await Teacher.create({
      userID,
      profileImage,
      gender,
      age: parseInt(age),
      qualifications,
      subjects,
      gradesTaught,
      bio
    });

    // Return the response with the full image URL
    return res.status(201).json({
      success: true,
      message: "Teacher profile created successfully",
      data: {
        ...teacher.toObject(),
        profileImageUrl: profileImage
          ? `${req.protocol}://${req.get('host')}/uploads/${profileImage}`
          : null // If no profile image, return null
      }
    });

  } catch (err) {
    console.error("Teacher creation error:", err);
    return res.status(500).json({
      success: false,
      error: "Internal server error",
      details: err.message
    });
  }
});



// teacherRouter.get("/details/:userID", async (req, res) => {
//   const { userID } = req.params;

//   try {
//     const teacher = await TeacherDetails.findOne({ userID }).populate("userID", "name email role");

//     if (!teacher) {
//       return res.status(404).json({
//         success: false,
//         error: "Teacher profile not found"
//       });
//     }

//     return res.json({
//       success: true,
//       data: {
//         ...teacher.toObject(),
//         profileImageUrl: teacher.profileImage 
//           ? `${req.protocol}://${req.get("host")}/uploads/${teacher.profileImage}`
//           : null
//       }
//     });

//   } catch (err) {
//     console.error("Teacher fetch error:", err);
//     return res.status(500).json({
//       success: false,
//       error: "Internal server error",
//       details: process.env.NODE_ENV === "development" ? err.message : undefined
//     });
//   }
// });


// teacherRouter.mjs

teacherRouter.get("/details/:userID", async (req, res) => {
  const { userID } = req.params;

  try {
    // 1. Check if user exists and role = teacher
    const user = await User.findOne({ _id: userID, role: "teacher" })
      .select("-password -__v");

    if (!user) {
      return res.status(404).json({
        success: false,
        error: "Teacher user not found",
      });
    }

    // 2. Fetch teacher profile
    const teacherDetails = await Teacher.findOne({ userID }).select("-__v");

    if (!teacherDetails) {
      return res.status(404).json({
        success: false,
        error: "Teacher profile not found",
      });
    }

    // 3. Convert to object and build profile image URL
    const teacher = teacherDetails.toObject();
    if (teacher.profileImage) {
      teacher.profileImageUrl = `${req.protocol}://${req.get("host")}/uploads/${teacher.profileImage}`;
    } else {
      teacher.profileImageUrl = null;
    }

    // 4. Send final response
    return res.status(200).json({
      success: true,
      message: "Teacher details fetched successfully",
      data: {
        user,      // user basic info (name, email, role)
        profile: teacher, // teacher-specific info
      },
    });

  } catch (error) {
    console.error("Error fetching teacher details:", error);
    return res.status(500).json({
      success: false,
      message: "Internal server error",
      error: process.env.NODE_ENV === "development" ? error.message : undefined,
    });
  }
});

// teacherRouter.put("/details/:userID", async (req, res) => {
//   const { userID } = req.params;
//   const {
//     firstName,
//     lastName,
//     email,
//     subject,
//     qualifications,
//     experience,
//     profileImageBase64
//   } = req.body;

//   if (!userID) {
//     return res.status(400).json({
//       success: false,
//       error: "User ID is required"
//     });
//   }

//   try {
//     // Find teacher and user
//     const teacher = await Teacher.findOne({ userID });
//     const user = await User.findById(userID); // assumes User._id === userID

//     if (!teacher) {
//       return res.status(404).json({
//         success: false,
//         error: "Teacher profile not found"
//       });
//     }

//     if (!user) {
//       return res.status(404).json({
//         success: false,
//         error: "User data not found"
//       });
//     }

//     // --- Update profile image if provided ---
//     if (profileImageBase64) {
//       const matches = profileImageBase64.match(/^data:image\/(jpeg|jpg|png);base64,(.+)$/i);
//       if (!matches) {
//         return res.status(400).json({
//           success: false,
//           error: "Invalid image format. Only JPEG/JPG/PNG allowed"
//         });
//       }

//       const imageType = matches[1];
//       const base64Data = matches[2];
//       const buffer = Buffer.from(base64Data, "base64");

//       // optional: check file size
//       if (buffer.length > 5 * 1024 * 1024) {
//         return res.status(413).json({
//           success: false,
//           error: "Image too large. Maximum size is 5MB"
//         });
//       }

//       // ensure uploads directory exists
//       try {
//         await fs.access(UPLOADS_DIR);
//       } catch {
//         await fs.mkdir(UPLOADS_DIR, { recursive: true });
//       }

//       const profileImage = `teacher_${Date.now()}.${imageType}`;
//       await fs.writeFile(path.join(UPLOADS_DIR, profileImage), buffer);
//       teacher.profileImage = profileImage;
//     }

//     // --- Update teacher fields ---
//     if (subject) teacher.subject = subject;
//     if (qualifications) teacher.qualifications = qualifications;
//     if (experience) teacher.experience = experience;

//     await teacher.save();

//     // --- Update user fields ---
//     if (firstName) user.firstName = firstName;
//     if (lastName) user.lastName = lastName;
//     if (email) user.email = email;

//     await user.save();

//     // --- Return updated data ---
//     const data = {
//       ...teacher.toObject(),
//       profileImageUrl: teacher.profileImage
//         ? `${req.protocol}://${req.get("host")}/uploads/${teacher.profileImage}`
//         : null,
//       userDetails: {
//         firstName: user.firstName,
//         lastName: user.lastName,
//         email: user.email
//       }
//     };

//     return res.status(200).json({
//       success: true,
//       message: "Teacher and user profile updated successfully",
//       data
//     });

//   } catch (err) {
//     console.error("Error updating teacher:", err);
//     return res.status(500).json({
//       success: false,
//       error: "Internal server error",
//       details: process.env.NODE_ENV === "development" ? err.message : undefined
//     });
//   }
// });
teacherRouter.put("/details/:userID", async (req, res) => {
  const { userID } = req.params;
  const {
    firstName,
    lastName,
    email,
    subject,
    qualifications,
    gradesTaught,
    experience,
    gender,
    age,
    bio,
    profileImageBase64
  } = req.body;

  if (!userID) {
    return res.status(400).json({ success: false, error: "User ID is required" });
  }

  try {
    const teacher = await Teacher.findOne({ userID });
    const user = await User.findById(userID);

    if (!teacher) {
      return res.status(404).json({ success: false, error: "Teacher profile not found" });
    }

    if (!user) {
      return res.status(404).json({ success: false, error: "User data not found" });
    }

    // --- Handle profile image ---
    if (profileImageBase64) {
      const matches = profileImageBase64.match(/^data:image\/(jpeg|jpg|png);base64,(.+)$/i);
      if (!matches) {
        return res.status(400).json({ success: false, error: "Invalid image format. Only JPEG/JPG/PNG allowed" });
      }

      const imageType = matches[1];
      const base64Data = matches[2];
      const buffer = Buffer.from(base64Data, "base64");

      if (buffer.length > 5 * 1024 * 1024) {
        return res.status(413).json({ success: false, error: "Image too large. Maximum size is 5MB" });
      }

      try {
        await fs.access(UPLOADS_DIR);
      } catch {
        await fs.mkdir(UPLOADS_DIR, { recursive: true });
      }

      const profileImage = `teacher_${Date.now()}.${imageType}`;
      await fs.writeFile(path.join(UPLOADS_DIR, profileImage), buffer);
      teacher.profileImage = profileImage;
    }

    // --- Update teacher fields ---
    if (subject) teacher.subject = subject;
    if (qualifications) teacher.qualifications = qualifications;
    if (gradesTaught) teacher.gradesTaught = gradesTaught;
    if (experience) teacher.experience = experience;
    if (gender) teacher.gender = gender;
    if (age) teacher.age = age;
    if (bio) teacher.bio = bio;

    await teacher.save();

    // --- Update user fields ---
    if (firstName) user.firstName = firstName;
    if (lastName) user.lastName = lastName;
    if (email) user.email = email;

    await user.save();

    // --- Return ALL details ---
    const data = {
      ...teacher.toObject(),
      profileImageUrl: teacher.profileImage
        ? `${req.protocol}://${req.get("host")}/uploads/${teacher.profileImage}`
        : null,
      userDetails: {
        ...user.toObject()
      }
    };

    return res.status(200).json({
      success: true,
      message: "Teacher and user profile updated successfully",
      data
    });

  } catch (err) {
    console.error("Error updating teacher:", err);
    return res.status(500).json({
      success: false,
      error: "Internal server error",
      details: process.env.NODE_ENV === "development" ? err.message : undefined
    });
  }
});

export default teacherRouter;

