//
//  PathStyle.h
//  LMY_note
//
//  Created by sq-ios81 on 16/5/5.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,PrintStyle) {
    PrintStyleFill = 1,
    PrintStyleStrock = 2
};
typedef NS_ENUM(NSInteger ,DrawStyle) {
    DrawStyleFreedomLine = 0,
    DrawStyleLine = 1,
    DrawStyleCircle = 2,
    DrawStyleRectangle = 3,
    DrawStyleRubber = 4
};

@interface PathStyle : NSObject

@property (nonatomic ,strong) UIColor *lineColor;
@property (nonatomic ,assign) CGFloat lineWidth;
@property (nonatomic ,assign) PrintStyle printStyle;
@property (nonatomic ,assign) DrawStyle drawStyle;

@end
