/*
 File: VoiceRecorder.m
 Authors: Geoff Hom (GeoffHom@gmail.com)
 */

#import <AVFoundation/AVFoundation.h>
#import "VoiceRecorder.h"

// Private category for private methods.
@interface VoiceRecorder ()

// For simpler audio recording than using an audio unit.
@property (nonatomic, retain) AVAudioRecorder *audioRecorder;

@end

@implementation VoiceRecorder

@synthesize isRecording;
@synthesize audioRecorder;

- (void)dealloc {
    
	[audioRecorder release];
    [super dealloc];
}

- (id)init {

	self = [super init];
    if (self) {
		isRecording = NO;
    }

    return self;
}

- (void)startRecordingWithAVAudioRecorder:(NSURL *)url {
	
	NSDictionary *settingsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
		[NSNumber numberWithFloat: 44100.0], AVSampleRateKey, 
		[NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
		[NSNumber numberWithInt: 1], AVNumberOfChannelsKey, 
		[NSNumber numberWithInt: AVAudioQualityMax], AVEncoderAudioQualityKey, nil];
	AVAudioRecorder *anAVAudioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:settingsDictionary error:nil];
	self.audioRecorder = anAVAudioRecorder;
	[anAVAudioRecorder release];
	[self.audioRecorder prepareToRecord];
	[self.audioRecorder record];
	self.isRecording = YES;
	//NSLog(@"Started recording with AV audio recorder. Will record to: %@", url);
}

- (void)stopRecordingWithAVAudioRecorder {
    
    [self.audioRecorder stop];
	self.audioRecorder = nil;
    self.isRecording = NO;
    //NSLog(@"Stopped Recording.");
}

@end
