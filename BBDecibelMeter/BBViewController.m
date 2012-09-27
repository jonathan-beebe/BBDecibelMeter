//
//  BBViewController.m
//  BBDecibelMeter
//
//  Created by Jonathan Beebe on 8/6/12.
//  Copyright (c) 2012 Jonathan Beebe. All rights reserved.
//

#import "BBViewController.h"
#import "BBDecibelMeter.h"

static 
@interface BBViewController ()

@property (nonatomic, strong) BBDecibelMeter *meter;

@end

@implementation BBViewController

@synthesize peakProgressView;
@synthesize avgProgressView;
@synthesize fbLevelView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    peakProgressView.trackImage = nil;
    peakProgressView.trackTintColor = [UIColor clearColor];
    
    self.meter = [BBDecibelMeter meter];
    self.meter.interval = 1/30;
    [self.meter startMeasuring];
    [self.meter addObserver:self forKeyPath:kBBDecibelMeterAvgPowerKey options:0 context:nil];
    [self.meter addObserver:self forKeyPath:kBBDecibelMeterPeakPowerKey options:0 context:nil];
    
    fbLevelView.numBars = 20;
    fbLevelView.holdPeak = YES;
}

- (void)viewDidUnload
{
    [self setPeakProgressView:nil];
    [self setAvgProgressView:nil];
    [self setFbLevelView:nil];
    self.meter = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:kBBDecibelMeterAvgPowerKey]) {
        
        //NSLog(@"Power: %f, Peak: %f", self.meter.averagePower, self.meter.peakPower);
        
        [peakProgressView setProgress:self.meter.peakPower];
        [avgProgressView setProgress:self.meter.averagePower];
        
        [fbLevelView resetPeak];
        fbLevelView.value = self.meter.peakPower;
        fbLevelView.value = self.meter.averagePower;
    }
}

@end
