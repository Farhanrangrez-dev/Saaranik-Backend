const asyncHandler = require('express-async-handler');
const Jobs = require('../../Model/Admin/JobsModel');
const Projects = require("../../Model/Admin/ProjectsModel");
const Assignment = require("../../Model/Admin/AssignmentJobControllerModel");
const cloudinary = require('../../Config/cloudinary');
const mongoose = require("mongoose")
const { generateJobsNo } = require('../../middlewares/generateEstimateRef');
const JobsSelect = require("../../Model/Admin/JobsSelectModel")

const CostEstimates = require('../../Model/Admin/CostEstimatesModel');
const InvoicingBilling = require('../../Model/Admin/InvoicingBillingModel');
const ReceivablePurchase = require('../../Model/Admin/ReceivablePurchaseModel');

cloudinary.config({
  cloud_name: 'dkqcqrrbp',
  api_key: '418838712271323',
  api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});

const jobCreate = asyncHandler(async (req, res) => {
  const {
    projectsId,
    brandName,
    subBrand,
    flavour,
    packType,
    packSize,
    packCode,
    priority,
    Status,
    assign,
    // totalTime,
    barcode
  } = req.body;

  try {
    // Validate each projectId
    if (!Array.isArray(projectsId) || projectsId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
      return res.status(400).json({
        success: false,
        message: "Invalid Project ID format. Ensure all IDs are valid."
      });
    }
    // Check if all projects exist
    const projects = await Projects.find({ '_id': { $in: projectsId } });
    if (projects.length !== projectsId.length) {
      return res.status(404).json({
        success: false,
        message: "One or more projects not found"
      });
    }
    const JobNo = await generateJobsNo();
    // Create the new Job
    const newJob = new Jobs({
      projectId: projectsId,
      JobNo,
      brandName,
      subBrand,
      flavour,
      packType,
      packCode,
      packSize,
      priority,
      Status,
      assign,
      // totalTime,
      barcode
    });

    await newJob.save();
    const jobData = newJob.toObject();
    jobData.projectId = jobData.projectId;
    delete jobData.projects;

    res.status(201).json({
      success: true,
      message: "Job created successfully",
      job: jobData,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "An error occurred while creating the Job",
      error: error.message,
    });
  }
});

// const AllJobID = async (req, res) => {
//   try {
//     const { projectId } = req.params;

//     if (!mongoose.Types.ObjectId.isValid(projectId)) {
//       return res.status(400).json({
//         success: false,
//         message: "Invalid projectId",
//       });
//     }

//     const allJobs = await Jobs.find({ projectId })
//       .populate({
//         path: 'projectId',
//         select: '_id projectName',
//         model: 'Projects',
//       });

//     const jobsWithDetails = allJobs.map(job => ({
//       ...job.toObject(),
//       projects: job.projectId
//         ? {
//           projectId: job.projectId._id,
//           projectName: job.projectId.projectName,
//         }
//         : {},
//     }));

//     res.status(200).json({
//       success: true,
//       jobs: jobsWithDetails,
//     });
//   } catch (error) {
//     console.error("Error fetching jobs:", error);
//     res.status(500).json({
//       success: false,
//       message: "An error occurred while fetching jobs",
//       error: error.message,
//     });
//   }
// };


