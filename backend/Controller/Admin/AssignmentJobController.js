// const asyncHandler = require('express-async-handler');
// const Assignment = require("../../Model/Admin/AssignmentJobControllerModel");
// const Jobs = require('../../Model/Admin/JobsModel');
// const User = require('../../Model/userModel');
// const mongoose = require("mongoose");

// const AssignmentCreate = asyncHandler(async (req, res) => {
//     const {
//         employeeId,     
//         jobId,         
//         selectDesigner,
//         description
//     } = req.body;

//     if (!Array.isArray(jobId) || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//         return res.status(400).json({
//             success: false,
//             message: "Invalid job ID format. Ensure all IDs are valid."
//         });
//     }

//     if (!Array.isArray(employeeId) || employeeId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//         return res.status(400).json({
//             success: false,
//             message: "Invalid employee ID format. Ensure all IDs are valid."
//         });
//     }

//     const jobs = await Jobs.find({ _id: { $in: jobId } });
//     if (jobs.length !== jobId.length) {
//         return res.status(404).json({
//             success: false,
//             message: "One or more jobs not found"
//         });
//     }

//     const users = await User.find({ _id: { $in: employeeId } });
//     if (users.length !== employeeId.length) {
//         return res.status(404).json({
//             success: false,
//             message: "One or more employees not found"
//         });
//     }

//     const newAssignment = new Assignment({
//         employeeId,
//         jobId,
//         selectDesigner,
//         description,
//     });
//     await newAssignment.save();
//     res.status(201).json({
//         success: true,
//         message: "Assignment created successfully",
//         assignment: newAssignment,
//     });
// });


// const AssignmentCreate = asyncHandler(async (req, res) => {
//     const {
//         employeeId,     
//         jobId,         
//         selectDesigner,
//         description
//     } = req.body;

//     if (!Array.isArray(jobId) || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//         return res.status(400).json({
//             success: false,
//             message: "Invalid job ID format. Ensure all IDs are valid."
//         });
//     }

//     if (!Array.isArray(employeeId) || employeeId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//         return res.status(400).json({
//             success: false,
//             message: "Invalid employee ID format. Ensure all IDs are valid."
//         });
//     }

//     const jobs = await Jobs.find({ _id: { $in: jobId } });
//     if (jobs.length !== jobId.length) {
//         return res.status(404).json({
//             success: false,
//             message: "One or more jobs not found"
//         });
//     }

//     const users = await User.find({ _id: { $in: employeeId } });
//     if (users.length !== employeeId.length) {
//         return res.status(404).json({
//             success: false,
//             message: "One or more employees not found"
//         });
//     }

//     // Find existing assignment for the given employeeId
//     const existingAssignment = await Assignment.findOne({
//         employeeId: { $in: employeeId },  // Checks if employeeId already exists
//         jobId: { $in: jobId }  // Checks if jobId is already assigned to the employee
//     });

//     if (existingAssignment) {
//         // If both employeeId and jobId exist in the database
//         return res.status(200).json({
//             success: false,
//             message: "Job already assigned to this employee."
//         });
//     } else {
//         // If assignment exists for the employee, but jobId is not present, add jobId
//         const existingAssignmentForEmployee = await Assignment.findOne({
//             employeeId: { $in: employeeId }
//         });

//         if (existingAssignmentForEmployee) {
//             // Push the new jobId to the existing record
//             const newJobIds = [...new Set([...existingAssignmentForEmployee.jobId, ...jobId])]; // Remove duplicates
//             existingAssignmentForEmployee.jobId = newJobIds;
//             existingAssignmentForEmployee.selectDesigner = selectDesigner;
//             existingAssignmentForEmployee.description = description;

//             await existingAssignmentForEmployee.save();

//             return res.status(200).json({
//                 success: true,
//                 message: "Job added to existing employee assignment",
//                 assignment: existingAssignmentForEmployee,
//             });
//         } else {
//             // If no existing record for the employee, create a new assignment
//             const newAssignment = new Assignment({
//                 employeeId,
//                 jobId,
//                 selectDesigner,
//                 description,
//             });

//             await newAssignment.save();

//             return res.status(201).json({
//                 success: true,
//                 message: "Assignment created successfully",
//                 assignment: newAssignment,
//             });
//         }
//     }
// });

// const AssignmentCreate = asyncHandler(async (req, res) => {
//     const {
//         employeeId,     
//         jobId,         
//         selectDesigner,
//         description
//     } = req.body;

