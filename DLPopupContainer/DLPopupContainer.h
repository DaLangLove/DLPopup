//
//  DLPopupContainer.h
//  Pods-DLPopupContainer
//
//  Created by Dalang on 2019/1/21.
//

#import <UIKit/UIKit.h>
#import "DLPopupContainerLayout.h"

// DLPopupContainerShowType
typedef NS_ENUM(NSInteger, DLPopupContainerShowType) {
    DLPopupContainerShowTypeNone = 0,
    DLPopupContainerShowTypeFadeIn,
    DLPopupContainerShowTypeGrowIn,
    DLPopupContainerShowTypeShrinkIn,
    DLPopupContainerShowTypeSlideInFromTop,
    DLPopupContainerShowTypeSlideInFromBottom,
    DLPopupContainerShowTypeSlideInFromLeft,
    DLPopupContainerShowTypeSlideInFromRight,
    DLPopupContainerShowTypeBounceIn,
    DLPopupContainerShowTypeBounceInFromTop,
    DLPopupContainerShowTypeBounceInFromBottom,
    DLPopupContainerShowTypeBounceInFromLeft,
    DLPopupContainerShowTypeBounceInFromRight,
};

// DLPopupContainerDismissType
typedef NS_ENUM(NSInteger, DLPopupContainerDismissType) {
    DLPopupContainerDismissTypeNone = 0,
    DLPopupContainerDismissTypeFadeOut,
    DLPopupContainerDismissTypeGrowOut,
    DLPopupContainerDismissTypeShrinkOut,
    DLPopupContainerDismissTypeSlideOutToTop,
    DLPopupContainerDismissTypeSlideOutToBottom,
    DLPopupContainerDismissTypeSlideOutToLeft,
    DLPopupContainerDismissTypeSlideOutToRight,
    DLPopupContainerDismissTypeBounceOut,
    DLPopupContainerDismissTypeBounceOutToTop,
    DLPopupContainerDismissTypeBounceOutToBottom,
    DLPopupContainerDismissTypeBounceOutToLeft,
    DLPopupContainerDismissTypeBounceOutToRight,
};


// DLPopupContainerMaskType
typedef NS_ENUM(NSInteger, DLPopupContainerMaskType) {
    DLPopupContainerMaskTypeNone = 0,
    DLPopupContainerMaskTypeClear,
    DLPopupContainerMaskTypeDimmed,
    DLPopupContainerMaskTypeLightBlur,
    DLPopupContainerMaskTypeDarkBlur,
};


NS_ASSUME_NONNULL_BEGIN

@interface DLPopupContainer : UIView

/**
 将要显示的 PopupView
 */
@property(nonatomic, strong) UIView *contentView;

/**
 显示动画类型 默认 DLPopupContainerShowTypeShrinkIn
 */
@property(nonatomic, assign) DLPopupContainerShowType showType;

/**
 隐藏动画类型 默认 DLPopupContainerDismissTypeShrinkOut
 */
@property(nonatomic, assign) DLPopupContainerDismissType dismissType;

/**
 背景类型 默认 DLPopupContainerMaskTypeDimmed
 */
@property(nonatomic, assign) DLPopupContainerMaskType maskType;

/**
 背景类型为DLPopupContainerMaskTypeDimmed时的的透明度 默认 0.5
 */
@property(nonatomic, assign) CGFloat dimmedMaskAlpha;

/**
 显示动画时间 默认0.5
 */
@property (nonatomic, assign) CGFloat showInDuration;

/**
 消失动画时间 默认0.5
 */
@property (nonatomic, assign) CGFloat dismissOutDuration;

/**
 点击背景是否消失，默认 YES
 */
@property(nonatomic, assign) BOOL shouldDismissOnBackgroundTouch;

/**
 点击 ContentView 是否消失 默认 NO
 */
@property(nonatomic, assign) BOOL shouldDismissOnContentTouch;

/**
 是否随键盘升降 默认 NO
 */
@property(nonatomic, assign) BOOL shouldHandleKeyboard;

/**
 将要显示的block
 */
@property (nonatomic, copy) void(^willStartShowingBlock)(void);

/**
 显示完成的block
 */
@property(nonatomic, copy) void (^didFinishShowingBlock)(void);

/**
 开始消失时的block
 */
@property(nonatomic, copy) void (^willStartDismissingBlock)(void);

/**
 消失完成的block
 */
@property(nonatomic, copy) void (^didFinishDismissingBlock)(void);

/**
 初始化
 
 @param contentView 要显示的View
 @return DLPopupContainer
 */
+ (instancetype)popupContainerWithContentView:(UIView *)contentView;

/**
 初始化
 
 @param contentView 要显示的View
 @param showType 显示动画类型
 @param dismissType 消失动画类型
 @param maskType 背景类型
 @param shouldDismissOnBackgroundTouch 点击背景是否小时
 @param shouldDismissOnContentTouch 点击contentView是否小时
 @return DLPopupContainer
 */
+ (instancetype)popupContainerWithContentView:(UIView *)contentView
                                     showType:(DLPopupContainerShowType)showType
                                  dismissType:(DLPopupContainerDismissType)dismissType
                                     maskType:(DLPopupContainerMaskType)maskType
               shouldDismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
                  shouldDismissOnContentTouch:(BOOL)shouldDismissOnContentTouch;

/**
 隐藏所有 DLPopupContainer
 */
+ (void)dismissAllPopups;


/**
 隐藏特定的ContentView

 @param view ContentView
 @param animated 是否显示动画
 */
+ (void)dismissPopupForView:(UIView *)view
                   animated:(BOOL)animated;


/**
 隐藏特定View内的DLPopupContainer

 @param view 特定view
 @param animated 是否显示动画
 */
+ (void)dismissSuperPopupIn:(UIView *)view
                   animated:(BOOL)animated;

/**
 Show
 */
- (void)show;

/**
 以特定布局显示
 
 @param layout 布局
 */
- (void)showWithLayout:(DLPopupContainerLayout *)layout;


/**
 显示特定时间后消失
 
 @param duration 时间
 */
- (void)showWithDuration:(NSTimeInterval)duration;

/**
 以特定布局显示特定时间后消失
 
 @param layout 布局
 @param duration 时间
 */
- (void)showWithLayout:(DLPopupContainerLayout *)layout
              duration:(NSTimeInterval)duration;

/**
 以特定布局显示View

 @param layout 布局
 @param view 特定view
 */
- (void)showWithLayout:(DLPopupContainerLayout *)layout
              inView:(UIView *)view;

/**
 在特定位置显示View
 
 @param center 特定位置
 @param view view
 */
- (void)showAtCenter:(CGPoint)center
              inView:(UIView *)view;


/**
 在特定位置使特定View显示特定时间后消失
 
 @param center 位置
 @param view View
 @param duration 时间
 */
- (void)showAtCenter:(CGPoint)center
              inView:(UIView *)view
        withDuration:(NSTimeInterval)duration;

/**
 消失
 
 @param animated 是否有消失动画
 */
- (void)dismissAnimated:(BOOL)animated;

#pragma mark - ReadOnly Properties
@property (nonatomic, strong, readonly) UIVisualEffectView *backgroundView;
@property (nonatomic, strong, readonly) UIView *containerView;
@property (nonatomic, assign, readonly) BOOL isBeingShown;
@property (nonatomic, assign, readonly) BOOL isShowing;
@property (nonatomic, assign, readonly) BOOL isBeingDismissed;


@end

NS_ASSUME_NONNULL_END
