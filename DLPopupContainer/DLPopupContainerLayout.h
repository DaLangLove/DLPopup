//
//  DLPopupContainerLayout.h
//  DLPopupContainer
//
//  Created by Dalang on 2019/1/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// DLPopupContainerHorizontalLayout
typedef NS_ENUM(NSInteger, DLPopupContainerHorizontalLayout) {
    DLPopupContainerHorizontalLayoutCustom = 0,
    DLPopupContainerHorizontalLayoutLeft,
    DLPopupContainerHorizontalLayoutLeftOfCenter,
    DLPopupContainerHorizontalLayoutCenter,
    DLPopupContainerHorizontalLayoutRightOfCenter,
    DLPopupContainerHorizontalLayoutRight,
};

// DLPopupContainerVerticalLayout
typedef NS_ENUM(NSInteger, DLPopupContainerVerticalLayout) {
    DLPopupContainerVerticalLayoutCustom = 0,
    DLPopupContainerVerticalLayoutTop,
    DLPopupContainerVerticalLayoutAboveCenter,
    DLPopupContainerVerticalLayoutCenter,
    DLPopupContainerVerticalLayoutBelowCenter,
    DLPopupContainerVerticalLayoutBottom,
};



@interface DLPopupContainerLayout : NSObject

/**
 水平方向的布局
 */
@property (nonatomic, assign) DLPopupContainerHorizontalLayout horizontalLayout;

/**
 水平方向的偏移量，horizontalOffset < 0，向左偏移，horizontalOffset > 0，向右偏移，
 */
@property (nonatomic, assign) CGFloat horizontalOffset;

/**
 垂直方向的布局
 */
@property (nonatomic, assign) DLPopupContainerVerticalLayout verticalLayout;

/**
 垂直方向的偏移量，verticalOffset < 0，向上偏移，verticalOffset > 0，向下偏移，
 */
@property (nonatomic, assign) CGFloat verticalOffset;

- (instancetype)initWithHorizontalLayout:(DLPopupContainerHorizontalLayout)horizontalLayout
                          verticalLayout:(DLPopupContainerVerticalLayout)verticalLayout;

- (instancetype)initWithHorizontalLayout:(DLPopupContainerHorizontalLayout)horizontalLayout
                        horizontalOffset:(CGFloat)horizontalOffset
                          verticalLayout:(DLPopupContainerVerticalLayout)verticalLayout
                          verticalOffset:(CGFloat)verticalOffset;

@end

DLPopupContainerLayout * DLPopupContainerLayoutMake(DLPopupContainerHorizontalLayout horizontal, DLPopupContainerVerticalLayout vertical);

DLPopupContainerLayout * DLPopupContainerLayoutCenter(void);


NS_ASSUME_NONNULL_END
