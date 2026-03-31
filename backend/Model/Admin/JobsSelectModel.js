const mongoose = require("mongoose");

const jobsSelectSchema = new mongoose.Schema(
  {
    // सभी नाम lowercase, required हटा कर default: [] जोड़ दिया
    brandName: [ { type: String, default: [] } ],      
    subBrand:  [ { type: String, default: [] } ],    
    flavour:   [ { type: String, default: [] } ],     
    packType:  [ { type: String, default: [] } ],    
    packCode:  [ { type: String, default: [] } ],   
    priority:  [ { type: String, default: [] } ],      
    status:    [ { type: String, default: [] } ],    
  },
  { timestamps: true }
);

module.exports = mongoose.model("JobsSelect", jobsSelectSchema);
