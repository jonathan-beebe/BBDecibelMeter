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

@end

@implementation BBViewController {
    BBDecibelMeter *meter_;
}
@synthesize peakProgressView;
@synthesize avgProgressView;
@synthesize fbLevelView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    peakProgressView.trackImage = nil;
    peakProgressView.trackTintColor = [UIColor clearColor];
    
    meter_ = [BBDecibelMeter meter];
    [meter_ startMeasuring];
    [meter_ addObserver:self forKeyPath:kBBDecibelMeterAvgPowerKey options:0 context:nil];
    [meter_ addObserver:self forKeyPath:kBBDecibelMeterPeakPowerKey options:0 context:nil];
    
    fbLevelView.numBars = 20;
    fbLevelView.holdPeak = YES;
}

- (void)viewDidUnload
{
    [self setPeakProgressView:nil];
    [self setAvgProgressView:nil];
    [self setFbLevelView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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
        
        //NSLog(@"Power: %f, Peak: %f", meter_.averagePower, meter_.peakPower);
        
        [peakProgressView setProgress:meter_.peakPower];
        [avgProgressView setProgress:meter_.averagePower];
        
        [fbLevelView resetPeak];
        fbLevelView.value = meter_.peakPower;
        fbLevelView.value = meter_.averagePower;
    }
}

@end
