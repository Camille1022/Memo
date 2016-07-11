//
//  changePasswordVC.h
//  毕设－多功能便签
//
//  Created by sq-ios81 on 16/4/9.
//  Copyright © 2016年 shangqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface changePasswordVC : UIViewController

// 原密码
@property (weak, nonatomic) IBOutlet UITextField *originalPass;
// 新密码
@property (weak, nonatomic) IBOutlet UITextField *passwordNew;
// 确认新密码
@property (weak, nonatomic) IBOutlet UITextField *comfirmPass;

// 警告
@property (weak, nonatomic) IBOutlet UILabel *warningLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (weak, nonatomic) IBOutlet UIButton *okBtnPrivate;

@end