const AllJobID = asyncHandler(async (req, res) => {
  try {
    const { projectId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(projectId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid projectId",
      });
    }

    const allJobs = await Jobs.find({ projectId }).populate({
      path: 'projectId',
      select: '_id projectName projectNo',
      model: 'Projects',
    });

    const jobsWithDetails = await Promise.all(allJobs.map(async (job) => {
  let assignedTo = "Not Assigned";
  let allDescriptions = [];

  if (job.assign === "Production") {
    assignedTo = "Production";
  }

  // ✅ Step 2: Check all Assignments for this job
  const assignments = await Assignment.find({ 'jobs.jobId': job._id }).populate({
    path: 'employeeId',
    select: 'firstName lastName',
  });

  // ✅ Collect all descriptions with employee name + createdAt
  allDescriptions = assignments.map(a => ({
    description: a.description,
    name: a.employeeId
      ? `${a.employeeId.firstName} ${a.employeeId.lastName}`
      : "Production",
    createdAt: a.createdAt,  // original Date from MongoDB
  }));

  // ✅ Check for any assigned employee (just show the first for now)
  const designerAssignment = assignments.find(a => a.employeeId !== null);
  if (designerAssignment && designerAssignment.employeeId) {
    assignedTo = `${designerAssignment.employeeId.firstName} ${designerAssignment.employeeId.lastName}`;
  }

  return {
    ...job.toObject(),
    projects: job.projectId
      ? {
          projectId: job.projectId._id,
          projectName: job.projectId.projectName,
          projectNo: job.projectId.projectNo || null,
        }
      : {},
    assignedTo,
    descriptions: allDescriptions, // ✅ Now array of objects
  };
}));


    res.status(200).json({
      success: true,
      jobs: jobsWithDetails,
    });
  } catch (error) {
    console.error("Error fetching jobs:", error);
    res.status(500).json({
      success: false,
      message: "An error occurred while fetching jobs",
      error: error.message,
    });
  }
});




//GET SINGLE AllProjects
//METHOD:GET
// GET All Jobs with project and client info
// const AllJob = async (req, res) => {
//   try {
//     const allJobs = await Jobs.find().populate({
//       path: 'projectId',
//       select: '_id projectName',
//       model: 'Projects'
//     });

//     if (!allJobs || allJobs.length === 0) {
//       return res.status(404).json({ success: false, message: "No jobs found" });
//     }

//     const jobsWithDetails = await Promise.all(allJobs.map(async (job) => {
//       const jobObj = job.toObject();

//       // Check assignment for this job
//       const assignment = await Assignment.findOne({ jobId: job._id })
//         .populate({
//           path: 'employeeId',
//           select: 'firstName lastName',
//         });

//       // Prepare assignedTo name
//       let assignedTo = "Not Assigned";
//       if (assignment && assignment.employeeId || assignment !== "Production") {
//         assignedTo = `${assignment.employeeId.firstName} ${assignment.employeeId.lastName}`;
//       }

//       return {
//         ...jobObj,
//         projects: Array.isArray(job.projectId)
//           ? job.projectId.map(project => ({
//             projectId: project?._id,
//             projectName: project?.projectName
//           }))
//           : (job.projectId ? {
//             projectId: job.projectId._id,
//             projectName: job.projectId.projectName
//           } : {}),
//         assignedTo  // 👈 add assignedTo here
//       };
//     }));

//     res.status(200).json({
//       success: true,
//       jobs: jobsWithDetails,
//     });

//   } catch (error) {
//     console.error("Error fetching jobs:", error);
//     res.status(500).json({
//       success: false,
//       message: "An error occurred while fetching jobs",
//       error: error.message,
//     });
//   }
// };

const AllJob = async (req, res) => {
  try {
    const allJobs = await Jobs.find().populate({
      path: 'projectId',
      select: '_id projectName projectNo',
      model: 'Projects'
    });

    if (!allJobs || allJobs.length === 0) {
      return res.status(404).json({ success: false, message: "No jobs found" });
    }

    const jobsWithDetails = await Promise.all(allJobs.map(async (job) => {
      const jobObj = job.toObject();

      // Check assignment for this job
      const assignment = await Assignment.findOne({ jobId: job._id })
        .populate({
          path: 'employeeId',
          select: 'firstName lastName description',
        });

      // Prepare assignedTo name
      let assignedTo = "Not Assigned";
      if (assignment && assignment.employeeId && assignment.selectDesigner !== "Production") {
        assignedTo = `${assignment.employeeId.firstName} ${assignment.employeeId.lastName}`;
      }

      return {
        ...jobObj,
        projects: Array.isArray(job.projectId)
          ? job.projectId.map(project => ({
            projectId: project?._id,
            projectName: project?.projectName,
            projectNo: project?.projectNo
          }))
          : (job.projectId ? {
            projectId: job.projectId._id,
            projectName: job.projectId.projectName,
            projectNo: job.projectId.projectNo
          } : {}),
        assignedTo  // ✅ now safely added
      };
    }));

    res.status(200).json({
      success: true,
      jobs: jobsWithDetails,
    });

  } catch (error) {
    console.error("Error fetching jobs:", error);
    res.status(500).json({
      success: false,
      message: "An error occurred while fetching jobs",
      error: error.message,
    });
  }
};



