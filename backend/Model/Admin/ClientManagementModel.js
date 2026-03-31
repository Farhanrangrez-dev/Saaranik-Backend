const mongoose = require("mongoose");


const ClientManagementSchema = new mongoose.Schema({
  clientName: { type: String, required: true },
  industry: { type: String, required: true },
  website: { type: String, required: true },
  clientAddress: { type: String, required: true },
  TaxID_VATNumber: { type: String, required: true },
  CSRCode: { type: String, required: true },
  Status: { type: String, required: true },

  contactPersons: [{
    contactName: { type: String, required: true },
    jobTitle: { type: String, required: true },
    email: { type: String, required: true },
    phone: { type: String, required: true },
    department: { type: String, required: true },
    salesRepresentative: { type: String, required: true },
    _id:false
  }],

  billingInformation: [{
    billingAddress: { type: String, },
    billingContactName: { type: String, },
    billingEmail: { type: String, },
    billingPhone: { type: String,  },
    currency: {
      type: String,
     
    },
    preferredPaymentMethod: {
      type: String,
     
    },
    _id:false
  }],

  shippingInformation: [{
    shippingAddress: { type: String},
    shippingContactName: { type: String, },
    shippingEmail: { type: String, },
    shippingPhone: { type: String, },
    preferredShippingMethod:{ type: String, },
    specialInstructions: { type: String, },
    _id:false
  }],

  financialInformation: [{
    annualRevenue: { type: Number, },
    creditRating: { type: String, },
    bankName: { type: String, },
    accountNumber: { type: String, },
    fiscalYearEnd: { type: Date, },
    financialContact: { type: String, },
    _id:false
  }],

  ledgerInformation: [{
    accountCode: { type: String, },
    accountType: {
      type: String,
    },
    openingBalance: { type: Number, },
    balanceDate: { type: Date, },
    taxCategory: { type: String, },
    costCenter: { type: String, },
    _id:false
  }],

  additionalInformation: {
    paymentTerms: { type: String, },
    creditLimit: { type: Number, },
    notes: { type: String, },
  },
 button_Client_Suplier:{
    type: String,
    default: "Add Client"
 },

}, {
  timestamps: true,
});

module.exports = mongoose.model('ClientManagement', ClientManagementSchema);
