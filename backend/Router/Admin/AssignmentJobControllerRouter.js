const express=require('express');
const { AssignmentCreate, AllAssignJobID, AllAssignJob, ProductionJobsGet, } = require('../../Controller/Admin/AssignmentJobController');


const router = express.Router()

router.post('/',AssignmentCreate)

router.get('/getbyid/:employeeId',AllAssignJobID)

// Admin MYJobs get api 
router.get('/',AllAssignJob)

// Admin Production get 
router.get('/ProductionJobsGet',ProductionJobsGet)
// router.patch('/:id',UpdateClient) 

// router.delete('/:id',deleteClient)

// router.get('/:id',SingleClient)

 module.exports = router 
