const http = require('http');

const BASE_URL = 'http://localhost:3000/api';

function makeRequest(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(BASE_URL + path);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(data) });
        } catch (e) {
          resolve({ status: res.statusCode, body: data });
        }
      });
    });

    req.on('error', (err) => reject(err));
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function runTestFlow() {
  console.log('🧪 [TEST SUITE] Starting Teryaq API & Escalation Engine Verification...\n');

  try {
    // 1. Verify Invite Code
    console.log('1️⃣ Testing Invite Code Verification (TRQ-7788)...');
    const authRes = await makeRequest('POST', '/auth/verify-invite', {
      inviteCode: 'TRQ-7788',
      deviceUuid: 'device-test-uuid-99'
    });
    console.log('Response:', authRes.body);
    if (!authRes.body.success) throw new Error('Invite verification failed');

    // 2. Trigger Alarm & Verification Flow (Success scenario)
    console.log('\n2️⃣ Testing Alarm Trigger & Immediate AI Verification...');
    const doseId1 = `dose-test-${Date.now()}`;
    const triggerRes = await makeRequest('POST', '/alarm/trigger', {
      doseId: doseId1,
      patientName: 'أحمد محمود',
      medicationName: 'كابوتين 25mg',
      caregiverPhone: '+966500000000',
      timeoutMs: 5000 // 5 seconds for fast test
    });
    console.log('Alarm Triggered Response:', triggerRes.body);

    console.log('Submitting AI Photo Verification...');
    const verifyRes = await makeRequest('POST', '/alarm/verify-dose', {
      doseId: doseId1,
      confidenceScore: 0.96,
      detectedText: 'CAPOTEN 25MG'
    });
    console.log('AI Verification Response:', verifyRes.body);

    // 3. Testing 10-Minute Timeout Escalation Scenario
    console.log('\n3️⃣ Testing Emergency Escalation Timeout Scenario (Fast 3s timeout)...');
    const doseId2 = `dose-timeout-${Date.now()}`;
    await makeRequest('POST', '/alarm/trigger', {
      doseId: doseId2,
      patientName: 'أحمد محمود',
      medicationName: 'كابوتين 25mg',
      caregiverPhone: '+966500000000',
      timeoutMs: 3000 // 3 seconds timeout
    });

    console.log('Waiting 4 seconds for timeout escalation trigger...');
    await new Promise(r => setTimeout(r, 4000));

    const statusRes = await makeRequest('GET', `/alarm/status/${doseId2}`);
    console.log('Status after timeout:', statusRes.body);

    if (statusRes.body.log && statusRes.body.log.status === 'ESCALATED') {
      console.log('\n✅ ALL INTEGRATION TESTS PASSED SUCCESSFULLY!');
    } else {
      console.error('\n❌ Escalation timeout test failed!');
    }

  } catch (err) {
    console.error('❌ Test failed with error:', err.message);
  }
}

runTestFlow();
