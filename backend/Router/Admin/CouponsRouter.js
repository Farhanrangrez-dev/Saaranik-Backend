const express = require("express");
const router = express.Router();
const couponCtrl = require("../../Controller/Admin/CouponsController");

router.post("/", couponCtrl.createCoupon);
router.get("/", couponCtrl.getAllCoupons);
router.put("/:id", couponCtrl.updateCoupon);
router.delete("/:id", couponCtrl.deleteCoupon);
router.get('/summary', couponCtrl.getCouponSummary);

module.exports = router;
