//
//  DLPopupContainer.m
//  Pods-DLPopupContainer
//
//  Created by Dalang on 2019/1/21.
//

#import "DLPopupContainer.h"
#import "UIView+DLPopupContainer.h"

static const CGFloat kDefaultSpringDamping = 0.8;
static const CGFloat kDefaultSpringVelocity = 10.0;
static const CGFloat kDefaultAnimateDuration = 0.5;
static const NSInteger kAnimationOptionCurve = (7 << 16);
static NSString *const kParametersViewName = @"parameters.view";
static NSString *const kParametersLayoutName = @"parameters.layout";
static NSString *const kParametersCenterName = @"parameters.center-point";
static NSString *const kParametersDurationName = @"parameters.duration";

@interface DLPopupContainer ()

@property (nonatomic, strong) UIVisualEffectView *backgroundView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isBeingShown;
@property (nonatomic, assign) BOOL isBeingDismissed;



@end

@implementation DLPopupContainer

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = UIColor.clearColor;
        self.alpha = 0.0;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.autoresizesSubviews = YES;
        
        self.shouldDismissOnBackgroundTouch = YES;
        self.shouldDismissOnContentTouch = NO;
        
        self.showType = DLPopupContainerShowTypeBounceInFromTop;
        self.dismissType = DLPopupContainerDismissTypeBounceOutToBottom;
        self.maskType = DLPopupContainerMaskTypeDimmed;
        self.dimmedMaskAlpha = 0.5;
        
        
        _isBeingShown = NO;
        _isShowing = NO;
        _isBeingDismissed = NO;
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.containerView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusbarOrientation:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    }
    return self;
}
#pragma mark - UIView hitTest
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        if (_shouldDismissOnBackgroundTouch) {
            [self dismissAnimated:YES];
        }
        return _maskType == DLPopupContainerMaskTypeNone ? nil : hitView;
    } else {
        if ([hitView isDescendantOfView:_containerView] && _shouldDismissOnContentTouch) {
            [self dismissAnimated:YES];
        }
        return hitView;
    }
}

#pragma mark - Public class methods
+ (instancetype)popupContainerWithContentView:(UIView *)contentView
{
    DLPopupContainer *popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    return popup;
}

+ (instancetype)popupContainerWithContentView:(UIView *)contentView
                                     showType:(DLPopupContainerShowType)showType
                                  dismissType:(DLPopupContainerDismissType)dismissType
                                     maskType:(DLPopupContainerMaskType)maskType
               shouldDismissOnBackgroundTouch:(BOOL)shouldDismissOnBackgroundTouch
                  shouldDismissOnContentTouch:(BOOL)shouldDismissOnContentTouch
{
    DLPopupContainer *popup = [[[self class] alloc] init];
    popup.contentView = contentView;
    popup.showType = showType;
    popup.dismissType = dismissType;
    popup.maskType = maskType;
    popup.shouldDismissOnBackgroundTouch = shouldDismissOnBackgroundTouch;
    popup.shouldDismissOnContentTouch = shouldDismissOnContentTouch;
    return popup;
}

+ (void)dismissAllPopups
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        [window forEachPopupDoBlock:^(DLPopupContainer *popup) {
            [popup dismissAnimated:NO];
        }];
    }
}

+ (void)dismissPopupForView:(UIView *)view animated:(BOOL)animated
{
    [view dismissPresentingPopupAnimated:animated];
}

+ (void)dismissSuperPopupIn:(UIView *)view animated:(BOOL)animated
{
    [view dismissPresentingPopupAnimated:animated];
}

#pragma mark - Public instance methods
- (void)show
{
    [self showWithLayout:DLPopupContainerLayoutCenter()];
}

- (void)showWithLayout:(DLPopupContainerLayout *)layout
{
    [self showWithLayout:layout duration:0.0];
}

- (void)showWithDuration:(NSTimeInterval)duration
{
    [self showWithLayout:DLPopupContainerLayoutCenter() duration:duration];
}

- (void)showWithLayout:(DLPopupContainerLayout *)layout duration:(NSTimeInterval)duration
{
    NSDictionary *parameters = @{
                                 kParametersLayoutName: layout,
                                 kParametersDurationName: @(duration)
                                 };
    [self showWithParameters:parameters];
}

