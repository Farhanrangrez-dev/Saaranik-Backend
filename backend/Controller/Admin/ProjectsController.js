const asyncHandler = require("express-async-handler");
const Projects = require("../../Model/Admin/ProjectsModel");
const Jobs = require('../../Model/Admin/JobsModel');
const Assignment = require("../../Model/Admin/AssignmentJobControllerModel");
const ReceivablePurchase = require('../../Model/Admin/ReceivablePurchaseModel');
const TimesheetWorklogs = require('../../Model/Admin/TimesheetWorklogModel');

const ClientManagement = require("../../Model/Admin/ClientManagementModel"); // Make sure the path is correct
const {generateProjectNo} = require('../../middlewares/generateEstimateRef');

const mongoose = require("mongoose");
const cloudinary = require('../../Config/cloudinary');

cloudinary.config({
  cloud_name: 'dkqcqrrbp',
  api_key: '418838712271323',
  api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});


const createProjects = asyncHandler(async (req, res) => {
  const {
    projectName,
    clientId,
    // managerId,
    startDate,
    endDate,
    projectPriority,
    description,
    status,
    projectRequirements,
    budgetAmount,
    currency,
  } = req.body;

  try {
    // ✅ Validate Client ID
    const existingClient = await ClientManagement.findById(clientId);
    if (!existingClient) {
      return res.status(400).json({
        success: false,
        message: 'Invalid clientId. No such client exists.',
      });
    }

     const projectNo = await generateProjectNo();
    
    // Optionally validate managerId similarly if needed
    const newAssignment = new Projects({
      projectNo,
      projectName,
      clientId,
      // managerId,
      startDate,
      endDate,
      projectPriority,
      description,
      status,
      projectRequirements,
      budgetAmount,
      currency,
    });

    const savedAssignment = await newAssignment.save();

    res.status(201).json({
      success: true,
      message: 'Project created successfully',
      data: savedAssignment.toJSON(),
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error creating project',
      error: error.message,
    });
  }
}
)



 //GET SINGLE AllProjects
  //METHOD:GET
