const mongoose = require("mongoose");

const domainSchema = new mongoose.Schema({
    name: { type: String, required: true },
    owner: {
        name: String,
        email: String,
    },
    status: { type: String, enum: ["Active", "Pending", "Expired"], default: "Pending" },
    type: { type: String, enum: ["Standard", "Premium"], default: "Standard" },
    expiryDate: { type: Date, required: true },
    revenue: { type: Number, default: 0 },
    visitsPerMonth: { type: String }, // Optional: "89.2K visits/month"
}, { timestamps: true });

module.exports = mongoose.model("Domain", domainSchema);
