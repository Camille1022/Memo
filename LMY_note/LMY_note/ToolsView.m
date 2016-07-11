//
//  ToolsView.m
//  LMY_note
//
//  Created by sq-ios81 on 16/5/5.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import "ToolsView.h"

@interface ToolsView ()

@end

@implementation ToolsView

+(instancetype)ToolsView {
    return [[[NSBundle mainBundle]loadNibNamed:@"ToolsView" owner:nil options:nil]lastObject];
}


@end
