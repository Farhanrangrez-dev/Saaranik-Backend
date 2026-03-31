const asyncHandler = require('express-async-handler');
const CostEstimates = require('../../Model/Admin/CostEstimatesModel');
const Projects = require("../../Model/Admin/ProjectsModel");
const ClientManagement = require("../../Model/Admin/ClientManagementModel");
const cloudinary = require('../../Config/cloudinary');
const { generateEstimateNo } = require('../../middlewares/generateEstimateRef');
const mongoose = require("mongoose");
const ReceivablePurchase = require('../../Model/Admin/ReceivablePurchaseModel');

cloudinary.config({
  cloud_name: 'dkqcqrrbp',
  api_key: '418838712271323',
  api_secret: 'p12EKWICdyHWx8LcihuWYqIruWQ'
});
// const costEstimatesCreate = asyncHandler(async (req, res) => {
//   const {
//     projectId,
//     clientId,
//     estimateDate,
//     validUntil,
//     currency,
//     lineItems,
//     VATRate,
//     Notes,
//     POStatus,
//     Status
//   } = req.body;

//   try {
//     // 1. Validate IDs
//     if (!Array.isArray(projectId) || projectId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//       return res.status(400).json({ success: false, message: "Invalid Project ID format." });
//     }

//     if (!Array.isArray(clientId) || clientId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//       return res.status(400).json({ success: false, message: "Invalid Client ID format." });
//     }

//     const projects = await Projects.find({ '_id': { $in: projectId } });
//     if (projects.length !== projectId.length) {
//       return res.status(404).json({ success: false, message: "One or more projects not found" });
//     }

//     const clients = await ClientManagement.find({ '_id': { $in: clientId } });
//     if (clients.length !== clientId.length) {
//       return res.status(404).json({ success: false, message: "One or more clients not found" });
//     }

//     // 2. Upload Images (if any)
//     let uploadedImages = [];

//     if (req.files && req.files.length > 0) {
//       const uploads = req.files.map(async (file) => {
//         const result = await cloudinary.uploader.upload_stream({ resource_type: "image" }, (error, result) => {
//           if (error) throw error;
//           return result;
//         });

//         return new Promise((resolve, reject) => {
//           const stream = cloudinary.uploader.upload_stream((err, result) => {
//             if (err) reject(err);
//             else resolve(result.secure_url);
//           });
//           stream.end(file.buffer);
//         });
//       });

//       uploadedImages = await Promise.all(uploads);
//     }

//     // 3. Create estimate
//     const estimateRef = await generateEstimateNo();
//     const newCostEstimate = new CostEstimates({
//       estimateRef,
//       projectId,
//       clientId,
//       estimateDate,
//       validUntil,
//       currency,
//       lineItems,
//       VATRate,
//       Notes,
//       Status,
//       image: uploadedImages,
//     });

//     await newCostEstimate.save();

//     res.status(201).json({
//       success: true,
//       message: "Cost Estimate created successfully",
//       costEstimate: newCostEstimate,
//     });

//   } catch (error) {
//     res.status(500).json({
//       success: false,
//       message: "An error occurred while creating the Cost Estimate",
//       error: error.message,
//     });
//   }
// });




// Notifications is ok porfect code this api code 
// const costEstimatesCreate = asyncHandler(async (req, res) => { 
//   try {
//     let {
//       projectId,
//       clientId,
//       estimateDate,
//       validUntil,
//       currency,
//       lineItems,
//       VATRate,
//       Notes,
//       CostPOStatus,
//       Status
//     } = req.body;

//     projectId = Array.isArray(projectId) ? projectId : [projectId];
//     clientId = Array.isArray(clientId) ? clientId : [clientId];

//     if (typeof lineItems === 'string') {
//       try {
//         lineItems = JSON.parse(lineItems);
//       } catch (err) {
//         return res.status(400).json({ success: false, message: "Invalid lineItems format. Must be valid JSON." });
//       }
//     }

//     if (projectId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//       return res.status(400).json({ success: false, message: "Invalid Project ID format." });
//     }
//     if (clientId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
//       return res.status(400).json({ success: false, message: "Invalid Client ID format." });
//     }

//     const projects = await Projects.find({ _id: { $in: projectId } });
//     if (projects.length !== projectId.length) {
//       return res.status(404).json({ success: false, message: "One or more projects not found." });
//     }
//     const clients = await ClientManagement.find({ _id: { $in: clientId } });
//     if (clients.length !== clientId.length) {
//       return res.status(404).json({ success: false, message: "One or more clients not found." });
//     }

