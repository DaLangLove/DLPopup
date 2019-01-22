//
//  UIView+DLPopupContainer.h
//  DLPopupContainer
//
//  Created by Dalang on 2019/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DLPopupContainer;
@interface UIView (DLPopupContainer)

- (void)forEachPopupDoBlock:(void (^)(DLPopupContainer *popup))block;

- (void)dismissPresentingPopupAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