//     if (!Array.isArray(jobId) || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//         return res.status(400).json({
//             success: false,
//             message: "Invalid job ID format. Ensure all IDs are valid."
//         });
//     }

//     if (!Array.isArray(employeeId) || employeeId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//         return res.status(400).json({
//             success: false,
//             message: "Invalid employee ID format. Ensure all IDs are valid."
//         });
//     }

//     const jobs = await Jobs.find({ _id: { $in: jobId } });
//     if (jobs.length !== jobId.length) {
//         return res.status(404).json({
//             success: false,
//             message: "One or more jobs not found"
//         });
//     }

//     const users = await User.find({ _id: { $in: employeeId } });
//     if (users.length !== employeeId.length) {
//         return res.status(404).json({
//             success: false,
//             message: "One or more employees not found"
//         });
//     }

//     // Check if the jobId is already assigned to any employee
//     const existingJobAssignment = await Assignment.findOne({
//         jobId: { $in: jobId }  // Check if jobId is already assigned
//     });

//     if (existingJobAssignment) {
//         // If the jobId is assigned to another employee, return a message
//         return res.status(400).json({
//             success: false,
//             message: "Job already assigned to another employee."
//         });
//     } else {
//         // Find existing assignment for the given employeeId
//         const existingAssignment = await Assignment.findOne({
//             employeeId: { $in: employeeId }  // Checks if employeeId already exists
//         });

//         if (existingAssignment) {
//             // Check if the jobId already exists in the assignment
//             const existingJobIds = existingAssignment.jobId || [];

//             // If the jobId is not already present, push it to the jobId array
//             const newJobIds = [...new Set([...existingJobIds, ...jobId])]; // Remove duplicates
//             if (existingJobIds.length !== newJobIds.length) {
//                 existingAssignment.jobId = newJobIds;
//                 existingAssignment.selectDesigner = selectDesigner;
//                 existingAssignment.description = description;

//                 await existingAssignment.save();

//                 return res.status(200).json({
//                     success: true,
//                     message: "Job added to existing employee assignment",
//                     assignment: existingAssignment,
//                 });
//             } else {
//                 return res.status(400).json({
//                     success: false,
//                     message: "The jobId already exists for this employee."
//                 });
//             }
//         } else {
//             // If no assignment exists for the employeeId, create a new assignment
//             const newAssignment = new Assignment({
//                 employeeId,
//                 jobId,
//                 selectDesigner,
//                 description,
//             });

//             await newAssignment.save();

//             return res.status(201).json({
//                 success: true,
//                 message: "Assignment created successfully",
//                 assignment: newAssignment,
//             });
//         }
//     }
// });

const asyncHandler = require('express-async-handler');
const Assignment = require("../../Model/Admin/AssignmentJobControllerModel");
const Jobs = require('../../Model/Admin/JobsModel');
const User = require('../../Model/userModel');
const mongoose = require("mongoose");

// const AssignmentCreate = asyncHandler(async (req, res) => {
//     const {
//         employeeId,
//         jobId,
//         selectDesigner,
//         description
//     } = req.body;

//     // ✅ 1. Validate jobId
//     if (!Array.isArray(jobId) || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//         return res.status(400).json({
//             success: false,
//             message: "Invalid job ID format."
//         });
//     }
//     const jobs = await Jobs.find({ _id: { $in: jobId } });
//     if (jobs.length !== jobId.length) {
//         return res.status(404).json({
//             success: false,
//             message: "One or more jobs not found"
//         });
//     }

//     // ✅ 2. Validate employeeId
//     let users = [];
//     if (employeeId && employeeId.length > 0) {
//         if (!Array.isArray(employeeId) || employeeId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//             return res.status(400).json({
//                 success: false,
//                 message: "Invalid employee ID format."
//             });
//         }

//         users = await User.find({ _id: { $in: employeeId } });
//         if (users.length !== employeeId.length) {
//             return res.status(404).json({
//                 success: false,
//                 message: "One or more employees not found"
//             });
//         }
//     }

//     // ✅ 3. Check if job already assigned
//     const existingJobAssignment = await Assignment.findOne({
//         jobId: { $in: jobId }
//     }).populate('employeeId');

//     if (existingJobAssignment) {
//         const designer = existingJobAssignment.selectDesigner?.toLowerCase();

