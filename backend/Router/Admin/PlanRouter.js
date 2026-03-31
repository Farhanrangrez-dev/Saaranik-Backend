const express = require('express');
const router = express.Router();
const {
    createPlan,
    getAllPlans,
    updatePlan,
    deletePlan
} = require('../../Controller/Admin/PlanController');

router.post('/', createPlan);
router.get('/', getAllPlans);
router.put('/:id', updatePlan);
router.delete('/:id', deletePlan);

module.exports = router;
