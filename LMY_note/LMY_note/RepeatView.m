//
//  RepeatView.m
//  LMY_note
//
//  Created by sq-ios81 on 16/5/7.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "RepeatView.h"
#import "RepeatModel.h"

@implementation RepeatView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        CGFloat repeatW = WIDTH*3/4;
        self.frame = CGRectMake((WIDTH-repeatW)/2, HEIGHT+5, repeatW, repeatW);
        self.layer.cornerRadius = repeatW/10;
        self.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1];
        
        UIPickerView *pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 20, repeatW, WIDTH/2)];
        [self addSubview:pickerView];
        pickerView.dataSource = self;
        pickerView.delegate = self;
        
        [self getdata];
        
        self.comfirm = [[UIButton alloc]initWithFrame:CGRectMake(repeatW/3, CGRectGetMaxY(pickerView.frame) + 5, repeatW/3, repeatW/10)];
        self.comfirm.titleLabel.font = [UIFont systemFontOfSize:20];
        [self.comfirm setTitle:@"confirm" forState:UIControlStateNormal];
        [self.comfirm setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.comfirm.showsTouchWhenHighlighted = YES;
        [self addSubview:self.comfirm];
    }
    return self;
}

-(void)getdata {
    self.nameSel = @"minute";
    self.numberSel = @"1";
    // 获取数据路径
    NSString *path = [[NSBundle mainBundle]pathForResource:@"repeatPlist.plist" ofType:nil];
    // 把数据转为数组
    NSArray *arr = [NSArray arrayWithContentsOfFile:path];
    
    self.names = [NSMutableArray arrayWithCapacity:arr.count];
    
    // 遍历数组中的每一个对象
    for (NSDictionary *dict in arr) {
        RepeatModel *model = [RepeatModel repeatModelWithDict:dict];
        // 把字典转模型之后的模型数据，添加到数组中
        [self.names addObject:model];
    }
}

-(void)comfirmRepeat {
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        CGFloat repeatW = WIDTH*3/4;
        self.frame = CGRectMake((WIDTH-repeatW)/2, HEIGHT+5, repeatW, repeatW);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - pickerView data source
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.names.count;
    } else {
        NSInteger index = [pickerView selectedRowInComponent:0];
        RepeatModel *model = self.names[index];
        return model.numbers.count;
    }
}

#pragma mark - pickerView delegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return [self.names[row] name];
    } else {
        RepeatModel *model = self.names[self.lastIndex];
        NSString *str = [NSString stringWithFormat:@"%@",model.numbers[row]];
        return str;
    }
}

// 选中某一行调用
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if(component == 0){
        self.lastIndex = [pickerView selectedRowInComponent:0];
        [pickerView reloadComponent:1];
    }
    
    RepeatModel *model = self.names[self.lastIndex];
    NSInteger cIndex = [pickerView selectedRowInComponent:1];
    self.nameSel = model.name;
    self.numberSel = [NSString stringWithFormat:@"%@",model.numbers[cIndex]];
}

@end
