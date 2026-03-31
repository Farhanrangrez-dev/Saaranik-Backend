const mongoose = require("mongoose");

const permissionSchema = new mongoose.Schema({
  sidebarName: { type: String, required: true },
  subSidebarName: { type: String, required: true },
  roleId: { type: mongoose.Schema.Types.ObjectId, ref: "Role", required: true },
  isEdit: { type: Boolean, default: false },
  isDelete: { type: Boolean, default: false },
  isView: { type: Boolean, default: false },
  isInsert: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model("Permission", permissionSchema);
