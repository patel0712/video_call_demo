# 🎬 Video Call Flow - Visual Guide

## 📊 Complete Flow Diagram

```
┌─────────────┐                                    ┌─────────────┐
│  Device 1   │                                    │  Device 2   │
│   (Alice)   │                                    │    (Bob)    │
└──────┬──────┘                                    └──────┬──────┘
       │                                                  │
       │ 1. Join "meeting-123"                           │
       ├──────────────────────────────────────────┐      │
       │                                          │      │
       ▼                                          │      │
┌─────────────────────────────────────────────┐  │      │
│         Backend Server (Node.js)            │  │      │
│                                             │  │      │
│  ┌─────────────────────────────────────┐   │  │      │
│  │ Check meetingCache                  │   │  │      │
│  │   "meeting-123" → NOT FOUND         │   │  │      │
│  └─────────────────────────────────────┘   │  │      │
│                 ↓                           │  │      │
│  ┌─────────────────────────────────────┐   │  │      │
│  │ Check pendingMeetings               │   │  │      │
│  │   "meeting-123" → NOT FOUND         │   │  │      │
│  └─────────────────────────────────────┘   │  │      │
│                 ↓                           │  │      │
│  ┌─────────────────────────────────────┐   │  │      │
│  │ CREATE NEW MEETING                  │   │  │      │
│  │ - Store promise in pendingMeetings  │   │  │      │
│  │ - Call AWS Chime CreateMeeting      │   │  │      │
│  └─────────────────────────────────────┘   │  │      │
│                 ↓                           │  │      │
│       [AWS Creates Meeting]                 │  │      │
│                 ↓                           │  │      │ 2. Join "meeting-123"
│  ┌─────────────────────────────────────┐   │  │      │ (arrives during Device 1's creation)
│  │ Meeting Created Successfully        │   │  │      ├────────────────────────┐
│  │ Internal ID: f6771ce2-...           │   │  │      │                        │
│  │ External ID: meeting-123            │   │  │      ▼                        │
│  └─────────────────────────────────────┘   │  │  ┌───────────────────────┐   │
│                 ↓                           │  │  │ Check meetingCache    │   │
│  ┌─────────────────────────────────────┐   │  │  │   NOT FOUND           │   │
│  │ Save to Cache                       │   │  │  └───────────────────────┘   │
│  │ meetingCache["meeting-123"]         │   │  │             ↓                │
│  │   = "f6771ce2-..."                  │   │  │  ┌───────────────────────┐   │
│  └─────────────────────────────────────┘   │  │  │ Check pendingMeetings │   │
│                 ↓                           │  │  │   FOUND! ✅           │   │
│  ┌─────────────────────────────────────┐   │  │  └───────────────────────┘   │
│  │ Remove from pendingMeetings         │   │  │             ↓                │
│  └─────────────────────────────────────┘   │  │  ┌───────────────────────┐   │
│                 ↓                           │  │  │ WAIT for promise      │   │
│  ┌─────────────────────────────────────┐   │  │  │ (Device 1's creation) │   │
│  │ Create Attendee "Alice"             │   │  │  └───────────────────────┘   │
│  │ AttendeeId: 1b69d5c6-...            │   │  │             ↓                │
│  └─────────────────────────────────────┘   │  │  [Promise Resolves]          │
│                 ↓                           │  │             ↓                │
│  ┌─────────────────────────────────────┐   │  │  ┌───────────────────────┐   │
│  │ Return Response                     │◄──┼──┼──┤ Got Same Meeting!     │   │
│  │ { Meeting, Attendee }               │   │  │  │ Internal ID:          │   │
│  └─────────────────────────────────────┘   │  │  │   f6771ce2-... ✅     │   │
└─────────────────────────────────────────────┘  │  └───────────────────────┘   │
       │                                          │             ↓                │
       │ 3. Response                              │  ┌───────────────────────┐   │
       │ Meeting ID: f6771ce2-...                 │  │ Create Attendee "Bob" │   │
       ◄──────────────────────────────────────────┤  │ AttendeeId: 9da558c1- │   │
       │                                          │  └───────────────────────┘   │
       │                                          │             ↓                │
       │                                          │  ┌───────────────────────┐   │
       │                                          │  │ Return Response       │   │
       │                                          │  │ { Meeting, Attendee } │   │
       │                                          │  └───────────────────────┘   │
       │                                          │             ↓                │
       │                                          │ 4. Response                  │
       │                                          │ Meeting ID: f6771ce2-... ✅  │
       │                                          ◄──────────────────────────────┘
       │                                          │
       │                                          │
       ▼                                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                      Flutter App Processing                       │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ ChimeApiResponse.fromJson()                                │  │
│  │ - Parse Meeting object                                     │  │
│  │ - Parse Attendee object                                    │  │
│  │ - Parse Capabilities (or use defaults)                     │  │
│  └────────────────────────────────────────────────────────────┘  │
│                               ↓                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ toJoinInfo()                                               │  │
│  │ - Create JSON with lowercase keys: 'meeting', 'attendee'  │  │
│  │ - Call JoinInfo.fromJson()                                │  │
│  └────────────────────────────────────────────────────────────┘  │
│                               ↓                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ VideoCallBloc                                              │  │
│  │ - State: isConnected = true                               │  │
│  │ - Store JoinInfo                                          │  │
│  └────────────────────────────────────────────────────────────┘  │
│                               ↓                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ VideoCallScreen                                            │  │
│  │ - Show ChimeMeetingWrapper                                │  │
│  └────────────────────────────────────────────────────────────┘  │
│                               ↓                                   │
│  ┌────────────────────────────────────────────────────────────┐  │
│  │ ChimeMeetingWrapper                                        │  │
│  │ - Render MeetingView(joinInfo)                            │  │
│  └────────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
       │                                          │
       │                                          │
       ▼                                          ▼
┌──────────────────────────────────────────────────────────────────┐
│                    AWS Chime SDK (WebRTC)                         │
│                                                                   │
│  - Establish P2P connection                                      │
│  - Exchange video/audio streams                                  │
│  - Handle network traversal (STUN/TURN)                          │
└──────────────────────────────────────────────────────────────────┘
       │                                          │
       ▼                                          ▼
┌─────────────┐                            ┌─────────────┐
│  Device 1   │◄───────── Video ─────────►│  Device 2   │
│   Showing   │◄───────── Audio ─────────►│   Showing   │
│  Bob's feed │                            │ Alice's feed│
└─────────────┘                            └─────────────┘
```

