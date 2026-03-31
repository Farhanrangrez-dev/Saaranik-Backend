const asyncHandler = require('express-async-handler');
const Jobs = require('../Model/JobsModel');
const Projects = require("../Model/ProjectsModel");
const cloudinary = require('../Config/cloudinary');
const mongoose =require("mongoose")

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
    priority,
    Status,
    assign,
    totalTime,
    barcode
  } = req.body;

  try {
    const project = await Projects.findById(projectsId);
    if (!mongoose.Types.ObjectId.isValid(projectsId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid Project ID format"
      });
    }
    
    const newJob = new Jobs({
      projects: projectsId,
      brandName,
      subBrand,
      flavour,
      packType,
      packSize,
      priority,
      Status,
      assign,
      totalTime,
      barcode
    });
    await newJob.save();
    const jobData = newJob.toObject();
    jobData.projectId = jobData.projects;
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


    //GET SINGLE AllProjects
  //METHOD:GET
  const AllJob = async (req, res) => {
    try {
      // Fetch all jobs and populate the related project data (_id and projectName)
      const allJobs = await Jobs.find()
        .populate('projects', '_id projectName'); // Populate project fields: _id and projectName
  
      if (!allJobs || allJobs.length === 0) {
        return res.status(404).json({ success: false, message: "No jobs found" });
      }
  
      res.status(200).json({
        success: true,
        jobs: allJobs, // Return all jobs with populated project data
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
      const allowedFields = [
        'projects',  // Project ID
        'projectName',     
        'brandName',
        'subBrand',    
        'flavour',    
        'packType',
        'packSize',
        'priority',
        'Status',
        'assign',
        'totalTime',
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
      const updatedDiary = await Jobs.findByIdAndUpdate(
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
    const SingleJob=async(req,res)=>{
      try {
          const SingleJob= await Jobs.findById(req.params.id);
          res.status(200).json(SingleJob)
      } catch (error) {
          res.status(404).json({msg:"Can t Find Diaries"} )
      }
  }


module.exports = {jobCreate,AllJob,deleteJob,UpdateJob,SingleJob};
























const asyncHandler = require('express-async-handler');
const Jobs = require('../Model/JobsModel');
const Projects = require("../Model/ProjectsModel");
const cloudinary = require('../Config/cloudinary');
const mongoose =require("mongoose")

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
    priority,
    Status,
    assign,
    totalTime,
    barcode
  } = req.body;

  try {
    // Check if the Project ID is valid
    if (!mongoose.Types.ObjectId.isValid(projectsId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid Project ID format"
      });
    }
    
    // Find the Project to verify it exists
    const project = await Projects.findById(projectsId);
    if (!project) {
      return res.status(404).json({
        success: false,
        message: "Project not found"
      });
    }

    // Create a new Job with the correct field name projectId
    const newJob = new Jobs({
      projectId: projectsId, // Fixing this to use projectId
      brandName,
      subBrand,
      flavour,
      packType,
      packSize,
      priority,
      Status,
      assign,
      totalTime,
      barcode
    });

    // Save the job
    await newJob.save();

    // Format the job data to include projectId instead of projects
    const jobData = newJob.toObject();
    jobData.projectId = jobData.projectId; // Ensure projectId is returned
    delete jobData.projects; // Remove the old field if it exists
    
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




    //GET SINGLE AllProjects
  //METHOD:GET
  const AllJob = async (req, res) => {
    try {
      const allJobs = await Jobs.find()
        .populate({
          path: 'projectId', // Use projectId to populate
          select: '_id name', // Include both project ID and name
          model: 'Projects'
        });
  
      if (!allJobs || allJobs.length === 0) {
        return res.status(404).json({ success: false, message: "No jobs found" });
      }
  
      // Modify the response to include projectId and projectName
      const jobsWithProjectDetails = allJobs.map(job => {
        return {
          ...job.toObject(),
          project: {
            projectId: job.projectId._id, // project ID
            projectName: job.projectId.name, // project name
          }
        };
      });
  
      res.status(200).json({
        success: true,
        jobs: jobsWithProjectDetails,
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
      const allowedFields = [
        'projects',  // Project ID
        'projectName',     
        'brandName',
        'subBrand',    
        'flavour',    
        'packType',
        'packSize',
        'priority',
        'Status',
        'assign',
        'totalTime',
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
      const updatedDiary = await Jobs.findByIdAndUpdate(
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
    const SingleJob=async(req,res)=>{
      try {
          const SingleJob= await Jobs.findById(req.params.id);
          res.status(200).json(SingleJob)
      } catch (error) {
          res.status(404).json({msg:"Can t Find Diaries"} )
      }
  }


module.exports = {jobCreate,AllJob,deleteJob,UpdateJob,SingleJob};





const mongoose = require("mongoose");

const Projects = require("./ProjectsModel");

const jobsSchema = new mongoose.Schema({
    projectId:[ {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Projects',
        required: true,
    }],
    brandName: {
        type:String ,
        required: true,
    },
    subBrand: {
        type: String,
        required: true,
    },
    flavour: {
        type: String,
        required: true,
    },
    packType: {
        type: String,
        required: true,
    },
    packSize: {
        type: String,
        required: true,
    },
    priority:{
        type: String,
        required: true,
    },
    Status: {
        type: String,
        required: true,
    },
    assign: {
        type: String,
        required: true,
    },
    barcode: {
        type: String,
        required: true
      },
    totalTime: {
        type: String,
        require: true
    }
},{
    timestamps: true,
});

module.exports = mongoose.model('Jobs', jobsSchema);






























  const AllJob = async (req, res) => {
    try {
      // Fetch all projects with their _id and projectName
      const allProjects = await Projects.find()
        .select('_id projectName'); // Only select _id and projectName fields
  
      if (!allProjects || allProjects.length === 0) {
        return res.status(404).json({ success: false, message: "No projects found" });
      }
  
      res.status(200).json({
        success: true,
        jobs: allProjects, // Return the projects in the response
      });
  
    } catch (error) {
      console.error("Error fetching projects:", error);
      res.status(500).json({
        success: false,
        message: "An error occurred while fetching projects",
        error: error.message,
      });
    }
  };
  



  {
    "projectsId": [
      "681c8656d90e15caa3863398", 
      "681c8662d90e15caa386339a"
    ],
    "brandName": "Pepsi",
    "subBrand": "Pepsi Max",
    "flavour": "Cherry",
    "packType": "Can",
    "packSize": "330ml",
    "priority": "Low",
    "Status": "In Progress",
    "assign": "Designer",
    "barcode": "POS-123456",
    "totalTime": "05:30"
  }
  

























  // //////////////
  
// ///////////////////


const userRegister=asynchandler(
async(req,res)=>{
    const {name,email,phone,address,city,password}=req.body

    if(!name || !email || !phone || !address || !city || !password ){
        throw new Error("Pliss Fill All Detilse")
    }
     if(phone.length > 10){
        res.status(401)
        throw new Error('Please number is 10 digit')    
     }
    // user Exist 
     const userExist = await User.findOne({email:email})

    if(userExist){
    res.status(401)
    throw new Error("User Already Exist")
    }

     const salt = await bcrypt.genSalt(10)
     const hashpassword =await bcrypt.hash(password,salt)

    //  creat 
    const user = await User.create({
        name,
        email,
        phone,
        address,
        city,
        password:hashpassword,
    })
    if(user){
        res.status(201).json({
            _id:user._id,
            name:user.name,
            email:user.email,
            phone:user.phone,
            address:user.address,
            city:user.city,
            password:user.password,
            token:genretToken(user._id)

        })
    } 
 
    res.send("Register Router")
})

const userlogin=asynchandler(
async(req,res)=>{
    const {email,password}=req.body
    if(!email || !password){
        throw new Error("Pliss Fill All Detilse")
    }

    //  user Exist 
    const  user =await User.findOne({email})

    if(user && (await bcrypt.compare(password,user.password))){
     res.status(200).json({
        _id:user._id,
        email:user.email,
        password:user.password,
        isAdmin : user?.isAdmin,
        token:genretToken(user._id),
        

     })
    }else{
        res.status(401)
        throw new Error("Invalid Cordetion")
    }

    res.send("Login Router")
})



module.exports = {userRegister,userlogin,getMe}

























const asyncHandler = require('express-async-handler');
const ReceivablePurchase = require('../Model/ReceivablePurchaseModel');
const Projects = require("../Model/ProjectsModel");
const ClientManagement = require("../Model/ClientManagementModel");
const cloudinary = require('../Config/cloudinary');
const mongoose = require("mongoose");

cloudinary.config({
    cloud_name: 'dkqcqrrbp',
    api_key: '418838712271323',
    api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});

const ReceivablePurchaseCreate = asyncHandler(async (req, res) => {
  let {
    projectsId,
    ClientId,
    Status,
    ReceivedDate,
    Amount
  } = req.body;

  try {
    if (typeof projectsId === "string") {
      try {
        projectsId = JSON.parse(projectsId);
      } catch (err) {
        return res.status(400).json({
          success: false,
          message: "Invalid projectsId format",
        });
      }
    }

    if (!projectsId || !Array.isArray(projectsId)) {
      return res.status(400).json({
        success: false,
        message: "projectsId is required and should be an array"
      });
    }

    const projects = await Projects.find({ _id: { $in: projectsId } });
    if (projects.length !== projectsId.length) {
      return res.status(404).json({
        success: false,
        message: "One or more projects not found."
      });
    }

    const client = await ClientManagement.findById(ClientId);
    if (!client) {
      return res.status(404).json({
        success: false,
        message: "Client not found."
      });
    }

    let imageUrls = [];

    if (req.files && req.files.image) {
      const files = Array.isArray(req.files.image) ? req.files.image : [req.files.image];

      for (const file of files) {
        try {
          const result = await cloudinary.uploader.upload(file.tempFilePath, {
            folder: 'user_profiles',
            resource_type: 'image',
          });
          if (result.secure_url) {
            imageUrls.push(result.secure_url);
          }
        } catch (uploadError) {
          console.error("Cloudinary upload error:", uploadError);
        }
      }
    }

    const newReceivablePurchase = new ReceivablePurchase({
      projectsId,
      ClientId,
      ReceivedDate,
      Status,
      Amount,
      image: imageUrls, 
    });

    await newReceivablePurchase.save();

    res.status(201).json({
      success: true,
      message: "Receivable Purchase created successfully",
      receivablePurchase: newReceivablePurchase,
    });

  } catch (error) {
    console.error("Error creating Receivable Purchase:", error);
    res.status(500).json({
      success: false,
      message: "An error occurred while creating the Receivable Purchase",
      error: error.message,
    });
  }
});


module.exports = { ReceivablePurchaseCreate };




















































function convertTo24Hour(timeStr) {
  const [time, modifier] = timeStr.trim().split(" ");
  let [hours, minutes] = time.split(":").map(Number);

  if (modifier.toUpperCase() === "PM" && hours !== 12) {
    hours += 12;
  } else if (modifier.toUpperCase() === "AM" && hours === 12) {
    hours = 0;
  }

  return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
}


const TimesheetWorklogCreate = asyncHandler(async (req, res) => {
  const {
    projectId,
    jobId,
    employeeId,
    date,
    startTime,
    endTime,
    taskDescription,
    status,
    tags
  } = req.body;

  try {
    // Validate project IDs
    if (!Array.isArray(projectId) || projectId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
      return res.status(400).json({
        success: false,
        message: "Invalid Project ID format. Ensure all IDs are valid."
      });
    }

    // Validate jobId array
    if (!Array.isArray(jobId) || jobId.length === 0 || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
      return res.status(400).json({
        success: false,
        message: "Invalid Job ID format. Ensure all IDs are valid."
      });
    }

    // Validate EmployeeId array
    // ✅ Validate Employee ID array
    if (!Array.isArray(employeeId) || employeeId.length === 0 || employeeId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
      return res.status(400).json({
        success: false,
        message: "Invalid Employee ID format. Ensure all IDs are valid."
      });
    }

    // Check if all projects exist
    const projects = await Projects.find({ '_id': { $in: projectId } });
    if (projects.length !== projectId.length) {
      return res.status(404).json({
        success: false,
        message: "One or more projects not found"
      });
    }

    // Check if job exists (using first jobId only)
    const job = await Jobs.findById(jobId[0]);
    if (!job) {
      return res.status(404).json({
        success: false,
        message: "Job not found"
      });
    }
    // Check if job exists (using first jobId only)

    // Validate EmployeeId array
    // ✅ Find employee in User table
    const employeeUser = await User.findOne({ _id: employeeId[0], role: "employee" });
    if (!employeeUser) {
      return res.status(404).json({
        success: false,
        message: "Employee user not found or role is not 'employee'"
      });
    }

    // Convert to 24-hour format
    const start24 = convertTo24Hour(startTime);
    const end24 = convertTo24Hour(endTime);

    // Validate and calculate hours
    const start = new Date(`${date}T${start24}`);
    const end = new Date(`${date}T${end24}`);


    if (isNaN(start.getTime()) || isNaN(end.getTime())) {
      return res.status(400).json({
        success: false,
        message: "Invalid startTime or endTime format"
      });
    }

    // ✅ Handle overnight shift
    if (start >= end) {
      end.setDate(end.getDate() + 1); // Add 1 day to end
    }

    const milliseconds = end - start;
    const totalMinutes = Math.floor(milliseconds / (1000 * 60));
    const hours = +(totalMinutes / 60).toFixed(2);
    const durationReadable = `${Math.floor(totalMinutes / 60)}:${String(totalMinutes % 60).padStart(2, '0')}`;

    // Create the new TimeLog
    const newTimesheetWorklog = new TimesheetWorklogs({
      projectId,
      jobId: jobId[0],
      employeeId: employeeUser._id,
      date,
      startTime,
      endTime,
      hours: durationReadable,
      taskDescription,
      status,
      tags
    });

    await newTimesheetWorklog.save();

    res.status(201).json({
      success: true,
      message: "TimeLog created successfully",
      TimesheetWorklog: newTimesheetWorklog.toObject(),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "An error occurred while creating the TimeLog",
      error: error.message,
    });
  }
});



















// const TimesheetWorklogCreate = asyncHandler(async (req, res) => {

//     const {
//         projectId,
//         jobId,
//         date,
//         startTime,
//         endTime,
//         hours,
//         taskDescription,
//         status,
//         tags
//     } = req.body;

//     try {
//         // Validate project IDs
//         if (!Array.isArray(projectId) || projectId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//             return res.status(400).json({
//                 success: false,
//                 message: "Invalid Project ID format. Ensure all IDs are valid."
//             });
//         }

//         // Validate jobId array
//         if (!Array.isArray(jobId) || jobId.length === 0 || jobId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//             return res.status(400).json({
//                 success: false,
//                 message: "Invalid Job ID format. Ensure all IDs are valid."
//             });
//         }

//         // Check if all projects exist
//         const projects = await Projects.find({ '_id': { $in: projectId } });
//         if (projects.length !== projectId.length) {
//             return res.status(404).json({
//                 success: false,
//                 message: "One or more projects not found"
//             });
//         }

//         // Check if job exists (using first jobId only)
//         const job = await Jobs.findById(jobId[0]);
//         if (!job) {
//             return res.status(404).json({
//                 success: false,
//                 message: "Job not found"
//             });
//         }

//         // Create the new TimeLog
//         const newTimesheetWorklog = new TimesheetWorklogs({
//             projectId: projectId,
//             jobId: jobId[0],  
//             date,
//             startTime,
//             endTime,
//             hours,
//             taskDescription,
//             status,
//             tags
//         });

//         await newTimesheetWorklog.save();

//         res.status(201).json({
//             success: true,
//             message: "TimeLog created successfully",
//             TimesheetWorklog: newTimesheetWorklog.toObject(),
//         });
//     } catch (error) {
//         res.status(500).json({
//             success: false,
//             message: "An error occurred while creating the TimeLog",
//             error: error.message,
//         });
//     }
// });

// Helper: Convert 12-hour format (e.g., "02:30 PM") to 24-hour format (e.g., "14:30")

























const asyncHandler = require('express-async-handler');
const CostEstimates = require('../../Model/Admin/CostEstimatesModel');
const Projects = require("../../Model/Admin/ProjectsModel");
const ClientManagement = require("../../Model/Admin/ClientManagementModel");
const cloudinary = require('../../Config/cloudinary');

const mongoose = require("mongoose");

cloudinary.config({
  cloud_name: 'dkqcqrrbp',
  api_key: '418838712271323',
  api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});
const costEstimatesCreate = asyncHandler(async (req, res) => {
  const {
    projectsId,
    clientId,
    estimateDate,
    validUntil,
    currency,
    lineItems,
    VATRate,
    Notes,
    POStatus,
    Status
  } = req.body;

  try {
if (!Array.isArray(projectsId) || projectsId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
  return res.status(400).json({ success: false, message: "Invalid Project ID format." });
}


    if (!mongoose.Types.ObjectId.isValid(clientId)) {
      return res.status(400).json({ success: false, message: "Invalid Client ID format." });
    }

    const projects = await Projects.find({ '_id': { $in: projectsId } });
    if (projects.length !== projectsId.length) {
      return res.status(404).json({ success: false, message: "One or more projects not found" });
    }

    const client = await ClientManagement.findById(clientId);
    if (!client) {
      return res.status(404).json({ success: false, message: "Client not found" });
    }

    const newCostEstimate = new CostEstimates({
      projectId: projectsId,
      clientId,
      estimateDate,
      validUntil,
      currency,
      lineItems,
      VATRate,
      Notes,
      POStatus,
      Status,
      estimateRef 
    });

    await newCostEstimate.save();

    res.status(201).json({
      success: true,
      message: "Cost Estimate created successfully",
      costEstimate: newCostEstimate,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      message: "An error occurred while creating the Cost Estimate",
      error: error.message,
    });
  }
});



























import React, { useState, useRef } from 'react';
import 'bootstrap/dist/css/bootstrap.min.css';

// Example user data (replace with props or redux in real app)
const userData = {
  permissions: {
    dashboardAccess: true,
    userManagement: true,
   
  },
  accessLevel: {
    fullAccess: true,
    limitedAccess: false,
    viewOnly: false
  },
  _id: '68418bc45df221af4efdffee',
  firstName: 'employee',
  lastName: '1',
  email: 'employee@gmail.com',
  phone: '1234567890',
  role: 'employee',
  state: 'California',
  country: 'California',
  assign: 'Production',
  isAdmin: false,
  profileImage: [
    ''
  ],
  googleSignIn: false,
  createdAt: '2025-06-05T12:21:24.100Z',
  updatedAt: '2025-06-05T12:21:24.100Z',
};


// // Example user data (replace with props or redux in real app)
const Data = {
  permissions: {
    dashboardAccess: true,
    userManagement: true,
    clientManagement: false,
    projectManagement: false,
    designTools: false,
    financialManagement: false,
    reportGeneration: false,
    systemSettings: false
  },
  accessLevel: {
    fullAccess: true,
    limitedAccess: false,
    viewOnly: false
  },
  _id: '68418bc45df221af4efdffee',
  firstName: 'employee',
  lastName: '1',
  email: 'employee@gmail.com',
  phone: '1234567890',
  role: 'employee',
  state: 'California',
  country: 'California',
  assign: 'Production',
  isAdmin: false,
  profileImage: [
    ''
  ],
  googleSignIn: false,
  createdAt: '2025-06-05T12:21:24.100Z',
  updatedAt: '2025-06-05T12:21:24.100Z',
};
function Profile() {
  // Form state
  const [form, setForm] = useState({
    firstName: userData.firstName,
    lastName: userData.lastName,
    email: userData.email,
    phone: userData.phone,
    state: userData.state,
    country: userData.country,
    assign: userData.assign,
    profileImage: userData.profileImage[0] || '',
  });
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const fileInputRef = useRef();

  // Handle form changes
  const handleChange = (e) => {
    const { name, value, files } = e.target;
    if (name === 'profileImage' && files && files[0]) {
      setForm({ ...form, profileImage: URL.createObjectURL(files[0]) });
    } else {
      setForm({ ...form, [name]: value });
    }
  };

  const handleImageClick = () => {
    fileInputRef.current.click();
  };

  // Handle form submit (simulate update)
  const handleSubmit = (e) => {
    e.preventDefault();
    setMessage('');
    setError('');
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      setMessage('Profile updated successfully!');
    }, 1200);
  };

  // Permissions badges
  const permissionBadges = Object.entries(userData.permissions).map(([key, value]) => (
    <span key={key} className={`badge me-2 mb-1 ${value ? 'bg-success' : 'bg-secondary'}`} title={key.replace(/([A-Z])/g, ' $1')}>
      {key.replace(/([A-Z])/g, ' $1')}
    </span>
  ));
  // Access level badges
  const accessBadges = Object.entries(userData.accessLevel).map(([key, value]) => (
    <span key={key} className={`badge me-2 mb-1 ${value ? 'bg-primary' : 'bg-light text-dark border'}`} title={key.replace(/([A-Z])/g, ' $1')}>
      {key.replace(/([A-Z])/g, ' $1')}
    </span>
  ));




  const createdDate = new Date(userData.createdAt).toLocaleDateString('en-GB');
  const updatedDate = new Date(userData.updatedAt).toLocaleDateString('en-GB');

  // Access Level list
  const accessLevels = Object.entries(userData.accessLevel).map(([key, value]) => (
    <li key={key} className="mb-2">
      <span className={`badge px-3 py-2 fs-6 d-flex align-items-center gap-2 ${value ? 'bg-primary' : 'bg-light text-dark border'}`}
        title={key.replace(/([A-Z])/g, ' $1').toLowerCase()}>
        <i className="bi bi-shield-lock-fill"></i>
        {key.replace(/([A-Z])/g, ' $1').toLowerCase()}
      </span>
    </li>
  ));

  // Permissions list
  const permissions = Object.entries(userData.permissions).map(([key, value]) => (
    <li key={key} className="mb-2">
      <span className={`badge px-3 py-2 fs-6 d-flex align-items-center gap-2 ${value ? 'bg-success' : 'bg-secondary'}`}
        title={key.replace(/([A-Z])/g, ' $1').toLowerCase()}>
        <i className="bi bi-check2-circle"></i>
        {key.replace(/([A-Z])/g, ' $1').toLowerCase()}
      </span>
    </li>
  ));

  return (
    <>
      <div className="container py-2">
        <div className="row justify-content-center g-4">
          {/* Profile summary */}
          <div className="col-lg-4 mb-4">
            <div className="card border-0 shadow-lg " style={{ background: 'linear-gradient(135deg, #f8fafc 60%, #e0e7ff 100%)', borderRadius: '1.5rem' }}>
              <div className="card-body text-center p-4 d-flex flex-column align-items-center justify-content-between h-100">
                <div className="position-relative d-inline-block mb-3">
                  <img
                    src={form.profileImage || 'https://wac-cdn.atlassian.com/dam/jcr:ba03a215-2f45-40f5-8540-b2015223c918/Max-R_Headshot%20(1).jpg?cdnVersion=2654'}
                    alt="avatar"
                    className="rounded-circle border border-3 border-primary shadow"
                    style={{ width: '140px', height: '140px', objectFit: 'cover', background: '#fff', boxShadow: '0 4px 24px rgba(0,0,0,0.08)' }}
                  />
                </div>
                <h4 className="fw-bold mb-1 mt-2">{userData.firstName} {userData.lastName}</h4>
                <div className="mb-2">
                  <i className="bi bi-envelope-at me-1"></i>
                  <span className="fw-semibold">{Data.email}</span>
                </div>
                <div className="mb-2">
                  <i className="bi bi-telephone me-1"></i>
                  <span className="fw-semibold">{Data.phone}</span>
                </div>
                <div className="d-flex flex-wrap gap-2 justify-content-center mt-3">
                  <span className="small text-secondary"><i className="bi bi-clock-history me-1"></i>Last Updated: {updatedDate}</span>
                  <span className="small text-secondary"><i className="bi bi-hash me-1"></i>User ID: {Data._id}</span>
                </div>
              </div>
            </div>
          </div>

          {/* Profile details & update form */}
          <div className="col-lg-8">
            <div className="card border-0 shadow-lg mb-4" style={{ background: 'linear-gradient(135deg, #f8fafc 60%, #e0e7ff 100%)', borderRadius: '1.5rem' }}>
              <div className="card-body p-4">
                <h5 className="mb-4 fw-bold d-flex align-items-center"><i className="bi bi-pencil-square me-2"></i>Profile Details</h5>
                {/* User Details Section */}
                <div className="row mb-3 g-3">
                  <div className="col-md-6">
                    <div className="mb-3">
                      <div className="d-flex align-items-center mb-2">
                        <i className="bi bi-envelope-at me-2 text-primary"></i>
                        <span className="fw-semibold">{Data.email}</span>
                      </div>
                      <div className="d-flex align-items-center mb-2">
                        <i className="bi bi-telephone me-2 text-primary"></i>
                        <span className="fw-semibold">{Data.phone}</span>
                      </div>
                      <div className="d-flex align-items-center mb-2">
                        <i className="bi bi-geo-alt me-2 text-primary"></i>
                        <span className="fw-semibold">{Data.state}, {Data.country}</span>
                      </div>
                      <div className="mb-2">
                        <span className="fw-semibold">Access Level:</span>
                        <span className="badge bg-primary ms-2 text-capitalize">Full Access</span>
                      </div>
                      <div className="mb-2 text-muted small">
                        {Data.role && <span className="badge bg-info text-dark me-1 text-capitalize">{Data.role}</span>}
                      </div>
                    </div>
                  </div>
                  <div className="col-md-6">
                    <div className="mb-3">
                      <div className="d-flex align-items-center mb-2">
                        <i className="bi bi-google me-2 text-primary"></i>
                        <span className="fw-semibold">Google Sign In:</span>
                        <span className={`badge ms-2 ${Data.googleSignIn ? 'bg-success' : 'bg-secondary'}`}>{Data.googleSignIn ? 'Yes' : 'No'}</span>
                      </div>
                      <div className="d-flex align-items-center mb-2">
                        <i className="bi bi-diagram-3-fill me-2 text-primary"></i>
                        <span className="fw-semibold">Department:</span>
                        <span className="text-muted ms-1">{Data.assign}</span>
                      </div>
                      <div className="d-flex align-items-center mb-2">
                        <i className="bi bi-check-circle-fill me-2 text-primary"></i>
                        <span className="fw-semibold">Status:</span>
                        <span className="badge ms-2 bg-success">Active</span>
                      </div>
                      <div className="d-flex align-items-center mb-2">
                        <i className="bi bi-calendar-event me-2 text-primary"></i>
                        <span className="fw-semibold">Account Created:</span>
                        <span className="text-muted ms-1">{createdDate}</span>
                      </div>
                      <div>
                        <h5 className="fw-bold mb-3 d-flex align-items-center"><i className="bi bi-check2-circle me-2"></i>Permissions</h5>
                        <ul className="list-unstyled d-flex flex-wrap gap-2 mb-0">
                          {permissions}
                        </ul>
                      </div>
                    </div>
                  </div>
                </div>

                <div className=" mt-4 border-0 ">
                  <div className="card-body p-4">
                    <h5 className="fw-bold mb-2 d-flex align-items-center"><i className="bi bi-info-circle me-2"></i>About</h5>
                    <p className="text-muted mb-2">This is a placeholder for user bio or additional information. You can add more details about the employee here.</p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

    </>
  );
}

export default Profile;
























const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../Model/userModel');
const cloudinary = require('../Config/cloudinary');
const nodemailer = require('nodemailer');
const {encodeToken} = require ("../middlewares/decodeToken")
// Cloudinary config
cloudinary.config({
    cloud_name: 'dkqcqrrbp',
    api_key: '418838712271323',
    api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});

// JWT Token function
const genretToken = (id) => {
    return jwt.sign({ id }, 'your_jwt_secret_key', { expiresIn: '7d' });
};

// Register user
const createUser = async (req, res) => {
    try {
        const {
            firstName, lastName, email, password, passwordConfirm,
            phone, role, state, country, permissions, accessLevel,assign
        } = req.body;

        const requiredFields = { firstName, lastName, email, password, passwordConfirm, phone, role, state, country,assign };
        for (const [key, value] of Object.entries(requiredFields)) {
            if (!value || value.toString().trim() === '') {
                return res.status(400).json({ status: false, message: `${key} is required` });
            }
        }

        if (password !== passwordConfirm) {
            return res.status(400).json({ status: false, message: 'Passwords do not match' });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: "User already exists with same email" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        let profileImage = '';
        if (req.files && req.files.image) {
            const result = await cloudinary.uploader.upload(req.files.image.tempFilePath, {
                folder: 'user_profiles',
                resource_type: 'image',
            });
            profileImage = result.secure_url;
        }

        const parsedPermissions = typeof permissions === 'string' ? JSON.parse(permissions) : permissions;
        const parsedAccessLevel = typeof accessLevel === 'string' ? JSON.parse(accessLevel) : accessLevel;

        const newUser = await User.create({
            firstName,
            lastName,
            email,
            phone,
            password: hashedPassword,
            role,
            state,
            country,
            assign,
            profileImage,
            permissions: parsedPermissions,
            accessLevel: parsedAccessLevel,
        });

        const token = genretToken(newUser._id);

        res.status(201).json({
            status: 'success',
            data: { user: newUser, token }
        });
    } catch (err) {
        res.status(400).json({ status: false, message: err.message });
    }
};

// Login
const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ status: false, message: 'Email and password are required' });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(401).json({ status: false, message: 'Invalid email or password' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ status: false, message: 'Invalid email or password' });
        }

        const token = await genretToken(user._id);
        console.log(token)
        const encodeTokens= await encodeToken(token)
        user.password = undefined;

        res.status(200).json({
            status: 'success',
            message: 'Login successful',
            token:encodeTokens,
            user
        });

    } catch (err) {
        res.status(500).json({ status: 'error', message: err.message });
    }
};

// Forgot password
const forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ status: "false", message: "User not found." });
        }

        if (user.googleSignIn === true) {
            return res.status(400).json({
                status: "false",
                message: "Password reset is not allowed for Google Sign-In users. Please log in using Google."
            });
        }

        const resetToken = crypto.randomBytes(32).toString("hex");
        user.resetToken = resetToken;
        user.resetTokenExpiry = Date.now() + 15 * 60 * 1000;
        await user.save();

        const transporter = nodemailer.createTransport({
            service: "gmail",
            auth: {
                user: 'packageitappofficially@gmail.com',
                pass: 'epvuqqesdioohjvi',
            },
            tls: {
                rejectUnauthorized: false,
            }
        });

        await transporter.sendMail({
            from: 'packageitappofficially@gmail.com',
            to: email,
            subject: "Your Password Reset Token",
            html: `<p>Your password reset token: <strong>${resetToken}</strong></p>
                   <p>This token is valid for <strong>15 minutes</strong>.</p>
                   <p>If you did not request this, please ignore this email.</p>`,
        });

        res.status(200).json({ status: "true", message: "Password reset email sent successfully." });

    } catch (error) {
        console.error("Forgot Password Error:", error);
        res.status(500).json({ status: "false", message: "Server error" });
    }
};

