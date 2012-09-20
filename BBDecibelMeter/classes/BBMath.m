//
//  BBMath.m
//  BBDecibelMeter
//
//  Created by Jonathan Beebe on 8/6/12.
//  Copyright (c) 2012 Jonathan Beebe. All rights reserved.
//

#import "BBMath.h"

@implementation BBMath

+ (float) scaleNumber: (float)num withinRangeMin: (float)rangeMin andRangeMax: (float)rangeMax withScaleMin: (float)scaleMin andScaleMax: (float)scaleMax
{
    return ( ((scaleMax - scaleMin) * (num - rangeMin)) / (rangeMax - rangeMin)) + scaleMin;
}

@end
