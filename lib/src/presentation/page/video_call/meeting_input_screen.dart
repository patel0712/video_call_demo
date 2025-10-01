import 'package:bloc_clean_architecture/src/comman/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

/// Screen for entering meeting details before joining a video call
/// This provides a better UX by separating meeting setup from the call screen
class MeetingInputScreen extends StatefulWidget {
  const MeetingInputScreen({super.key});

  @override
  State<MeetingInputScreen> createState() => _MeetingInputScreenState();
}

class _MeetingInputScreenState extends State<MeetingInputScreen> {
  final TextEditingController _meetingIdController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _meetingIdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _joinMeeting() {
    if (_formKey.currentState!.validate()) {
      final meetingId = _meetingIdController.text.trim();
      final name = _nameController.text.trim();

      // Navigate to video call screen with parameters
      context.pushNamed(
        AppRoutes.VIDEO_CALL_ROUTE_NAME,
        queryParameters: {'meetingId': meetingId, 'participantName': name},
      );
    }
  }

  void _generateRandomMeeting() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomId = 'meeting-$timestamp';
    _meetingIdController.text = randomId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Join Video Call',
          style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // Video call icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.video_call,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'Enter Meeting Details',
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Both participants must use the same Meeting ID',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Meeting ID field
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _meetingIdController,
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g., meeting-123',
                            prefixIcon: const Icon(Icons.meeting_room),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a meeting ID';
                            }
                            if (value.trim().length < 3) {
                              return 'Meeting ID must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton.icon(
                            onPressed: _generateRandomMeeting,
                            icon: const Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Colors.black,
                            ),
                            label: Text(
                              'Generate Random Meeting ID',
                              style: GoogleFonts.roboto(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Name field
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.roboto(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        hintText: 'e.g., Alice',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Join button
                  ElevatedButton(
                    onPressed: _joinMeeting,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.video_call, color: Colors.white),
                        const SizedBox(width: 12),
                        Text(
                          'Join Meeting',
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Info card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'How it works',
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          '1.',
                          'Share the Meeting ID with the other participant',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoItem(
                          '2.',
                          'Both participants enter the SAME Meeting ID',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoItem(
                          '3.',
                          'Each participant enters their own unique name',
                        ),
                        const SizedBox(height: 8),
                        _buildInfoItem(
                          '4.',
                          'Both tap "Join Meeting" to start the video call',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.blue.shade900,
            ),
          ),
        ),
      ],
    );
  }
}