//     let imageUrls = [];
//     if (req.files && req.files.image) {
//       const files = Array.isArray(req.files.image) ? req.files.image : [req.files.image];
//       for (const file of files) {
//         try {
//           const result = await cloudinary.uploader.upload(file.tempFilePath, {
//             folder: 'user_profiles',
//             resource_type: 'image',
//           });
//           if (result.secure_url) {
//             imageUrls.push(result.secure_url);
//           }
//         } catch (uploadError) {
//           console.error("Cloudinary upload error:", uploadError);
//         }
//       }
//     }

//     const estimateRef = await generateEstimateNo();

//     const newCostEstimate = new CostEstimates({
//       estimateRef,
//       projectId: projectId[0],
//       clientId: clientId[0],
//       estimateDate,
//       validUntil,
//       currency,
//       lineItems,
//       VATRate,
//       Notes,
//       CostPOStatus,
//       Status,
//       image: imageUrls,
//     });

//     await newCostEstimate.save();

//     // 🔔 Add notification entry here
//     await Notification.create({
//       title: `New Cost Estimate #${estimateRef} created`,
//       description: `Estimate for client ${clients[0]?.clientName || "Unknown Client"} has been created.`,
//       category: "costEstimate",
//       relatedId: newCostEstimate._id
//     });

//     res.status(201).json({
//       success: true,
//       message: "Cost Estimate created successfully",
//       costEstimate: newCostEstimate,
//     });

//   } catch (error) {
//     res.status(500).json({
//       success: false,
//       message: "An error occurred while creating the Cost Estimate",
//       error: error.message,
//     });
//   }
// });
////