// Reset password
const resetPassword = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ status: false, message: "Email and password are required." });
    }l
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ status: false, message: "User not found." });
    }

    if (user.googleSignIn === true) {
      return res.status(400).json({ status: false, message: "Google sign-in user cannot reset password." });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    user.password = hashedPassword;
    await user.save();

    res.status(200).json({ status: true, message: "Password reset successfully." });
  } catch (error) {
    console.error("Reset Password Error:", error);
    res.status(500).json({ status: false, message: "Server error." });
  }
};

// Get all users
const getAllUsers = async (req, res) => {
    try {
        const users = await User.find();
        res.status(200).json({
            status: 'success',
            results: users.length,
            data: { users }
        });
    } catch (err) {
        res.status(400).json({ status: false, message: err.message });
    }
};


       //GET SINGLE DeleteUser
  //METHOD:DELETE
  const deleteUser = async (req, res) => {
    let deleteUserID = req.params.id
    if (deleteUser) {
      const deleteUser = await User.findByIdAndDelete(deleteUserID, req.body);
      res.status(200).json("Delete Checklists Successfully")
    } else {
      res.status(400).json({ message: "Not Delete User" })
    }
  }

  //GET SINGLE UserUpdate
    //METHOD:PUT
    const UpdateUser = async (req, res) => {
      try {
        const allowedFields = [
           'firstName',
            'lastName',
            'email',
            'phone',
            'role',
            'state',
            'country',
            'profileImage',
            'permissions',
            'accessLevel'
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
        const updatedDiary = await User.findByIdAndUpdate(
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
  

    module.exports = {createUser ,loginUser,forgotPassword,resetPassword,getAllUsers,deleteUser,UpdateUser}
















    const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../Model/userModel');
const cloudinary = require('../Config/cloudinary');
const nodemailer = require('nodemailer');
const {encodeToken} = require ("../middlewares/decodeToken")
// Cloudinary config
cloudinary.config({
    cloud_name: 'dkqcqrrbp',
    api_key: '418838712271323',
    api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});

// JWT Token function
const genretToken = (id) => {
    return jwt.sign({ id }, 'your_jwt_secret_key', { expiresIn: '7d' });
};

// Register user
const createUser = async (req, res) => {
    try {
        const {
            firstName, lastName, email, password, passwordConfirm,
            phone, role, state, country, permissions, accessLevel,assign
        } = req.body;

        const requiredFields = { firstName, lastName, email, password, passwordConfirm, phone, role, state, country,assign };
        for (const [key, value] of Object.entries(requiredFields)) {
            if (!value || value.toString().trim() === '') {
                return res.status(400).json({ status: false, message: `${key} is required` });
            }
        }

        if (password !== passwordConfirm) {
            return res.status(400).json({ status: false, message: 'Passwords do not match' });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: "User already exists with same email" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        let profileImage = '';
        if (req.files && req.files.image) {
            const result = await cloudinary.uploader.upload(req.files.image.tempFilePath, {
                folder: 'user_profiles',
                resource_type: 'image',
            });
            profileImage = result.secure_url;
        }

        const parsedPermissions = typeof permissions === 'string' ? JSON.parse(permissions) : permissions;
        const parsedAccessLevel = typeof accessLevel === 'string' ? JSON.parse(accessLevel) : accessLevel;

        const newUser = await User.create({
            firstName,
            lastName,
            email,
            phone,
            password: hashedPassword,
            role,
            state,
            country,
            assign,
            profileImage,
            permissions: parsedPermissions,
            accessLevel: parsedAccessLevel,
        });

        const token = genretToken(newUser._id);

        res.status(201).json({
            status: 'success',
            data: { user: newUser, token }
        });
    } catch (err) {
        res.status(400).json({ status: false, message: err.message });
    }
};

// Login
const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ status: false, message: 'Email and password are required' });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(401).json({ status: false, message: 'Invalid email or password' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ status: false, message: 'Invalid email or password' });
        }

        const token = await genretToken(user._id);
        console.log(token)
        const encodeTokens= await encodeToken(token)
        user.password = undefined;

        res.status(200).json({
            status: 'success',
            message: 'Login successful',
            token:encodeTokens,
            user
        });

    } catch (err) {
        res.status(500).json({ status: 'error', message: err.message });
    }
};

