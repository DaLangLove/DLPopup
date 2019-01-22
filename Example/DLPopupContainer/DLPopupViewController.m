//
//  DLPopupViewController.m
//  DLPopupContainer
//
//  Created by Dalang on 2019/1/22.
//  Copyright © 2019 Dalang. All rights reserved.
//

#import "DLPopupViewController.h"

#import "DLPopupView.h"

#import "DLPopupContainer.h"

@interface DLPopupViewController ()

@property (nonatomic, strong) DLPopupView *popupView;

@end

@implementation DLPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _popupView = [DLPopupView popupView];
}

- (IBAction)show:(id)sender {
    
    DLPopupContainer *container = [DLPopupContainer popupContainerWithContentView:_popupView
                                                                         showType:DLPopupContainerShowTypeFadeIn
                                                                      dismissType:DLPopupContainerDismissTypeFadeOut
                                                                         maskType:DLPopupContainerMaskTypeDimmed
                                                   shouldDismissOnBackgroundTouch:YES
                                                      shouldDismissOnContentTouch:NO];
    container.shouldHandleKeyboard = YES;
    
    [container setWillStartShowingBlock:^{
        NSLog(@"willStartShowing");
    }];
    
    [container setDidFinishShowingBlock:^{
        NSLog(@"didFinishShowing");
    }];
    
    [container setWillStartDismissingBlock:^{
        NSLog(@"willStartDismissing");
    }];
    
    [container setDidFinishDismissingBlock:^{
        NSLog(@"didFinishDismissing");
    }];
    
    [container showWithLayout:DLPopupContainerLayoutMake(DLPopupContainerHorizontalLayoutCenter, DLPopupContainerVerticalLayoutCenter)];
    
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
