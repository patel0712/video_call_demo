// server.js - FIXED VERSION
// This version properly handles meeting lookups using ExternalMeetingId


import express from "express";
import AWS from "aws-sdk";
import { v4 as uuidv4 } from "uuid";
import cors from "cors";
import dotenv from "dotenv";
dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;
const DEFAULT_REGION = process.env.AWS_REGION || "us-east-1";

// Check for AWS credentials
if (!process.env.AWS_ACCESS_KEY_ID || !process.env.AWS_SECRET_ACCESS_KEY) {
  console.log("⚠️  AWS credentials not found in environment variables.");
  console.log("📝 Please set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY");
  console.log("💡 You can create a .env file with your credentials");
  console.log("📋 Required AWS permissions: chime:CreateMeeting, chime:GetMeeting, chime:DeleteMeeting, chime:CreateAttendee, chime:GetAttendee");
  console.log("\n🔧 Server will start but API calls will fail until credentials are configured.\n");
}

app.use(cors());
app.use(express.json());

// Add global error handler to prevent server crashes
app.use((err, req, res, next) => {
  console.error("❌ Unhandled error:", err);
  res.status(500).json({ error: "Internal server error" });
});

// In-memory cache to map External Meeting IDs to Internal AWS Meeting IDs
// In production, use Redis or a database
const meetingCache = new Map();

// Track in-progress meeting creations to prevent race conditions
const pendingMeetings = new Map();

// Track active participants per meeting for 1-to-1 call logic
// Structure: { meetingId: { attendees: Set, maxParticipants: 2, participantStates: Map } }
const participantTracker = new Map();

// Helper functions for participant tracking
function initializeParticipantTracker(meetingId) {
  if (!participantTracker.has(meetingId)) {
    participantTracker.set(meetingId, {
      attendees: new Set(),
      maxParticipants: 2,
      createdAt: new Date(),
      participantStates: new Map() // Track audio/video states per attendee
    });
  }
}

function addParticipant(meetingId, attendeeId) {
  initializeParticipantTracker(meetingId);
  const tracker = participantTracker.get(meetingId);

  if (tracker.attendees.size >= tracker.maxParticipants) {
    return { success: false, error: "Meeting is full. Maximum 2 participants allowed." };
  }

  tracker.attendees.add(attendeeId);

  // Initialize participant state (audio and video enabled by default)
  tracker.participantStates.set(attendeeId, {
    audioEnabled: true,
    videoEnabled: true,
    joinedAt: new Date()
  });

  return { success: true, participantCount: tracker.attendees.size };
}

function removeParticipant(meetingId, attendeeId) {
  const tracker = participantTracker.get(meetingId);
  if (tracker) {
    tracker.attendees.delete(attendeeId);
    tracker.participantStates.delete(attendeeId); // Clean up participant state
    return { success: true, participantCount: tracker.attendees.size };
  }
  return { success: false, error: "Meeting not found" };
}

function getParticipantCount(meetingId) {
  const tracker = participantTracker.get(meetingId);
  return tracker ? tracker.attendees.size : 0;
}

function cleanupParticipantTracker(meetingId) {
  participantTracker.delete(meetingId);
}

// Audio/Video control functions
function updateParticipantAudioState(meetingId, attendeeId, audioEnabled) {
  const tracker = participantTracker.get(meetingId);
  if (tracker && tracker.participantStates.has(attendeeId)) {
    const state = tracker.participantStates.get(attendeeId);
    state.audioEnabled = audioEnabled;
    state.lastUpdated = new Date();
    return { success: true, audioEnabled };
  }
  return { success: false, error: "Participant not found" };
}

function updateParticipantVideoState(meetingId, attendeeId, videoEnabled) {
  const tracker = participantTracker.get(meetingId);
  if (tracker && tracker.participantStates.has(attendeeId)) {
    const state = tracker.participantStates.get(attendeeId);
    state.videoEnabled = videoEnabled;
    state.lastUpdated = new Date();
    return { success: true, videoEnabled };
  }
  return { success: false, error: "Participant not found" };
}

