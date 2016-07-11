//
//  remindTableViewController.m
//  LMY_note
//
//  Created by sq-ios81 on 16/4/15.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "remindTableViewController.h"
#import "RepeatView.h"


@interface remindTableViewController ()

@property (nonatomic, assign) int section;

@property (nonatomic, strong) RepeatView *repeatView;
@property (weak, nonatomic) IBOutlet UILabel *repeatStr;
@property (weak, nonatomic) IBOutlet UISwitch *idRepeat;
@property (nonatomic, copy) NSString *repeat;

@end

@implementation remindTableViewController
-(RepeatView *)repeatView {
    if (_repeatView == nil) {
        _repeatView = [RepeatView new];
    }
    return _repeatView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.repeat = @"0";
    [self.view addSubview:self.repeatView];
}

-(void)viewWillAppear:(BOOL)animated {
    // 将 remind 的开启状况传递过来显示
    NSString *str = [[NSUserDefaults standardUserDefaults]valueForKey:@"remind"];
    BOOL isOnRemind = str.boolValue;
    self.isRemind.on = isOnRemind;
    
    NSString *getRepeat = [[NSUserDefaults standardUserDefaults]valueForKey:@"repeat"];
    NSArray *arr = [getRepeat componentsSeparatedByString:@" "];
    NSString *state = arr[0];
    BOOL isOnRepeat = state.boolValue;
    self.idRepeat.on = isOnRepeat;
    
    if (arr.count == 2) {
        self.repeatStr.text = arr[1];
    } else {
        self.repeatStr.text = [NSString stringWithFormat:@"%@ %@",arr[1],arr[2]];
    }
}

- (IBAction)OKbtn:(id)sender {
    self.repeat = [NSString stringWithFormat:@"%@ %@",self.repeat,self.repeatStr.text];
    // block 传值
    if (self.block)
        self.block(self.isRemind.on,self.datePicker.date,self.repeat);
    
    // 代理传值
    if ([self.delegate respondsToSelector:@selector(remindDate:remind:repeat:)])
        [self.delegate remindDate:self.datePicker.date remind:self.isRemind.on repeat:self.repeat];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)isRepeatClicked:(UISwitch *)sender {
    if (self.idRepeat.on) {
        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
            CGFloat repeatW = WIDTH*3/4;
            self.repeatView.frame = CGRectMake(0, 0, repeatW, repeatW);
            self.repeatView.center = CGPointMake(WIDTH/2, HEIGHT*1/3);
            
            [self.repeatView.comfirm addTarget:self action:@selector(comfirmRepeat) forControlEvents:UIControlEventTouchUpInside];
        } completion:^(BOOL finished) {
            self.repeat = @"1";
        }];
    } else {
        [self comfirmRepeat];
        self.repeatStr.text = @"never";
        self.repeat = @"0";
    }
}

-(void)comfirmRepeat {
    self.repeatStr.text = [NSString stringWithFormat:@"%@ %@",self.repeatView.nameSel,self.repeatView.numberSel];
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        CGFloat repeatW = WIDTH*3/4;
        self.repeatView.frame = CGRectMake((WIDTH-repeatW)/2, HEIGHT+5, repeatW, repeatW);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


@end
