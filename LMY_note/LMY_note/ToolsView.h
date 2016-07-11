//
//  ToolsView.h
//  LMY_note
//
//  Created by sq-ios81 on 16/5/5.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ToolsView : UIView

@property (weak, nonatomic) IBOutlet UIButton *pan;
@property (weak, nonatomic) IBOutlet UIButton *line;
@property (weak, nonatomic) IBOutlet UIButton *circle;
@property (weak, nonatomic) IBOutlet UIButton *rectangle;
@property (weak, nonatomic) IBOutlet UIButton *rubber;


+(instancetype)ToolsView;

@end


