import ReplayKit
import Flutter

class ScreenSharePlugin: NSObject, FlutterPlugin {
    private let streamHandler = ScreenShareStreamHandler()
    private var eventChannel: FlutterEventChannel?
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "screen_share_plugin", binaryMessenger: registrar.messenger())
        let instance = ScreenSharePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Setup event channel for broadcast updates
        instance.eventChannel = FlutterEventChannel(name: "screen_share_events", binaryMessenger: registrar.messenger())
        instance.eventChannel?.setStreamHandler(instance.streamHandler)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startScreenShare":
            startScreenShare(result: result)
        case "stopScreenShare":
            stopScreenShare(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func startScreenShare(result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            let recorder = RPScreenRecorder.shared()
            
            recorder.isMicrophoneEnabled = false
            guard recorder.isAvailable else {
                result(FlutterError(code: "SCREEN_RECORDING_UNAVAILABLE",
                                  message: "Screen recording is not available",
                                  details: nil))
                return
            }
            
            recorder.startCapture { [weak self] (buffer, type, error) in
                guard error == nil else {
                    result(FlutterError(code: "SCREEN_RECORDING_ERROR",
                                      message: error?.localizedDescription ?? "Unknown error",
                                      details: nil))
                    return
                }
                
                // Handle the screen capture buffer
                self?.streamHandler.sendBuffer(buffer, type: type)
            } completionHandler: { error in
                if let error = error {
                    result(FlutterError(code: "SCREEN_RECORDING_ERROR",
                                      message: error.localizedDescription,
                                      details: nil))
                } else {
                    result(true)
                }
            }
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION",
                              message: "Screen recording requires iOS 12.0 or later",
                              details: nil))
        }
    }
    
    private func stopScreenShare(result: @escaping FlutterResult) {
        if #available(iOS 12.0, *) {
            let recorder = RPScreenRecorder.shared()
            recorder.stopCapture { error in
                if let error = error {
                    result(FlutterError(code: "STOP_RECORDING_ERROR",
                                      message: error.localizedDescription,
                                      details: nil))
                } else {
                    result(nil)
                }
            }
        } else {
            result(FlutterError(code: "UNSUPPORTED_VERSION",
                              message: "Screen recording requires iOS 12.0 or later",
                              details: nil))
        }
    }
}

class ScreenShareStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
    
    func sendBuffer(_ buffer: CMSampleBuffer, type: RPSampleBufferType) {
        guard let eventSink = eventSink else { return }
        
        // Convert buffer to format suitable for AWS Chime SDK
        // Implementation depends on AWS Chime SDK requirements
    }
}