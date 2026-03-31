const asyncHandler = require('express-async-handler');
const Assignment = require("../../Model/Admin/AssignmentJobControllerModel");
const Jobs = require('../../Model/Admin/JobsModel');
const Projects = require("../../Model/Admin/ProjectsModel");
const User = require('../../Model/userModel');
const mongoose = require("mongoose");

// const RemoveAssignedJob = asyncHandler(async (req, res) => {
//   const { employeeId, jobId } = req.body;

//   const employeeIdValue = Array.isArray(employeeId) ? employeeId[0] : employeeId;

//   if (!mongoose.Types.ObjectId.isValid(employeeIdValue)) {
//     return res.status(400).json({ success: false, message: 'Invalid employee ID' });
//   }

//   const user = await User.findById(employeeIdValue);
//   if (!user) {
//     return res.status(404).json({ success: false, message: 'Employee not found' });
//   }

//   if (!Array.isArray(jobId) || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//     return res.status(400).json({
//       success: false,
//       message: 'Invalid job ID format. Ensure array of valid IDs.'
//     });
//   }

//   const assignment = await Assignment.findOne({ employeeId: employeeIdValue });
//   if (!assignment) {
//     return res.status(404).json({ success: false, message: 'No assignment found for this employee' });
//   }

//   const beforeCount = assignment.jobId.length;
//   assignment.jobId = assignment.jobId.filter(
//     id => !jobId.includes(id.toString())
//   );

//   if (assignment.jobId.length === beforeCount) {
//     return res.status(400).json({
//       success: false,
//       message: 'No matching jobId(s) found in this assignment'
//     });
//   }

//   try {
//   const data = await assignment.save();
//   if (data) {
//     await Jobs.updateMany(
//       { _id: { $in: Array.isArray(jobId) ? jobId : [jobId] } },
//       { $set: { Status: "In Progress" } }
//     );
//   }
// } catch (err) {
//   console.error(err);
// }

//   res.status(200).json({
//   success: true,
//   message: 'Job(s) removed successfully',
//   assignment
// });
// });

// const RemoveAssignedJob = asyncHandler(async (req, res) => {
//   const { employeeId, jobId } = req.body;

//   const employeeIdValue = Array.isArray(employeeId) ? employeeId[0] : employeeId;

//   // Validate employeeId
//   if (!mongoose.Types.ObjectId.isValid(employeeIdValue)) {
//     return res.status(400).json({ success: false, message: 'Invalid employee ID' });
//   }

//   const user = await User.findById(employeeIdValue);
//   if (!user) {
//     return res.status(404).json({ success: false, message: 'Employee not found' });
//   }

//   // Validate jobId array
//   if (!Array.isArray(jobId) || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//     return res.status(400).json({
//       success: false,
//       message: 'Invalid job ID format. Ensure array of valid IDs.'
//     });
//   }

//   const assignment = await Assignment.findOne({ employeeId: employeeIdValue });
//   if (!assignment) {
//     return res.status(404).json({ success: false, message: 'No assignment found for this employee' });
//   }

//   try {
//     // 1. Update Jobs collection
//     await Jobs.updateMany(
//       { _id: { $in: jobId } },
//       { $set: { Status: "In Progress" } }
//     );

//     // 2. Update nested jobs array in Assignment
//     const result = await Assignment.updateOne(
//       { employeeId: employeeIdValue },
//       {
//         $set: {
//           "jobs.$[elem].jobReturnStatus": true
//         }
//       },
//       {
//         arrayFilters: [
//           { "elem.jobId": { $in: jobId.map(id => new mongoose.Types.ObjectId(id)) } }
//         ]
//       }
//     );

//     console.log("Jobs returned:", jobId);
//     console.log("Assignment update result:", result);

//     return res.status(200).json({
//       success: true,
//       message: 'Job(s) marked as returned successfully',
//       assignment
//     });

//   } catch (err) {
//     console.error(err);
//     return res.status(500).json({ success: false, message: 'Error updating jobs' });
//   }
// });

