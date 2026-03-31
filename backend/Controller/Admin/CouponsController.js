const Coupon = require("../../Model/Admin/Coupons");


exports.createCoupon = async (req, res) => {
    try {
        const coupon = new Coupon(req.body);
        await coupon.save();
        // const permissions = [
        //     {
        //         side: "dashboard",
        //         sub: "null", ,
        //     crud,
        //     roleid:
        //     }
        // ]
        res.status(201).json({ message: "Coupon created", coupon });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get All
exports.getAllCoupons = async (req, res) => {
    try {
        const coupons = await Coupon.find().sort({ createdAt: -1 });
        res.json(coupons);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Update
exports.updateCoupon = async (req, res) => {
    try {
        const { id } = req.params;
        const updated = await Coupon.findByIdAndUpdate(id, req.body, { new: true });
        res.json({ message: "Coupon updated", coupon: updated });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Delete
exports.deleteCoupon = async (req, res) => {
    try {
        const { id } = req.params;
        await Coupon.findByIdAndDelete(id);
        res.json({ message: "Coupon deleted" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};



exports.getCouponSummary = async (req, res) => {
    try {
        const totalCoupons = await Coupon.countDocuments();
        const activeCoupons = await Coupon.countDocuments({ status: "Active" });


        const coupons = await Coupon.find();

        let totalSavings = 0;
        let totalUsed = 0;

        coupons.forEach(coupon => {
            const { used } = coupon.usage;
            totalUsed += used;

            if (coupon.type === 'Flat') {
                totalSavings += used * coupon.value;
            } else if (coupon.type === 'Percentage') {
                // Assuming average order value ₹500 (or replace with your logic)
                totalSavings += used * (500 * (coupon.value / 100));
            }
        });

        const usageRate = totalCoupons > 0 ? ((totalUsed / totalCoupons) * 100).toFixed(2) : 0;

        res.status(200).json({
            totalCoupons,
            activeCoupons,
            totalSavings: `₹${totalSavings.toFixed(2)}`,
            usageRate: `${usageRate}%`
        });

    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Something went wrong', error: err.message });
    }
};
