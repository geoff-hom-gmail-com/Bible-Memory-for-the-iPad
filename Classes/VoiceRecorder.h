/*
 File: VoiceRecorder.h
 Authors: Geoff Hom (GeoffHom@gmail.com)
 Abstract: For recording audio, especially voice, from the built-in microphone. Currently this uses the AV Audio Recorder because it's simple. Better voice quality might be obtained by using the Voice-Processing IO Audio Unit, which features echo suppression. If the voice recorder is recording, stop recording before calling dealloc:.
 */

@interface VoiceRecorder : NSObject {
}

// Whether the voice recorder is currently recording.
@property (nonatomic, assign) BOOL isRecording;

// Start recording via AVAudioRecorder class.
- (void)startRecordingWithAVAudioRecorder:(NSURL *)url;

// Stop the current audio recording process, assuming it's using the AVAudioRecorder class.
- (void)stopRecordingWithAVAudioRecorder;

@end
