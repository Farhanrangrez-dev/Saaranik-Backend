const express=require('express');
const { ClientCreate, getAllClient, deleteClient, UpdateClient, SingleClient, getSelectValues, addSelectValues } = require('../../Controller/Admin/ClientManagementController');


const router = express.Router()

router.post('/selectclient',addSelectValues)

router.get('/selectclient',getSelectValues)

router.post('/',ClientCreate)

router.get('/',getAllClient)

router.patch('/:id',UpdateClient)

router.delete('/:id',deleteClient)

router.get('/:id',SingleClient)
 module.exports = router 
