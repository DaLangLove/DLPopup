//
//  DLPopupContainerLayout.m
//  DLPopupContainer
//
//  Created by Dalang on 2019/1/21.
//

#import "DLPopupContainerLayout.h"

@implementation DLPopupContainerLayout

- (instancetype)initWithHorizontalLayout:(DLPopupContainerHorizontalLayout)horizontalLayout
                          verticalLayout:(DLPopupContainerVerticalLayout)verticalLayout
{
    self = [super init];
    if (self) {
        _horizontalLayout = horizontalLayout;
        _horizontalOffset = 0;
        _verticalLayout = verticalLayout;
        _verticalOffset = 0;
    }
    return self;
}

- (instancetype)initWithHorizontalLayout:(DLPopupContainerHorizontalLayout)horizontalLayout
                        horizontalOffset:(CGFloat)horizontalOffset
                          verticalLayout:(DLPopupContainerVerticalLayout)verticalLayout
                          verticalOffset:(CGFloat)verticalOffset
{
    self = [super init];
    if (self) {
        _horizontalLayout = horizontalLayout;
        _horizontalOffset = horizontalOffset;
        _verticalLayout = verticalLayout;
        _verticalOffset = verticalOffset;
    }
    return self;
}

@end

DLPopupContainerLayout * DLPopupContainerLayoutMake(DLPopupContainerHorizontalLayout horizontal, DLPopupContainerVerticalLayout vertical) {
    return [[DLPopupContainerLayout alloc] initWithHorizontalLayout:horizontal verticalLayout:vertical];
}

DLPopupContainerLayout * DLPopupContainerLayoutCenter(void) {
    
    return DLPopupContainerLayoutMake(DLPopupContainerHorizontalLayoutCenter, DLPopupContainerVerticalLayoutCenter);
}