//         if (designer !== 'production' && existingJobAssignment.jobReturnStatus === false ) {
//             return res.status(409).json({
//                 success: false,
//                 message: "Job already assigned to an employee. Cannot reassign."
//             });
//         }

//         if (!(employeeId && employeeId.length > 0)) {
//             return res.status(409).json({
//                 success: false,
//                 message: "Job already assigned to Production."
//             });
//         }
//     }

//     // ✅ 4. If assignment already exists for employee, just add jobId
//     if (employeeId && employeeId.length > 0) {
//         const existingAssignment = await Assignment.findOne({
//             employeeId: { $in: employeeId }
//         });

//         if (existingAssignment) {
//             const existingJobIds = existingAssignment.jobId || [];
//             const newJobIds = [...new Set([...existingJobIds, ...jobId])];

//             if (existingJobIds.length !== newJobIds.length) {
//                 existingAssignment.jobId = newJobIds;
//                 existingAssignment.selectDesigner = selectDesigner;
//                 existingAssignment.description = description;

//                 await existingAssignment.save();

//                 // ✅ FIX: Update assign field in Jobs
//                 const assignedUser = await User.findById(employeeId[0]);
//                 const assignValue = assignedUser
//                     ? `${assignedUser.firstName} ${assignedUser.lastName}`
//                     : "production";

//                 await Jobs.updateMany(
//                     { _id: { $in: jobId } },
//                     {
//                         $set: {
//                             Status: "In Progress",
//                             employeeId,
//                             selectDesigner,
//                             description,
//                             assign: assignValue
//                         }
//                     }
//                 );

//                 return res.status(200).json({
//                     success: true,
//                     message: "Job added to existing employee assignment",
//                     assignment: existingAssignment,
//                 });
//             } else {
//                 return res.status(400).json({
//                     success: false,
//                     message: "The jobId already exists for this employee."
//                 });
//             }
//         }
//     }

//     // ✅ 5. New assignment
//     const newAssignment = new Assignment({
//         employeeId: employeeId && employeeId.length > 0 ? employeeId : null,
//         jobId,
//         selectDesigner,
//         description,
//     });

//     await newAssignment.save();
//     await newAssignment.populate('employeeId');

//     const statusValue = employeeId && employeeId.length > 0 ? "In Progress" : "Active";
//     // ✅ Set assign field properly
//     let assignValue = "Not Assigned";
//     if (employeeId && employeeId.length > 0) {
//         const assignedUser = await User.findById(employeeId[0]);
//         assignValue = assignedUser
//             ? `${assignedUser.firstName} ${assignedUser.lastName}`
//             : "production";
//     } else {
//         assignValue = "production";
//     }

//     await Jobs.updateMany(
//         { _id: { $in: jobId } },
//         {
//             $set: {
//                 Status: statusValue,
//                 employeeId,
//                 selectDesigner,
//                 description,
//                 assign: assignValue
//             }
//         }
//     );

//     return res.status(201).json({
//         success: true,
//         message: "Assignment created successfully",
//         assignment: newAssignment,
//     });
// });




//GET SINGLE ProjectsUpdate
//METHOD:PUT
// GET /api/assignments/by-employee/:employeeId
// const AssignmentCreate = asyncHandler(async (req, res) => {
//     const { employeeId, jobId, selectDesigner, description } = req.body;

//     // 1. Validate jobId
//     if (!Array.isArray(jobId) || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//         return res.status(400).json({
//             success: false,
//             message: "Invalid job ID format."
//         });
//     }
//     const jobsData = await Jobs.find({ _id: { $in: jobId } });
//     if (jobsData.length !== jobId.length) {
//         return res.status(404).json({
//             success: false,
//             message: "One or more jobs not found"
//         });
//     }

//     // 2. Validate employeeId
//     let users = [];
//     if (employeeId && employeeId.length > 0) {
//         if (!Array.isArray(employeeId) || employeeId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//             return res.status(400).json({
//                 success: false,
//                 message: "Invalid employee ID format."
//             });
//         }

//         users = await User.find({ _id: { $in: employeeId } });
//         if (users.length !== employeeId.length) {
//             return res.status(404).json({
//                 success: false,
//                 message: "One or more employees not found"
//             });
//         }
//     }

//     // 3. Check if any of the jobs are already assigned
//     const existingJobAssignment = await Assignment.findOne({
//         "jobs.jobId": { $in: jobId }
//     }).populate('employeeId');

