//
//  BBDecibelMeter.h
//  BBDecibelMeter
//
//  Created by Jonathan Beebe on 8/6/12.
//  Copyright (c) 2012 Jonathan Beebe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBDecibelMeter : NSObject

@property (nonatomic, readonly) float averagePower;
@property (nonatomic, readonly) float peakPower;
@property (nonatomic, readonly) BOOL recording;

+ (id) meter;

- (void) startMeasuring;
- (void) stopMeasuring;

@end
