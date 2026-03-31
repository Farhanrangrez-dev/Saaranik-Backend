// models/Token.js
const mongoose = require("mongoose");

const tokenSchema = new mongoose.Schema(
  {
    userId: { type: String, index: true },
    token: { type: String, required: true },
    lastSeenAt: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

module.exports = mongoose.model("Token", tokenSchema);
