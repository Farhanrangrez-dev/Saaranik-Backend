const express = require('express');
const { costEstimatesCreate, AllCostEstimates, deleteCostEstimate, imagelogoCostEstimate, UpdateCostEstimate, SingleCostEstimate } = require('../../Controller/Admin/CostEstimatesController');


const router = express.Router()

router.post('/', costEstimatesCreate)

router.get('/', AllCostEstimates)

router.get('/image', imagelogoCostEstimate)

router.delete('/:id', deleteCostEstimate);

router.patch('/:id', UpdateCostEstimate)

router.get('/:id', SingleCostEstimate)

module.exports = router