- (void)showWithLayout:(DLPopupContainerLayout *)layout
                inView:(UIView *)view
{
    NSDictionary *parameters = @{
                                 kParametersLayoutName: layout,
                                 kParametersViewName: view
                                 };
    
    [self showWithParameters:parameters];
}

- (void)showAtCenter:(CGPoint)center inView:(UIView *)view
{
    [self showAtCenter:center inView:view withDuration:0.0];
}

- (void)showAtCenter:(CGPoint)center inView:(UIView *)view withDuration:(NSTimeInterval)duration
{
    NSDictionary *parameters = @{
                                 kParametersCenterName: [NSValue valueWithCGPoint:center],
                                 kParametersDurationName: @(duration),
                                 kParametersViewName: view
                                 };
    
    [self showWithParameters:parameters];
}

#pragma mark - Private Methods
- (void)showWithParameters:(NSDictionary *)parameters {
    if (!_isBeingShown && !_isShowing && !_isBeingDismissed) {
        _isBeingShown = YES;
        _isShowing = NO;
        _isBeingDismissed = NO;
        
        if (self.willStartShowingBlock != nil) {
            self.willStartShowingBlock();
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf.superview) {
                NSEnumerator *reverseWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
                for (UIWindow *window in reverseWindows) {
                    if (window.windowLevel == UIWindowLevelNormal) {
                        [window addSubview:self];
                        break;
                    }
                }
            }
            
            [strongSelf updateInterfaceOrientation];
            
            strongSelf.hidden = NO;
            strongSelf.alpha = 1.0;
            
            strongSelf.backgroundView.alpha = 0.0;
            switch (strongSelf.maskType) {
                case DLPopupContainerMaskTypeClear:
                    strongSelf.backgroundView.backgroundColor = UIColor.clearColor;
                    break;
                case DLPopupContainerMaskTypeDimmed:
                    strongSelf.backgroundView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:strongSelf.dimmedMaskAlpha];
                    break;
                case DLPopupContainerMaskTypeLightBlur:
                    strongSelf.backgroundView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                    break;
                case DLPopupContainerMaskTypeDarkBlur:
                    strongSelf.backgroundView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                    break;
                    
                default:
                    break;
            }
            
            
            void (^backgroundAnimationBlock)(void) = ^(void) {
                strongSelf.backgroundView.alpha = 1.0;
            };
            
            if (strongSelf.showType != DLPopupContainerShowTypeNone) {
                CGFloat showInDuration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                [UIView animateWithDuration:showInDuration
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:backgroundAnimationBlock
                                 completion:NULL];
            } else {
                backgroundAnimationBlock();
            }
            
            NSNumber *durationNumber = parameters[kParametersDurationName];
            NSTimeInterval duration = durationNumber != nil ? durationNumber.doubleValue : 0.0;
            
            void (^completionBlock)(BOOL) = ^(BOOL finished) {
                strongSelf.isBeingShown = NO;
                strongSelf.isShowing = YES;
                strongSelf.isBeingDismissed = NO;
                if (strongSelf.didFinishShowingBlock) {
                    strongSelf.didFinishShowingBlock();
                }
                if (duration > 0.0) {
                    [strongSelf performSelector:@selector(dismiss) withObject:nil afterDelay:duration];
                }
                
                if (strongSelf.shouldHandleKeyboard) {
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
                    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
                }
                
            };
            
            if (strongSelf.contentView.superview != strongSelf.containerView) {
                [strongSelf.containerView addSubview:strongSelf.contentView];
            }
            
            strongSelf.contentView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [strongSelf.contentView layoutIfNeeded];
            
            CGRect containerFrame = strongSelf.containerView.frame;
            containerFrame.size = strongSelf.contentView.frame.size;
            strongSelf.containerView.frame = containerFrame;
            
            CGRect contentFrame = strongSelf.contentView.frame;
            contentFrame.origin = CGPointZero;
            strongSelf.contentView.frame = contentFrame;
            
            UIView *contentView = strongSelf.contentView;
            NSDictionary *viewsDict = NSDictionaryOfVariableBindings(contentView);
            [strongSelf.containerView removeConstraints:strongSelf.containerView.constraints];
            [strongSelf.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:viewsDict]];
            [strongSelf.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:viewsDict]];
            
            CGRect finalContainerFrame = containerFrame;
            UIViewAutoresizing containerAutoresizingMask = UIViewAutoresizingNone;
            
            NSValue *centerValue = parameters[kParametersCenterName];
            if (centerValue) {
                CGPoint centerInView = centerValue.CGPointValue;
                CGPoint centerInSelf;
                UIView *fromView = parameters[kParametersViewName];
                centerInSelf = fromView != nil ? [self convertPoint:centerInView toView:fromView] : centerInView;
                finalContainerFrame.origin.x = centerInSelf.x - CGRectGetWidth(finalContainerFrame)*0.5;
                finalContainerFrame.origin.y = centerInSelf.y - CGRectGetHeight(finalContainerFrame)*0.5;
                containerAutoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
            } else {
                DLPopupContainerLayout *layout = parameters[kParametersLayoutName];
                if (layout == nil) {
                    layout = DLPopupContainerLayoutCenter();
                }
                switch (layout.horizontalLayout) {
                    case DLPopupContainerHorizontalLayoutLeft:
                        finalContainerFrame.origin.x = 0.0 + layout.horizontalOffset;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    case DLPopupContainerHorizontalLayoutRight:
                        finalContainerFrame.origin.x = CGRectGetWidth(strongSelf.bounds) - CGRectGetWidth(containerFrame) + layout.horizontalOffset;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin;
                        break;
                    case DLPopupContainerHorizontalLayoutLeftOfCenter:
                        finalContainerFrame.origin.x = floorf(CGRectGetWidth(strongSelf.bounds) / 3.0 - CGRectGetWidth(containerFrame) * 0.5) + layout.horizontalOffset;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    case DLPopupContainerHorizontalLayoutRightOfCenter:
                        finalContainerFrame.origin.x = floorf(CGRectGetWidth(strongSelf.bounds) * 2.0 / 3.0 - CGRectGetWidth(containerFrame) * 0.5) + layout.horizontalOffset;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    case DLPopupContainerHorizontalLayoutCenter:
                        finalContainerFrame.origin.x = floorf((CGRectGetWidth(strongSelf.bounds) - CGRectGetWidth(containerFrame)) * 0.5) + layout.horizontalOffset;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                        break;
                    default:
                        break;
                }
                
                switch (layout.verticalLayout) {
                    case DLPopupContainerVerticalLayoutTop:
                        finalContainerFrame.origin.y = 0.0 + layout.verticalOffset;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case DLPopupContainerVerticalLayoutAboveCenter:
                        finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds) / 3.0 - CGRectGetHeight(containerFrame) * 0.5) + layout.verticalOffset;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case DLPopupContainerVerticalLayoutCenter:
                        finalContainerFrame.origin.y = floorf((CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame)) * 0.5) + layout.verticalOffset;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case DLPopupContainerVerticalLayoutBelowCenter:
                        finalContainerFrame.origin.y = floorf(CGRectGetHeight(self.bounds) * 2.0 / 3.0 - CGRectGetHeight(containerFrame) * 0.5) + layout.verticalOffset;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
                        break;
                    case DLPopupContainerVerticalLayoutBottom:
                        finalContainerFrame.origin.y = CGRectGetHeight(self.bounds) - CGRectGetHeight(containerFrame) + layout.verticalOffset;
                        containerAutoresizingMask = containerAutoresizingMask | UIViewAutoresizingFlexibleTopMargin;
                        break;
                    default:
                        break;
                }
            }
            
            strongSelf.containerView.autoresizingMask = containerAutoresizingMask;
            
            switch (strongSelf.showType) {
                case DLPopupContainerShowTypeFadeIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    strongSelf.containerView.frame = finalContainerFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                        strongSelf.containerView.alpha = 1.0;
                    } completion:completionBlock];
                }   break;
                case DLPopupContainerShowTypeGrowIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformMakeScale(0.85, 0.85);
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.alpha = 1.0;
                        strongSelf.containerView.transform = CGAffineTransformIdentity;
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case DLPopupContainerShowTypeShrinkIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.alpha = 1.0;
                        strongSelf.containerView.transform = CGAffineTransformIdentity;
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case DLPopupContainerShowTypeSlideInFromTop: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = - CGRectGetHeight(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case DLPopupContainerShowTypeSlideInFromBottom: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = CGRectGetHeight(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case DLPopupContainerShowTypeSlideInFromLeft: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = - CGRectGetWidth(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kAnimationOptionCurve animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case DLPopupContainerShowTypeSlideInFromRight: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = CGRectGetWidth(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 options:kDefaultAnimateDuration animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case DLPopupContainerShowTypeBounceIn: {
                    strongSelf.containerView.alpha = 0.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.alpha = 1.0;
                        strongSelf.containerView.transform = CGAffineTransformIdentity;
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case DLPopupContainerShowTypeBounceInFromTop: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = - CGRectGetHeight(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case DLPopupContainerShowTypeBounceInFromBottom: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.y = CGRectGetHeight(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case DLPopupContainerShowTypeBounceInFromLeft: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = - CGRectGetWidth(finalContainerFrame);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                case DLPopupContainerShowTypeBounceInFromRight: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    CGRect startFrame = finalContainerFrame;
                    startFrame.origin.x = CGRectGetWidth(self.bounds);
                    strongSelf.containerView.frame = startFrame;
                    CGFloat duration = strongSelf.showInDuration ?: kDefaultAnimateDuration;
                    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:kDefaultSpringDamping initialSpringVelocity:kDefaultSpringVelocity options:0 animations:^{
                        strongSelf.containerView.frame = finalContainerFrame;
                    } completion:completionBlock];
                }   break;
                default: {
                    strongSelf.containerView.alpha = 1.0;
                    strongSelf.containerView.frame = finalContainerFrame;
                    strongSelf.containerView.transform = CGAffineTransformIdentity;
                    completionBlock(YES);
                }   break;
            }
        });
    }
}

