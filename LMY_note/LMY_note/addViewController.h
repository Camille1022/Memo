//
//  addViewController.h
//  毕设－多功能便签
//
//  Created by sq-ios81 on 16/4/7.
//  Copyright © 2016年 shangqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface addViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *noteText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topCons;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textToBotton;
@end
