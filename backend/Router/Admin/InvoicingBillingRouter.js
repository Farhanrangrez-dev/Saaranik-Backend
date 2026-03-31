const express=require('express');
const { InvoicingBillingCreate, AllInvoicingBilling, UpdateInvoicingBilling, deleteInvoicingBilling, GetSingleInvoice } = require('../../Controller/Admin/InvoicingBillingController');

const router = express.Router()

router.post('/',InvoicingBillingCreate)

router.get('/',AllInvoicingBilling)

router.delete('/:id',deleteInvoicingBilling);

router.patch('/:id',UpdateInvoicingBilling)

router.post('/invoicing',GetSingleInvoice)
// router.get('/:id',SingleInvoicingBilling)

module.exports = router 