// server.js - FIXED VERSION
// This version properly handles meeting lookups using ExternalMeetingId

const express = require("express");
const AWS = require("aws-sdk");
const { v4: uuidv4 } = require("uuid");
const cors = require("cors");
require("dotenv").config();

const app = express();
const PORT = process.env.PORT || 5000;
const DEFAULT_REGION = process.env.AWS_REGION || "us-east-1";

app.use(cors());
app.use(express.json());

// In-memory cache to map External Meeting IDs to Internal AWS Meeting IDs
// In production, use Redis or a database
const meetingCache = new Map();

// Create a Chime SDK Meetings client for a given region
function createChimeClient(region) {
    AWS.config.update({ region });
    return new AWS.ChimeSDKMeetings({ region });
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

        // Create new meeting if not found
        if (!meeting) {
            console.log(`🆕 Creating new meeting for external ID: ${safeMeetingId}`);

            meeting = await chime.createMeeting({
                ClientRequestToken: uuidv4(),
                MediaRegion: region,
                ExternalMeetingId: safeMeetingId,
            }).promise();

            // Cache the mapping: External ID -> Internal AWS Meeting ID
            meetingCache.set(safeMeetingId, meeting.Meeting.MeetingId);

            console.log(`✅ Created meeting:`);
            console.log(`   - Internal ID: ${meeting.Meeting.MeetingId}`);
            console.log(`   - External ID: ${meeting.Meeting.ExternalMeetingId}`);
            console.log(`   - Region: ${meeting.Meeting.MediaRegion}`);
        }

        // Create attendee for this meeting
        const attendee = await chime.createAttendee({
            MeetingId: meeting.Meeting.MeetingId,
            ExternalUserId: safeName,
        }).promise();

        console.log(`👤 Created attendee: ${safeName}`);
        console.log(`   - Attendee ID: ${attendee.Attendee.AttendeeId}`);
        console.log(`   - Join Token: ${attendee.Attendee.JoinToken.substring(0, 20)}...`);
        console.log(`   - Full Attendee Object: ${JSON.stringify(attendee.Attendee, null, 2)}`);

        // Return the response in the format Flutter expects
        return res.json({
            Meeting: meeting.Meeting,
            Attendee: attendee.Attendee,
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
            // If not in cache, assume it's the internal ID
            internalMeetingId = safeMeetingId;
        }

        await chime.deleteMeeting({ MeetingId: internalMeetingId }).promise();

        // Remove from cache
        meetingCache.delete(safeMeetingId);

        console.log(`✅ Meeting deleted: ${internalMeetingId}`);

        return res.json({ ok: true });

    } catch (err) {
        console.error("❌ Error ending meeting:", err);
        return res.status(500).json({ error: err.message || "Server error" });
    }
});

/**
 * GET /meetings
 * Returns list of active meetings in cache
 * Useful for debugging
 */
app.get("/meetings", (req, res) => {
    const meetings = Array.from(meetingCache.entries()).map(([externalId, internalId]) => ({
        externalId,
        internalId,
    }));

    return res.json({
        count: meetings.length,
        meetings,
    });
});

// Start server
app.listen(PORT, "0.0.0.0", () => {
    console.log(`\n✅ Chime backend running at http://localhost:${PORT}`);
    console.log(`📍 Region: ${DEFAULT_REGION}`);
    console.log(`🔧 Endpoints:`);
    console.log(`   POST /join    - Join/create meeting`);
    console.log(`   POST /end     - End meeting`);
    console.log(`   GET  /health  - Health check`);
    console.log(`   GET  /meetings - List active meetings`);
    console.log(`\n⏳ Waiting for requests...\n`);
});

// Cleanup on shutdown
process.on('SIGINT', () => {
    console.log('\n\n🛑 Shutting down server...');
    console.log(`📊 Active meetings in cache: ${meetingCache.size}`);
    process.exit(0);
});
