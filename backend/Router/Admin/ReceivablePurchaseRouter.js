const express=require('express');
const { ReceivablePurchaseCreate, AllReceivablePurchase, deleteReceivablePurchase, UpdateReceivablePurchase ,imagelogoReceivablePurchase} = require('../../Controller/Admin/ReceivablePurchaseController');


const router = express.Router()

router.post('/',ReceivablePurchaseCreate)

router.get('/',AllReceivablePurchase)

router.get('/image',imagelogoReceivablePurchase)

router.delete('/:id',deleteReceivablePurchase)

router.patch('/:id',UpdateReceivablePurchase)

// router.get('/:id',SingleJob)

 module.exports = router 
