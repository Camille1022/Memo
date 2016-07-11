//
//  ContactView.m
//  LMY_note
//
//  Created by sq-ios81 on 16/5/3.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "ContactView.h"

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation ContactView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = CGRectMake(30, -200, WIDTH/2, WIDTH/2);
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.cornerRadius = WIDTH/4;
        
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH/4, WIDTH/8)];
        title.textAlignment = NSTextAlignmentCenter;
        title.center = CGPointMake(WIDTH/4, WIDTH/7);
        title.text = @"Contact";
        title.font = [UIFont systemFontOfSize:22];
        [self addSubview:title];
        
        self.number = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, WIDTH/2.5, 25)];
        self.number.center = CGPointMake(WIDTH/4, WIDTH/4);
        self.number.backgroundColor = [UIColor whiteColor];
        self.number.layer.cornerRadius = 4.5;
        self.number.placeholder = @" phont number";
        self.number.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self addSubview:self.number];
        
        CGFloat phoneY = CGRectGetMaxY(self.number.frame) + 30;
        self.phoneBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH/12, WIDTH/12)];
        self.phoneBtn.center = CGPointMake(WIDTH/6, phoneY);
        [self.phoneBtn setBackgroundImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
        self.phoneBtn.showsTouchWhenHighlighted = YES;
        [self.phoneBtn addTarget:self action:@selector(callNumber) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.phoneBtn];
        
        CGFloat messageX = CGRectGetMaxX(self.phoneBtn.frame) + 40;
        self.messageBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH/12, WIDTH/12)];
        self.messageBtn.center = CGPointMake(messageX, phoneY);
        [self.messageBtn setBackgroundImage:[UIImage imageNamed:@"SMS"] forState:UIControlStateNormal];
        self.messageBtn.showsTouchWhenHighlighted = YES;
        [self.messageBtn addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.messageBtn];
    }
    return self;
}

// 拨打电话
-(void)callNumber {
    // 1.构造应用打开的格式化字符串
    NSString *string;
    if (self.number.text.length > 0) {
        // 直接拨打电话，不提示
//        string = [NSString stringWithFormat:@"tel://%@", self.telephoneTextField.text];
        // 拨打前对话框提示
        string = [NSString stringWithFormat:@"telprompt://%@", self.number.text];
    }
    NSURL *url = [NSURL URLWithString:string];
    
    // 2.调用openUrl方法打开
    [[UIApplication sharedApplication] openURL:url];
}

// 发短信
-(void)sendMessage {
    // 1.构造应用打开的格式化字符串
    NSString *string;
    if (self.number.text.length > 0) {
        string = [NSString stringWithFormat:@"sms://%@", self.number.text];
    }
    NSURL *url = [NSURL URLWithString:string];
    
    // 2.调用openUrl方法打开
    [[UIApplication sharedApplication] openURL:url];
}

@end