function getParticipantStates(meetingId) {
  const tracker = participantTracker.get(meetingId);
  if (tracker) {
    const states = {};
    tracker.participantStates.forEach((state, attendeeId) => {
      states[attendeeId] = {
        audioEnabled: state.audioEnabled,
        videoEnabled: state.videoEnabled,
        joinedAt: state.joinedAt,
        lastUpdated: state.lastUpdated
      };
    });
    return { success: true, states };
  }
  return { success: false, error: "Meeting not found" };
}

// Create a Chime SDK Meetings client for a given region
function createChimeClient(region) {
  try {
    // Configure AWS with credentials if available
    if (process.env.AWS_ACCESS_KEY_ID && process.env.AWS_SECRET_ACCESS_KEY) {
      AWS.config.update({
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
        region: region
      });
      console.log(`🔑 Using provided AWS credentials for region: ${region}`);
    } else {
      // Use default credential chain (IAM roles, ~/.aws/credentials, etc.)
      AWS.config.update({ region });
      console.log(`🔧 Using default AWS credential chain for region: ${region}`);
    }

    const chimeClient = new AWS.ChimeSDKMeetings({ region });
    console.log(`✅ Chime client created successfully for region: ${region}`);
    return chimeClient;
  } catch (error) {
    console.error("❌ Failed to create Chime client:", error.message);
    console.error("📋 Full error:", error);
    throw new Error(`Failed to initialize AWS Chime client: ${error.message}`);
  }
}

// Health check
app.get("/health", (req, res) => res.json({ ok: true, region: DEFAULT_REGION }));

/**
 * POST /join
 * Body: { meetingId: string, name: string, region?: string }
 * Response: { Meeting, Attendee }
 * 
 * FIXED: Now properly handles meeting lookup using ExternalMeetingId
 */
