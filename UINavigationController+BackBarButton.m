//
//  UINavigationController+OJAOP.m
//  OpenJoySDK
//
//  Created by jiaying on 16/3/14.
//  Copyright © 2016年 imakejoy. All rights reserved.
//

#import "UINavigationController+BackBarButton.h"
#import <objc/runtime.h>

@interface UINavigationController ()

@end

static const char one_SwapBackBarButtonKey;

static const char one_backBarButtonCallBackKey;

@implementation UINavigationController (BackBarButton)

-(void)setOne_backBarButtonCallBack:(ONE_BoolBlockNil)one_backBarButtonCallBack{
    objc_setAssociatedObject(self, &one_backBarButtonCallBackKey, one_backBarButtonCallBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(ONE_BoolBlockNil)one_backBarButtonCallBack{
    return objc_getAssociatedObject(self, &one_backBarButtonCallBackKey);
}

-(void)setOne_SwapBackBarButton:(BOOL)one_SwapBackBarButton{
    objc_setAssociatedObject(self, &one_SwapBackBarButtonKey, @(one_SwapBackBarButton), OBJC_ASSOCIATION_ASSIGN);
}

-(BOOL)one_SwapBackBarButton{
    return [objc_getAssociatedObject(self, &one_SwapBackBarButtonKey) boolValue];
}

+(void)load{
    [self exchangeMethordOld:@selector(navigationBar:shouldPopItem:) New:@selector(one_navigationBar:shouldPopItem:)];
    
    [self exchangeMethordOld:@selector(pushViewController:animated:) New:@selector(one_pushViewController:animated:)];
}

-(void)one_pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    self.one_SwapBackBarButton = NO;
    
    [self one_pushViewController:viewController animated:animated];
}


-(BOOL)one_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    if (self.one_SwapBackBarButton) {
        // && [self.topViewController isKindOfClass:NSClassFromString(@"OJSDKViewController")]
        
        for(UIView *subview in [navigationBar subviews]) {
            if(subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
        
        if (self.one_backBarButtonCallBack) {
            BOOL result = self.one_backBarButtonCallBack();
            if (result) {
                
                self.one_SwapBackBarButton = NO;
                
                return [self one_navigationBar:navigationBar shouldPopItem:item];
            }else{
                return result;
            }
        }
        
        return NO;
    }else{
        self.one_SwapBackBarButton = NO;
        
        return [self one_navigationBar:navigationBar shouldPopItem:item];
    }
}

@end
