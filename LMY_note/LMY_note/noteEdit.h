//
//  noteEdit.h
//  毕设－多功能便签
//
//  Created by sq-ios81 on 16/4/7.
//  Copyright © 2016年 shangqian. All rights reserved.
//

// 编辑已存在的文本
#import <UIKit/UIKit.h>

@interface noteEdit : UIViewController<UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,copy) NSString *cText; // 对应 cell 文本内容
@property (nonatomic,copy) NSString *cDate; // 对应 cell 日期
@property (nonatomic,strong) NSData *cImgData; // 图片
@property (nonatomic, copy) NSString *remindStr;
@property (nonatomic, strong) NSDate *dateRemind;
@property (nonatomic, copy) NSString *repeatStr;
@property (nonatomic, strong)NSMutableDictionary *audioDict;

// 初始化方法
-(instancetype)initWithText:(NSString *)text;

@end
