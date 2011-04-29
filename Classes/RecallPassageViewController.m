/*
 File: RecallPassageViewController.m
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 */

#import <AudioToolbox/AudioToolbox.h>
#import "Passage.h"
#import "RecallPassageViewController.h"
#import "VoiceRecorder.h"

// Private category for private methods.
@interface RecallPassageViewController ()

// Button for starting/stopping audio recording.
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;

// This app's audio session.
@property (nonatomic, retain) AVAudioSession *audioSession;

// The Documents directory for this app.
@property (nonatomic, retain) NSURL *documentDirectoryURL;

// The passage being studied.
@property (nonatomic, retain) Passage *passage;

// For storing a reference to the voice recorder.
@property (nonatomic, retain) VoiceRecorder *voiceRecorder;

// Set the audio session's category to playback. If other music is playing, allow that. Else, use the "solo ambient" category to enable hardware decoding.
- (void)setPlaybackCategory;

// Update what's seen. For example, in response to the showable text changing.
- (void)updateView;

@end

@implementation RecallPassageViewController

@synthesize referenceTextView, startOrStopPlaybackButton, startOrStopPlayback2Button, startOrStopRecordingButton, startOrStopRecording2Button;
@synthesize audioPlayer, audioSession, documentDirectoryURL, passage, voiceRecorder;

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)audioPlayer successfully:(BOOL)completed {
	
	if (completed == YES) { 
		[self.startOrStopPlaybackButton setTitle:@"Start" forState:UIControlStateNormal];
		[self.startOrStopPlayback2Button setTitle:@"Start" forState:UIControlStateNormal];
		NSLog(@"Playback finished on own.");
	}
}

- (void)dealloc {
	
	NSArray *anArray = [NSArray arrayWithObjects: referenceTextView, startOrStopPlaybackButton, startOrStopPlayback2Button, startOrStopRecordingButton, startOrStopRecording2Button, nil];
	for (NSObject *anObject in anArray) {
		[anObject release];
	}
	anArray = [NSArray arrayWithObjects: audioPlayer, audioSession, documentDirectoryURL, passage, voiceRecorder, nil];
	for (NSObject *anObject in anArray) {
		[anObject release];
	}
    [super dealloc];
}

- (void)didReceiveMemoryWarning {

    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (id)initWithPassage:(Passage *)thePassage {

	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		
		// Get audio session. Set initial category to playback.
		self.audioSession = [AVAudioSession sharedInstance];
		[self setPlaybackCategory];
		[self.audioSession setActive:YES error:nil];
		
		self.passage = thePassage;
		
		// Find Documents directory.
		NSFileManager *aFileManager = [[NSFileManager alloc] init];
		NSArray *urlArray = [aFileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
		[aFileManager release];
		self.documentDirectoryURL = (NSURL *)[urlArray objectAtIndex:0];
		
		// do I need/want this here? wait until I have only one record button.
		//VoiceRecorder *aVoiceRecorder = [[VoiceRecorder alloc] init];
//		self.voiceRecorder = aVoiceRecorder;
//		[aVoiceRecorder release];
		
		//self.firstLetterText = @"";
    }
    return self;
}

- (void)setPlaybackCategory {
	
	UInt32 otherAudioIsPlaying;
	UInt32 propertySize = sizeof(otherAudioIsPlaying);
	AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, 
		&otherAudioIsPlaying);
	if (otherAudioIsPlaying) { 
		[self.audioSession setCategory:AVAudioSessionCategoryAmbient error: nil];
		UInt32 one = 1;
		AudioSessionSetProperty(kAudioSessionProperty_OtherMixableAudioShouldDuck, sizeof(one), 
			&one);
		NSLog(@"RPVC: Category set to ambient, with ducking.");
	} else { 
		[self.audioSession setCategory:AVAudioSessionCategorySoloAmbient error: nil];
		NSLog(@"RPVC: Category set to solo ambient.");
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // Overriden to allow any orientation.
    return YES;
}

- (IBAction)startOrStopPlayback:(id)sender {

	UIButton *button = (UIButton *)sender;
	if (!self.audioPlayer.playing) {
		[button setTitle:@"Stop" forState:UIControlStateNormal];
		
		// Play different filenames depending on which button was pressed.
		NSString *filename;
		if (button == self.startOrStopPlaybackButton) {
			filename = @"testing.caf";
		} else {
			filename = @"testing2.caf";			
		}
		NSURL *url = [self.documentDirectoryURL URLByAppendingPathComponent:filename];
		AVAudioPlayer *anAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
		anAudioPlayer.delegate = self;
		self.audioPlayer = anAudioPlayer;
		[anAudioPlayer release];
		
		NSLog(@"RPVC sOSP: About to call prepareToPlay");
		[self.audioPlayer prepareToPlay];
		NSLog(@"RPVC sOSP: Will play from: %@", url);
		[self.audioPlayer play];
	} else {
		[button setTitle:@"Start" forState:UIControlStateNormal];
		//[self.audioPlayer pause];
		[self.audioPlayer stop];
		// still need to reset currentTime
	}
}

- (IBAction)startOrStopRecording:(id)sender {

	UIButton *button = (UIButton *)sender;
	if (!self.voiceRecorder.isRecording) {
		[button setTitle:@"Stop" forState:UIControlStateNormal];
		[self.audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
		
		VoiceRecorder *aVoiceRecorder = [[VoiceRecorder alloc] init];
		self.voiceRecorder = aVoiceRecorder;
		[aVoiceRecorder release];
		
		// Record to different filenames depending on which button was pressed.
		// Record with different setups depending on which button was pressed.
		NSString *filename;
		NSURL *url;
		if (button == self.startOrStopRecordingButton) {
			filename = @"testing.caf";
			url = [self.documentDirectoryURL URLByAppendingPathComponent:filename];
			[self.voiceRecorder startRecordingWithAVAudioRecorder:url]; 
		} else {
			filename = @"testing2.caf";
			url = [self.documentDirectoryURL URLByAppendingPathComponent:filename];
			//[self.voiceRecorder startRecordingWithVoiceProcessingAudioUnit:url];
		}
	} else {
		[button setTitle:@"Start" forState:UIControlStateNormal];
		if (button == self.startOrStopRecordingButton) {
			[self.voiceRecorder stopRecordingWithAVAudioRecorder]; 
		} else {
			//[self.voiceRecorder stopRecordingWithVoiceProcessingAudioUnit];
		}
		//[self.voiceRecorder stopRecording];
		self.voiceRecorder = nil;
		[self setPlaybackCategory];
		//[self.audioSession setCategory:AVAudioSessionCategoryAmbient error:nil];
	}
}

- (void)updateView {
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	[self updateView];
}

- (void)viewDidUnload {
    
	[super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.referenceTextView = nil;
	self.startOrStopPlaybackButton = nil;
	self.startOrStopPlayback2Button = nil;
	self.startOrStopRecordingButton = nil;
	self.startOrStopRecording2Button = nil;
	
	// Release any data that is recreated in viewDidLoad.
}

@end
