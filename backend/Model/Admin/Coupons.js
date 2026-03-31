const mongoose = require("mongoose");

const couponSchema = new mongoose.Schema({
    code: { type: String, required: true, unique: true },
    type: { type: String, enum: ["Percentage", "Fixed Amount"], required: true },
    value: { type: Number, required: true },
    description: { type: String },
    usage: {
        used: { type: Number, default: 0 },
        limit: { type: Number, required: true }
    },
    validFrom: { type: Date, required: true },
    validTo: { type: Date, required: true },
    status: { type: String, enum: ["Active", "Inactive"], default: "Active" }
}, { timestamps: true });

module.exports = mongoose.model("Coupon", couponSchema);
