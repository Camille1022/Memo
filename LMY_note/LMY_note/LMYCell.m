//
//  LMYCell.m
//  LMY_note
//
//  Created by apple on 16/4/25.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "LMYCell.h"

@implementation LMYCell

+(instancetype)LMYCell {
    return [[[NSBundle mainBundle]loadNibNamed:@"LMYCell" owner:nil options:nil]lastObject];
}

@end
