//
//  remindTableViewController.h
//  LMY_note
//
//  Created by sq-ios81 on 16/4/15.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import <UIKit/UIKit.h>

// 代理传值
@protocol CJReMindTableVCDelegate <NSObject>
-(void)remindDate:(NSDate *)date remind:(BOOL)isRemind repeat:(NSString *)repeat;
@end


@interface remindTableViewController : UITableViewController

// 是否提醒
@property (weak, nonatomic) IBOutlet UISwitch *isRemind;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

// block 传值
@property (nonatomic, copy) void (^block)(BOOL isRemind,NSDate *remindDate,NSString *repeat);
// 代理传值 - 用 weak 防止循环调用
@property (nonatomic, weak) id<CJReMindTableVCDelegate>delegate;

@end
