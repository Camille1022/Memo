//
//  DrawBoardVC.m
//  LMY_note
//
//  Created by sq-ios81 on 16/5/4.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "DrawBoardVC.h"
#import "DrawBoardView.h"
#import "ToolsView.h"
#import "painter.h"
#import "SVProgressHUD.h"

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface DrawBoardVC ()
{
    BOOL toolsExit;
}

@property (nonatomic, strong) ToolsView *tools;
@property (nonatomic, strong) painter *colors;
@property (nonatomic, strong) UIButton *blackBtn;

@property (nonatomic, strong) NSArray *toolsArr;

@end

@implementation DrawBoardVC

-(ToolsView *)tools {
    if (_tools == nil)
        _tools = [ToolsView ToolsView];
    return _tools;
}
-(painter *)colors {
    if (_colors == nil)
        _colors = [painter new];
    return _colors;
}
-(NSArray *)toolsArr {
    if (_toolsArr == nil)
        _toolsArr = [NSArray array];
    return _toolsArr;
}

#pragma mark - View Operation
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(widthClicked:) name:@"colorDismiss" object:nil];
    
    _toolsArr = @[self.tools.pan,self.tools.line,self.tools.circle,self.tools.rectangle,self.tools.rubber];
    
    [self getDrawStyle:self.tools.pan];
    
    [[NSUserDefaults standardUserDefaults]setObject:@"color 0 0 0 1" forKey:@"lineColor"];
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",3] forKey:@"lineWidth"];
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",0] forKey:@"styleTag"];
    
    self.widthSlider.minimumValue = 1;
    self.widthSlider.maximumValue = 50;
    
}

-(void)viewDidAppear:(BOOL)animated {
    // 右侧 工具栏
    self.tools.frame = CGRectMake(WIDTH + 10, HEIGHT/3.5, 60, 400);
    [self.view addSubview:self.tools];
    // 下方 调色盘
    self.colors.hidden = YES;
    [self.view insertSubview:self.colors aboveSubview:self.boardView];
    
    CGFloat blackX = CGRectGetMaxX(self.colors.frame) + 5;
    CGFloat blackY = CGRectGetMaxY(self.boardView.frame) + 15;
    self.blackBtn = [[UIButton alloc]initWithFrame:CGRectMake(blackX, blackY, 20, 20)];
    self.blackBtn.backgroundColor = [UIColor blackColor];
    self.blackBtn.layer.cornerRadius = 6;
    [self.blackBtn addTarget:self action:@selector(getBlackColor) forControlEvents:UIControlEventTouchUpInside];
    self.blackBtn.showsTouchWhenHighlighted = YES;
    [self.view addSubview:self.blackBtn];
    self.blackBtn.hidden = YES;
}

#pragma mark - Button Clicked
- (IBAction)deleteClicked:(UIButton *)sender {
    sender.showsTouchWhenHighlighted = YES;
    NSNotification *notifClear = [NSNotification notificationWithName:@"clearBoard" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notifClear];
}
- (IBAction)backClicked:(UIButton *)sender {
    sender.showsTouchWhenHighlighted = YES;
    NSNotification *notifRevoke = [NSNotification notificationWithName:@"revokeBoard" object:nil];
    [[NSNotificationCenter defaultCenter]postNotification:notifRevoke];
}
- (IBAction)okClicked:(UIButton *)sender {
    sender.showsTouchWhenHighlighted = YES;
    CGSize size = CGSizeMake(self.boardView.bounds.size.width, self.boardView.bounds.size.height-44);
    UIGraphicsBeginImageContext(size);
    CGContextRef ref = UIGraphicsGetCurrentContext();
    //截图
    [self.boardView.layer renderInContext:ref];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error)
        [SVProgressHUD showWithStatus:@"wait for preserving..."];
    else
        [SVProgressHUD showErrorWithStatus:@"failed~"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1 animations:^{
            [SVProgressHUD showWithStatus:@"success~"];
            // 发送通知，插入画的图片
            NSDictionary *dict = @{
                                   @"image" :image
                                   };
            NSNotification *drawImage = [NSNotification notificationWithName:@"drawImage" object:nil userInfo:dict];
            [[NSNotificationCenter defaultCenter]postNotification:drawImage];
            
        } completion:^(BOOL finished) {
            [SVProgressHUD dismiss];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    });
}

#pragma mark - toolBar Items Clicked
- (IBAction)widthClicked:(id)sender {
    self.widthSlider.hidden = NO;
    self.colors.hidden = YES;
    self.blackBtn.hidden = YES;
}
- (IBAction)colorClicked:(id)sender {
    self.widthSlider.hidden = YES;
    self.colors.hidden = NO;
    self.blackBtn.hidden = NO;
    
    [self getColor];
}
- (IBAction)toolsClicked:(id)sender {
    toolsExit = !toolsExit;
    
    if (toolsExit)
        [UIView animateWithDuration:0.5 animations:^{
            self.tools.frame = CGRectMake(WIDTH-50, HEIGHT/3.5, 60,350);
            [self getTool];
        }];
    else
        [UIView animateWithDuration:0.5 animations:^{
            self.tools.frame = CGRectMake(WIDTH+10, HEIGHT/3.5, 60,350);
        }];
}

#pragma mark - Get Draw State
// tool
-(void)getTool {
    [self.tools.pan addTarget:self action:@selector(getDrawStyle:) forControlEvents:UIControlEventTouchUpInside];
    [self.tools.line addTarget:self action:@selector(getDrawStyle:) forControlEvents:UIControlEventTouchUpInside];
    [self.tools.circle addTarget:self action:@selector(getDrawStyle:) forControlEvents:UIControlEventTouchUpInside];
    [self.tools.rectangle addTarget:self action:@selector(getDrawStyle:) forControlEvents:UIControlEventTouchUpInside];
    [self.tools.rubber addTarget:self action:@selector(getDrawStyle:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)getDrawStyle:(UIButton *)btn {
    for (UIButton *button in _toolsArr)
        button.backgroundColor = [UIColor clearColor];
    
    btn.backgroundColor = [UIColor lightGrayColor];
    btn.layer.cornerRadius = 3;
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%lu",btn.tag] forKey:@"styleTag"];
}
// width
- (IBAction)getWidth:(id)sender {
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",(int)self.widthSlider.value] forKey:@"lineWidth"];
}
// color
-(void)getColor {
//    __weak DrawBoardVC* weakself = self;
    self.colors.colBlock = ^(UIColor *col){
//        weakself.lineColor = col;
        
        [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%@",col] forKey:@"lineColor"];
    };
}
-(void)getBlackColor {
    [[NSUserDefaults standardUserDefaults]setObject:@"color 0 0 0 1" forKey:@"lineColor"];
}

@end
