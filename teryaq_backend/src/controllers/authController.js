// Auth & Invite Code Controller for Restricted Access

// Database of pre-generated invite codes for family members
const validInviteCodes = new Map([
  ['TRQ-MOTHER', { patientName: 'والدتي العزيزة', patientId: 'p-mother', medication: 'دواء الضغط (كابوتين 25mg)', caregiverPhone: '+201000000000' }],
  ['TRQ-WIFE', { patientName: 'زوجتي الغالية', patientId: 'p-wife', medication: 'الفيتامينات اليومية', caregiverPhone: '+201000000000' }],
  ['TRQ-SISTER', { patientName: 'أختي الكريمة', patientId: 'p-sister', medication: 'دواء الحديد والحديديك', caregiverPhone: '+201000000000' }],
  ['TRQ-7788', { patientName: 'أحمد محمود', patientId: 'p-101', medication: 'كابوتين 25mg', caregiverPhone: '+201000000000' }]
]);

const registeredDevices = new Map();

/**
 * Validate Invite Code & Bind Device
 */
function validateInvite(req, res) {
  const { inviteCode, deviceUuid } = req.body;

  if (!inviteCode || !deviceUuid) {
    return res.status(400).json({ success: false, message: 'كود الدعوة ومعرف الجهاز مطلوبان.' });
  }

  const codeData = validInviteCodes.get(inviteCode.trim().toUpperCase());

  if (!codeData) {
    return res.status(401).json({ success: false, message: 'كود الدعوة غير صحيح أو منتهي الصلاحية.' });
  }

  // Check device binding
  if (registeredDevices.has(codeData.patientId)) {
    const boundDevice = registeredDevices.get(codeData.patientId);
    if (boundDevice !== deviceUuid) {
      return res.status(403).json({ success: false, message: 'هذا الحساب مرتبط بجهاز آخر بالفعل.' });
    }
  } else {
    registeredDevices.set(codeData.patientId, deviceUuid);
  }

  return res.json({
    success: true,
    message: 'تم تفعيل الحساب وربطه بالجهاز بنجاح.',
    token: `token-${codeData.patientId}-${Date.now()}`,
    user: codeData
  });
}

/**
 * Generate new invite code (Admin Only)
 */
function generateInviteCode(req, res) {
  const { patientName, medication, caregiverPhone } = req.body;
  const newCode = `TRQ-${Math.floor(1000 + Math.random() * 9000)}`;

  const patientId = `p-${Date.now()}`;
  validInviteCodes.set(newCode, { patientName, patientId, medication, caregiverPhone });

  return res.json({
    success: true,
    inviteCode: newCode,
    details: { patientName, medication, caregiverPhone }
  });
}

module.exports = {
  validateInvite,
  generateInviteCode
};
