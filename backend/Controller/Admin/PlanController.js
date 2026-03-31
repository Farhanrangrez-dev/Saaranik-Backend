const Plan = require("../../Model/Admin/Plans")

exports.createPlan = async (req, res) => {
    try {
        const { name, price, type, features, subscribers, revenue, status } = req.body;

        const newPlan = new Plan({
            name,
            price,
            type,
            features: features.split(',').map(f => f.trim()), // split by comma
            subscribers,
            revenue,
            status
        });

        await newPlan.save();
        res.status(201).json({ message: "Plan created successfully", plan: newPlan });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};


exports.getAllPlans = async (req, res) => {
    try {
        const plans = await Plan.find().sort({ createdAt: -1 });
        res.json(plans);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.updatePlan = async (req, res) => {
    try {
        const { id } = req.params;
        const { name, price, type, features, subscribers, revenue, status } = req.body;

        const updatedPlan = await Plan.findByIdAndUpdate(
            id,
            {
                name,
                price,
                type,
                features: features ? features.split(',').map(f => f.trim()) : [], // ✅ Safe fallback
                subscribers,
                revenue,
                status
            },
            { new: true }
        );

        res.json({ message: "Plan updated", plan: updatedPlan });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.deletePlan = async (req, res) => {
    try {
        const { id } = req.params;
        await Plan.findByIdAndDelete(id);
        res.json({ message: "Plan deleted successfully" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

