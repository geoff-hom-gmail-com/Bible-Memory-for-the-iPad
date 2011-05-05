/*
 File: RecallPassageViewController.m
 Authors: Geoffrey Hom (GeoffHom@gmail.com)
 */

#import <AudioToolbox/AudioToolbox.h>
#import "Passage.h"
#import "RecallPassageViewController.h"
#import "VoiceRecorder.h"

// Filename to store the user's voice recording.
NSString *filenameForRecording = @"recording1.caf";

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

// Change the styles of the buttons/controls.
- (void)stylizeControls;

// Enable/disable passage controls based on context. Change control labels based on context.
- (void)updateControlAppearance;

// Update what's seen. For example, in response to the showable text changing.
- (void)updateView;

@end

@implementation RecallPassageViewController

@synthesize referenceTextView, startOrPausePlaybackButton, startOrStopRecordingButton;
@synthesize audioPlayer, audioSession, documentDirectoryURL, passage, voiceRecorder;

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)audioPlayer successfully:(BOOL)completed {
	
	if (completed == YES) { 
		[self.startOrPausePlaybackButton setTitle:@"Start" forState:UIControlStateNormal];
		self.startOrStopRecordingButton.enabled = YES;
		//NSLog(@"Playback finished on own.");
	}
}

- (void)dealloc {
	
	// If recording, stop.
	if (self.voiceRecorder.isRecording) {
		[self.voiceRecorder stopRecordingWithAVAudioRecorder];
	}
	
	NSArray *anArray = [NSArray arrayWithObjects: audioPlayer, audioSession, documentDirectoryURL, passage, voiceRecorder, nil];
	for (NSObject *anObject in anArray) {
		[anObject release];
	}
	anArray = [NSArray arrayWithObjects: referenceTextView, startOrPausePlaybackButton, startOrStopRecordingButton, nil];
	for (NSObject *anObject in anArray) {
		[anObject release];
	}
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
	
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
	NSLog(@"RPVC memory warning called.");
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
		self.documentDirectoryURL = (NSURL *)[urlArray objectAtIndex:0];
		[aFileManager release];
		
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
		//NSLog(@"RPVC: Category set to ambient, with ducking.");
	} else { 
		[self.audioSession setCategory:AVAudioSessionCategorySoloAmbient error: nil];
		//NSLog(@"RPVC: Category set to solo ambient.");
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

    // Overriden to allow any orientation.
    return YES;
}

- (IBAction)startOrPausePlayback:(id)sender {

	UIButton *button = (UIButton *)sender;
	if (!self.audioPlayer.playing) {
		[button setTitle:@"Pause" forState:UIControlStateNormal];
		self.startOrStopRecordingButton.enabled = NO;
		
		NSURL *url = [self.documentDirectoryURL URLByAppendingPathComponent:filenameForRecording];
		AVAudioPlayer *anAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
		anAudioPlayer.delegate = self;
		self.audioPlayer = anAudioPlayer;
		[anAudioPlayer release];
		
		[self.audioPlayer prepareToPlay];
		[self.audioPlayer play];
	} else {
		[button setTitle:@"Start" forState:UIControlStateNormal];
		[self.audioPlayer pause];
		self.startOrStopRecordingButton.enabled = YES;
	}
}

- (IBAction)startOrStopRecording:(id)sender {

	UIButton *button = (UIButton *)sender;
	if (!self.voiceRecorder.isRecording) {
		[button setTitle:@"Stop" forState:UIControlStateNormal];
		[self.audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
		self.startOrPausePlaybackButton.enabled = NO;
		
		VoiceRecorder *aVoiceRecorder = [[VoiceRecorder alloc] init];
		self.voiceRecorder = aVoiceRecorder;
		[aVoiceRecorder release];
		
		NSURL *url;
		url = [self.documentDirectoryURL URLByAppendingPathComponent:filenameForRecording];
		[self.voiceRecorder startRecordingWithAVAudioRecorder:url]; 
	} else {
		[button setTitle:@"Start" forState:UIControlStateNormal];
		[self.voiceRecorder stopRecordingWithAVAudioRecorder]; 
		self.voiceRecorder = nil;
		[self setPlaybackCategory];
		self.startOrPausePlaybackButton.enabled = YES;
	}
}

- (void)stylizeControls {

	NSArray *controlsArray = [NSArray arrayWithObjects:self.startOrPausePlaybackButton, self.startOrStopRecordingButton, nil];
	
	UIColor *disabledTitleColor = [UIColor lightGrayColor];
	
	for (UIButton *aButton in controlsArray) {
		[aButton setTitleColor:disabledTitleColor forState:UIControlStateDisabled];
	}
}

- (void)updateControlAppearance {
}

- (void)updateView {
	[self updateControlAppearance];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

    [super viewDidLoad];
	
	[self stylizeControls];
	
	// If file for recording exists, enable playback controls. Else, disable.
	NSURL *url = [self.documentDirectoryURL URLByAppendingPathComponent:filenameForRecording];
	NSFileManager *aFileManager = [[NSFileManager alloc] init];
	BOOL fileForRecordingExists = [aFileManager fileExistsAtPath:[url path] ];
	[aFileManager release];
	NSArray *playbackControlsArray = [NSArray arrayWithObjects:self.startOrPausePlaybackButton, nil];
	if (fileForRecordingExists) {
		for (UIButton *aButton in playbackControlsArray) {
			aButton.enabled = YES;
		}
	} else {
		for (UIButton *aButton in playbackControlsArray) {
			aButton.enabled = NO;
		}
	}
	
	[self updateView];
}

- (void)viewDidUnload {
    NSLog(@"RPVC viewDidUnload called.");
	[super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.referenceTextView = nil;
	self.startOrPausePlaybackButton = nil;
	self.startOrStopRecordingButton = nil;
	
	// Release any data that is recreated in viewDidLoad.
}

@end