// Forgot password
const forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;
        const user = await User.findOne({ email });

        if (!user) {
            return res.status(404).json({ status: "false", message: "User not found." });
        }

        if (user.googleSignIn === true) {
            return res.status(400).json({
                status: "false",
                message: "Password reset is not allowed for Google Sign-In users. Please log in using Google."
            });
        }

        const resetToken = crypto.randomBytes(32).toString("hex");
        user.resetToken = resetToken;
        user.resetTokenExpiry = Date.now() + 15 * 60 * 1000;
        await user.save();

        const transporter = nodemailer.createTransport({
            service: "gmail",
            auth: {
                user: 'packageitappofficially@gmail.com',
                pass: 'epvuqqesdioohjvi',
            },
            tls: {
                rejectUnauthorized: false,
            }
        });

        await transporter.sendMail({
            from: 'packageitappofficially@gmail.com',
            to: email,
            subject: "Your Password Reset Token",
            html: `<p>Your password reset token: <strong>${resetToken}</strong></p>
                   <p>This token is valid for <strong>15 minutes</strong>.</p>
                   <p>If you did not request this, please ignore this email.</p>`,
        });

        res.status(200).json({ status: "true", message: "Password reset email sent successfully." });

    } catch (error) {
        console.error("Forgot Password Error:", error);
        res.status(500).json({ status: "false", message: "Server error" });
    }
};