const costEstimatesCreate = asyncHandler(async (req, res) => {
  try {
    // Parse fields from form-data
    let {
      projectId,
      clientId,
      estimateDate,
      validUntil,
      currency,
      lineItems,
      VATRate,
      Notes,
      CostPOStatus,
      Status
    } = req.body;

    // Convert to arrays if necessary
    projectId = Array.isArray(projectId) ? projectId : [projectId];
    clientId = Array.isArray(clientId) ? clientId : [clientId];

    // Parse lineItems JSON string
    if (typeof lineItems === 'string') {
      try {
        lineItems = JSON.parse(lineItems);
      } catch (err) {
        return res.status(400).json({ success: false, message: "Invalid lineItems format. Must be valid JSON." });
      }
    }

    // Validate IDs
    if (projectId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
      return res.status(400).json({ success: false, message: "Invalid Project ID format." });
    }
    if (clientId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
      return res.status(400).json({ success: false, message: "Invalid Client ID format." });
    }

    // Check existence
    const projects = await Projects.find({ _id: { $in: projectId } });
    if (projects.length !== projectId.length) {
      return res.status(404).json({ success: false, message: "One or more projects not found." });
    }
    const clients = await ClientManagement.find({ _id: { $in: clientId } });
    if (clients.length !== clientId.length) {
      return res.status(404).json({ success: false, message: "One or more clients not found." });
    }

    // Image upload handling (agar koi file aaye toh)
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

    // Generate Estimate Ref
    const estimateRef = await generateEstimateNo();

    // Create and Save Document
    const newCostEstimate = new CostEstimates({
      estimateRef,
      projectId: projectId[0], // Assuming single selection
      clientId: clientId[0],
      estimateDate,
      validUntil,
      currency,
      lineItems,
      VATRate,
      Notes,
      CostPOStatus,
      Status,
      image: imageUrls,
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



// GET All Cost Estimates with project and client info
const AllCostEstimates = async (req, res) => {
  try {
    const allCostEstimates = await CostEstimates.aggregate([
      // 1) Join Projects
      {
        $lookup: {
          from: 'projects',
          localField: 'projectId',
          foreignField: '_id',
          as: 'projects'
        }
      },
      // 2) Join Clients
      {
        $lookup: {
          from: 'clientmanagements',
          localField: 'clientId',
          foreignField: '_id',
          as: 'clients'
        }
      },
      // 3) Join ReceivablePurchases
      {
        $lookup: {
          from: 'receivablepurchases',
          localField: '_id',
          foreignField: 'CostEstimatesId',
          as: 'receivablePurchases'
        }
      },
      // 4) Project needed fields (this is a new separate stage)
      {
        $project: {
          _id: 1,
          estimateDate: 1,
          validUntil: 1,
          currency: 1,
          estimateRef: 1,
          lineItems: 1,
          VATRate: 1,
          Notes: 1,
          CostPOStatus: 1,
          Status: 1,
          createdAt: 1,
          updatedAt: 1,
          projects: {
            $map: {
              input: '$projects',
              as: 'p',
              in: {
                projectId: '$$p._id',
                projectName: '$$p.projectName',
                projectNo: '$$p.projectNo'
              }
            }
          },
          clients: {
            $map: {
              input: '$clients',
              as: 'c',
              in: {
                clientId: '$$c._id',
                clientName: '$$c.clientName',
                clientEmail: '$$c.contactPersons.email',
                clientPhone: '$$c.contactPersons.phone'
              }
            }
          },
          receivablePurchases: {
            $map: {
              input: '$receivablePurchases',
              as: 'rp',
              in: {
                _id: '$$rp._id',
                POStatus: '$$rp.POStatus',
                purchaseDate: '$$rp.purchaseDate',
                amount: '$$rp.amount'
              }
            }
          }
        }
      }
    ]);

    // Handle empty
    if (!allCostEstimates.length) {
      return res
        .status(404)
        .json({ success: false, message: 'No cost estimates found' });
    }

    // Success
    return res.status(200).json({
      success: true,
      costEstimates: allCostEstimates
    });
  } catch (error) {
    console.error('Error fetching cost estimates:', error);
    return res.status(500).json({
      success: false,
      message: 'An error occurred while fetching cost estimates',
      error: error.message
    });
  }
};

const imagelogoCostEstimate = async (req, res) => {
  try {

    const result = await CostEstimates.find().distinct('image')
    res.status(201).json({
      success: true,
      message: "imagelogoCostEstimate fethched successfully",
      image: result,
    });

  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
}

//GET SINGLE DeleteProjects
//METHOD:DELETE
const deleteCostEstimate = async (req, res) => {
  let deleteCostEstimateID = req.params.id
  if (deleteCostEstimateID) {
    const deleteCostEstimate = await CostEstimates.findByIdAndDelete(deleteCostEstimateID, req.body);
    res.status(200).json("Delete Cost Estimate Successfully")
  } else {
    res.status(400).json({ message: "Not Delete Cost Estimate" })
  }
}

//GET SINGLE ProjectsUpdate
//METHOD:PUT
const UpdateCostEstimate = asyncHandler(async (req, res) => {
  const id = req.body.id || req.params.id;

  if (!id || !mongoose.Types.ObjectId.isValid(id)) {
    return res.status(400).json({ success: false, message: 'Invalid or missing Cost Estimate ID' });
  }

  let {
    projectId,
    clientId,
    estimateDate,
    validUntil,
    currency,
    lineItems,
    VATRate,
    Notes,
    POStatus,
    CostPOStatus,
    Status
  } = req.body;

  // Convert to arrays if necessary
  projectId = Array.isArray(projectId) ? projectId : [projectId];
  clientId = Array.isArray(clientId) ? clientId : [clientId];

  // Parse lineItems JSON string
  if (typeof lineItems === 'string') {
    try {
      lineItems = JSON.parse(lineItems);
    } catch (err) {
      return res.status(400).json({ success: false, message: "Invalid lineItems format. Must be valid JSON." });
    }
  }

  // Validate IDs
  if (projectId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
    return res.status(400).json({ success: false, message: "Invalid Project ID format." });
  }
  if (clientId.some(id => !mongoose.Types.ObjectId.isValid(id))) {
    return res.status(400).json({ success: false, message: "Invalid Client ID format." });
  }

  // Check existence
  const projects = await Projects.find({ _id: { $in: projectId } });
  if (projects.length !== projectId.length) {
    return res.status(404).json({ success: false, message: "One or more projects not found." });
  }
  const clients = await ClientManagement.find({ _id: { $in: clientId } });
  if (clients.length !== clientId.length) {
    return res.status(404).json({ success: false, message: "One or more clients not found." });
  }

  // Image upload handling (if image files are uploaded)
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

  try {
    const updatedCostEstimate = await CostEstimates.findByIdAndUpdate(
      id,
      {
        projectId: projectId[0], // assuming single select
        clientId: clientId[0],
        estimateDate,
        validUntil,
        currency,
        lineItems,
        VATRate,
        Notes,
        POStatus,
        CostPOStatus,
        Status,
        ...(imageUrls.length > 0 && { image: imageUrls }), // update only if new image uploaded
      },
      { new: true }
    );

    if (!updatedCostEstimate) {
      return res.status(404).json({ success: false, message: 'Cost Estimate not found' });
    }

    res.status(200).json({
      success: true,
      message: "Cost Estimate updated successfully",
      costEstimate: updatedCostEstimate,
    });

  } catch (error) {
    console.error("Error updating cost estimate:", error);
    res.status(500).json({ success: false, message: 'Server error', error: error.message });
  }
});



//METHOD:Single
//TYPE:PUBLIC
const SingleCostEstimate = async (req, res) => {
  try {
    const SingleCostEstimate = await CostEstimates.findById(req.params.id);
    res.status(200).json(SingleCostEstimate)
  } catch (error) {
    res.status(404).json({ msg: "Can t Find Cost Estimate" })
  }
}


module.exports = { imagelogoCostEstimate, costEstimatesCreate, AllCostEstimates, deleteCostEstimate, UpdateCostEstimate, SingleCostEstimate }