app.post("/join", async (req, res) => {
  try {
    let { meetingId, name, region } = req.body || {};

    if (!meetingId || !name) {
      return res.status(400).json({ error: "meetingId and name are required" });
    }

    meetingId = String(meetingId).trim();
    name = String(name).trim();
    region = (region || DEFAULT_REGION).trim();

    // Respect max lengths required by Chime
    const safeMeetingId = meetingId.slice(0, 64);
    const safeName = name.slice(0, 64);

    console.log(`\n📞 Join request: meetingId="${safeMeetingId}", name="${safeName}"`);

    const chime = createChimeClient(region);

    let meeting;

    // Check if we've seen this External Meeting ID before
    if (meetingCache.has(safeMeetingId)) {
      const cachedInternalId = meetingCache.get(safeMeetingId);
      console.log(`📍 Found cached meeting for "${safeMeetingId}": ${cachedInternalId}`);

      try {
        // Try to get the existing meeting using the internal ID
        const result = await chime.getMeeting({ MeetingId: cachedInternalId }).promise();
        meeting = result;
        console.log(`✅ Retrieved existing meeting: ${meeting.Meeting.MeetingId}`);
      } catch (err) {
        // Meeting might have been deleted, remove from cache and create new
        console.log(`⚠️  Cached meeting not found (may have been deleted), creating new one`);
        meetingCache.delete(safeMeetingId);
        meeting = null;
      }
    }
    // Check if another request is currently creating this meeting
    else if (pendingMeetings.has(safeMeetingId)) {
      console.log(`⏳ Meeting creation already in progress for "${safeMeetingId}", waiting...`);
      // Wait for the other request to finish creating the meeting
      const pendingPromise = pendingMeetings.get(safeMeetingId);
      meeting = await pendingPromise;
      console.log(`✅ Retrieved meeting created by concurrent request: ${meeting.Meeting.MeetingId}`);
    }

    // Create new meeting if not found
    if (!meeting) {
      console.log(`🆕 Creating new meeting for external ID: ${safeMeetingId}`);

      // Create a promise for this meeting creation and store it
      const createMeetingPromise = chime.createMeeting({
        ClientRequestToken: uuidv4(),
        MediaRegion: region,
        ExternalMeetingId: safeMeetingId,
      }).promise();

      // Store the promise so concurrent requests can wait for it
      pendingMeetings.set(safeMeetingId, createMeetingPromise);

      try {
        meeting = await createMeetingPromise;

        // Cache the mapping: External ID -> Internal AWS Meeting ID
        meetingCache.set(safeMeetingId, meeting.Meeting.MeetingId);

        console.log(`✅ Created meeting:`);
        console.log(`   - Internal ID: ${meeting.Meeting.MeetingId}`);
        console.log(`   - External ID: ${meeting.Meeting.ExternalMeetingId}`);
        console.log(`   - Region: ${meeting.Meeting.MediaRegion}`);
      } finally {
        // Remove from pending after creation completes (success or failure)
        pendingMeetings.delete(safeMeetingId);
      }
    }

    // Check if meeting has reached maximum participants (2 for 1-to-1 calls)
    const currentParticipantCount = getParticipantCount(safeMeetingId);
    if (currentParticipantCount >= 2) {
      console.log(`❌ Meeting "${safeMeetingId}" is full. Current participants: ${currentParticipantCount}`);
      return res.status(403).json({
        error: "Meeting is full. Maximum 2 participants allowed for 1-to-1 calls.",
        participantCount: currentParticipantCount,
        maxParticipants: 2
      });
    }

    // Create attendee for this meeting
    const attendee = await chime.createAttendee({
      MeetingId: meeting.Meeting.MeetingId,
      ExternalUserId: safeName,
    }).promise();

    // Add participant to tracker
    const addResult = addParticipant(safeMeetingId, attendee.Attendee.AttendeeId);
    if (!addResult.success) {
      // If adding failed (shouldn't happen due to check above), clean up the attendee
      try {
        await chime.deleteAttendee({
          MeetingId: meeting.Meeting.MeetingId,
          AttendeeId: attendee.Attendee.AttendeeId
        }).promise();
      } catch (cleanupErr) {
        console.error("❌ Failed to cleanup attendee after add failure:", cleanupErr);
      }
      return res.status(403).json({ error: addResult.error });
    }

    console.log(`👤 Created attendee: ${safeName}`);
    console.log(`   - Attendee ID: ${attendee.Attendee.AttendeeId}`);
    console.log(`   - Join Token: ${attendee.Attendee.JoinToken.substring(0, 20)}...`);
    console.log(`   - Participant Count: ${addResult.participantCount}/2`);
    console.log(`   - Full Attendee Object: ${JSON.stringify(attendee.Attendee, null, 2)}`);

    // Log current participant tracker state
    const tracker = participantTracker.get(safeMeetingId);
    if (tracker) {
      console.log(`📊 Current meeting participants: ${Array.from(tracker.attendees).join(', ')}`);
      console.log(`📊 Participant states:`, Array.from(tracker.participantStates.entries()).map(([id, state]) => ({
        attendeeId: id,
        ...state
      })));
    }

    // Return the response in the format Flutter expects
    return res.json({
      Meeting: meeting.Meeting,
      Attendee: attendee.Attendee,
      participantCount: addResult.participantCount,
      maxParticipants: 2
    });

  } catch (err) {
    console.error("❌ Error creating/joining meeting:", err);
    return res.status(500).json({ error: err.message || "Server error" });
  }
});

/**
 * POST /end
 * Body: { meetingId: string, region?: string }
 * 
 * Ends a meeting and removes it from cache
 */
