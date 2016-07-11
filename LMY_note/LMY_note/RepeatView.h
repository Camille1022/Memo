//
//  RepeatView.h
//  LMY_note
//
//  Created by sq-ios81 on 16/5/7.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface RepeatView : UIView
                        <UIPickerViewDelegate,UIPickerViewDataSource>

// 用于保存字典转模型的所有数据
@property (nonatomic, strong) NSMutableArray *names;

@property (nonatomic, assign) NSInteger lastIndex;

@property (nonatomic, copy) NSString *numberSel;
@property (nonatomic, copy) NSString *nameSel;

@property (nonatomic, strong) UIButton *comfirm;

@end