// Reset password
const resetPassword = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password) {
      return res.status(400).json({ status: false, message: "Email and password are required." });
    }l
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(404).json({ status: false, message: "User not found." });
    }

    if (user.googleSignIn === true) {
      return res.status(400).json({ status: false, message: "Google sign-in user cannot reset password." });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    user.password = hashedPassword;
    await user.save();

    res.status(200).json({ status: true, message: "Password reset successfully." });
  } catch (error) {
    console.error("Reset Password Error:", error);
    res.status(500).json({ status: false, message: "Server error." });
  }
};

// Get all users
const getAllUsers = async (req, res) => {
    try {
        const users = await User.find();
        res.status(200).json({
            status: 'success',
            results: users.length,
            data: { users }
        });
    } catch (err) {
        res.status(400).json({ status: false, message: err.message });
    }
};


       //GET SINGLE DeleteUser
  //METHOD:DELETE
  const deleteUser = async (req, res) => {
    let deleteUserID = req.params.id
    if (deleteUser) {
      const deleteUser = await User.findByIdAndDelete(deleteUserID, req.body);
      res.status(200).json("Delete Checklists Successfully")
    } else {
      res.status(400).json({ message: "Not Delete User" })
    }
  }

  //GET SINGLE UserUpdate
    //METHOD:PUT
    const UpdateUser = async (req, res) => {
      try {
        const allowedFields = [
           'firstName',
            'lastName',
            'email',
            'phone',
            'role',
            'state',
            'country',
            'profileImage',
            'permissions',
            'accessLevel'
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
        const updatedDiary = await User.findByIdAndUpdate(
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
  

    module.exports = {createUser ,loginUser,forgotPassword,resetPassword,getAllUsers,deleteUser,UpdateUser}






    const crypto = require('crypto');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../Model/userModel');
const cloudinary = require('../Config/cloudinary');
const nodemailer = require('nodemailer');
const {encodeToken} = require ("../middlewares/decodeToken")
// Cloudinary config
cloudinary.config({
    cloud_name: 'dkqcqrrbp',
    api_key: '418838712271323',
    api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});

// JWT Token function
const genretToken = (id) => {
    return jwt.sign({ id }, 'your_jwt_secret_key', { expiresIn: '7d' });
};

// Register user
const createUser = async (req, res) => {
    try {
        const {
            firstName, lastName, email, password, passwordConfirm,
            phone, role, state, country, permissions, accessLevel,assign
        } = req.body;

        const requiredFields = { firstName, lastName, email, password, passwordConfirm, phone, role, state, country,assign };
        for (const [key, value] of Object.entries(requiredFields)) {
            if (!value || value.toString().trim() === '') {
                return res.status(400).json({ status: false, message: `${key} is required` });
            }
        }

        if (password !== passwordConfirm) {
            return res.status(400).json({ status: false, message: 'Passwords do not match' });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ message: "User already exists with same email" });
        }

        const hashedPassword = await bcrypt.hash(password, 10);

        let profileImage = '';
        if (req.files && req.files.image) {
            const result = await cloudinary.uploader.upload(req.files.image.tempFilePath, {
                folder: 'user_profiles',
                resource_type: 'image',
            });
            profileImage = result.secure_url;
        }

        const parsedPermissions = typeof permissions === 'string' ? JSON.parse(permissions) : permissions;
        const parsedAccessLevel = typeof accessLevel === 'string' ? JSON.parse(accessLevel) : accessLevel;

        const newUser = await User.create({
            firstName,
            lastName,
            email,
            phone,
            password: hashedPassword,
            role,
            state,
            country,
            assign,
            profileImage,
            permissions: parsedPermissions,
            accessLevel: parsedAccessLevel,
        });

        const token = genretToken(newUser._id);

        res.status(201).json({
            status: 'success',
            data: { user: newUser, token }
        });
    } catch (err) {
        res.status(400).json({ status: false, message: err.message });
    }
};

// Login
const loginUser = async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ status: false, message: 'Email and password are required' });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(401).json({ status: false, message: 'Invalid email or password' });
        }

        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ status: false, message: 'Invalid email or password' });
        }

        const token = await genretToken(user._id);
        console.log(token)
        const encodeTokens= await encodeToken(token)
        user.password = undefined;

        res.status(200).json({
            status: 'success',
            message: 'Login successful',
            token:encodeTokens,
            user
        });

    } catch (err) {
        res.status(500).json({ status: 'error', message: err.message });
    }
};

