//
//  HWWeakTimer.h
//  TimerTest
//
//  Created by 陈智颖 on 15/9/9.
//  Copyright (c) 2015年 YY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWWeakTimer : NSObject

+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                      target:(id)aTarget
                                    selector:(SEL)aSelector
                                    userInfo:(id)userInfo
                                     repeats:(BOOL)repeats;

@end
