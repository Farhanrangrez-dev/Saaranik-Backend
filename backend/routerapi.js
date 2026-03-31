const express = require('express');

const routerapi = express.Router()

// Projects
routerapi.use('/projects', require('./Router/Admin/ProjectsRouter'));
// Jobs
routerapi.use('/jobs', require('./Router/Admin/JobsRouter'));
// Client
routerapi.use('/client', require('./Router/Admin/ClientManagementRouter'));
// User
routerapi.use('/user', require('./Router/userRouter'));
// CostEstimates
routerapi.use('/costEstimates', require('./Router/Admin/CostEstimatesRouter'));
// TimeLogs
routerapi.use('/timeLogs', require('./Router/Admin/TimeLogsRouter'));
// ReceivablePurchase
routerapi.use('/receivablePurchase', require('./Router/Admin/ReceivablePurchaseRouter'));
// TimesheetWorklog
routerapi.use('/timesheetWorklog', require('./Router/Admin/TimesheetWorklogRouter'));
// InvoicingBilling
routerapi.use('/invoicingBilling', require('./Router/Admin/InvoicingBillingRouter'));
// AssignmentJob
routerapi.use('/AssignmentJob', require('./Router/Admin/AssignmentJobControllerRouter'));
// ReportsAnalyticsController
routerapi.use('/ReportsAnalytics', require('./Router/Admin/ReportsAnalyticsrRouter'));
// Remove Assign Job
routerapi.use('/Remove', require('./Router/Admin/removeAssignRouter'));
// PDFCreate
routerapi.use('/pdf', require('./Router/Admin/PDF_EstimatesRouter'));
///////Employee
routerapi.use('/employee/dashboard', require('./Router/Employee/DashboardRouter'));
//Plan
routerapi.use('/admin/plans', require('./Router/Admin/PlanRouter'));
//Coupons
routerapi.use('/coupons', require('./Router/Admin/CouponsRouter'));
//Domain
routerapi.use('/domain', require('./Router/Admin/DomainRouter'));
// notifiction 
routerapi.use('/notifiction',require('./Router/notifictionRouter'));

module.exports = routerapi