app.post("/end", async (req, res) => {
  try {
    let { meetingId, region } = req.body || {};

    if (!meetingId) {
      return res.status(400).json({ error: "meetingId is required" });
    }

    meetingId = String(meetingId).trim();
    region = (region || DEFAULT_REGION).trim();

    const safeMeetingId = meetingId.slice(0, 64);

    console.log(`\n🔴 End meeting request: "${safeMeetingId}"`);

    const chime = createChimeClient(region);

    // Get the internal meeting ID from cache
    let internalMeetingId = meetingCache.get(safeMeetingId);

    if (!internalMeetingId) {
      return res.status(404).json({ error: "Meeting not found" });
    }

    // Verify it's a valid UUID before trying to delete
    if (!/^[a-fA-F0-9]{8}(?:-[a-fA-F0-9]{4}){3}-[a-fA-F0-9]{12}$/.test(internalMeetingId)) {
      return res.status(400).json({ error: "Invalid meeting ID format" });
    }

    // Get all participants before ending the meeting
    const tracker = participantTracker.get(safeMeetingId);
    const participants = tracker ? Array.from(tracker.attendees) : [];

    await chime.deleteMeeting({ MeetingId: internalMeetingId }).promise();

    // Remove from cache and participant tracker
    meetingCache.delete(safeMeetingId);
    cleanupParticipantTracker(safeMeetingId);

    console.log(`✅ Meeting deleted: ${internalMeetingId}`);
    console.log(`🧹 Cleaned up participant tracking for meeting: ${safeMeetingId}`);
    console.log(`👥 Notifying ${participants.length} participants about meeting end`);

    return res.json({ 
      ok: true,
      meetingId: safeMeetingId,
      endedFor: participants,
      message: "Meeting ended for all participants"
    });

  } catch (err) {
    console.error("❌ Error ending meeting:", err);
    return res.status(500).json({ error: err.message || "Server error" });
  }
});

/**
 * POST /leave
 * Body: { meetingId: string, attendeeId: string, region?: string }
 * 
 * Allows a participant to leave the meeting without ending it
 */
app.post("/leave", async (req, res) => {
  try {
    let { meetingId, attendeeId, region } = req.body || {};

    if (!meetingId || !attendeeId) {
      return res.status(400).json({ error: "meetingId and attendeeId are required" });
    }

    meetingId = String(meetingId).trim();
    attendeeId = String(attendeeId).trim();
    region = (region || DEFAULT_REGION).trim();

    const safeMeetingId = meetingId.slice(0, 64);
    const safeAttendeeId = attendeeId.slice(0, 64);

    console.log(`\n👋 Leave request: meetingId="${safeMeetingId}", attendeeId="${safeAttendeeId}"`);

    const chime = createChimeClient(region);

    // Get the internal meeting ID from cache
    let internalMeetingId = meetingCache.get(safeMeetingId);
    if (!internalMeetingId) {
      return res.status(404).json({ error: "Meeting not found" });
    }

    // Remove participant from tracker
    const removeResult = removeParticipant(safeMeetingId, safeAttendeeId);
    if (!removeResult.success) {
      return res.status(404).json({ error: removeResult.error });
    }

    // Delete the attendee from AWS Chime
    try {
      await chime.deleteAttendee({
        MeetingId: internalMeetingId,
        AttendeeId: safeAttendeeId
      }).promise();
      console.log(`✅ Attendee deleted from AWS Chime: ${safeAttendeeId}`);
    } catch (err) {
      console.error("❌ Error deleting attendee from AWS Chime:", err);
      // Continue even if AWS deletion fails - participant is removed from tracker
    }

    console.log(`👋 Participant left meeting: ${safeAttendeeId}`);
    console.log(`   - Remaining participants: ${removeResult.participantCount}`);

    // If no participants left, clean up the meeting
    if (removeResult.participantCount === 0) {
      console.log(`🧹 No participants left, cleaning up meeting: ${safeMeetingId}`);
      try {
        await chime.deleteMeeting({ MeetingId: internalMeetingId }).promise();
        console.log(`✅ Meeting deleted due to no participants: ${internalMeetingId}`);
      } catch (err) {
        console.error("❌ Error deleting empty meeting:", err);
      }

      // Remove from cache and participant tracker
      meetingCache.delete(safeMeetingId);
      cleanupParticipantTracker(safeMeetingId);
      console.log(`🧹 Cleaned up meeting cache and participant tracker for: ${safeMeetingId}`);
    }

    return res.json({
      ok: true,
      participantCount: removeResult.participantCount,
      maxParticipants: 2
    });

  } catch (err) {
    console.error("❌ Error leaving meeting:", err);
    return res.status(500).json({ error: err.message || "Server error" });
  }
});