//     if (existingJobAssignment) {
//         const designer = existingJobAssignment.selectDesigner?.toLowerCase();

//         // If assigned to someone (not production) and not returned yet
//         if (designer !== 'production') {
//             const jobReturned = existingJobAssignment.jobs.some(j =>
//                 jobId.includes(j.jobId.toString()) && j.jobReturnStatus === false
//             );
//             if (jobReturned) {
//                 return res.status(409).json({
//                     success: false,
//                     message: "Job already assigned to an employee. Cannot reassign."
//                 });
//             }
//         }

//         if (!(employeeId && employeeId.length > 0)) {
//             return res.status(409).json({
//                 success: false,
//                 message: "Job already assigned to Production."
//             });
//         }
//     }

//     // 4. If assignment already exists for the employee, just add new jobs
//     if (employeeId && employeeId.length > 0) {
//         const existingAssignment = await Assignment.findOne({
//             employeeId: { $in: employeeId }
//         });
//         if (existingAssignment) {
//             let updated = false;

//             jobId.forEach(id => {
//                 const existingJob = existingAssignment.jobs.find(j => j.jobId.toString() === id.toString());

//                 if (existingJob) {
//                     if (existingJob.jobReturnStatus === true) {
//                         // 🔁 Update status to false
//                         existingJob.jobReturnStatus = false;
//                         updated = true;
//                     }
//                     // ❌ Don't push duplicate
//                 } else {
//                     // ✅ Only push if not present
//                     existingAssignment.jobs.push({ jobId: id, jobReturnStatus: false });
//                     updated = true;
//                 }
//             });

//             if (updated) {
//                 existingAssignment.selectDesigner = selectDesigner;
//                 existingAssignment.description = description;
//                 await existingAssignment.save();

//                 const assignedUser = await User.findById(employeeId[0]);
//                 const assignValue = assignedUser
//                     ? `${assignedUser.firstName} ${assignedUser.lastName}`
//                     : "production";

//                 await Jobs.updateMany(
//                     { _id: { $in: jobId } },
//                     {
//                         $set: {
//                             Status: "In Progress",
//                             employeeId,
//                             selectDesigner,
//                             description,
//                             assign: assignValue
//                         }
//                     }
//                 );

//                 return res.status(200).json({
//                     success: true,
//                     message: "Job(s) assigned/updated in existing assignment",
//                     assignment: existingAssignment,
//                 });
//             } else {
//                 return res.status(400).json({
//                     success: false,
//                     message: "All jobs already assigned and active.",
//                 });
//             }
//         }


//     }

//     // 5. New assignment
//     const jobsArray = jobId.map(id => ({ jobId: id, jobReturnStatus: false }));

//     const newAssignment = new Assignment({
//         employeeId: employeeId && employeeId.length > 0 ? employeeId[0] : null,
//         jobs: jobsArray,
//         selectDesigner,
//         description,
//     });

//     await newAssignment.save();
//     await newAssignment.populate('employeeId');

//     const statusValue = employeeId && employeeId.length > 0 ? "In Progress" : "Active";
//     let assignValue = "Not Assigned";
//     if (employeeId && employeeId.length > 0) {
//         const assignedUser = await User.findById(employeeId[0]);
//         assignValue = assignedUser
//             ? `${assignedUser.firstName} ${assignedUser.lastName}`
//             : "production";
//     } else {
//         assignValue = "production";
//     }

//     await Jobs.updateMany(
//         { _id: { $in: jobId } },
//         {
//             $set: {
//                 Status: statusValue,
//                 employeeId,
//                 selectDesigner,
//                 description,
//                 assign: assignValue
//             }
//         }
//     );

//     return res.status(201).json({
//         success: true,
//         message: "Assignment created successfully",
//         assignment: newAssignment,
//     });
// });

