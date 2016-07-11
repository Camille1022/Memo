//
//  OnlineView.m
//  LMY_note
//
//  Created by sq-ios81 on 16/5/4.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "OnlineView.h"

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation OnlineView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(WIDTH/6, -200, WIDTH/3, WIDTH/3);
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.cornerRadius = WIDTH/6;
        
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH/4, WIDTH/8)];
        title.textAlignment = NSTextAlignmentCenter;
        title.center = CGPointMake(WIDTH/6, WIDTH/9);
        title.text = @"Online";
        title.font = [UIFont systemFontOfSize:22];
        [self addSubview:title];
        
        CGFloat onlineY = CGRectGetMaxY(title.frame) + 20;
        UIButton *onlineBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH/10, WIDTH/10)];
        onlineBtn.center = CGPointMake(WIDTH/6, onlineY);
        [onlineBtn setBackgroundImage:[UIImage imageNamed:@"baidu"] forState:UIControlStateNormal];
        onlineBtn.showsTouchWhenHighlighted = YES;
        [onlineBtn addTarget:self action:@selector(searchOnline) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:onlineBtn];
    }
    return self;
}

-(void)searchOnline {
    // 1.构造应用打开的格式化字符串
    NSString *string = @"http://www.baidu.com";
    NSURL *url = [NSURL URLWithString:string];

    // 2.调用openUrl方法打开
    [[UIApplication sharedApplication] openURL:url];
}


@end
