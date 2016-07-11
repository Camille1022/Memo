//
//  SettingVC.m
//  LMY_note
//
//  Created by sq-ios81 on 16/4/29.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "SettingVC.h"
#import "ContactView.h"
#import "OnlineView.h"
#import "AppDelegate.h"

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface SettingVC ()

@property (nonatomic, strong) ContactView *contactView;
@property (nonatomic, strong) OnlineView *onlineView;
@property (nonatomic, strong) UIView *passwordView;

@end

@implementation SettingVC
#pragma mark - 懒加载
-(ContactView *)contactView{
    if (_contactView == nil)
        _contactView = [[ContactView alloc]init];
    return _contactView;
}
-(OnlineView *)onlineView{
    if (_onlineView == nil)
        _onlineView = [[OnlineView alloc]init];
    return _onlineView;
}

#pragma mark - view operation
- (void)viewDidLoad {
    [super viewDidLoad];
    // 显示各个控件
    [self showView];
    
    // 手势识别器 --- 轻扫
    UISwipeGestureRecognizer *mySwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doSwipe:)];
    mySwipe.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:mySwipe];
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getNotificationOn) name:@"notifOn" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getNotificationOff) name:@"notifOff" object:nil];
}

// 处理 轻扫手势 的回调函数 －－－－ 下滑 关闭键盘
-(void)doSwipe:(UISwipeGestureRecognizer *)swipe {
    [self.view endEditing:YES];
}

-(void)showView {
    [self.view addSubview:self.contactView];
    [self.view addSubview:self.onlineView];
    
    
    self.passwordView = [[UIView alloc]initWithFrame:CGRectMake(WIDTH/12, -200, WIDTH/4, WIDTH/4)];
    self.passwordView.backgroundColor = [UIColor lightGrayColor];
    self.passwordView.layer.cornerRadius = WIDTH/8;
    // Label
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH/4, WIDTH/8)];
    title.textAlignment = NSTextAlignmentCenter;
    title.center = CGPointMake(WIDTH/8, WIDTH/12);
    title.text = @"Code";
    title.font = [UIFont systemFontOfSize:22];
    [self.passwordView addSubview:title];
    // Button
    CGFloat passwordY = CGRectGetMaxY(title.frame) + 10;
    UIButton *passwordBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, WIDTH/12, WIDTH/12)];
    passwordBtn.center = CGPointMake(WIDTH/8, passwordY);
    [passwordBtn setBackgroundImage:[UIImage imageNamed:@"change"] forState:UIControlStateNormal];
    passwordBtn.showsTouchWhenHighlighted = YES;
    [passwordBtn addTarget:self action:@selector(changePasswrod) forControlEvents:UIControlEventTouchUpInside];
    [self.passwordView addSubview:passwordBtn];
    
    [self.view addSubview:self.passwordView];
}

#pragma mark - 收到通知后的相关界面操作
// 界面子控件出现
-(void)getNotificationOn {
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.contactView.frame = CGRectMake(30, CGRectGetMaxY(self.line.frame)+15, WIDTH/2, WIDTH/2);
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.8 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        CGFloat searCY = CGRectGetMaxY(self.contactView.frame) + 15;
        self.onlineView.frame = CGRectMake(0, 0, WIDTH/3, WIDTH/3);
        self.onlineView.center = CGPointMake(WIDTH/3, searCY+WIDTH/6);
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.8 delay:0.2 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        CGFloat passwd = CGRectGetMaxY(self.onlineView.frame) + 15;
        self.passwordView.frame = CGRectMake(0, 0, WIDTH/4, WIDTH/4);
        self.passwordView.center = CGPointMake(WIDTH/3, passwd+WIDTH/8);
    } completion:^(BOOL finished) {
    }];
}
// 界面子控件消失
-(void)getNotificationOff {
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.contactView.frame = CGRectMake(30, -200, WIDTH/2, WIDTH/2);
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.8 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.onlineView.frame = CGRectMake(WIDTH/6, -200, WIDTH/3, WIDTH/3);
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:0.8 delay:0.1 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.passwordView.frame = CGRectMake(WIDTH/12, -200, WIDTH/4, WIDTH/4);
    } completion:^(BOOL finished) {
    }];
    // 隐藏键盘
    [self.view endEditing:YES];
}

#pragma mark - 更改密码
-(void)changePasswrod {
    [[NSUserDefaults standardUserDefaults]setObject:@"Modal" forKey:@"Tran"];
    UIStoryboard *storyboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc=[storyboard instantiateViewControllerWithIdentifier:@"changeVC"];
    AppDelegate *appD = [UIApplication sharedApplication].delegate;
    appD.window.rootViewController = vc;
}

@end
