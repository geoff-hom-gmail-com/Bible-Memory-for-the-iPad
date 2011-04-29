/*
 File: VoiceRecorder.m
 Authors: Geoff Hom (GeoffHom@gmail.com)
 */

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "VoiceRecorder.h"

// Private category for private methods.
@interface VoiceRecorder ()

// For simpler audio recording than using an audio unit.
@property (nonatomic, retain) AVAudioRecorder *audioRecorder;

// The file in which to store the audio.
//rename this to something else? fileTarget makes me think of a string like "test.txt"
@property (nonatomic, assign) ExtAudioFileRef fileTarget;

// For storing the audio in memory.
@property (nonatomic, assign) AudioBufferList inputBufferList;

// The IO audio unit to use.
@property (nonatomic, assign) AudioUnit ioAudioUnit;

// mono, AAC format, 16 kHz? may not need this, and it's currently not aac anyway, right?
@property (nonatomic, assign) AudioStreamBasicDescription monoAAC16kHzAudioStreamBasicDescription;

// Recommended stream format for remote and voice-processing audio units.
@property (nonatomic, assign) AudioStreamBasicDescription monoCanonicalAudioStreamBasicDescription;

// Check whether the status shows an error for the task. If so, log and raise an exception.
- (void)checkStatus:(OSStatus)status task:(NSString*)string;

@end

@implementation VoiceRecorder

@synthesize isRecording;
@synthesize audioRecorder, fileTarget, inputBufferList, ioAudioUnit, monoAAC16kHzAudioStreamBasicDescription, monoCanonicalAudioStreamBasicDescription;

OSStatus RecordCallbackFunction (void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData) {
    
    VoiceRecorder *aVoiceRecorder = (VoiceRecorder *)inRefCon;
    
    AudioBufferList *audioBufferList = &aVoiceRecorder->inputBufferList;
    audioBufferList->mNumberBuffers = 1;
    audioBufferList->mBuffers[0].mNumberChannels = 1;
    audioBufferList->mBuffers[0].mData = NULL;
    audioBufferList->mBuffers[0].mDataByteSize = inNumberFrames * aVoiceRecorder->monoCanonicalAudioStreamBasicDescription.mBytesPerFrame;
    
    OSStatus status = AudioUnitRender(aVoiceRecorder->ioAudioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, audioBufferList);
    
    if (status != noErr) {
        NSLog(@"Error rendering Audio!");
        return status;
    }
    
    // we could in fact only write into the file once we have not received ANY
    // silence
    
    //TODO: should we react to silence in here?
    
    status = ExtAudioFileWriteAsync(aVoiceRecorder.fileTarget, inNumberFrames, audioBufferList);
    //[aVoiceRecorder checkStatus:status task:@"While writing."];
    
    return noErr;
}
    
- (void)checkStatus:(OSStatus)status task:(NSString*)string {
    
    if (status != noErr) {
		NSLog(@"OS Status = %ld, for task \"%@\"", status, string);
		[NSException raise:@"OSStatusCheck" format:@"Checking the return code of a task failed: '%@'", string];
    }
	// For testing.
	else {
		NSLog(@"OS Status worked. Status = %d, for task \"%@\"", status, string);
	}
}

- (void)dealloc {
    
	// put this back later, when I've chosen AVAudioRecorder vs audio unit.
	//if (self.isRecording) {
//		[self stopRecording];  
//	}
	
	[audioRecorder release];
	    
   // OSStatus result = AudioUnitRemovePropertyListenerWithUserData(self.ioAudioUnit, kAudioUnitProperty_LastRenderError, ErrorCallbackHandler, NULL);
   // [self checkResult:result withMessage:@"Removing Error Callback Handler."]; 
      
/*
    OSStatus status = AudioUnitUninitialize(self.ioAudioUnit);
    [self checkStatus:status task:@"Uninitializing IO audio unit."];
        
    status = AudioComponentInstanceDispose(self.ioAudioUnit);
    [self checkStatus:status task:@"Disposing of audio component instance."];
    
	// maybe I don't need this, since it's not retained anyway; figure this out after I've got good audio recording
    ioAudioUnit = NULL;
    
    if (fileTarget != NULL) {
		status = ExtAudioFileDispose(self.fileTarget);
		[self checkStatus:status task:@"Disposing of extended audio file object."];
    }
*/
    [super dealloc];
}

