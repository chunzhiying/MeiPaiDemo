//
//  LoadingBox.h
//  yyfe
//
//  Created by chenzy on 15/7/21.
//  Copyright (c) 2015年 yy.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingBox : UIView

@property(nonatomic) BOOL isHide;

- (void)showInView:(UIView*)parentView withText:(NSString*)str;
- (void)hide;

@end