- (void)dismissAnimated:(BOOL)animated
{
    if (_isShowing && !_isBeingDismissed) {
        _isShowing = NO;
        _isBeingShown = NO;
        _isBeingDismissed = YES;
        
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismissAnimated:) object:nil];
        
        if (self.willStartDismissingBlock) {
            self.willStartDismissingBlock();
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(weakSelf) strongSelf = self;
            void (^backgroundAnimationBlock)(void) = ^(void) {
                strongSelf.backgroundView.alpha = 0.0;
            };
            
            if (animated && strongSelf.showType != DLPopupContainerShowTypeNone) {
                CGFloat duration = strongSelf.dismissOutDuration ?: kDefaultAnimateDuration;
                [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:backgroundAnimationBlock completion:NULL];
            } else {
                backgroundAnimationBlock();
            }
            
            void (^completionBlock)(BOOL) = ^(BOOL finished) {
                [strongSelf removeFromSuperview];
                strongSelf.isBeingShown = NO;
                strongSelf.isShowing = NO;
                strongSelf.isBeingDismissed = NO;
                if (strongSelf.didFinishDismissingBlock) {
                    strongSelf.didFinishDismissingBlock();
                }
            };
            
            NSTimeInterval duration = strongSelf.dismissOutDuration ?: kDefaultAnimateDuration;
            NSTimeInterval bounceDurationA = duration * 1.0 / 3.0;
            NSTimeInterval bounceDurationB = duration * 2.0 / 3.0;
            
            if (strongSelf.shouldHandleKeyboard) {
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
            }
            
            if (animated) {
                NSTimeInterval dismissOutDuration = strongSelf.dismissOutDuration ?: kDefaultAnimateDuration;
                switch (strongSelf.dismissType) {
                    case DLPopupContainerDismissTypeFadeOut: {
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                            strongSelf.containerView.alpha = 0.0;
                        } completion:completionBlock];
                    }   break;
                    case DLPopupContainerDismissTypeGrowOut: {
                        [UIView animateKeyframesWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.alpha = 0.0;
                            strongSelf.containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                        } completion:completionBlock];
                    }   break;
                    case DLPopupContainerDismissTypeShrinkOut: {
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.alpha = 0.0;
                            strongSelf.containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
                        } completion:completionBlock];
                    }   break;
                    case DLPopupContainerDismissTypeSlideOutToTop: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.y = - CGRectGetHeight(finalFrame);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case DLPopupContainerDismissTypeSlideOutToBottom: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.y = CGRectGetHeight(strongSelf.bounds);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case DLPopupContainerDismissTypeSlideOutToLeft: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.x = - CGRectGetWidth(finalFrame);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case DLPopupContainerDismissTypeSlideOutToRight: {
                        CGRect finalFrame = strongSelf.containerView.frame;
                        finalFrame.origin.x = CGRectGetWidth(strongSelf.bounds);
                        [UIView animateWithDuration:dismissOutDuration delay:0.0 options:kAnimationOptionCurve animations:^{
                            strongSelf.containerView.frame = finalFrame;
                        } completion:completionBlock];
                    }   break;
                    case DLPopupContainerDismissTypeBounceOut: {
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.transform = CGAffineTransformMakeScale(1.1, 1.1);
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.alpha = 0.0;
                                strongSelf.containerView.transform = CGAffineTransformMakeScale(0.1, 0.1);
                            } completion:completionBlock];
                        }];
                    }   break;
                    case DLPopupContainerDismissTypeBounceOutToTop: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.y += 20.0;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.y = - CGRectGetHeight(finalFrameB);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    case DLPopupContainerDismissTypeBounceOutToBottom: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.y -= 20;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.y = CGRectGetHeight(self.bounds);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    case DLPopupContainerDismissTypeBounceOutToLeft: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.x += 20.0;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.x = - CGRectGetWidth(finalFrameB);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    case DLPopupContainerDismissTypeBounceOutToRight: {
                        CGRect finalFrameA = strongSelf.containerView.frame;
                        finalFrameA.origin.x -= 20.0;
                        CGRect finalFrameB = strongSelf.containerView.frame;
                        finalFrameB.origin.x = CGRectGetWidth(strongSelf.bounds);
                        [UIView animateWithDuration:bounceDurationA delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                            strongSelf.containerView.frame = finalFrameA;
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:bounceDurationB delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                                strongSelf.containerView.frame = finalFrameB;
                            } completion:completionBlock];
                        }];
                    }   break;
                    default: {
                        strongSelf.containerView.alpha = 0.0;
                        completionBlock(YES);
                    }   break;
                }
            } else {
                strongSelf.containerView.alpha = 0.0;
                completionBlock(YES);
            }
        });
    }
}

