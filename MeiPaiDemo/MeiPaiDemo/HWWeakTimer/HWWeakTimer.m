//
//  HWWeakTimer.m
//  TimerTest
//
//  Created by 陈智颖 on 15/9/9.
//  Copyright (c) 2015年 YY. All rights reserved.
//

#import "HWWeakTimer.h"

@interface HWWeakTimerTarget : NSObject
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation HWWeakTimerTarget

- (void)fire:(NSTimer *)timer {
    
    if (self.target) {
        [self.target performSelector:self.selector withObject:(NSTimer*)timer afterDelay:0];
        
    } else {
        [self.timer invalidate];
    }
}

@end

@implementation HWWeakTimer

+ (NSTimer *) scheduledTimerWithTimeInterval:(NSTimeInterval)interval target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)repeats{
    
    HWWeakTimerTarget *timerTarget = [[HWWeakTimerTarget alloc] init];
    timerTarget.target = aTarget;
    timerTarget.selector = aSelector;
    timerTarget.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                         target:timerTarget
                                                       selector:@selector(fire:)
                                                       userInfo:userInfo
                                                        repeats:repeats];
    
    return timerTarget.timer;
}

@end
