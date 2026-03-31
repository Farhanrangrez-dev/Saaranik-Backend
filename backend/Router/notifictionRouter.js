// routes/fcmRoutes.js
const express = require("express");
const { saveToken, sendNotification ,getAllNotifications} = require("../Controller/notifictionControllre");

const router = express.Router();

router.post("/save-token", saveToken);
router.post("/send", sendNotification);
router.get("/getAllNotifications", getAllNotifications);


module.exports = router;
