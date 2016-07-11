//
//  changePasswordVC.m
//  毕设－多功能便签
//
//  Created by sq-ios81 on 16/4/9.
//  Copyright © 2016年 shangqian. All rights reserved.
//

#import "changePasswordVC.h"
#import "ViewController.h"
#import "AppDelegate.h"

@interface changePasswordVC ()

@end

@implementation changePasswordVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *lightBlue = [UIColor colorWithRed:196/255.0 green:214/255.0 blue:239/255.0 alpha:1];
    self.navigationController.view.backgroundColor = lightBlue;
    
    // 隐藏警告 Label
    self.warningLabel.hidden = YES;
    // 设置 Button 边框
    CGFloat corn = self.okBtnPrivate.bounds.size.width / 7;
    self.okBtnPrivate.layer.borderWidth = corn/10 + 1;
    self.okBtnPrivate.layer.cornerRadius = corn;
    self.okBtnPrivate.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    self.okBtn.layer.borderWidth = corn/10 + 1;
    self.okBtn.layer.cornerRadius = corn;
    self.okBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    self.cancelBtn.layer.borderWidth = corn/10 + 1;
    self.cancelBtn.layer.cornerRadius = corn;
    self.cancelBtn.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    // 轻扫 手势识别器
    UISwipeGestureRecognizer *mySwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doSwipe:)];
    mySwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:mySwipe];
}

- (IBAction)backAction:(id)sender {
    AppDelegate *appD = [UIApplication sharedApplication].delegate;
    appD.window.rootViewController = [appD sharedLeftSlider];
}

-(void)viewWillAppear:(BOOL)animated {
    NSString *flagStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"Tran"];
    if ([flagStr isEqualToString:@"Modal"]) {
        self.okBtn.hidden = NO;
        self.cancelBtn.hidden = NO;
        self.okBtnPrivate.hidden = YES;
        self.titleLabel.hidden = NO;
    } else {
        self.okBtn.hidden = YES;
        self.cancelBtn.hidden = YES;
        self.okBtnPrivate.hidden = NO;
        self.titleLabel.hidden = YES;
    }
}

// 处理 轻扫手势 的回调函数 ------ 下滑 关闭键盘
-(void)doSwipe:(UISwipeGestureRecognizer *)swipe {
    [self.view endEditing:YES];
}

#pragma mark - response click OK
- (IBAction)okBtn:(id)sender {
    if ([self.passwordNew.text isEqualToString:self.comfirmPass.text]&& [[[NSUserDefaults standardUserDefaults]valueForKey:@"passwd"] isEqualToString:self.originalPass.text] && self.passwordNew.text.length > 0) {
        self.warningLabel.hidden = YES;
        [self changeComfirm]; // 是否确认修改
    } else {
        if (![self.originalPass.text isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:@"passwd"]])
            self.warningLabel.text =@"The original password is wrong!";
        else if (self.passwordNew.text.length == 0)
            self.warningLabel.text = @"New password can't be null!";
        else
            self.warningLabel.text = @"Two new password is different!";
        
        self.warningLabel.hidden = NO;
        // 清空输入栏的数据
        self.originalPass.text = nil;
        self.passwordNew.text = nil;
        self.comfirmPass.text = nil;
    }
}
// 是否确认修改
-(void)changeComfirm {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reminding" message:@"Sure to change password?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 将新密码存入 preference
        [[NSUserDefaults standardUserDefaults]setObject:self.passwordNew.text forKey:@"passwd"];
        
        NSString* flagStr =[[NSUserDefaults standardUserDefaults] objectForKey:@"Tran"];
        if ([flagStr isEqualToString:@"Modal"]) {
            AppDelegate *appD = [UIApplication sharedApplication].delegate;
            appD.window.rootViewController = [appD sharedLeftSlider];
        }
        else
            [self.navigationController popToRootViewControllerAnimated:YES];   
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