const getAllProjects = async (req, res) => {
  try {
    const allProjects = await Projects.find()
      .populate({
        path: 'clientId',
        select: 'clientName', // Only fetch the clientName field
      });

    const projectsWithVirtuals = allProjects.map(project =>
      project.toObject({ virtuals: true })
    );

    res.status(200).json({
      success: true,
      data: projectsWithVirtuals,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error fetching projects",
      error: error.message,
    });
  }
};

  


       //GET SINGLE DeleteProjects
  //METHOD:DELETE
  const deleteProjects = async (req, res) => {
    let deleteProjectsID = req.params.id
    if (deleteProjects) {
      const deleteProjects = await Projects.findByIdAndDelete(deleteProjectsID, req.body);
      res.status(200).json("Delete Checklists Successfully")
    } else {
      res.status(400).json({ message: "Not Delete project" })
    }
  }

 //GET SINGLE ProjectsUpdate
  //METHOD:PUT
  const UpdateProject = async (req, res) => {
    try {
      const allowedFields = [
        'projectName',
        'clientId',
        // 'managerId',
        'startDate',
        'endDate',
        'projectPriority',
        'description',
        'status',
        'projectRequirements',
        'budgetAmount',
        'currency',
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
      const updatedDiary = await Projects.findByIdAndUpdate(
        req.params.id,
        updateData,
        { new: true }
      );
      if (!updatedDiary) {
        return res.status(404).json({ message: 'Diary not found' });
      }
      res.status(200).json(updatedDiary);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Server error', error });
    }
  };


    
  //METHOD:Single
  //TYPE:PUBLIC
  const SingleProjects=async(req,res)=>{
    try {
        const SingleProjects= await Projects.findById(req.params.id);
        res.status(200).json(SingleProjects)
    } catch (error) {
        res.status(404).json({msg:"Can t Find Diaries"} )
    }
}

// const OverviewProject = asyncHandler(async (req, res) => {
//     const { id } = req.params;

//     if (!mongoose.Types.ObjectId.isValid(id)) {
//         return res.status(400).json({ message: "Invalid projectId" });
//     }

//     // 1. Project details
//     const project = await Projects.findById(id);
//     if (!project) {
//         return res.status(404).json({ message: "Project not found" });
//     }

//     // 2. All jobs for this project
//     const allJobs = await Jobs.find({ projectId: id });

//     // Progress percentage
//     const completedJobs = allJobs.filter(j => j.Status === "Completed").length;
//     const progress = allJobs.length > 0 ? Math.round((completedJobs / allJobs.length) * 100) : 0;

//     // In Progress jobs count
//     const inProgressJobs = allJobs.filter(j => j.Status === "In Progress").length;

//     // Days remaining (aaj se project.endDate tak)
//     const today = new Date();
//     const endDate = new Date(project.endDate);

//     // Zero out the time for both dates to avoid partial day rounding issues
//     today.setHours(0, 0, 0, 0);
//     endDate.setHours(0, 0, 0, 0);

//     const msInDay = 1000 * 60 * 60 * 24;
//     const daysRemaining = Math.max(0, Math.ceil((endDate - today) / msInDay));

//     // Jobs due today
//     const jobsDueToday = allJobs.filter(job => {
//         const jobDate = new Date(job.createdAt);
//         jobDate.setHours(0, 0, 0, 0);
//         return jobDate.getTime() === today.getTime();
//     }).length;

//     // Total hours (agar totalTime field hai)
//     let totalHours = allJobs.reduce((sum, job) => {
//         return sum + (job.totalTime ? Number(job.totalTime) : 0);
//     }, 0);

//     // Recent Activity
//     const recentActivity = [
//         { title: "Design phase completed", value: `${completedJobs} jobs completed` },
//         { title: "New purchase order created", value: "" },
//         {
//             title: "New team member added",
//             value: await Assignment.distinct("employeeId", { "jobs.jobId": { $in: allJobs.map(j => j._id) } })
//                 .then(list => list.length + " employees assigned")
//         }
//     ];

//     // Purchase Orders
//     const purchaseOrders = await ReceivablePurchase.find({ projectId: id });
//     const receivedPOs = purchaseOrders.filter(po => po.POStatus.toLowerCase() === "received");
//     const totalPOValue = purchaseOrders.reduce((sum, po) => sum + (po.Amount || 0), 0);

//     const purchaseOrderStats = {
//         received: receivedPOs.length,
//         issued: purchaseOrders.length,
//         totalValue: totalPOValue
//     };

//     // Final response
//     res.json({
//         projectNo: project.projectNo,
//         projectName: project.projectName,
//         progress,          // % completed
//         inProgressJobs,    // count of "In Progress" jobs
//         daysRemaining,     // exact days left from today to endDate
//         dueDate: project.endDate,
//         jobsDueToday,
//         totalHours,
//         recentActivity,
//         purchaseOrders: purchaseOrderStats
//     });
// });


const OverviewProject = asyncHandler(async (req, res) => {
  const { id } = req.params;

  if (!mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ message: "Invalid projectId" });
  }

  // Project details
  const project = await Projects.findById(id);
  if (!project) {
    return res.status(404).json({ message: "Project not found" });
  }

  // Jobs for this project
  const allJobs = await Jobs.find({ projectId: id });
  const jobIds = allJobs.map(j => j._id); // keep as ObjectId array

  // Progress
  const completedJobs = allJobs.filter(j => j.Status === "Completed").length;
  const progress = allJobs.length > 0
    ? Math.round((completedJobs / allJobs.length) * 100)
    : 0;

  // In Progress jobs
  const inProgressJobs = allJobs.filter(j => j.Status === "In Progress").length;

  // Days remaining
  const today = new Date();
  const endDate = new Date(project.endDate);
  today.setHours(0, 0, 0, 0);
  endDate.setHours(0, 0, 0, 0);
  const msInDay = 1000 * 60 * 60 * 24;
  const daysRemaining = Math.max(0, Math.ceil((endDate - today) / msInDay));

  // Jobs due today
  const jobsDueToday = allJobs.filter(job => {
    const jobDate = new Date(job.createdAt);
    jobDate.setHours(0, 0, 0, 0);
    return jobDate.getTime() === today.getTime();
  }).length;

  // Time logs
  const timeLogs = await TimesheetWorklogs.find({
    projectId: { $in: [new mongoose.Types.ObjectId(id)] },
    jobId: { $in: jobIds }
  });

  let totalMinutes = 0;
  timeLogs.forEach(log => {
    const timeStr = log.totalTime || log.hours;
    if (timeStr) {
      const [h, m] = timeStr.split(":").map(Number);
      if (!isNaN(h) && !isNaN(m)) totalMinutes += (h * 60) + m;
    }
  });
  const totalHours = `${Math.floor(totalMinutes / 60)}:${String(totalMinutes % 60).padStart(2, '0')}`;

  // ---- Assignee total ----
  const assigneeCountAgg = await Assignment.aggregate([
    { $unwind: "$jobs" },
    { $match: { "jobs.jobId": { $in: jobIds } } },
    { $count: "total" }
  ]);
  const totalAssignedRows = assigneeCountAgg[0]?.total || 0;

  // ---- Purchase orders ----
  const purchaseOrders = await ReceivablePurchase.find({ projectId: id });
  const receivedPOs = purchaseOrders.filter(po => po.POStatus?.toLowerCase() === "received");
  const totalPOValue = purchaseOrders.reduce((sum, po) => sum + (po.Amount || 0), 0);

  const purchaseOrderStats = {
    received: receivedPOs.length,
    issued: purchaseOrders.length,
    totalValue: totalPOValue
  };

  // ---- Recent activity as OBJECT ----
  const recentActivity = {
    completedJob: completedJobs,
    purchaseOrderCreated: "",
    assignment: totalAssignedRows
  };

  // Final response
  res.json({
    projectNo: project.projectNo,
    projectName: project.projectName,
    progress,
    inProgressJobs,
    daysRemaining,
    dueDate: project.endDate,
    jobsDueToday,
    totalHours,
    recentActivity,
    purchaseOrders: purchaseOrderStats
  });
});

module.exports = {createProjects,getAllProjects,UpdateProject,deleteProjects,SingleProjects,OverviewProject};