//GET SINGLE AllProjects
//METHOD:GET
// GET All Jobs with project and client info
const filter = async (req, res) => {
  try {
    const { Status } = req.params;

    // ✅ Check if Status is missing or invalid
    if (!Status || Status.trim() === "") {
      return res.status(400).json({
        success: false,
        message: "Status parameter is required",
      });
    }

    const allJobs = await Jobs.find({ Status: Status }).populate({
      path: 'projectId',
      select: '_id projectName projectNo',
      model: 'Projects'
    });

    if (!allJobs || allJobs.length === 0) {
      return res.status(404).json({ success: false, message: "No jobs found" });
    }

    const jobsWithDetails = await Promise.all(allJobs.map(async (job) => {
      const jobObj = job.toObject();

      const assignment = await Assignment.findOne({ jobId: job._id })
        .populate({
          path: 'employeeId',
          select: 'firstName lastName description',
        });

      let assignedTo = "Not Assigned";
      if (assignment && assignment.employeeId) {
        assignedTo = `${assignment.employeeId.firstName} ${assignment.employeeId.lastName}`;
      }

      return {
        ...jobObj,
        projects: Array.isArray(job.projectId)
          ? job.projectId.map(project => ({
            projectId: project?._id,
            projectName: project?.projectName
          }))
          : (job.projectId ? {
            projectId: job.projectId._id,
            projectName: job.projectId.projectName
          } : {}),
        assignedTo
      };
    }));

    res.status(200).json({
      success: true,
      jobs: jobsWithDetails,
    });

  } catch (error) {
    console.error("Error fetching jobs:", error);
    res.status(500).json({
      success: false,
      message: "An error occurred while fetching jobs",
      error: error.message,
    });
  }
};


//Status Complete  WaitingApproval api get
const Complete_WaitingApproval = async (req, res) => {
  try {
    const allJobs = await Jobs.find({
      Status: { $in: ['WaitingApproval', 'Completed'] }
    }).populate({
      path: 'projectId',
      select: '_id projectName',
      model: 'Projects'
    });
    console.log("allJobs", allJobs)
    // if (!allJobs || allJobs.length === 0) {
    //   return res.status(404).json({ success: false, message: "No jobs found" });
    // }
    const jobsWithDetails = await Promise.all(allJobs.map(async (job) => {
      const jobObj = job.toObject();

      const assignment = await Assignment.findOne({ jobId: job._id }).populate({
        path: 'employeeId',
        select: 'firstName lastName description',
      });

      let assignedTo = "Not Assigned";
      if (assignment?.employeeId) {
        assignedTo = `${assignment.employeeId.firstName} ${assignment.employeeId.lastName}`;
      }

      return {
        ...jobObj,
        projects: Array.isArray(job.projectId)
          ? job.projectId.map(project => ({
            projectId: project?._id,
            projectName: project?.projectName
          }))
          : (job.projectId ? {
            projectId: job.projectId._id,
            projectName: job.projectId.projectName
          } : {}),
        assignedTo
      };
    }));

    res.status(200).json({
      success: true,
      jobs: jobsWithDetails,
    });

  } catch (error) {
    console.error("Error fetching jobs:", error);
    res.status(500).json({
      success: false,
      message: "An error occurred while fetching jobs",
      error: error.message,
    });
  }
};



