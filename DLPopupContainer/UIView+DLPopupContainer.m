//
//  UIView+DLPopupContainer.m
//  DLPopupContainer
//
//  Created by Dalang on 2019/1/22.
//

#import "UIView+DLPopupContainer.h"
#import "DLPopupContainer.h"

@implementation UIView (DLPopupContainer)


- (void)forEachPopupDoBlock:(void (^)(DLPopupContainer *popup))block
{
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[DLPopupContainer class]]) {
            block((DLPopupContainer *) subview);
        } else {
            [subview forEachPopupDoBlock:block];
        }
    }
}


- (void)dismissPresentingPopupAnimated:(BOOL)animated
{
    UIView *view = self;
    while (view != nil) {
        if ([view isKindOfClass:[DLPopupContainer class]]) {
            [(DLPopupContainer *) view dismissAnimated:animated];
            break;
        }
        view = view.superview;
    }
}


@end