const AssignmentCreate = asyncHandler(async (req, res) => {
    const { employeeId, jobId, selectDesigner, description } = req.body;

    // 1. Validate jobId
    if (!Array.isArray(jobId) || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
        return res.status(400).json({
            success: false,
            message: "Invalid job ID format."
        });
    }

    const jobsData = await Jobs.find({ _id: { $in: jobId } });
    if (jobsData.length !== jobId.length) {
        return res.status(404).json({
            success: false,
            message: "One or more jobs not found"
        });
    }

    // 2. Validate employeeId
    let users = [];
    if (employeeId && employeeId.length > 0) {
        if (!Array.isArray(employeeId) || employeeId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
            return res.status(400).json({
                success: false,
                message: "Invalid employee ID format."
            });
        }

        users = await User.find({ _id: { $in: employeeId } });
        if (users.length !== employeeId.length) {
            return res.status(404).json({
                success: false,
                message: "One or more employees not found"
            });
        }
    }

    // 3. Check if any of the jobs are already assigned
    const existingJobAssignment = await Assignment.findOne({
        "jobs.jobId": { $in: jobId }
    }).populate('employeeId');
    if (existingJobAssignment) {
        const designer = existingJobAssignment.selectDesigner?.toLowerCase();
        const blockingJobs = await Jobs.find({
            _id: { $in: jobId },
            Status: { $ne: "Completed" } // ✅ Block only if job is not completed
        });
        const blockingJobIds = blockingJobs.map(job => job._id.toString());
        if (designer !== 'production') {
            const jobReturned = existingJobAssignment.jobs.some(j =>
                blockingJobIds.includes(j.jobId.toString()) && j.jobReturnStatus === false
            );
            if (jobReturned) {
                return res.status(409).json({
                    success: false,
                    message: "Job already assigned and not completed. Cannot reassign."
                });
            }
        }

        if (!(employeeId && employeeId.length > 0)) {
            const jobReturnedToProduction = existingJobAssignment.jobs.some(j =>
                blockingJobIds.includes(j.jobId.toString()) && j.jobReturnStatus === false
            );

            if (jobReturnedToProduction) {
                return res.status(409).json({
                    success: false,
                    message: "Job already assigned to Production and not completed."
                });
            }
        }
    }

    // 4. If assignment already exists for the employee, just add new jobs
    if (employeeId && employeeId.length > 0) {
        const existingAssignment = await Assignment.findOne({
            employeeId: { $in: employeeId }
        });

        if (existingAssignment) {
            let updated = false;

            for (const id of jobId) {
                const existingJob = existingAssignment.jobs.find(j => j.jobId.toString() === id.toString());
                const jobData = await Jobs.findById(id);

                if (existingJob) {
                    // ✅ Allow reassigning if job was returned or completed
                    if (existingJob.jobReturnStatus === true || jobData?.Status === "Completed") {
                        existingJob.jobReturnStatus = false;
                        updated = true;
                    }
                } else {
                    // ✅ Add new job
                    existingAssignment.jobs.push({ jobId: id, jobReturnStatus: false });
                    updated = true;
                }
            }

            if (updated) {
                existingAssignment.selectDesigner = selectDesigner;
                existingAssignment.description = description;
                await existingAssignment.save();

                const assignedUser = await User.findById(employeeId[0]);
                const assignValue = assignedUser
                    ? `${assignedUser.firstName} ${assignedUser.lastName}`
                    : "production";

                await Jobs.updateMany(
                    { _id: { $in: jobId } },
                    {
                        $set: {
                            Status: "In Progress",
                            employeeId,
                            selectDesigner,
                            description,
                            assign: assignValue
                        }
                    }
                );

                return res.status(200).json({
                    success: true,
                    message: "Job(s) assigned/updated in existing assignment",
                    assignment: existingAssignment,
                });
            } else {
                return res.status(400).json({
                    success: false,
                    message: "All jobs already assigned and active.",
                });
            }
        }
    }

    // 5. New assignment
    const jobsArray = jobId.map(id => ({ jobId: id, jobReturnStatus: false }));

    const newAssignment = new Assignment({
        employeeId: employeeId && employeeId.length > 0 ? employeeId[0] : null,
        jobs: jobsArray,
        selectDesigner,
        description,
    });

    await newAssignment.save();
    await newAssignment.populate('employeeId');

    const statusValue = employeeId && employeeId.length > 0 ? "In Progress" : "Active";
    let assignValue = "Not Assigned";
    if (employeeId && employeeId.length > 0) {
        const assignedUser = await User.findById(employeeId[0]);
        assignValue = assignedUser
            ? `${assignedUser.firstName} ${assignedUser.lastName}`
            : "production";
    } else {
        assignValue = "production";
    }

    await Jobs.updateMany(
        { _id: { $in: jobId } },
        {
            $set: {
                Status: statusValue,
                employeeId,
                selectDesigner,
                description,
                assign: assignValue
            }
        }
    );

    return res.status(201).json({
        success: true,
        message: "Assignment created successfully",
        assignment: newAssignment,
    });
});


