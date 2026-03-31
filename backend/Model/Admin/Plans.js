const mongoose = require('mongoose');

const planSchema = new mongoose.Schema({
    name: { type: String, required: true },
    price: { type: Number, required: true },
    type: { type: String, enum: ['Monthly', 'Yearly'], required: true },
    features: [{ type: String }],
    subscribers: { type: Number, default: 0 },
    revenue: { type: Number, default: 0 },
    status: { type: String, enum: ['Active', 'Inactive'], default: 'Active' }
}, { timestamps: true });

module.exports = mongoose.model('Plan', planSchema);