const RemoveAssignedJob = asyncHandler(async (req, res) => {
  const { employeeId, jobId } = req.body;

  const employeeIdValue = Array.isArray(employeeId) ? employeeId[0] : employeeId;

  // Validate employeeId
  if (!mongoose.Types.ObjectId.isValid(employeeIdValue)) {
    return res.status(400).json({ success: false, message: 'Invalid employee ID' });
  }

  const user = await User.findById(employeeIdValue);
  if (!user) {
    return res.status(404).json({ success: false, message: 'Employee not found' });
  }

  // Validate jobId array
  if (!Array.isArray(jobId) || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
    return res.status(400).json({
      success: false,
      message: 'Invalid job ID format. Ensure array of valid IDs.'
    });
  }

  const assignment = await Assignment.findOne({ employeeId: employeeIdValue });
  if (!assignment) {
    return res.status(404).json({ success: false, message: 'No assignment found for this employee' });
  }

  try {
    // 1. Update Jobs collection
    await Jobs.updateMany(
      { _id: { $in: jobId } },
      { $set: { Status: "In Progress" } }
    );

    // 2. Update nested jobs array in Assignment
    const result = await Assignment.updateOne(
      { employeeId: employeeIdValue },
      {
        $set: {
          "jobs.$[elem].jobReturnStatus": true
        }
      },
      {
        arrayFilters: [
          { "elem.jobId": { $in: jobId.map(id => new mongoose.Types.ObjectId(id)) } }
        ]
      }
    );

    console.log("Jobs returned:", jobId);
    console.log("Assignment update result:", result);

    return res.status(200).json({
      success: true,
      message: 'Job(s) marked as returned successfully',
      assignment
    });

  } catch (err) {
    console.error(err);
    return res.status(500).json({ success: false, message: 'Error updating jobs' });
  }
});


// const ReturnAssignedJob = asyncHandler(async (req, res) => {
//   const data = await Assignment.find();

//   if (!data || data.length === 0) {
//     return res.status(404).json({
//       success: false,
//       message: 'No assigned jobs found'
//     });
//   }

//   // Filter only those assignments where jobId is empty
//   const returnedJobs = data
//     .filter(item => !item.jobId || (Array.isArray(item.jobId) && item.jobId.length === 0))
//     .map(item => ({
//       ...item.toObject(),
//       jobId: "This job return by this emp"
//     }));

//   if (returnedJobs.length === 0) {
//     return res.status(404).json({
//       success: false,
//       message: 'No returned jobs found'
//     });
//   }

//   res.status(200).json({
//     success: true,
//     message: 'Returned jobs retrieved successfully',
//     data: returnedJobs
//   });
// });


const ReturnAssignedJobHistory = asyncHandler(async (req, res) => {
  const data = await Assignment.find();

  if (!data || data.length === 0) {
    return res.status(404).json({
      success: false,
      message: 'No assigned jobs found'
    });
  }

  const returnedJobs = await Promise.all(
    data.map(async (item) => {
      const userData = await User.findById(item.employeeId || item.empId);
     
      const updatedJobs = await Promise.all(
        (item.jobs || []).map(async (j) => {
          if (j.jobReturnStatus === true) {
            const jobDetails = await Jobs.findById(j.jobId);
            const employeeName = userData ? `${ userData.firstName } ${ userData.lastName }`: "Unknown Employee";

            if (jobDetails) {
              return {
                ...j.toObject(),
                ...jobDetails.toObject(),
                message: `Job ${jobDetails.JobNo} returned by ${employeeName}`,
              };
            } else {
              return {
                ...j.toObject(),
                message: `Job undefined returned by ${employeeName}`,
              };
            }
          } else {
            return j.toObject();
          }
        })
      );

      return {
        ...item.toObject(),
        employeeData: userData || null,
        jobs: updatedJobs,
      };
    })
  );

  if (returnedJobs.length === 0) {
    return res.status(404).json({
      success: false,
      message: 'No returned jobs found'
    });
  }

  res.status(200).json({
    success: true,
    message: 'Returned jobs retrieved successfully',
    data: returnedJobs
  });
});

const ReturnAssignedJob = asyncHandler(async (req, res) => {
  const assignments = await Assignment.find();

  let result = [];

  for (const assignment of assignments) {
    const employee = await User.findById(assignment.employeeId);

    // Sirf wo jobs filter karo jinka jobReturnStatus true hai
    const returnedJobs = assignment.jobs.filter(j => j.jobReturnStatus === true);

    for (const j of returnedJobs) {
      // Job details ke saath project populate kar rahe hain
      const jobDetails = await Jobs.findById(j.jobId)
        .populate("projectId", "projectName projectNo"); // <-- yaha se project data aa jayega

      if (jobDetails) {
        result.push({
          jobId: j.jobId,
          jobReturnStatus: j.jobReturnStatus,
          employee: {
            _id: employee?._id,
            name: employee ? `${employee.firstName} ${employee.lastName}` : "Unknown Employee",
            email: employee?.email || ""
          },
          jobdata: jobDetails,
        });
      }
    }
  }

  res.status(200).json({
    success: true,
    message: "Returned jobs fetched successfully",
    data: result,
  });
});


module.exports = { RemoveAssignedJob, ReturnAssignedJobHistory, ReturnAssignedJob };

