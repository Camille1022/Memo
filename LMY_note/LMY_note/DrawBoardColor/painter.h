//
//  painter.h
//  circle Control
//
//  Created by 阿城 on 15/10/14.
//  Copyright © 2015年 阿城. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface painter : UIView

@property (nonatomic ,copy) void (^colBlock) (UIColor *);

@end
