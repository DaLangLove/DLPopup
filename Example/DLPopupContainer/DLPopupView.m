//
//  DLPopupView.m
//  DLPopupContainer
//
//  Created by Dalang on 2019/1/22.
//  Copyright © 2019 Dalang. All rights reserved.
//

#import "DLPopupView.h"

@implementation DLPopupView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 10.0;
}

+ (instancetype)popupView
{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"DLPopupView" owner:nil options:nil];
    return array.firstObject;
}

@end
