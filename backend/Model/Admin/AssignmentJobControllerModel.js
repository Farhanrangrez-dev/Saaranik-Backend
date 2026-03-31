const mongoose = require("mongoose");



const AssignmentSchema = new mongoose.Schema({
    employeeId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        // required: true,
    },
    // jobId: [{
    //     type: mongoose.Schema.Types.ObjectId,
    //     ref: 'Jobs',
    //     required: true
    // }],
     jobs: [
    {
      jobId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Jobs',
        required: true
      },
      jobReturnStatus: {
        type: Boolean,
        default: false
      }
    }
  ],
    selectDesigner: {
        type: String,
        required: true,
    },
  
    // employee: {
    //     type: String,
    //     required: true,
    // },
    description: {
        type: String,
    },

}, {
    timestamps: true,
});

module.exports = mongoose.model('Assignment', AssignmentSchema);