## 🔑 Key Points

### **Race Condition Handling**
```
Time    Device 1                Device 2
────────────────────────────────────────────────
0ms     POST /join              -
1ms     Check cache (empty)     -
2ms     Check pending (empty)   -
3ms     Start creation          POST /join
4ms     AWS API call...         Check cache (empty)
5ms     (waiting for AWS)       Check pending (FOUND!)
6ms     (waiting for AWS)       ⏳ WAIT for promise
...     ...                     ...
500ms   ✅ Meeting created      (still waiting)
501ms   Save to cache           Promise resolves!
502ms   Remove from pending     Get meeting object
503ms   Create Attendee 1       Create Attendee 2
504ms   Return response         Return response
```

### **JSON Structure Mapping**

**Backend Response:**
```json
{
  "Meeting": {              ← Uppercase (AWS format)
    "MeetingId": "...",
    "ExternalMeetingId": "...",
    ...
  },
  "Attendee": {             ← Uppercase (AWS format)
    "AttendeeId": "...",
    ...
  }
}
```

**Flutter Internal:**
```dart
ChimeApiResponse {
  meeting: Meeting(...),
  attendee: Attendee(...)
}
```

**JoinInfo Format (Plugin Expects):**
```json
{
  "meeting": {              ← Lowercase (Plugin format)
    "MeetingId": "...",
    "ExternalMeetingId": "...",
    ...
  },
  "attendee": {             ← Lowercase (Plugin format)
    "AttendeeId": "...",
    ...
  }
}
```

## 🎯 Success Indicators

### **Backend Logs ✅**
```
📞 Join request: meetingId="meeting-123", name="Alice"
🆕 Creating new meeting for external ID: meeting-123
✅ Created meeting: Internal ID: f6771ce2-...

📞 Join request: meetingId="meeting-123", name="Bob"
⏳ Meeting creation already in progress, waiting...
✅ Retrieved meeting created by concurrent request: f6771ce2-...
```
**Both devices get the SAME Internal Meeting ID!**

### **Flutter Logs ✅**
```
Device 1:
📄 Creating JoinInfo with JSON: {...}
🔍 meeting (lowercase): {...}
🔍 attendee (lowercase): {...}
✅ Video call connected!

Device 2:
📄 Creating JoinInfo with JSON: {...}
🔍 meeting (lowercase): {...}
🔍 attendee (lowercase): {...}
✅ Video call connected!
```
**No "type 'Null' is not a subtype" errors!**

## 🚀 What Changed

### **Before (Broken) ❌**
```javascript
// Backend: No race condition handling
if (cache has meeting) {
    use cached
} else {
    create new    // ← Both requests hit this!
}
```

### **After (Fixed) ✅**
```javascript
// Backend: With race condition handling
if (cache has meeting) {
    use cached
} else if (pending has meeting) {
    wait for it   // ← Second request waits here!
} else {
    create new
}
```

---

## 📱 User Experience

### **Before**
1. Alice joins "meeting-123" → Gets Meeting ID: abc123
2. Bob joins "meeting-123" → Gets Meeting ID: def456 ❌
3. **They're in DIFFERENT meetings!** 😢

### **After**
1. Alice joins "meeting-123" → Gets Meeting ID: f6771ce2
2. Bob joins "meeting-123" → Gets Meeting ID: f6771ce2 ✅
3. **They're in the SAME meeting!** 🎉
4. Video/audio streams connect via WebRTC
5. Both can see and hear each other

---

## 🎓 Learn More

- **AWS Chime Meeting IDs:** [AWS Docs](https://docs.aws.amazon.com/chime-sdk/latest/dg/meeting-identifiers.html)
- **Race Conditions:** [Wikipedia](https://en.wikipedia.org/wiki/Race_condition)
- **WebRTC:** [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API)
