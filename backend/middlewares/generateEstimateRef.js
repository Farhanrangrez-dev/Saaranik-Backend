const CostEstimates = require('../Model/Admin/CostEstimatesModel'); // Path ko adjust karein agar model ka path alag hai
const Projects = require("../Model/Admin/ProjectsModel");
const Jobs = require('../Model/Admin/JobsModel');
const ReceivablePurchase = require('../Model/Admin/ReceivablePurchaseModel');
const InvoicingBilling = require('../Model/Admin/InvoicingBillingModel');

const generateEstimateNo = async () => {
  // Find last estimate with CO- prefix
  const lastEstimate = await CostEstimates.findOne({
    estimateRef: { $regex: /^CE-\d{4}$/ }
  }).sort({ createdAt: -1 });

  let lastNumber = 0;

  if (lastEstimate && lastEstimate.estimateRef) {
    const parts = lastEstimate.estimateRef.split("-");
    lastNumber = parseInt(parts[1], 10);
  }
  const newNumber = (lastNumber + 1).toString().padStart(4, '0');

  return `CE-${newNumber}`;
};

// const generateProjectNo = async () => {
//   const currentYear = new Date().getFullYear();

//   const prefix = `EST-${currentYear}-`;

//   // Find last project matching current year pattern
//   const lastProject = await Projects.findOne({
//     projectNo: { $regex: `^${prefix}\\d{4}$` }
//   }).sort({ createdAt: -1 });

//   let lastNumber = 0;

//   if (lastProject && lastProject.projectNo) {
//     const parts = lastProject.projectNo.split("-");
//     lastNumber = parseInt(parts[2], 10);
//   }

//   const newNumber = (lastNumber + 1).toString().padStart(4, '0');
//   const newProjectNo = `${prefix}${newNumber}`;

//   return newProjectNo;
// };


const generateProjectNo = async () => {
  const lastProject = await Projects.findOne({
    projectNo: { $regex: /^\d{4}$/ }
  }).sort({ createdAt: -1 });

  let lastNumber = 0;

  if (lastProject && lastProject.projectNo) {
    lastNumber = parseInt(lastProject.projectNo, 10);
  }
  const newNumber = (lastNumber + 1).toString().padStart(4, '0');
  return newNumber; 
};

const generateJobsNo = async () => {
  const lastJob = await Jobs.findOne({
    JobNo: { $regex: /^\d{4}$/ }
  }).sort({ createdAt: -1 });

  let lastNumber = 0;

  if (lastJob && lastJob.JobNo) {
    lastNumber = parseInt(lastJob.JobNo, 10);
  }

  const newNumber = (lastNumber + 1).toString().padStart(4, '0');
  return newNumber; // e.g. '0002', '0003'
};


const ReceivablePurchaseNo = async () => {
  const lastEntry = await ReceivablePurchase.findOne({
    PONumber: { $regex: /^PO-\d{4}$/ }
  }).sort({ createdAt: -1 });

  let lastNumber = 0;

  if (lastEntry && lastEntry.PONumber) {
    const match = lastEntry.PONumber.match(/^PO-(\d{4})$/);
    if (match) {
      lastNumber = parseInt(match[1], 10);
    }
  }

  const newNumber = (lastNumber + 1).toString().padStart(4, '0');
  return `PO-${newNumber}`; // e.g. PO-0002, PO-0003
};


const generateInvoicingNo = async () => {
  const lastEntry = await InvoicingBilling.findOne({
    InvoiceNo: { $regex: /^INV-\d{4}$/ }
  }).sort({ createdAt: -1 });

  let lastNumber = 0;

  if (lastEntry && lastEntry.InvoiceNo) {
    const match = lastEntry.InvoiceNo.match(/^INV-(\d{4})$/);
    if (match) {
      lastNumber = parseInt(match[1], 10);
    }
  }

  const newNumber = (lastNumber + 1).toString().padStart(4, '0');
  return `${newNumber}`;
};

module.exports = {
  generateEstimateNo,
  generateProjectNo,
  generateJobsNo,
  ReceivablePurchaseNo,
  generateInvoicingNo
};