- (void)didChangeStatusbarOrientation:(NSNotification *)notification
{
    [self updateInterfaceOrientation];
}

- (void)updateInterfaceOrientation
{
    self.frame = self.window.bounds;
}

- (void)dismiss
{
    [self dismissAnimated:YES];
}


- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    [self moveContainerViewForKeyboard:notification up:YES];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    [self moveContainerViewForKeyboard:notification up:NO];
}

- (void)moveContainerViewForKeyboard:(NSNotification *)notification up:(BOOL)up
{
    NSDictionary *userInfo = notification.userInfo;
    NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve animationCurve = (UIViewAnimationCurve) [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    CGRect keyboardEndFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    self.containerView.center = CGPointMake(self.containerView.superview.frame.size.width / 2, self.containerView.superview.frame.size.height / 2);
    CGRect frame = self.containerView.frame;
    if (up) {
        frame.origin.y -= keyboardEndFrame.size.height / 2;
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    self.containerView.frame = frame;
    [UIView commitAnimations];
}


#pragma mark - Properties

- (UIVisualEffectView *)backgroundView
{
    if (!_backgroundView) {
        _backgroundView = [[UIVisualEffectView alloc] initWithEffect:nil];
        _backgroundView.backgroundColor = UIColor.clearColor;
        _backgroundView.userInteractionEnabled = NO;
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _backgroundView.frame = self.bounds;
    }
    return _backgroundView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.autoresizesSubviews = NO;
        _containerView.userInteractionEnabled = YES;
        _containerView.backgroundColor = UIColor.clearColor;
    }
    return _containerView;
}



@end
