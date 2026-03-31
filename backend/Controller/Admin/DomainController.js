const Domain = require("../../Model/Admin/Domain");

exports.createDomain = async (req, res) => {
    try {
        const domain = await Domain.create(req.body);
        res.status(201).json({ message: "Domain created", domain });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
};


exports.updateDomain = async (req, res) => {
    try {
        const { id } = req.params;
        const domain = await Domain.findByIdAndUpdate(id, req.body, { new: true });
        res.json({ message: "Domain updated", domain });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
};


exports.deleteDomain = async (req, res) => {
    try {
        const { id } = req.params;
        await Domain.findByIdAndDelete(id);
        res.json({ message: "Domain deleted" });
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
};


exports.getAllDomains = async (req, res) => {
    try {
        const domains = await Domain.find().sort({ createdAt: -1 });
        res.json(domains);
    } catch (err) {
        res.status(400).json({ error: err.message });
    }
};


exports.getDomainSummary = async (req, res) => {
    try {
        const totalDomains = await Domain.countDocuments();
        const activeDomains = await Domain.countDocuments({ status: "Active" });
        const pendingDomains = await Domain.countDocuments({ status: "Pending" });
        const expiredDomains = await Domain.countDocuments({ status: "Expired" });

        const domains = await Domain.find();
        const totalRevenue = domains.reduce((sum, d) => sum + (d.revenue || 0), 0);

        res.json({
            totalDomains,
            activeDomains,
            pendingDomains,
            expiredDomains,
            totalRevenue,
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};