// ✅ Email Function
const sendEmail = async (options) => {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: 'packageitappofficially@gmail.com',
      pass: 'epvuqqesdioohjvi'
    },
    tls: {
      rejectUnauthorized: false
    }
  });

  const mailOptions = {
    from: 'sagarkher1999@gmail.com',
    to: options.email,
    subject: options.subject,
    html: `
      <div style="font-family: Arial, sans-serif; font-size: 15px; color: #333;">
        <h2>Password Reset Request</h2>
        <p>Hi,</p>
        <p>We received a request to reset your password. Please click the button below to reset your password:</p>
        <a href="https://construction-mngmt.netlify.app/resetpassword?token=${options.resetToken}" 
           style="display: inline-block; padding: 10px 20px; background-color: #007bff; color: #fff; text-decoration: none; border-radius: 5px;">
          Reset Password
        </a>
        <p>If you did not request this, you can safely ignore this email.</p>
        <p>This link will expire in 10 minutes for security reasons.</p>
        <br>
        <p>Regards,<br>PackageIt Team</p>
      </div>
    `
  };

  await transporter.sendMail(mailOptions);
};

// Forgot Password Controller
const forgotPassword = async (req, res) => {
  try {
    const user = await User.findOne({ email: req.body.email });

    if (!user) {
      return res.status(404).json({ status: 'fail', message: 'User not found with this email' });
    }

    const resetToken = user.createPasswordResetToken();
    await user.save({ validateBeforeSave: false });

    await sendEmail({
      email: user.email,
      subject: 'Reset Your Password',
      resetToken: resetToken
    });

    res.status(200).json({
      status: 'success',
      message: 'Reset token sent to email!',
      resetToken: resetToken
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ status: 'error', message: 'There was an error sending email.' });
  }
};