/**
 * POST /clear-cache
 * Body: { meetingId: string }
 * 
 * Clears the meeting cache for a specific meeting ID
 */
app.post("/clear-cache", async (req, res) => {
  try {
    let { meetingId } = req.body || {};

    if (!meetingId) {
      return res.status(400).json({ error: "meetingId is required" });
    }

    meetingId = String(meetingId).trim();
    const safeMeetingId = meetingId.slice(0, 64);

    console.log(`\n🧹 Clear cache request: "${safeMeetingId}"`);

    // Remove from cache and participant tracker
    const wasInCache = meetingCache.has(safeMeetingId);
    meetingCache.delete(safeMeetingId);
    cleanupParticipantTracker(safeMeetingId);

    console.log(`🧹 Cache cleared for meeting: ${safeMeetingId} (was in cache: ${wasInCache})`);

    return res.json({
      ok: true,
      cleared: wasInCache,
      message: wasInCache ? "Cache cleared successfully" : "Meeting not found in cache"
    });

  } catch (err) {
    console.error("❌ Error clearing cache:", err);
    return res.status(500).json({ error: err.message || "Server error" });
  }
});

/**
 * POST /audio/toggle
 * Body: { meetingId: string, attendeeId: string, audioEnabled: boolean, region?: string }
 * 
 * Toggle audio on/off for a participant
 */
app.post("/audio/toggle", async (req, res) => {
  try {
    let { meetingId, attendeeId, audioEnabled, region } = req.body || {};

    if (!meetingId || !attendeeId || typeof audioEnabled !== 'boolean') {
      return res.status(400).json({
        error: "meetingId, attendeeId, and audioEnabled (boolean) are required"
      });
    }

    meetingId = String(meetingId).trim();
    attendeeId = String(attendeeId).trim();
    region = (region || DEFAULT_REGION).trim();

    const safeMeetingId = meetingId.slice(0, 64);
    const safeAttendeeId = attendeeId.slice(0, 64);

    console.log(`\n🎤 Audio toggle request: meetingId="${safeMeetingId}", attendeeId="${safeAttendeeId}", audioEnabled=${audioEnabled}`);

    // Update participant audio state
    const updateResult = updateParticipantAudioState(safeMeetingId, safeAttendeeId, audioEnabled);
    if (!updateResult.success) {
      return res.status(404).json({ error: updateResult.error });
    }

    console.log(`🎤 Audio ${audioEnabled ? 'enabled' : 'disabled'} for participant: ${safeAttendeeId}`);

    return res.json({
      ok: true,
      audioEnabled: updateResult.audioEnabled,
      attendeeId: safeAttendeeId,
      meetingId: safeMeetingId
    });

  } catch (err) {
    console.error("❌ Error toggling audio:", err);
    return res.status(500).json({ error: err.message || "Server error" });
  }
});

/**
 * POST /video/toggle
 * Body: { meetingId: string, attendeeId: string, videoEnabled: boolean, region?: string }
 * 
 * Toggle video on/off for a participant
 */
app.post("/video/toggle", async (req, res) => {
  try {
    let { meetingId, attendeeId, videoEnabled, region } = req.body || {};

    if (!meetingId || !attendeeId || typeof videoEnabled !== 'boolean') {
      return res.status(400).json({
        error: "meetingId, attendeeId, and videoEnabled (boolean) are required"
      });
    }

    meetingId = String(meetingId).trim();
    attendeeId = String(attendeeId).trim();
    region = (region || DEFAULT_REGION).trim();

    const safeMeetingId = meetingId.slice(0, 64);
    const safeAttendeeId = attendeeId.slice(0, 64);

    console.log(`\n📹 Video toggle request: meetingId="${safeMeetingId}", attendeeId="${safeAttendeeId}", videoEnabled=${videoEnabled}`);

    // Update participant video state
    const updateResult = updateParticipantVideoState(safeMeetingId, safeAttendeeId, videoEnabled);
    if (!updateResult.success) {
      return res.status(404).json({ error: updateResult.error });
    }

    console.log(`📹 Video ${videoEnabled ? 'enabled' : 'disabled'} for participant: ${safeAttendeeId}`);

    return res.json({
      ok: true,
      videoEnabled: updateResult.videoEnabled,
      attendeeId: safeAttendeeId,
      meetingId: safeMeetingId
    });

  } catch (err) {
    console.error("❌ Error toggling video:", err);
    return res.status(500).json({ error: err.message || "Server error" });
  }
});

