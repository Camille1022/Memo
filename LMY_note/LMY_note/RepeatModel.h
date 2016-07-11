//
//  RepeatModel.h
//  LMY_note
//
//  Created by sq-ios81 on 16/5/7.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RepeatModel : NSObject

// 模型属性
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *numbers;

// 字典转模型方法
-(instancetype)initWithDict:(NSDictionary *)dict;
+(instancetype)repeatModelWithDict:(NSDictionary *)dict;

@end
