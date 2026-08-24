const express = require('express');
const router = express.Router();

const authController = require('../controllers/authController');
const alarmController = require('../controllers/alarmController');

// Auth & Invite Routes
router.post('/auth/verify-invite', authController.validateInvite);
router.post('/admin/generate-invite', authController.generateInviteCode);

// Alarm & Verification Routes
router.post('/alarm/trigger', alarmController.handleAlarmTriggered);
router.post('/alarm/verify-dose', alarmController.handleVerifyDose);
router.get('/alarm/status/:doseId', alarmController.getLogStatus);
router.get('/admin/logs', alarmController.getAllLogs);

module.exports = router;
