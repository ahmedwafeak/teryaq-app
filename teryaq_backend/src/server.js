const http = require('http');
const authController = require('./controllers/authController');
const alarmController = require('./controllers/alarmController');

const PORT = process.env.PORT || 3000;

function parseJsonBody(req) {
  return new Promise((resolve) => {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (e) {
        resolve({});
      }
    });
  });
}

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type'
  });
  res.end(JSON.stringify(data));
}

const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type'
    });
    return res.end();
  }

  const url = new URL(req.url, `http://${req.headers.host || 'localhost'}`);
  req.body = await parseJsonBody(req);

  // Router
  if (req.method === 'GET' && url.pathname === '/') {
    return sendJson(res, 200, {
      status: 'ONLINE',
      service: 'Teryaq Backend API Gateway & Escalation Engine',
      timestamp: new Date().toISOString()
    });
  }

  // Auth Routes
  if (req.method === 'POST' && url.pathname === '/api/auth/verify-invite') {
    return authController.validateInvite(req, {
      status: (code) => ({ json: (data) => sendJson(res, code, data) }),
      json: (data) => sendJson(res, 200, data)
    });
  }

  if (req.method === 'POST' && url.pathname === '/api/admin/generate-invite') {
    return authController.generateInviteCode(req, {
      status: (code) => ({ json: (data) => sendJson(res, code, data) }),
      json: (data) => sendJson(res, 200, data)
    });
  }

  // Alarm Routes
  if (req.method === 'POST' && url.pathname === '/api/alarm/trigger') {
    return alarmController.handleAlarmTriggered(req, {
      status: (code) => ({ json: (data) => sendJson(res, code, data) }),
      json: (data) => sendJson(res, 200, data)
    });
  }

  if (req.method === 'POST' && url.pathname === '/api/alarm/verify-dose') {
    return alarmController.handleVerifyDose(req, {
      status: (code) => ({ json: (data) => sendJson(res, code, data) }),
      json: (data) => sendJson(res, 200, data)
    });
  }

  if (req.method === 'GET' && url.pathname.startsWith('/api/alarm/status/')) {
    const doseId = url.pathname.replace('/api/alarm/status/', '');
    req.params = { doseId };
    return alarmController.getLogStatus(req, {
      status: (code) => ({ json: (data) => sendJson(res, code, data) }),
      json: (data) => sendJson(res, 200, data)
    });
  }

  if (req.method === 'GET' && url.pathname === '/api/admin/logs') {
    return alarmController.getAllLogs(req, {
      status: (code) => ({ json: (data) => sendJson(res, code, data) }),
      json: (data) => sendJson(res, 200, data)
    });
  }

  return sendJson(res, 404, { success: false, message: 'Endpoint not found' });
});

server.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(`🚀 Teryaq Native Backend running on http://localhost:${PORT}`);
  console.log(`=======================================================`);
});