/**
 * GET /participants/:meetingId
 * 
 * Get participant states for a meeting
 */
app.get("/participants/:meetingId", (req, res) => {
  try {
    const { meetingId } = req.params;
    const safeMeetingId = String(meetingId).trim().slice(0, 64);

    console.log(`\n👥 Get participants request: meetingId="${safeMeetingId}"`);

    const statesResult = getParticipantStates(safeMeetingId);
    if (!statesResult.success) {
      return res.status(404).json({ error: statesResult.error });
    }

    const tracker = participantTracker.get(safeMeetingId);
    const participantCount = tracker ? tracker.attendees.size : 0;

    console.log(`👥 Retrieved ${participantCount} participants for meeting: ${safeMeetingId}`);

    return res.json({
      ok: true,
      meetingId: safeMeetingId,
      participantCount,
      maxParticipants: 2,
      participants: statesResult.states
    });

  } catch (err) {
    console.error("❌ Error getting participants:", err);
    return res.status(500).json({ error: err.message || "Server error" });
  }
});

/**
 * GET /meetings
 * Returns list of active meetings in cache
 * Useful for debugging
 */
app.get("/meetings", (req, res) => {
  const meetings = Array.from(meetingCache.entries()).map(([externalId, internalId]) => {
    const tracker = participantTracker.get(externalId);
    const participantStates = {};

    if (tracker && tracker.participantStates) {
      tracker.participantStates.forEach((state, attendeeId) => {
        participantStates[attendeeId] = {
          audioEnabled: state.audioEnabled,
          videoEnabled: state.videoEnabled,
          joinedAt: state.joinedAt,
          lastUpdated: state.lastUpdated
        };
      });
    }

    return {
      externalId,
      internalId,
      participantCount: tracker ? tracker.attendees.size : 0,
      maxParticipants: tracker ? tracker.maxParticipants : 2,
      attendees: tracker ? Array.from(tracker.attendees) : [],
      participantStates,
      createdAt: tracker ? tracker.createdAt : null
    };
  });

  return res.json({
    count: meetings.length,
    meetings,
  });
});

// Start server
try {
  const server = app.listen(PORT, () => {
    console.log(`\n✅ Chime backend running at http://localhost:${PORT}`);
    console.log(`📍 Region: ${DEFAULT_REGION}`);
    console.log(`🔧 Endpoints:`);
    console.log(`   POST /join    - Join/create meeting (max 2 participants)`);
    console.log(`   POST /leave   - Leave meeting (remove participant)`);
    console.log(`   POST /end     - End meeting`);
    console.log(`   POST /audio/toggle - Toggle audio on/off`);
    console.log(`   POST /video/toggle - Toggle video on/off`);
    console.log(`   GET  /participants/:meetingId - Get participant states`);
    console.log(`   GET  /health  - Health check`);
    console.log(`   GET  /meetings - List active meetings with participant info`);
    console.log(`\n⏳ Waiting for requests...\n`);
  });

  server.on('error', (err) => {
    if (err.code === 'EADDRINUSE') {
      console.error(`❌ Port ${PORT} is already in use. Please use a different port.`);
      console.log(`💡 Try setting PORT environment variable to a different value`);
    } else {
      console.error(`❌ Server error:`, err);
    }
    // Don't exit immediately, let the process handle it
  });

  // Keep the process alive
  setInterval(() => {
    // This keeps the event loop alive
  }, 1000);

} catch (error) {
  console.error(`❌ Failed to start server:`, error);
  console.log(`🔄 Server will attempt to continue...`);
}

