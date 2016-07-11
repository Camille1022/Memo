//
//  LMYCell.h
//  LMY_note
//
//  Created by apple on 16/4/25.
//  Copyright © 2016年 lmy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LMYCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *textLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UIImageView *img1;
@property (weak, nonatomic) IBOutlet UIImageView *img2;
@property (weak, nonatomic) IBOutlet UIImageView *img3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftCons;

+(instancetype)LMYCell;

@end