//GET SINGLE DeleteProjects
//METHOD:DELETE
const deleteJob = async (req, res) => {
  let deleteJobID = req.params.id
  if (deleteJob) {
    const deleteJob = await Jobs.findByIdAndDelete(deleteJobID, req.body);
    res.status(200).json("Delete Job Successfully")
  } else {
    res.status(400).json({ message: "Not Delete project" })
  }
}

//GET SINGLE ProjectsUpdate
//METHOD:PUT
const UpdateJob = async (req, res) => {
  try {
    const jobId = req.params.id; // ✅ ID from URL

    if (!jobId) {
      return res.status(400).json({ message: 'Job ID is required' });
    }
    const allowedFields = [
      'projects',
      'projectName',
      'brandName',
      'subBrand',
      'flavour',
      'packType',
      'packCode',
      'packSize',
      'priority',
      'Status',
      'assign',
      // 'totalTime',
    ];

    const updateData = {};
    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    });

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ message: 'At least one field must be provided for update' });
    }
    const updatedJob = await Jobs.findByIdAndUpdate(
      jobId,
      updateData,
      { new: true }
    );

    if (!updatedJob) {
      return res.status(404).json({ message: 'Job not found' });
    }

    res.status(200).json(updatedJob);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error });
  }
};


//GET SINGLE ProjectsUpdate
//METHOD:PUT
const UpdateJobAssign = async (req, res) => {
  try {
    const allowedFields = [
      'projects',
      'projectName',
      'brandName',
      'subBrand',
      'flavour',
      'packType',
      "packCode",
      'packSize',
      'priority',
      'Status',
      'assign',
      // 'totalTime',
    ];

    const updateData = {};
    allowedFields.forEach(field => {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    });

    if (!Array.isArray(req.body.id) || req.body.id.length === 0) {
      return res.status(400).json({ message: 'ID array is required and must not be empty' });
    }

    if (Object.keys(updateData).length === 0) {
      return res.status(400).json({ message: 'At least one field must be provided for update' });
    }

    const updatedResult = await Jobs.updateMany(
      { _id: { $in: req.body.id } },
      { $set: updateData }
    );

    res.status(200).json({
      message: 'Jobs updated successfully',
      matchedCount: updatedResult.matchedCount,
      modifiedCount: updatedResult.modifiedCount
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error });
  }
};

//METHOD:Single
//TYPE:PUBLIC
const SingleJob = async (req, res) => {
  try {
    const SingleJob = await Jobs.findById(req.params.id);
    res.status(200).json(SingleJob)
  } catch (error) {
    res.status(404).json({ msg: "Can t Find Diaries" })
  }
}

// POST /api/selects  ➜ add new option values
const addSelectValues = asyncHandler(async (req, res) => {
  const {
    brandName,
    subBrand,
    flavour,
    packType,
    packCode,
    priority,
    status,      // 🔄 Status → status
  } = req.body;

  try {

    const addSet = {};

    if (brandName) addSet.brandName = { $each: [].concat(brandName).filter(Boolean) };
    if (subBrand) addSet.subBrand = { $each: [].concat(subBrand).filter(Boolean) };
    if (flavour) addSet.flavour = { $each: [].concat(flavour).filter(Boolean) };
    if (packType) addSet.packType = { $each: [].concat(packType).filter(Boolean) };
    if (packCode) addSet.packCode = { $each: [].concat(packCode).filter(Boolean) };
    if (priority) addSet.priority = { $each: [].concat(priority).filter(Boolean) };
    if (status) addSet.status = { $each: [].concat(status).filter(Boolean) };

    // अगर addSet में कुछ भी नहीं बचा तो 400
    if (Object.keys(addSet).length === 0) {
      return res.status(400).json({
        success: false,
        message: "No valid values provided",
      });
    }

    const doc = await JobsSelect.findOneAndUpdate(
      {},                       // single master doc
      { $addToSet: addSet },
      { upsert: true, new: true }
    );

    return res.status(201).json({
      success: true,
      message: "Select lists updated",
      data: doc,
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: "Failed to update select lists",
      error: err.message,
    });
  }
});

