// models/Token.js
const mongoose = require("mongoose");

const NotifictionSchema = new mongoose.Schema(
    {
        title: { type: String },
        body: { type: String },
    },
    { timestamps: true }
);

module.exports = mongoose.model("Notifiction", NotifictionSchema);
