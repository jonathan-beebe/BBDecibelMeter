//
//  BBDecibelMeter.h
//  BBDecibelMeter
//
//  Created by Jonathan Beebe on 8/6/12.
//  Copyright (c) 2012 Jonathan Beebe. All rights reserved.
//

#import <Foundation/Foundation.h>

// Use these constants to access the properties using KVO
extern NSString *const kBBDecibelMeterAvgPowerKey;
extern NSString *const kBBDecibelMeterPeakPowerKey;

@interface BBDecibelMeter : NSObject

@property (nonatomic, readonly) float averagePower;
@property (nonatomic, readonly) float peakPower;
@property (nonatomic, readonly) BOOL recording;
@property (nonatomic, assign) float interval;

+ (id) meter;

- (void) startMeasuring;
- (void) stopMeasuring;

@end