// GET API to fetch the select values
const getSelectValues = asyncHandler(async (req, res) => {
  try {
    // Assuming there's only one master document
    const doc = await JobsSelect.findOne({});

    if (!doc) {
      return res.status(404).json({
        success: false,
        message: "No select values found",
      });
    }

    return res.status(200).json({
      success: true,
      message: "Select values fetched successfully",
      data: doc,
    });
  } catch (err) {
    return res.status(500).json({
      success: false,
      message: "Failed to fetch select values",
      error: err.message,
    });
  }
});


// Employee Completed Status chang job is ko 0 aur 1 ne maneg kiy hai status ko 1 hai to admin ne complede nahi kiy hai 
const EmployeeCompletedStatus = asyncHandler(async (req, res) => {
  const { id } = req.params;
  const CompletedStatus = req.body;

  // Validate ID
  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({
      success: false,
      message: "Invalid ID format."
    });
  }

  const updatedJob = await Jobs.findByIdAndUpdate(id, CompletedStatus, {
    new: true,
    runValidators: true,
  });

  if (!updatedJob) {
    return res.status(404).json({
      success: false,
      message: "Job not found."
    });
  }

  res.status(200).json({
    success: true,
    message: "Job updated successfully.",
    data: updatedJob
  });
});





// project kiy id se data get ho raha ha admin sahit par finse me data  get kiy api hai 
// const JobFinance = asyncHandler(async (req, res) => {
//   try {
//     const { projectId } = req.params;

//     if (!mongoose.Types.ObjectId.isValid(projectId)) {
//       return res.status(400).json({
//         success: false,
//         message: "Invalid projectId",
//       });
//     }

//     // 🟩 Fetch CostEstimates and populate project & client
//     const rawEstimates = await CostEstimates.find({ projectId })
//       .populate({
//         path: "projectId",
//         select: "projectName",
//       })
//       .populate({
//         path: "clientId",
//         select: "clientName contactPersons",
//         strictPopulate: false,
//       });

//     const costEstimates = rawEstimates.map((estimate) => ({
//       _id: estimate._id,
//       estimateRef: estimate.estimateRef,
//       estimateDate: estimate.estimateDate,
//       validUntil: estimate.validUntil,
//       currency: estimate.currency,
//       VATRate: estimate.VATRate,
//       Status: estimate.Status,
//       Notes: estimate.Notes,
//       lineItems: estimate.lineItems,
//       createdAt: estimate.createdAt,
//       updatedAt: estimate.updatedAt,
//       clients: [{
//         clientId: estimate.clientId?._id,
//         clientName: estimate.clientId?.clientName,
//         clientEmail: estimate.clientId?.contactPersons?.map(c => c.email),
//         clientPhone: estimate.clientId?.contactPersons?.map(c => c.phone),
//       }],
//       projects: [{
//         projectId: estimate.projectId?._id,
//         projectName: estimate.projectId?.projectName,
//       }],
//     }));

//     // 🟩 Fetch ReceivablePurchase with populated references
//     const rawReceivablePurchases = await ReceivablePurchase.find({ projectId })
//       .populate({
//         path: "projectId",
//         select: "projectName",
//       })
//       .populate({
//         path: "ClientId",
//         select: "clientName",
//         strictPopulate: false,
//       })
//       .populate({
//         path: "CostEstimatesId",
//         select: "estimateRef",
//         strictPopulate: false,
//       });

//     const receivablePurchases = rawReceivablePurchases.map((po) => ({
//       _id: po._id,
//       PONumber: po.PONumber,
//       POStatus: po.POStatus,
//       ReceivedDate: po.ReceivedDate,
//       Amount: po.Amount,
//       image: po.image,
//       createdAt: po.createdAt,
//       updatedAt: po.updatedAt,