// Reset Password Controller
const resetPassword = async (req, res) => {
  try {
    const { token, newPassword, confirmPassword } = req.body;

    if (!token || !newPassword || !confirmPassword) {
      return res.status(400).json({ status: 'fail', message: 'All fields are required.' });
    }

    if (newPassword !== confirmPassword) {
      return res.status(400).json({ status: 'fail', message: 'Passwords do not match.' });
    }

    // Hash the token to match with DB
    const hashedToken = crypto.createHash('sha256').update(token).digest('hex');

    // Find user with this token and check expiration
    const user = await User.findOne({
      passwordResetToken: hashedToken,
      passwordResetExpires: { $gt: Date.now() }
    });

    if (!user) {
      return res.status(400).json({ status: 'fail', message: 'Token is invalid or has expired.' });
    }

    // Update password
    user.password = await bcrypt.hash(newPassword, 10);
    user.passwordResetToken = undefined;
    user.passwordResetExpires = undefined;

    await user.save();

    res.status(200).json({
      status: 'success',
      message: 'Password reset successfully.'
    });

  } catch (err) {
    console.error('Error resetting password:', err);
    res.status(500).json({ status: 'error', message: 'Internal server error.' });
  }
};

// Get all users
const getAllUsers = async (req, res) => {
    try {
        const users = await User.find();
        res.status(200).json({
            status: 'success',
            results: users.length,
            data: { users }
        });
    } catch (err) {
        res.status(400).json({ status: false, message: err.message });
    }
};


       //GET SINGLE DeleteUser
  //METHOD:DELETE
  const deleteUser = async (req, res) => {
    let deleteUserID = req.params.id
    if (deleteUser) {
      const deleteUser = await User.findByIdAndDelete(deleteUserID, req.body);
      res.status(200).json("Delete Checklists Successfully")
    } else {
      res.status(400).json({ message: "Not Delete User" })
    }
  }

  //GET SINGLE UserUpdate
    //METHOD:PUT
    const UpdateUser = async (req, res) => {
      try {
        const allowedFields = [
           'firstName',
            'lastName',
            'email',
            'phone',
            'role',
            'state',
            'country',
            'profileImage',
            'permissions',
            'accessLevel'
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
        const updatedDiary = await User.findByIdAndUpdate(
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
  

    module.exports = {createUser ,loginUser,forgotPassword,resetPassword,getAllUsers,deleteUser,UpdateUser}











    // const mongoose = require('mongoose');
// const bcrypt = require('bcryptjs');

// const userSchema = new mongoose.Schema({
//     firstName: {
//         type: String,
//         required: [true, 'First name is required'],
//         trim: true
//     },
//     lastName: {
//         type: String,
//         required: [true, 'Last name is required'],
//         trim: true
//     },
//     email: {
//         type: String,
//         required: [true, 'Email is required'],
//             unique: true, 
//     },
//     phone: {
//         type: String,
//         required: true,
//     },
//     password: {
//         type: String,
//         required: [true, 'Password is required'],
//     },
//     role: {
//         type: String,
//         required: [true, 'Role is required'],
//         default: "user",
//     },
//     state: {
//         type: String,
//         required: true,
//     },
//     country: {
//         type: String,
//         required: true,
//     },
//     permissions: {
//         dashboardAccess: {
//             type: Boolean,
//             default: false
//         },
//         clientManagement: {
//             type: Boolean,
//             default: false
//         },
//         projectManagement: {
//             type: Boolean,
//             default: false
//         },
//         designTools: {
//             type: Boolean,
//             default: false
//         },
//         financialManagement: {
//             type: Boolean,
//             default: false
//         },
//         userManagement: {
//             type: Boolean,
//             default: false
//         },
//         reportGeneration: {
//             type: Boolean,
//             default: false
//         },
//         systemSettings: {
//             type: Boolean,
//             default: false
//         }
//     },
//     accessLevel: {
//         fullAccess: {
//             type: Boolean,
//             default: false
//         },
//         limitedAccess: {
//             type: Boolean,
//             default: false
//         },
//         viewOnly: {
//             type: Boolean,
//             default: false
//         }
//     },
//     isAdmin: {
//         type: Boolean,
//         default: false
//     },
//     createdAt: {
//         type: Date,
//         default: Date.now
//     },
//     updatedAt: {
//         type: Date,
//         default: Date.now
//     },
//     profileImage: [],
// });



// const User = mongoose.model('User', userSchema);

// module.exports = User;



const mongoose = require('mongoose');
const crypto = require('crypto');

const userSchema = new mongoose.Schema({
    firstName: {
        type: String,
        required: [true, 'First name is required'],
        trim: true
    },
    lastName: {
        type: String,
        required: [true, 'Last name is required'],
        trim: true
    },
    email: {
        type: String,
        required: [true, 'Email is required'],
        unique: true,
    },
    phone: {
        type: String,
        required: true,
    },
    password: {
        type: String,
        required: [true, 'Password is required'],
    },
    role: {
        type: String,
        required: [true, 'Role is required'],
        default: "user",
    },
    state: {
        type: String,
        required: true,
    },
    country: {
        type: String,
        required: true,
    },
    assign:{
        type:String,
        required:true
    },
    permissions: {
        dashboardAccess: { type: Boolean, default: false },
        clientManagement: { type: Boolean, default: false },
        projectManagement: { type: Boolean, default: false },
        designTools: { type: Boolean, default: false },
        financialManagement: { type: Boolean, default: false },
        userManagement: { type: Boolean, default: false },
        reportGeneration: { type: Boolean, default: false },
        systemSettings: { type: Boolean, default: false }
    },
    accessLevel: {
        fullAccess: { type: Boolean, default: false },
        limitedAccess: { type: Boolean, default: false },
        viewOnly: { type: Boolean, default: false }
    },
    isAdmin: {
        type: Boolean,
        default: false
    },
    profileImage: [],
    googleSignIn: {
        type: Boolean,
        default: false
    },
    resetToken: String,
    resetTokenExpiry: Date,
    passwordResetToken: String,
    passwordResetExpires: Date,
    createdAt: {
        type: Date,
        default: Date.now
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
});

// Add method to generate and hash password reset token
userSchema.methods.createPasswordResetToken = function () {
    const resetToken = crypto.randomBytes(32).toString('hex');
    this.passwordResetToken = crypto.createHash('sha256').update(resetToken).digest('hex');
    this.passwordResetExpires = Date.now() + 10 * 60 * 1000; // 10 minutes
    return resetToken;
};

const User = mongoose.model('User', userSchema);
module.exports = User;

































// /////////////////////////
const asyncHandler = require('express-async-handler');
const Jobs = require('../../Model/Admin/JobsModel');
const Projects = require("../../Model/Admin/ProjectsModel");
const Assignment = require("../../Model/Admin/AssignmentJobControllerModel");
const cloudinary = require('../../Config/cloudinary');
const mongoose = require("mongoose")
const { generateJobsNo } = require('../../middlewares/generateEstimateRef');
const JobsSelect = require("../../Model/Admin/JobsSelectModel")

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

    const allJobs = await Jobs.find({ projectId })
      .populate({
        path: 'projectId',
        select: '_id projectName',
        model: 'Projects',
      });

    const jobsWithDetails = await Promise.all(allJobs.map(async (job) => {
      let assignedTo = "Not Assigned";

      // ✅ Step 1: Check if job.assign === 'production'
      if (job.assign === "production") {
        assignedTo = "production";
      } else {
        // ✅ Step 2: Check Assignment model for employee
        const assignment = await Assignment.findOne({ jobId: job._id })
          .populate({
            path: 'employeeId',
            select: 'firstName lastName',
          });

        if (assignment && assignment.employeeId) {
          assignedTo = `${assignment.employeeId.firstName} ${assignment.employeeId.lastName}`;
        }
      }

      return {
        ...job.toObject(),
        projects: job.projectId
          ? {
              projectId: job.projectId._id,
              projectName: job.projectId.projectName,
            }
          : {},
        assignedTo,
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
const AllJob = async (req, res) => {
  try {
    const allJobs = await Jobs.find().populate({
      path: 'projectId',
      select: '_id projectName',
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
          select: 'firstName lastName',
        });

      // Prepare assignedTo name
      let assignedTo = "Not Assigned";
      if (assignment && assignment.employeeId || assignment !== "Production") {
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
        assignedTo  // 👈 add assignedTo here
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

    const allJobs = await Jobs.find({ Status: Status }).populate({
      path: 'projectId',
      select: '_id projectName',
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
          select: 'firstName lastName',
        });

      // Prepare assignedTo name
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
        assignedTo  // 👈 add assignedTo here
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
module.exports = { jobCreate, AllJob, deleteJob, UpdateJob, SingleJob, UpdateJobAssign, AllJobID, filter, addSelectValues, getSelectValues };

dd




























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

        // If assigned to someone (not production) and not returned yet
        if (designer !== 'production') {
            const jobReturned = existingJobAssignment.jobs.some(j =>
                jobId.includes(j.jobId.toString()) && j.jobReturnStatus === false
            );
            if (jobReturned) {
                return res.status(409).json({
                    success: false,
                    message: "Job already assigned to an employee. Cannot reassign."
                });
            }
        }

        if (!(employeeId && employeeId.length > 0)) {
            return res.status(409).json({
                success: false,
                message: "Job already assigned to Production."
            });
        }
    }

    // 4. If assignment already exists for the employee, just add new jobs
    if (employeeId && employeeId.length > 0) {
        const existingAssignment = await Assignment.findOne({
            employeeId: { $in: employeeId }
        });
if (existingAssignment) {
    const existingJobIds = existingAssignment.jobs
        .filter(j => j.jobReturnStatus === false) // ❌ Abhi assigned jobs
        .map(j => j.jobId.toString());

    // ✅ Sirf wahi jobId allow karo jo abhi assigned nahi hai (return ho chuki ho)
    const newJobsToAdd = jobId.filter(id => !existingJobIds.includes(id.toString()));

    console.log("hh", newJobsToAdd);
    console.log("existingAssignment.jobs", existingAssignment);

    if (newJobsToAdd.length > 0) {
        newJobsToAdd.forEach(id => {
            existingAssignment.jobs.push({ jobId: id, jobReturnStatus: false });
        });

        existingAssignment.selectDesigner = selectDesigner;
        existingAssignment.description = description;
        await existingAssignment.save();

        const assignedUser = await User.findById(employeeId[0]);
        const assignValue = assignedUser
            ? `${assignedUser.firstName} ${assignedUser.lastName}`
            : "production";

        await Jobs.updateMany(
            { _id: { $in: newJobsToAdd } },
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
            message: "Job(s) added to existing employee assignment",
            assignment: existingAssignment,
        });
    } else {
        return res.status(400).json({
            success: false,
            message: "All these jobId(s) are either already assigned or in progress."
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
                select: 'projectName'
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
    const data = await Assignment.find({ selectDesigner: "Production" })
        .populate({
            path: "jobId",
            populate: {
                path: "projectId",
                select: "projectName projectNo", // Only get projectName
            },
        });

    return res.status(200).json({
        success: true,
        count: data.length,
        data,
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


const AllAssignJob = asyncHandler(async (req, res) => {
    try {
        const assignments = await Assignment.find()
            .populate('employeeId') // populate user details
            .populate('jobId');     // populate job details

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

        // 🔍 Jobs that are NOT completed
        const blockingJobs = await Jobs.find({
            _id: { $in: jobId },
            Status: { $ne: "Completed" }
        });

        const blockingJobIds = blockingJobs.map(job => job._id.toString());

        const isTryingToAssignToEmployee = employeeId && employeeId.length > 0;
        const isAlreadyAssignedToProduction = designer === 'production';
        const isAlreadyAssignedToEmployee = designer !== 'production';

        const jobReturned = existingJobAssignment.jobs.some(j =>
            blockingJobIds.includes(j.jobId.toString()) && j.jobReturnStatus === false
        );

        // ✅ All jobs completed → allow
        if (blockingJobIds.length === 0) {
            // Allow
        }

        // ✅ Production → Employee → allow
        else if (isAlreadyAssignedToProduction && isTryingToAssignToEmployee) {
            // Allow
        }

        // ❌ Employee → Production → block
        else if (isAlreadyAssignedToEmployee && !isTryingToAssignToEmployee) {
            if (jobReturned) {
                return res.status(409).json({
                    success: false,
                    message: "Job already assigned to employee and not completed. Cannot assign to Production."
                });
            }
        }

        // ❌ Any other → block
        else if (jobReturned) {
            return res.status(409).json({
                success: false,
                message: "Job already assigned and not completed. Cannot reassign."
            });
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
                existingAssignment.description.push(description);
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
                select: 'projectName'
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

        // 🔍 Jobs that are NOT completed
        const blockingJobs = await Jobs.find({
            _id: { $in: jobId },
            Status: { $ne: "Completed" }
        });

        const blockingJobIds = blockingJobs.map(job => job._id.toString());

        const isTryingToAssignToEmployee = employeeId && employeeId.length > 0;
        const isAlreadyAssignedToProduction = designer === 'production';
        const isAlreadyAssignedToEmployee = designer !== 'production';

        const jobReturned = existingJobAssignment.jobs.some(j =>
            blockingJobIds.includes(j.jobId.toString()) && j.jobReturnStatus === false
        );

        // ✅ All jobs completed → allow
        if (blockingJobIds.length === 0) {
            // Allow
        }

        // ✅ Production → Employee → allow
        else if (isAlreadyAssignedToProduction && isTryingToAssignToEmployee) {
            // Allow
        }

        // ❌ Employee → Production → block
        else if (isAlreadyAssignedToEmployee && !isTryingToAssignToEmployee) {
            if (jobReturned) {
                return res.status(409).json({
                    success: false,
                    message: "Job already assigned to employee and not completed. Cannot assign to Production."
                });
            }
        }

        // ❌ Any other → block
        else if (jobReturned) {
            return res.status(409).json({
                success: false,
                message: "Job already assigned and not completed. Cannot reassign."
            });
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
                existingAssignment.description.push(description);
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
                select: 'projectName'
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





































// const admin = require("firebase-admin");
// const Token = require("../Model/notifictionModle");
// const fs = require("fs");
// const path = require("path");
// const { readFileSync } = fs;

// const serviceAccount = JSON.parse(
//   Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_BASE64, "base64").toString("utf8")
// );

// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
// });

// const fcm = admin.messaging();


// // Save FCM Token
// exports.saveToken = async (req, res) => {
//   const { token, userId = "guest" } = req.body;
//   if (!token) return res.status(400).json({ ok: false, error: "Token required" });

//   try {
//     const existing = await Token.findOne({ token });
//     if (existing) {
//       existing.userId = userId;
//       existing.lastSeenAt = new Date();
//       await existing.save();
//     } else {
//       await Token.create({ token, userId });
//     }
//     res.json({ ok: true });
//   } catch (err) {
//     res.status(500).json({ ok: false, error: err.message });
//   }
// };

// // Send Notification
// exports.sendNotification = async (req, res) => {
//   const { token, userId, notification = {}, data = {} } = req.body;

//   try {
//     let tokens = [];
//     if (token) {
//       tokens = [token];
//     } else if (userId) {
//       const docs = await Token.find({ userId });
//       tokens = docs.map((d) => d.token);
//     } else {
//       const docs = await Token.find({});
//       tokens = docs.map((d) => d.token);
//     }

//     if (!tokens.length) {
//       return res.status(404).json({ ok: false, error: "No tokens found" });
//     }

//     const message = {
//       notification,
//       data,
//       tokens,
//       webpush: {
//         fcmOptions: { link: data.click_action || "https://example.com" },
//         headers: { Urgency: "high" },
//       },
//     };

//     const response = await fcm.sendEachForMulticast(message);

//     // Remove invalid tokens
//     const invalidTokens = [];
//     response.responses.forEach((result, idx) => {
//       if (result.error) {
//         const code = result.error.code || result.error.errorInfo?.code;
//         if (code === "messaging/registration-token-not-registered") {
//           invalidTokens.push(tokens[idx]);
//         }
//       }
//     });

//     if (invalidTokens.length) {
//       await Token.deleteMany({ token: { $in: invalidTokens } });
//     }

//     res.json({
//       ok: true,
//       successCount: response.successCount,
//       failureCount: response.failureCount,
//       removedInvalid: invalidTokens.length,
//     });
//   } catch (err) {
//     res.status(500).json({ ok: false, error: err.message });
//   }
// };

const admin = require("firebase-admin");
const Token = require("../Model/notifictionModle");

// Firebase service account init
const serviceAccount = JSON.parse(
  Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_BASE64, "base64").toString("utf8")
);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const fcm = admin.messaging();

/**
 * Save FCM Token
 */
exports.saveToken = async (req, res) => {
  const { token, userId = "guest" } = req.body;

  if (!token) {
    return res.status(400).json({ ok: false, error: "Token required" });
  }

  try {
    const existing = await Token.findOne({ token });
    if (existing) {
      existing.userId = userId;
      existing.lastSeenAt = new Date();
      await existing.save();
    } else {
      await Token.create({ token, userId });
    }

    res.json({ ok: true, message: "Token saved successfully" });
  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};

/**
 * Send Notification to:
 * - Specific token (if `token` provided)
 * - All tokens of a user (if `userId` provided)
 * - All tokens (if nothing provided)
 */
exports.sendNotification = async (req, res) => {
  const { token, userId, notification = {}, data = {} } = req.body;

  try {
    let tokens = [];

    if (token) {
      // Send to a single token
      tokens = [token];
    } else if (userId) {
      // Send to all tokens of a specific user
      const docs = await Token.find({ userId });
      tokens = docs.map((d) => d.token);
    } else {
      // Send to all saved tokens
      const docs = await Token.find({});
      tokens = docs.map((d) => d.token);
    }

    if (!tokens.length) {
      return res.status(404).json({ ok: false, error: "No tokens found" });
    }

    const message = {
      notification,
      data,
      tokens,
      webpush: {
        fcmOptions: {
          link: data.click_action || "https://example.com",
        },
        headers: { Urgency: "high" },
      },
    };

    // Send to multiple tokens
    const response = await fcm.sendEachForMulticast(message);

    // Remove invalid tokens
    const invalidTokens = [];
    response.responses.forEach((result, idx) => {
      if (result.error) {
        const code = result.error.code || result.error.errorInfo?.code;
        if (code === "messaging/registration-token-not-registered") {
          invalidTokens.push(tokens[idx]);
        }
      }
    });

    if (invalidTokens.length) {
      await Token.deleteMany({ token: { $in: invalidTokens } });
    }

    res.json({
      ok: true,
      successCount: response.successCount,
      failureCount: response.failureCount,
      removedInvalid: invalidTokens.length,
      removedTokens: invalidTokens,
    });

  } catch (err) {
    res.status(500).json({ ok: false, error: err.message });
  }
};
