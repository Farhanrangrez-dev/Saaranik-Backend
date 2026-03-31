const express = require("express");
const router = express.Router();
const domainController = require("../../Controller/Admin/DomainController");

router.post("/", domainController.createDomain);
router.put("/:id", domainController.updateDomain);
router.delete("/:id", domainController.deleteDomain);
router.get("/", domainController.getAllDomains);
router.get("/summary", domainController.getDomainSummary);

module.exports = router;