const AllAssignJobID = asyncHandler(async (req, res) => {
    const { employeeId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(employeeId)) {
        return res.status(400).json({ message: 'Invalid employee ID' });
    }

    // Fetch assignments for this employee
    const assignments = await Assignment.find({ employeeId })
        .populate('employeeId')
        .populate({
            path: 'jobs.jobId',  // populate inside jobs array
            populate: {
                path: 'projectId',
                select: 'projectName projectNo'
            }
        });

    if (!assignments || assignments.length === 0) {
        return res.status(404).json({
            success: false,
            message: 'No assignments found for this employee'
        });
    }

    // Filter only jobs with jobReturnStatus === false
    const filteredAssignments = assignments.map(assign => {
        const activeJobs = assign.jobs.filter(j => j.jobReturnStatus === false);
        return {
            ...assign.toObject(),
            jobs: activeJobs
        };
    }).filter(assign => assign.jobs.length > 0); // remove assignments that have no active jobs

    if (filteredAssignments.length === 0) {
        return res.status(404).json({
            success: false,
            message: 'No active (non-returned) jobs found for this employee'
        });
    }

    res.status(200).json({
        success: true,
        count: filteredAssignments.length,
        assignments: filteredAssignments,
    });
});


// const ProductionJobsGet = asyncHandler(async (req, res) => {
//     const data = await Assignment.find({ selectDesigner: "Production" })
//         .populate("jobId"); // <-- This will populate job data

//     return res.status(200).json({
//         success: true,
//         count: data.length,
//         data,
//     });
// });

const ProductionJobsGet = asyncHandler(async (req, res) => {
    const assignments = await Assignment.find({ selectDesigner: "Production" })
        .populate({
            path: "jobs.jobId",
            populate: {
                path: "projectId",
                select: "projectName projectNo"
            }
        })
        .populate("employeeId");

    const modifiedData = assignments.map((item) => {
        const fullJobDetails = [];
        const justJobIds = [];

        for (const job of item.jobs) {
            if (typeof job.jobId === 'object' && job.jobId !== null && job.jobId._id) {
                // populated job
                fullJobDetails.push(job.jobId);
                justJobIds.push({ jobId: job.jobId._id, jobReturnStatus: job.jobReturnStatus, _id: job._id });
            } else {
                justJobIds.push(job); // push as-is
            }
        }

        return {
            _id: item._id,
            employeeId: item.employeeId || null,
            jobId: fullJobDetails.length > 0 ? fullJobDetails : [],
            jobs: justJobIds,
            selectDesigner: item.selectDesigner,
            description: item.description,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt,
            __v: item.__v,
        };
    });

    return res.status(200).json({
        success: true,
        count: modifiedData.length,
        data: modifiedData,
    });
});


// const AllAssignJobID = asyncHandler(async (req, res) => {
//     const { employeeId } = req.params;

//     if (!mongoose.Types.ObjectId.isValid(employeeId)) {
//         return res.status(400).json({ message: 'Invalid employee ID' });
//     }

//     const assignments = await Assignment.find({ employeeId: employeeId })
//         .populate({
//             path: 'employeeId',
//             select: 'firstName lastName email phone' 
//         })
//         .populate({
//             path: 'jobId', 
//             select: 'JobNo brandName subBrand flavour packType priority Status barcode',
//             populate: {
//                 path: 'projectId', 
//                 select: 'projectName' 
//             }
//         });

//     if (!assignments || assignments.length === 0) {
//         return res.status(404).json({ message: 'No assignments found for this employee' });
//     }

//     res.status(200).json({
//         success: true,
//         count: assignments.length,
//         assignments,
//     });
// });

// My job get api
const AllAssignJob = asyncHandler(async (req, res) => {
    try {
        const assignments = await Assignment.find({
            employeeId: { $ne: null },
            selectDesigner: "Designer"
        })
            .populate('employeeId')
            .populate({
                path: 'jobs.jobId',
                model: 'Jobs'
            });
        if (!assignments || assignments.length === 0) {
            return res.status(404).json({ message: 'No assignments found' });
        }

        res.status(200).json({
            success: true,
            count: assignments.length,
            assignments,
        });
    } catch (error) {
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});



module.exports = { AssignmentCreate, AllAssignJobID, AllAssignJob, ProductionJobsGet };
