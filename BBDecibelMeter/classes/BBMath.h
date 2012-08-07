//
//  BBMath.h
//  BBDecibelMeter
//
//  Created by Jonathan Beebe on 8/6/12.
//  Copyright (c) 2012 Jonathan Beebe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBMath : NSObject

+ (float) scaleNumber: (float)num withinRangeMin: (float)rangeMin andRangeMax: (float)rangeMax withScaleMin: (float)scaleMin andScaleMax: (float)scaleMax;

@end
