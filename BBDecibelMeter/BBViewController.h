//
//  BBViewController.h
//  BBDecibelMeter
//
//  Created by Jonathan Beebe on 8/6/12.
//  Copyright (c) 2012 Jonathan Beebe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "F3BarGauge.h"

@interface BBViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIProgressView *peakProgressView;
@property (weak, nonatomic) IBOutlet UIProgressView *avgProgressView;
@property (weak, nonatomic) IBOutlet F3BarGauge *fbLevelView;

@end
