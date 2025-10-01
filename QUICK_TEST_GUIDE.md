# 🎬 Quick Testing Reference

## 🚀 Quick Start (3 Steps)

### 1️⃣ Start Backend
```bash
cd chime-backend
node server.js
```
Expected: `✅ Chime backend running at http://localhost:5000`

### 2️⃣ Update Backend URL (if using physical device)
**File:** `lib/src/comman/api.dart`
```dart
static const awsChimeLocalhost = 'http://YOUR_LAN_IP:5000';
```

### 3️⃣ Run Tests
| Device | Meeting ID | Name |
|--------|------------|------|
| Device 1 | `test-meeting-123` | `Alice` |
| Device 2 | `test-meeting-123` | `Bob` |

---

## 📋 Test Scenarios

### Scenario 1: Basic Call
- **Device 1:** Join with `meetingId=room-001`, `name=Alice`
- **Device 2:** Join with `meetingId=room-001`, `name=Bob`
- **Expected:** Both see each other's video

### Scenario 2: Multiple Meetings
- **Device 1:** Join with `meetingId=room-001`, `name=Alice`
- **Device 2:** Join with `meetingId=room-002`, `name=Bob`
- **Expected:** Separate meetings, no video connection

### Scenario 3: Late Join
- **Device 1:** Join and wait
- **Device 2:** Join 10 seconds later
- **Expected:** Device 2 connects and video appears on both

---

## 🔍 Debug Checklist

When things don't work, check these in order:

### ✅ Backend Health
```bash
curl http://YOUR_IP:5000/health
```
Expected response: `{"ok":true,"region":"us-east-1"}`

### ✅ Backend Logs
Look for:
```
POST /join { meetingId: 'test-meeting-123', name: 'Alice' }
Meeting created/retrieved
Attendee created
Response sent
```

### ✅ Flutter Console Logs
Look for (in order):
1. `🔄 JoinVideoCall event started`
2. `📤 Calling join usecase`
3. `Raw API response =====>`
4. `Created JoinInfo successfully`
5. `✅ JoinVideoCall success`
6. `🎬 Rendering ChimeMeetingWrapper`

### ✅ Permissions
- Camera: ✅
- Microphone: ✅
- Network: ✅

---

## ❌ Common Errors & Fixes

### Error: "Failed to fetch JoinInfo"
**Fix:** Check backend URL in `api.dart`

### Error: "Network error: Failed host lookup"
**Fix:** Use LAN IP instead of `localhost` for physical devices

### Error: "Permission denied"
**Fix:** Grant camera/microphone permissions in device settings

### Error: "Can't see other person"
**Fix:** Ensure both devices use SAME `meetingId`

### Error: "Backend returns 400"
**Fix:** Check you're sending both `meetingId` and `name` in request

---

## 🎯 Expected Console Output (Success)

### Device 1 (Alice):
```
🔄 JoinVideoCall event started
📤 Calling join usecase with meetingId: test-meeting-123, participant: Alice
Joining meeting: test-meeting-123 with participant: Alice
Raw API response =====> {Meeting: {...}, Attendee: {...}}
Meeting ID: abc-123-def
Attendee ID: attendee-alice-001
External User ID: Alice
Created JoinInfo successfully
✅ JoinVideoCall success! JoinInfo received: JoinInfo
🏁 VideoCall state updated - isConnected: true
🎬 Rendering ChimeMeetingWrapper with JoinInfo
```

### Device 2 (Bob):
```
🔄 JoinVideoCall event started
📤 Calling join usecase with meetingId: test-meeting-123, participant: Bob
Joining meeting: test-meeting-123 with participant: Bob
Raw API response =====> {Meeting: {...}, Attendee: {...}}
Meeting ID: abc-123-def  [SAME as Device 1]
Attendee ID: attendee-bob-002  [DIFFERENT from Device 1]
External User ID: Bob
Created JoinInfo successfully
✅ JoinVideoCall success! JoinInfo received: JoinInfo
🏁 VideoCall state updated - isConnected: true
🎬 Rendering ChimeMeetingWrapper with JoinInfo
```

**Key Point:** Both devices get the SAME `Meeting ID` but DIFFERENT `Attendee IDs`

---

## 🔧 Emergency Fixes

### Can't Connect to Backend
```bash
# Windows: Find your IP
ipconfig

# Update api.dart
static const awsChimeLocalhost = 'http://192.168.1.XXX:5000';
```

### Backend Not Starting
```bash
# Install dependencies
npm install

# Check AWS credentials
echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY

# Set if missing
export AWS_ACCESS_KEY_ID="your-key"
export AWS_SECRET_ACCESS_KEY="your-secret"
```

### Flutter Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📞 Test Commands

```bash
# Terminal 1: Backend
cd chime-backend && node server.js

# Terminal 2: Device 1
flutter run

# Terminal 3: Device 2 (if using emulator)
flutter devices
flutter run -d emulator-5554

# Terminal 4: Check backend health
curl http://localhost:5000/health
```

---

## ✨ Success Indicators

You know it's working when:
1. ✅ Backend shows two POST /join requests
2. ✅ Both devices show "🎬 Rendering ChimeMeetingWrapper"
3. ✅ Both devices display video interface
4. ✅ You can see yourself on one device and the other person appears
5. ✅ Audio works (you can hear each other)

---

## 🎉 Ready to Test!

1. Start backend: `node server.js`
2. Update IP in `api.dart` (if needed)
3. Run app on two devices
4. Both join same meeting ID
5. See each other's video! 📹
