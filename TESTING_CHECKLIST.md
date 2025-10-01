# ✅ Video Call Testing Checklist

## 🔧 Setup (One-Time)

### **1. Backend Server**
- [ ] Navigate to `C:\Users\nadiy\Desktop\task\chime-backend`
- [ ] Ensure `server.js` has all fixes applied
- [ ] Start server: `node server.js`
- [ ] Verify output shows: `✅ Chime backend running at http://localhost:5000`
- [ ] Leave terminal open (don't close it)

### **2. Flutter App**
- [ ] Hot restart both devices
- [ ] Verify no compilation errors
- [ ] Check that Meeting Input Screen is accessible from Dashboard

---

## 🧪 Test Scenario 1: Simultaneous Join (Race Condition Test)

**Objective:** Verify both devices join the SAME meeting when they click "Join" at the same time.

### **Device 1 (Alice)**
- [ ] Open app
- [ ] Tap "Video Call" card
- [ ] Enter Meeting ID: `test-race-123`
- [ ] Enter Name: `Alice`
- [ ] **WAIT** for Device 2 to be ready
- [ ] **Tap "Join Meeting" at the SAME TIME as Device 2** (coordinate with partner)

### **Device 2 (Bob)**
- [ ] Open app
- [ ] Tap "Video Call" card
- [ ] Enter Meeting ID: `test-race-123`
- [ ] Enter Name: `Bob`
- [ ] **WAIT** for Device 1 to be ready
- [ ] **Tap "Join Meeting" at the SAME TIME as Device 1**

### **Expected Backend Logs:**
```
📞 Join request: meetingId="test-race-123", name="Alice"
🆕 Creating new meeting for external ID: test-race-123
📞 Join request: meetingId="test-race-123", name="Bob"
⏳ Meeting creation already in progress for "test-race-123", waiting...
✅ Created meeting:
   - Internal ID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   - External ID: test-race-123
👤 Created attendee: Alice
   - Attendee ID: ...
✅ Retrieved meeting created by concurrent request: xxxxxxxx...
👤 Created attendee: Bob
   - Attendee ID: ...
```

### **Expected Result:**
- [ ] Backend shows "Meeting creation already in progress"
- [ ] Both devices show THE SAME Internal Meeting ID in logs
- [ ] Both devices connect to video call
- [ ] Alice sees Bob's video
- [ ] Bob sees Alice's video
- [ ] Audio works both ways

---

## 🧪 Test Scenario 2: Sequential Join (Cache Test)

**Objective:** Verify second device uses cached meeting instead of creating new one.

### **Device 1 (Charlie)**
- [ ] Open app
- [ ] Tap "Video Call" card
- [ ] Enter Meeting ID: `test-cache-456`
- [ ] Enter Name: `Charlie`
- [ ] Tap "Join Meeting"
- [ ] **WAIT** until video call screen shows

### **Device 2 (Diana)**
- [ ] **WAIT** for Device 1 to fully connect (3-5 seconds)
- [ ] Open app
- [ ] Tap "Video Call" card
- [ ] Enter Meeting ID: `test-cache-456`
- [ ] Enter Name: `Diana`
- [ ] Tap "Join Meeting"

### **Expected Backend Logs:**
```
📞 Join request: meetingId="test-cache-456", name="Charlie"
🆕 Creating new meeting for external ID: test-cache-456
✅ Created meeting:
   - Internal ID: yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy
   - External ID: test-cache-456
👤 Created attendee: Charlie

(wait 3-5 seconds)

📞 Join request: meetingId="test-cache-456", name="Diana"
📍 Found cached meeting for "test-cache-456": yyyyyyyy-yyyy...
✅ Retrieved existing meeting: yyyyyyyy-yyyy...
👤 Created attendee: Diana
```

### **Expected Result:**
- [ ] Backend shows "Found cached meeting"
- [ ] Both devices show THE SAME Internal Meeting ID
- [ ] Diana joins Charlie's existing meeting
- [ ] Video/audio works for both

---

## 🧪 Test Scenario 3: Different Meetings (Isolation Test)

**Objective:** Verify different meeting IDs create separate meetings.

### **Device 1 (Eve)**
- [ ] Open app
- [ ] Tap "Video Call" card
- [ ] Enter Meeting ID: `meeting-aaa`
- [ ] Enter Name: `Eve`
- [ ] Tap "Join Meeting"

### **Device 2 (Frank)**
- [ ] Open app
- [ ] Tap "Video Call" card
- [ ] Enter Meeting ID: `meeting-bbb` ← **Different meeting ID**
- [ ] Enter Name: `Frank`
- [ ] Tap "Join Meeting"

### **Expected Result:**
- [ ] Backend creates TWO different meetings (correct behavior)
- [ ] Device 1 gets Meeting ID: xxxxxxxx...
- [ ] Device 2 gets Meeting ID: zzzzzzzz... ← **Different ID**
- [ ] They are in SEPARATE video calls (cannot see each other)
- [ ] No crashes or errors

---

## 🧪 Test Scenario 4: Leave and Rejoin

**Objective:** Verify users can leave and rejoin the same meeting.

### **Device 1 (Grace)**
- [ ] Join meeting `test-rejoin-789` as `Grace`
- [ ] Wait for connection
- [ ] **Tap "Leave Call" button**
- [ ] Verify returned to Meeting Input Screen
- [ ] **Rejoin the SAME meeting** `test-rejoin-789` as `Grace`

### **Device 2 (Henry)**
- [ ] Join meeting `test-rejoin-789` as `Henry`
- [ ] Stay in call while Device 1 leaves and rejoins
- [ ] Verify Device 1 disappears when they leave
- [ ] Verify Device 1 reappears when they rejoin

### **Expected Result:**
- [ ] Backend uses cached meeting on rejoin
- [ ] Same Internal Meeting ID on rejoin
- [ ] Video reconnects successfully
- [ ] No memory leaks or crashes

---

## 🧪 Test Scenario 5: Error Handling

### **Test 5a: Invalid Meeting ID**
- [ ] Enter Meeting ID: `""` (empty)
- [ ] Expected: Validation error, cannot join

### **Test 5b: Invalid Name**
- [ ] Enter Meeting ID: `test-123`
- [ ] Enter Name: `""` (empty)
- [ ] Expected: Validation error, cannot join

### **Test 5c: Backend Down**
- [ ] Stop backend server (Ctrl+C)
- [ ] Try to join meeting
- [ ] Expected: Error message shown, no crash
- [ ] Restart backend and try again
- [ ] Expected: Works normally

---

## 📊 Success Metrics

### **Backend Metrics** ✅
- [ ] Cache hit rate > 50% (Device 2 finds cached meeting)
- [ ] No duplicate meetings created for same external ID
- [ ] Concurrent requests handled without creating duplicates
- [ ] All attendees successfully created

### **Flutter Metrics** ✅
- [ ] No `type 'Null' is not a subtype` errors
- [ ] No crashes during join/leave
- [ ] Video call connects within 3 seconds
- [ ] Audio and video quality is acceptable

### **User Experience** ✅
- [ ] Meeting ID is easy to share
- [ ] Join process is intuitive
- [ ] Video call UI is responsive
- [ ] Leave button works correctly
- [ ] Can quickly rejoin after leaving

---

## 🐛 Known Issues to Watch For

### **Issue 1: Server Restart**
**Symptom:** After server restart, "Found cached meeting" shows error.
**Cause:** Cache is cleared on restart.
**Expected:** Server creates new meeting, works normally.

### **Issue 2: Network Latency**
**Symptom:** One device connects, other device stuck on loading.
**Possible Causes:**
- Firewall blocking WebRTC ports
- NAT traversal issues
- TURN server not accessible
**Solution:** Check firewall settings, ensure AWS Chime TURN servers are reachable.

### **Issue 3: AWS Rate Limits**
**Symptom:** "Too many requests" error from backend.
**Cause:** Hitting AWS Chime API rate limits (unlikely in testing).
**Solution:** Add exponential backoff retry logic.

---

## 📝 Test Results Template

### **Test Date:** _______________
### **Tested By:** _______________
### **Device 1:** _______________
### **Device 2:** _______________

| Scenario | Result | Notes |
|----------|--------|-------|
| Simultaneous Join | ☐ Pass / ☐ Fail | |
| Sequential Join | ☐ Pass / ☐ Fail | |
| Different Meetings | ☐ Pass / ☐ Fail | |
| Leave and Rejoin | ☐ Pass / ☐ Fail | |
| Error Handling | ☐ Pass / ☐ Fail | |

### **Overall Assessment:**
☐ All tests passed - Ready for production
☐ Some tests failed - Needs fixes (see notes)
☐ Major issues found - Requires redesign

### **Additional Notes:**
```
(Add any observations, issues, or suggestions here)
```

---

## 🎯 Quick Reference

### **Backend Logs to Look For:**
- ✅ `📍 Found cached meeting` → Cache working correctly
- ✅ `⏳ Meeting creation already in progress` → Race condition handled
- ✅ Same Internal Meeting ID for both devices → Success!
- ❌ Two different Internal Meeting IDs → Bug, race condition not handled

### **Flutter Logs to Look For:**
- ✅ `📄 Creating JoinInfo with JSON` → Conversion started
- ✅ `🔍 meeting (lowercase)` → Correct key casing
- ✅ `🔍 attendee (lowercase)` → Correct key casing
- ❌ `❌ Error creating JoinInfo` → Bug, check JSON structure
- ❌ `type 'Null' is not a subtype` → Bug, missing field

### **Terminal Commands:**
```powershell
# Start backend
cd C:\Users\nadiy\Desktop\task\chime-backend
node server.js

# Restart backend (if needed)
Ctrl+C
node server.js

# Check backend health
curl http://localhost:5000/health

# List active meetings
curl http://localhost:5000/meetings
```

---

## 🚀 Next Steps After Testing

### **If All Tests Pass:**
1. ✅ Document the implementation
2. ✅ Create user guide
3. ✅ Consider production deployment
4. ✅ Add monitoring and analytics
5. ✅ Upgrade to AWS SDK v3
6. ✅ Replace in-memory cache with Redis

### **If Tests Fail:**
1. ❌ Review backend logs for errors
2. ❌ Review Flutter logs for errors
3. ❌ Check network connectivity
4. ❌ Verify AWS credentials and permissions
5. ❌ Consult FINAL_FIX_SUMMARY.md for troubleshooting

---

**Good luck with testing! 🎉**
