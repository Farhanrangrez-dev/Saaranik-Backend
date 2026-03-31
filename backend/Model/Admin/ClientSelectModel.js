const mongoose = require("mongoose");

const ClientSelectSchema = new mongoose.Schema(
  {
    industry: [ { type: String, default: [] } ],     
    currency:  [ { type: String, default: [] } ],      
    preferredPaymentMethod:[ { type: String, default: [] } ],    
    preferredShippingMethod: [ { type: String, default: [] } ],
    accountType: [ { type: String, default: [] } ],
  },
  { timestamps: true }
);

module.exports = mongoose.model("ClientSelect", ClientSelectSchema);
