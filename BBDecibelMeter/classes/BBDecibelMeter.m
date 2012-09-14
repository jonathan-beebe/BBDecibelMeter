//
//  BBDecibelMeter.m
//  BBDecibelMeter
//
//  Created by Jonathan Beebe on 8/6/12.
//  Copyright (c) 2012 Jonathan Beebe. All rights reserved.
//

#import "BBDecibelMeter.h"

#import <AVFoundation/AVFoundation.h>
#import <math.h>
#import "BBMath.h"

NSString * const kBBDecibelMeterAvgPowerKey = @"averagePower";
NSString * const kBBDecibelMeterPeakPowerKey = @"peakPower";

@interface BBDecibelMeter() {
    AVAudioRecorder* _recorder;
    double min;
    double max;
    int powerFactor;
    NSTimer *_decibelTimer;
    
    dispatch_queue_t audioRecorderQueue;
}

@property (nonatomic, assign) float averagePower;
@property (nonatomic, assign) float peakPower;
@property (nonatomic, assign) BOOL recording;

- (float) power;
- (float) powerScale;
- (float) peak;
- (float) peakScale;

@end

@implementation BBDecibelMeter

@synthesize averagePower;
@synthesize peakPower;
@synthesize recording;

+ (id) meter
{
    return [[BBDecibelMeter alloc] init];
}

- (id) init
{
    self = [super init];
    
    audioRecorderQueue = dispatch_queue_create("audio recorder thread", NULL);
    
    // this article shows using 20
    // http://stackoverflow.com/questions/11417243/ios-iphone-microphone-calibration
    // but 40 seems to work a bit closer to the Mac sound preferences app.
    //
    // good discussion here: http://stackoverflow.com/questions/8586216/linear-x-logarithmic-scale
    
    powerFactor = 40;
    
    if(self) {
        min = pow (10, 0 / powerFactor);
        max = pow (10, 160 / powerFactor);
    }
    return self;
}

- (void) dealloc
{
    [_decibelTimer invalidate];
    _decibelTimer = nil;
    
    if(_recorder) {
        [_recorder stop];
        _recorder = nil;
    }
}

- (void) startMeasuring
{
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
    
    if(!_recorder) {
        
        NSDictionary* recorderSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInt:kAudioFormatAppleIMA4],AVFormatIDKey,
                                          [NSNumber numberWithInt:44100],AVSampleRateKey,
                                          [NSNumber numberWithInt:1],AVNumberOfChannelsKey,
                                          [NSNumber numberWithInt:8],AVLinearPCMBitDepthKey,
                                          [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
                                          [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                          nil];
        NSError* error = nil;
        
        NSString *tempDir = [NSTemporaryDirectory() stringByAppendingPathComponent:@"tmp.caf"];
        tempDir = [tempDir stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
        NSURL *url = [NSURL URLWithString:tempDir];
        
        _recorder = [[AVAudioRecorder alloc] initWithURL:url
                                                settings:recorderSettings
                                                   error:&error];
        _recorder.meteringEnabled = YES;
    }
    
    dispatch_async(audioRecorderQueue, ^{
        [_recorder record];
        dispatch_release(audioRecorderQueue);
    });
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    [_decibelTimer invalidate];
    _decibelTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(recordDecibelLevel:) userInfo:nil repeats:YES];
    //});
    
    self.recording = YES;
}

- (void) stopMeasuring
{
    [_decibelTimer invalidate];
    _decibelTimer = nil;
    
    if(_recorder) {
        [_recorder stop];
        _recorder = nil;
    }
    self.recording = NO;
}

- (float) power
{
    if(_recorder) {
        [_recorder updateMeters];
        return [_recorder averagePowerForChannel:0] + 160;
    }
    else {
        return 0;
    }
}

- (float) peak
{
    if(_recorder) {
        [_recorder updateMeters];
        return [_recorder peakPowerForChannel:0] + 160;
    }
    else {
        return 0;
    }
}

- (float) powerScale
{
    double linear = pow (10, self.power / powerFactor);
    return fabsf([BBMath scaleNumber:linear withinRangeMin:min andRangeMax:max withScaleMin:0.0f andScaleMax:1.0f]);
}

- (float) peakScale
{
    double linear = pow (10, self.peak / powerFactor);
    return fabsf([BBMath scaleNumber:linear withinRangeMin:min andRangeMax:max withScaleMin:0.0f andScaleMax:1.0f]);
}

- (void)recordDecibelLevel:(NSTimer*)timer
{
    // Only make changes to the values when they differ.
    // This makes KVO more efficient as it's not triggered when the values don't change.
    
    float avg = [self powerScale];
    if(self.averagePower != avg) {
        self.averagePower = avg;
    }
    
    float peak = [self peakScale];
    if(self.peakPower != peak) {
        self.peakPower = peak;
    }
}

@end
