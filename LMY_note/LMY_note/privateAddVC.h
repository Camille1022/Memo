//
//  privateAddVC.h
//  毕设－多功能便签
//
//  Created by sq-ios81 on 16/4/8.
//  Copyright © 2016年 shangqian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface privateAddVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *privateNote;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topCons;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textToBotton;
@end
