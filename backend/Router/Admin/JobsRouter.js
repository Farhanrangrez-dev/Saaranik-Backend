const express = require('express');
const { jobCreate, AllJob, deleteJob, UpdateJob, SingleJob, UpdateJobAssign, AllJobID, filter, Complete_WaitingApproval, addSelectValues, getSelectValues, EmployeeCompletedStatus, JobFinance } = require('../../Controller/Admin/JobsController');


const router = express.Router()

router.get('/Complete_WaitingApproval', Complete_WaitingApproval)

router.get('/jjj/:projectId', JobFinance);

router.post('/select', addSelectValues)

router.get('/select', getSelectValues)

router.post('/', jobCreate)

router.get('/:projectId', AllJobID);

router.get('/filter/:Status', filter)

router.get('/', AllJob)

router.delete('/:id', deleteJob)

router.patch('/:id', UpdateJob)

router.get('/:id', SingleJob)

router.put('/:id', UpdateJobAssign)

router.put('/CompletesStatus/:id', EmployeeCompletedStatus)

module.exports = router 