- (id)init {

	self = [super init];
    if (self) {
        
		isRecording = NO;
        fileTarget = NULL;
        
/*
        AudioComponentDescription ioUnitDescr;
        ioUnitDescr.componentType = kAudioUnitType_Output;
		// want option to choose either vp or remote io
        ioUnitDescr.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
//        io_unit_descr.componentSubType = kAudioUnitSubType_RemoteIO;
        ioUnitDescr.componentManufacturer = kAudioUnitManufacturer_Apple;
        ioUnitDescr.componentFlags = 0;
        ioUnitDescr.componentFlagsMask = 0;
                
        //Find the Audio Unit (either RemoteIO or VoiceProcessing unit)
        ioAudioUnit = NULL;
        AudioComponent comp = AudioComponentFindNext(NULL, &ioUnitDescr);
        
        OSStatus status = AudioComponentInstanceNew(comp, &ioAudioUnit);
		[self checkStatus:status task:@"Creating an instance of the IO audio unit."];

        UInt32 one = 1;
        UInt32 zero = 0;        
        
        status = AudioUnitSetProperty(ioAudioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &one, sizeof(UInt32));
        [self checkStatus:status task:@"Enabling input on IO audio unit."];
        
        status = AudioUnitSetProperty(ioAudioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &zero, sizeof(UInt32));
        [self checkStatus:status task:@"Disabling IO's output."];           
        
        // Setting a callback to receive errors from the IO AU
		// trying without error callback handler
        //result = AudioUnitAddPropertyListener(ioAudioUnit, kAudioUnitProperty_LastRenderError, ErrorCallbackHandler, NULL);
        //[self checkResult:result withMessage:@"Installing Error Callback Handler."];
        
        // Setting voice-processing-specific properties
        
		status = AudioUnitSetProperty(ioAudioUnit, kAUVoiceIOProperty_DuckNonVoiceAudio, kAudioUnitScope_Global, 1, &zero, sizeof(UInt32));
        [self checkStatus:status task:@"Disabling audio ducking."];    
        
//        result = AudioUnitSetProperty(ioAudioUnit, kAUVoiceIOProperty_VoiceProcessingEnableAGC, kAudioUnitScope_Global, 1, &zero, sizeof(UInt32) );
//        [self checkResult:result withMessage:@"Disabling AGC."];        
        
        // Setting the client stream format for the IO audio unit.
        
        size_t bytesPerSample = sizeof(AudioSampleType);
        memset(&monoCanonicalAudioStreamBasicDescription, 0, sizeof(AudioStreamBasicDescription));
        
        monoCanonicalAudioStreamBasicDescription.mBitsPerChannel    = 8 * bytesPerSample;
        monoCanonicalAudioStreamBasicDescription.mBytesPerFrame     = bytesPerSample;
        monoCanonicalAudioStreamBasicDescription.mBytesPerPacket    = bytesPerSample;
        monoCanonicalAudioStreamBasicDescription.mChannelsPerFrame  = 1;
        monoCanonicalAudioStreamBasicDescription.mFormatID          = kAudioFormatLinearPCM;
        monoCanonicalAudioStreamBasicDescription.mFormatFlags       = kAudioFormatFlagsCanonical;
        monoCanonicalAudioStreamBasicDescription.mFramesPerPacket   = 1;
        monoCanonicalAudioStreamBasicDescription.mSampleRate        = 16000.0;
      
        status = AudioUnitSetProperty(ioAudioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &monoCanonicalAudioStreamBasicDescription, sizeof(monoCanonicalAudioStreamBasicDescription) );
        [self checkStatus:status task:@"Setting client stream format on input."];    

        status = AudioUnitSetProperty(ioAudioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &monoCanonicalAudioStreamBasicDescription, sizeof(monoCanonicalAudioStreamBasicDescription) );
        [self checkStatus:status task:@"Setting client stream format on output."];       

        // Specify an input callback which will handle writing into the designated ExtAudioFile instance.
        AURenderCallbackStruct renderCallback;
        renderCallback.inputProc = RecordCallbackFunction;
        renderCallback.inputProcRefCon = (void *)self;
        
        status = AudioUnitSetProperty(ioAudioUnit, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 0, &renderCallback, sizeof(AURenderCallbackStruct) );
		[self checkStatus:status task:@"Setting AU IO's input callback struct property."];
		        
        // Also build our destination ASBD for the ExtAudioFile services

        memset(&monoAAC16kHzAudioStreamBasicDescription, 0, sizeof(AudioStreamBasicDescription) );

        monoAAC16kHzAudioStreamBasicDescription.mBitsPerChannel = 16;
        monoAAC16kHzAudioStreamBasicDescription.mBytesPerFrame = 2;
		monoAAC16kHzAudioStreamBasicDescription.mBytesPerPacket = 2;
        monoAAC16kHzAudioStreamBasicDescription.mChannelsPerFrame = 1;
        monoAAC16kHzAudioStreamBasicDescription.mFormatID = kAudioFormatLinearPCM;        
        monoAAC16kHzAudioStreamBasicDescription.mFormatFlags = kAudioFormatFlagsNativeEndian |kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
        monoAAC16kHzAudioStreamBasicDescription.mFramesPerPacket = 1;
		monoAAC16kHzAudioStreamBasicDescription.mSampleRate = 16000.0;
        
        status = AudioUnitInitialize(ioAudioUnit);
		[self checkStatus:status task:@"Initializing the IO audio unit."];
*/
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
	// do I need this delegate? what if I handle the interruptions via AVAudioSessionsDelegate?
	//anAVAudioRecorder.delegate = self;
	self.audioRecorder = anAVAudioRecorder;
	[anAVAudioRecorder release];
	NSLog(@"VR sRWAAR: before prepareToRecord");
	[self.audioRecorder prepareToRecord];
	NSLog(@"VR sRWAAR: after prepareToRecord");
	[self.audioRecorder record];
	self.isRecording = YES;
	NSLog(@"Started recording with AV audio recorder. Will record to: %@", url);
}

- (void)startRecordingWithVoiceProcessingAudioUnit:(NSURL *)url {
	/*
	// Check file validity.
    if (![url isFileURL]) {
        [NSException raise:@"Error" format:@"URL %@ is not a file-URL", url];
    }
	
	OSStatus status = ExtAudioFileCreateWithURL( (CFURLRef)url, kAudioFileCAFType, 
		&monoAAC16kHzAudioStreamBasicDescription, NULL, kAudioFileFlags_EraseFile, &fileTarget);
    [self checkStatus:status task:@"Create extended audio file with the URL."];

    // For development. If the url is for "testing2.caf," then use alternative recording options.
	NSString *filename = [url lastPathComponent];
	if ([filename isEqualToString:@"testing.caf"]) {
		NSLog(@"VR startR, use default recording options.");
	} else {
		NSLog(@"VR startR, use alternative recording options.");
	}
    
	status =  ExtAudioFileSetProperty(self.fileTarget, kExtAudioFileProperty_ClientDataFormat, 
		sizeof(monoCanonicalAudioStreamBasicDescription), &monoCanonicalAudioStreamBasicDescription);
    [self checkStatus:status task:@"Set extended-audio-file client format."];
    
    // Initialize async writes.
    status = ExtAudioFileWriteAsync(fileTarget, 0, NULL);
    [self checkStatus:status task:@"Initialize asynchronous writes."];
    
    // Actually start the IO unit to render.
    status = AudioOutputUnitStart(ioAudioUnit);
    [self checkStatus:status task:@"Start the IO audio unit."];
    
	self.isRecording = YES;
    
    NSLog(@"Started Recording.");
    NSLog(@"Will write into: %@", url);
	*/
}

- (void)stopRecordingWithAVAudioRecorder {
    
    NSLog(@"VR sRWAAR: before stop");
	[self.audioRecorder stop];
	self.audioRecorder = nil;
    self.isRecording = NO;
    NSLog(@"Stopped Recording.");
}

- (void)stopRecordingWithVoiceProcessingAudioUnit {
    
	/*
    OSStatus status = AudioOutputUnitStop(self.ioAudioUnit);
    [self checkStatus:status task:@"Stopping the IO audio unit."];
    
    //[SOVoiceRecorder checkResult:result withMessage:@"Removing render callback."];
    
    status = ExtAudioFileDispose(self.fileTarget);
    [self checkStatus:status task:@"Disposing ExtAudioFile."];
    
    fileTarget = NULL;
    
    self.isRecording = NO;
    
    NSLog(@"Stopped Recording.");
	*/
}


@end
