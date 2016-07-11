//
//  RepeatModel.m
//  LMY_note
//
//  Created by sq-ios81 on 16/5/7.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "RepeatModel.h"

@implementation RepeatModel

// 初始化方法
-(instancetype)initWithDict:(NSDictionary *)dict {
    // 字典转模型 -- 把对应的字典中的key的value值给模型中的属性字段
    if (self = [super init]) {
        self.name = dict[@"name"];
        self.numbers = dict[@"number"];
    }
    return self;
}

// 工厂方法
+(instancetype)repeatModelWithDict:(NSDictionary *)dict {
    return [[self alloc]initWithDict:dict];
}

@end
