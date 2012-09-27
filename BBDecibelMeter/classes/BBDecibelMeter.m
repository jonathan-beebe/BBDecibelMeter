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

NSString * const kBBDecibelMeterAvgPowerKey = @"averagePower";
NSString * const kBBDecibelMeterPeakPowerKey = @"peakPower";

@interface BBDecibelMeter() {
    dispatch_queue_t audioRecorderQueue;
}

@property (nonatomic, assign) int powerFactor;
@property (nonatomic, assign) int min;
@property (nonatomic, assign) int max;

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *decibelTimer;

@property (nonatomic, assign) float averagePower;
@property (nonatomic, assign) float peakPower;
@property (nonatomic, assign) BOOL recording;

- (float) power;
- (float) powerScale;
- (float) peak;
- (float) peakScale;

- (float) scale:(float)num rangeMin:(float)rMin rangeMax:(float)rMax scaleMin:(float)sMin scaleMax:(float)sMax;

@end

@implementation BBDecibelMeter

+ (id) meter
{
    return [[BBDecibelMeter alloc] init];
}

- (id) init
{
    self = [super init];

    self.interval = 0.1;

    audioRecorderQueue = dispatch_queue_create("audio recorder thread", NULL);
    
    // this article shows using 20
    // http://stackoverflow.com/questions/11417243/ios-iphone-microphone-calibration
    // but 40 seems to work a bit closer to the Mac sound preferences app.
    //
    // good discussion here: http://stackoverflow.com/questions/8586216/linear-x-logarithmic-scale
    
    self.powerFactor = 40;
    
    if(self) {
        self.min = pow (10, 0 / self.powerFactor);
        self.max = pow (10, 160 / self.powerFactor);
    }
    return self;
}

- (void) dealloc
{
    [self.decibelTimer invalidate];
    self.decibelTimer = nil;
    
    if(_recorder) {
        [_recorder stop];
        _recorder = nil;
    }
}

- (float) scale:(float)num rangeMin:(float)rMin rangeMax:(float)rMax scaleMin:(float)sMin scaleMax:(float)sMax
{
    return ( ((sMax - sMin) * (num - rMin)) / (rMax - rMin)) + sMin;
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

    [self.decibelTimer invalidate];
    self.decibelTimer = [NSTimer scheduledTimerWithTimeInterval:self.interval target:self selector:@selector(recordDecibelLevel:) userInfo:nil repeats:YES];
    
    self.recording = YES;
}

- (void) stopMeasuring
{
    [self.decibelTimer invalidate];
    self.decibelTimer = nil;
    
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
    double linear = pow (10, self.power / self.powerFactor);
    return fabsf([self scale:linear rangeMin:self.min rangeMax:self.max scaleMin:0.0f scaleMax:1.0f]);
}

- (float) peakScale
{
    double linear = pow (10, self.peak / self.powerFactor);
    return fabsf([self scale:linear rangeMin:self.min rangeMax:self.max scaleMin:0.0f scaleMax:1.0f]);
}

- (void)recordDecibelLevel:(NSTimer*)timer
{

    NSLog(@"record...");
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
