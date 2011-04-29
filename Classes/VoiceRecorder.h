/*
 File: VoiceRecorder.h
 Authors: Geoff Hom (GeoffHom@gmail.com)
 Abstract: For recording audio, especially voice, from the microphone. Based on "SOVoiceRecorder": https://github.com/hfink/matchbox/blob/master/Xcode/SimodOne/SOVoiceRecorder.h. The recording uses Apple's Voice-Processing Audio Unit, which includes echo suppression. 16khz AAC audio (or CAF?) and ...?
 */

@interface VoiceRecorder : NSObject {
}

// Whether the voice recorder is currently recording.
@property (nonatomic, assign) BOOL isRecording;

// Start recording via AVAudioRecorder class.
- (void)startRecordingWithAVAudioRecorder:(NSURL *)url;

// Start audio recording. Will be saved to URL.
- (void)startRecordingWithVoiceProcessingAudioUnit:(NSURL *)url;

// Stop the current audio recording process, assuming it's using the AVAudioRecorder class.
- (void)stopRecordingWithAVAudioRecorder;

// Stop the current audio recording process, assuming it's using an audio unit.
- (void)stopRecordingWithVoiceProcessingAudioUnit;

@end