//       // ✅ clientId as array of object with _id and clientName
//       ClientId: Array.isArray(po.ClientId)
//         ? po.ClientId.map((c) => ({
//           _id: c?._id,
//           clientName: c?.clientName,
//         }))
//         : [],

//       // ✅ separate client field (can be empty object)
//       client: {},

//       // ✅ CostEstimatesId as array of _id and estimateRef
//       CostEstimatesId: Array.isArray(po.CostEstimatesId)
//         ? po.CostEstimatesId.map((c) => ({
//           _id: c?._id,
//           estimateRef: c?.estimateRef,
//         }))
//         : [],

//       // ✅ costEstimates same as above for reference
//       costEstimates: Array.isArray(po.CostEstimatesId)
//         ? po.CostEstimatesId.map((c) => ({
//           costEstimateId: c?._id,
//           estimateRef: c?.estimateRef,
//         }))
//         : [],

//       // ✅ projectId with _id and projectName
//       projectId: Array.isArray(po.projectId)
//         ? po.projectId.map((p) => ({
//           _id: p?._id,
//           projectName: p?.projectName,
//         }))
//         : [],

//       // ✅ projects same as above for reference
//       projects: Array.isArray(po.projectId)
//         ? po.projectId.map((p) => ({
//           _id: p?._id,
//           projectName: p?.projectName,
//         }))
//         : [],
//     }));


//     // 🟩 Fetch InvoicingBilling (no changes)
//     const invoicingData = await InvoicingBilling.find({ projectId });

//     // 🟩 Final Response
//     res.status(200).json({
//       success: true,
//       costEstimates,
//       receivablePurchases,
//       invoicingData,
//     });

//   } catch (error) {
//     console.error("Error fetching job finance data:", error);
//     res.status(500).json({
//       success: false,
//       message: "An error occurred while fetching finance data",
//       error: error.message,
//     });
//   }
// });


