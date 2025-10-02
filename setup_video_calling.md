# Video Calling Setup Guide

This guide will help you set up the video calling functionality with AWS Chime SDK.

## Prerequisites

1. **AWS Account** with Chime SDK access
2. **Node.js and npm** installed
3. **Flutter SDK** (>=3.8.0)

## Step-by-Step Setup

### 1. AWS IAM User Setup

1. Go to [AWS IAM Console](https://console.aws.amazon.com/iam/)
2. Create a new user with programmatic access
3. Attach the following policy:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "chime:CreateMeeting",
                "chime:GetMeeting",
                "chime:DeleteMeeting",
                "chime:CreateAttendee",
                "chime:GetAttendee",
                "chime:DeleteAttendee"
            ],
            "Resource": "*"
        }
    ]
}
```

4. Save the Access Key ID and Secret Access Key

### 2. Backend Server Setup

1. **Navigate to backend directory**:
   ```bash
   cd chime-backend
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Create .env file**:
   ```bash
   # Create .env file in chime-backend folder
   echo "AWS_ACCESS_KEY_ID=your_access_key_id_here" > .env
   echo "AWS_SECRET_ACCESS_KEY=your_secret_access_key_here" >> .env
   echo "AWS_REGION=us-east-1" >> .env
   echo "PORT=5000" >> .env
   ```

4. **Edit .env file** with your actual AWS credentials:
   ```env
   AWS_ACCESS_KEY_ID=AKIA...your_actual_key
   AWS_SECRET_ACCESS_KEY=your_actual_secret_key
   AWS_REGION=us-east-1
   PORT=5000
   ```

5. **Start the backend server**:
   ```bash
   npm start
   ```

   You should see:
   ```
   ✅ Chime backend running at http://localhost:5000
   📍 Region: us-east-1
   ```

### 3. Flutter App Setup

1. **Navigate to Flutter app directory**:
   ```bash
   cd video_call_demo
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate code**:
   ```bash
   dart run build_runner build
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

### 4. Test Video Calling

1. **Make sure backend server is running** (Step 2)
2. **Make sure Flutter app is running** (Step 3)
3. **Navigate to Video Call section** in the app
4. **Create or join a meeting**
5. **Test with multiple devices/emulators**

## Troubleshooting

### Backend Server Issues

- **Port already in use**: Change PORT in .env file
- **AWS credentials error**: Verify your credentials are correct
- **Permission denied**: Check IAM policy permissions

### Flutter App Issues

- **Build errors**: Clean and rebuild
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```
- **Video not working**: Grant camera and microphone permissions
- **Connection issues**: Ensure backend server is running on localhost:5000

### Video Call Issues

- **No video**: Check camera permissions
- **No audio**: Check microphone permissions
- **Connection failed**: Verify backend server is accessible

## API Endpoints

The backend provides these endpoints:

- `POST /join` - Join or create a meeting
- `POST /leave` - Leave a meeting  
- `POST /end` - End a meeting
- `POST /audio/toggle` - Toggle audio on/off
- `POST /video/toggle` - Toggle video on/off
- `GET /participants/:meetingId` - Get participant states
- `GET /health` - Health check
- `GET /meetings` - List active meetings

## Development Tips

1. **Use physical devices** for better video call testing
2. **Check server logs** for debugging API issues
3. **Test with multiple participants** to verify meeting functionality
4. **Use different meeting IDs** for separate test sessions

## Security Notes

- Never commit your .env file to version control
- Use environment variables in production
- Rotate AWS credentials regularly
- Consider using IAM roles instead of access keys in production
