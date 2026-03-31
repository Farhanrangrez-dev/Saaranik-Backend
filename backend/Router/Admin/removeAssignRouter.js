const express=require('express');
const { RemoveAssignedJob ,ReturnAssignedJobHistory , ReturnAssignedJob} = require('../../Controller/Admin/removeAssignController');

const router = express.Router()

router.delete('/', RemoveAssignedJob);
router.get('/ReturnAssignedJobHistory', ReturnAssignedJobHistory);
router.get('/ReturnAssignedJob', ReturnAssignedJob);

 module.exports = router 