const JobFinance = asyncHandler(async (req, res) => {
  try {
    const { projectId } = req.params;

    if (!mongoose.Types.ObjectId.isValid(projectId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid projectId",
      });
    }

    // 🟩 Fetch CostEstimates and populate project & client
    const rawEstimates = await CostEstimates.find({ projectId })
      .populate({
        path: "projectId",
        select: "projectName",
      })
      .populate({
        path: "clientId",
        select: "clientName contactPersons",
        strictPopulate: false,
      });

    const costEstimates = rawEstimates.map((estimate) => ({
      _id: estimate._id,
      estimateRef: estimate.estimateRef,
      estimateDate: estimate.estimateDate,
      validUntil: estimate.validUntil,
      currency: estimate.currency,
      VATRate: estimate.VATRate,
      Status: estimate.Status,
      Notes: estimate.Notes,
      lineItems: estimate.lineItems,
      createdAt: estimate.createdAt,
      updatedAt: estimate.updatedAt,
      CostPOStatus:estimate.CostPOStatus,
      clients: [{
        clientId: estimate.clientId?._id,
        clientName: estimate.clientId?.clientName,
        clientEmail: estimate.clientId?.contactPersons?.map(c => c.email),
        clientPhone: estimate.clientId?.contactPersons?.map(c => c.phone),
      }],
      projects: [{
        projectId: estimate.projectId?._id,
        projectName: estimate.projectId?.projectName,
      }],
    }));

    // 🟩 Fetch ReceivablePurchase with populated references
    const rawReceivablePurchases = await ReceivablePurchase.find({ projectId })
      .populate({
        path: "projectId",
        select: "projectName",
      })
      .populate({
        path: "ClientId",
        select: "clientName",
        strictPopulate: false,
      })
      .populate({
        path: "CostEstimatesId",
        select: "estimateRef",
        strictPopulate: false,
      });

    const receivablePurchases = rawReceivablePurchases.map((po) => ({
      _id: po._id,
      PONumber: po.PONumber,
      POStatus: po.POStatus,
      ReceivedDate: po.ReceivedDate,
      Amount: po.Amount,
      image: po.image,
      createdAt: po.createdAt,
      updatedAt: po.updatedAt,

      ClientId: Array.isArray(po.ClientId)
        ? po.ClientId.map((c) => ({
          _id: c?._id,
          clientName: c?.clientName,
        }))
        : [],

      client: {},

      CostEstimatesId: Array.isArray(po.CostEstimatesId)
        ? po.CostEstimatesId.map((c) => ({
          _id: c?._id,
          estimateRef: c?.estimateRef,
        }))
        : [],

      costEstimates: Array.isArray(po.CostEstimatesId)
        ? po.CostEstimatesId.map((c) => ({
          costEstimateId: c?._id,
          estimateRef: c?.estimateRef,
        }))
        : [],

      projectId: Array.isArray(po.projectId)
        ? po.projectId.map((p) => ({
          _id: p?._id,
          projectName: p?.projectName,
        }))
        : [],

      projects: Array.isArray(po.projectId)
        ? po.projectId.map((p) => ({
          _id: p?._id,
          projectName: p?.projectName,
        }))
        : [],
    }));

    // 🟩 Fetch InvoicingBilling with populated Client, Project, and Estimate
    const rawInvoicingData = await InvoicingBilling.find({ projectId })
      .populate({
        path: "clientId",
        select: "clientName contactPersons",
      })
      .populate({
        path: "projectId",
        select: "projectName",
      })
      .populate({
        path: "CostEstimatesId",
        select: "estimateRef",
      });

    // 🟩 Format Invoicing Data
    const formattedInvoicingData = rawInvoicingData.map((invoice) => {
      return {
        _id: invoice._id,
        InvoiceNo: invoice.InvoiceNo,
        ReceivablePurchaseId: invoice.ReceivablePurchaseId || null,
        receivablePurchase: invoice.ReceivablePurchaseId || null,

        CostEstimatesId: {
          _id: invoice.CostEstimatesId?._id,
        },
        costEstimate: {
          estimateId: invoice.CostEstimatesId?._id,
        },

        clientId: invoice.clientId ? {
          _id: invoice.clientId._id,
          clientName: invoice.clientId.clientName,
          contactPersons: invoice.clientId.contactPersons,
        } : {},

        clients: invoice.clientId ? [{
          clientId: invoice.clientId._id,
          clientName: invoice.clientId.clientName,
        }] : [],

        projectId: Array.isArray(invoice.projectId)
          ? invoice.projectId.map((p) => ({
            _id: p?._id,
            projectName: p?.projectName,
          }))
          : (invoice.projectId ? [{
            _id: invoice.projectId._id,
            projectName: invoice.projectId.projectName,
          }] : []),

        projects: Array.isArray(invoice.projectId)
          ? invoice.projectId.map((p) => ({
            projectId: p?._id,
            projectName: p?.projectName,
          }))
          : (invoice.projectId ? [{
            projectId: invoice.projectId._id,
            projectName: invoice.projectId.projectName,
          }] : []),

        date: invoice.date,
        currency: invoice.currency,
        output: invoice.output,
        document: invoice.document,
        lineItems: invoice.lineItems,
        status: invoice.status,
        createdAt: invoice.createdAt,
        updatedAt: invoice.updatedAt,
      };
    });

    // 🟩 Final Response
    res.status(200).json({
      success: true,
      costEstimates,
      receivablePurchases,
      invoicingData: formattedInvoicingData,
    });

  } catch (error) {
    console.error("Error fetching job finance data:", error);
    res.status(500).json({
      success: false,
      message: "An error occurred while fetching finance data",
      error: error.message,
    });
  }
});




module.exports = { Complete_WaitingApproval, jobCreate, AllJob, deleteJob, UpdateJob, SingleJob, UpdateJobAssign, AllJobID, filter, addSelectValues, getSelectValues, EmployeeCompletedStatus, JobFinance };