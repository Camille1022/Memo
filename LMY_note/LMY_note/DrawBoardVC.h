//
//  DrawBoardVC.h
//  LMY_note
//
//  Created by sq-ios81 on 16/5/4.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DrawBoardView;

@interface DrawBoardVC : UIViewController

@property (weak, nonatomic) IBOutlet UISlider *widthSlider;

@property (weak, nonatomic) IBOutlet DrawBoardView *boardView;

@end
