//
//  UINavigationController+XPopControl.m
//  XPopControl
//
//  Created by xmt0615 on 16/3/14.
//  Copyright © 2016年 xmt0615. All rights reserved.
//

#import "UINavigationController+XPopControl.h"
#import <objc/runtime.h>

@interface X_PopGestureRecognizerDelegate : NSObject <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation X_PopGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
    /**
     *  感谢Sunny(GitHub孙源)大神, 作者参考 并 "移植"了一部分 FDFullscreenPopGesture的源码 制作了这个类
     *  在此给出大神的Git地址
     *  https://github.com/forkingdog
     */
    
    // Ignore when no view controller is pushed into the navigation stack.
    if (self.navigationController.viewControllers.count <= 1) {
        return NO;
    }
    
    UIViewController *topViewController = self.navigationController.viewControllers.lastObject;
    
    if (topViewController.x_HookGesture) {
        
        if (topViewController.x_HookGestureWannaBegin) {
            topViewController.x_HookGestureWannaBegin();
        }
        
        return NO;
    }
    
    // Ignore when the active view controller doesn't allow interactive pop.
    
//    if (topViewController.fd_interactivePopDisabled) {
//        return NO;
//    }
    
    // Ignore when the beginning location is beyond max allowed initial distance to left edge.
    CGPoint beginningLocation = [gestureRecognizer locationInView:gestureRecognizer.view];
    /**
     *  作者并没有实现 侧滑最大范围，若需要 可自行设置哦
     */
    CGFloat maxAllowedInitialDistance = 100;
    if (maxAllowedInitialDistance > 0 && beginningLocation.x > maxAllowedInitialDistance) {
        return NO;
    }
    
    // Ignore pan gesture when the navigation controller is currently in transition.
    if ([[self.navigationController valueForKey:@"_isTransitioning"] boolValue]) {
        return NO;
    }
    
    // Prevent calling the handler when the gesture begins in an opposite direction.
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    if (translation.x <= 0) {
        return NO;
    }
    
    return YES;
}

@end

@interface UINavigationController ()

@end

@implementation UINavigationController (XPopControl)

+(void)load{
    SEL seletors[] = {
        @selector(navigationBar:shouldPopItem:),
        @selector(pushViewController:animated:),
    };
    
    for (int i = 0; i < sizeof(seletors)/sizeof(SEL); i++) {
        SEL originalSeletor = seletors[i];
        SEL swizzledSeletor = NSSelectorFromString([@"x_" stringByAppendingString:NSStringFromSelector(originalSeletor)]);
        
        Method originMethod = class_getInstanceMethod([self class], originalSeletor);
        Method swizzledMethod = class_getInstanceMethod([self class], swizzledSeletor);
        
        method_exchangeImplementations(originMethod, swizzledMethod);
    }
}

-(void)setX_popGesture:(UIPanGestureRecognizer *)x_popGesture{
    objc_setAssociatedObject(self, @selector(x_popGesture), x_popGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIPanGestureRecognizer *)x_popGesture{
    UIPanGestureRecognizer *panGestureRecognizer = objc_getAssociatedObject(self, _cmd);
    
    if (!panGestureRecognizer) {
        panGestureRecognizer = [[UIPanGestureRecognizer alloc] init];
        panGestureRecognizer.maximumNumberOfTouches = 1;
        
        self.x_popGesture = panGestureRecognizer;
    }
    return panGestureRecognizer;
}

-(void)x_pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    if (![self.interactivePopGestureRecognizer.view.gestureRecognizers containsObject:self.x_popGesture]) {
        
        [self.interactivePopGestureRecognizer.view addGestureRecognizer:self.x_popGesture];
        NSArray *internalTargets = [self.interactivePopGestureRecognizer valueForKey:@"targets"];
        id internalTarget = [internalTargets.firstObject valueForKey:@"target"];
        SEL internalAction = NSSelectorFromString(@"handleNavigationTransition:");
        self.x_popGesture.delegate = self.X_PopGestureRecognizerDelegate;
        [self.x_popGesture addTarget:internalTarget action:internalAction];
        
    }
    
    self.interactivePopGestureRecognizer.enabled = NO;
    
    if (![self.viewControllers containsObject:viewController] && ![[self valueForKey:@"_isTransitioning"] boolValue]) {
        [self x_pushViewController:viewController animated:animated];
    }
}

- (X_PopGestureRecognizerDelegate *)X_PopGestureRecognizerDelegate
{
    X_PopGestureRecognizerDelegate *delegate = objc_getAssociatedObject(self, _cmd);
    
    if (!delegate) {
        delegate = [[X_PopGestureRecognizerDelegate alloc] init];
        delegate.navigationController = self;
        
        objc_setAssociatedObject(self, _cmd, delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return delegate;
}

-(BOOL)x_navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item{
    
    //防止 导航Bar  跟 Controller 切换 不协调的问题
//    if (self.viewControllers.count < navigationBar.items.count) {
//        return YES;
//    }
    
    UIViewController *topViewController = self.viewControllers.lastObject;
    
    if (topViewController.x_HookBackBarButton) {
        
        for(UIView *subview in [navigationBar subviews]) {
            if(subview.alpha < 1.) {
                [UIView animateWithDuration:.25 animations:^{
                    subview.alpha = 1.;
                }];
            }
        }
        
        if (topViewController.x_HookBarButtonCallBack) {
            BOOL result = topViewController.x_HookBarButtonCallBack();
            if (result) {
                return [self x_navigationBar:navigationBar shouldPopItem:item];
            }else{
                return result;
            }
        }
        
        return YES;
    }else{
        return [self x_navigationBar:navigationBar shouldPopItem:item];
    }
}

@end

@implementation UIViewController (XPopControl)

#pragma 管理BackBarButton的Action
-(BOOL)x_HookBackBarButton{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
-(void)setX_HookBackBarButton:(BOOL)x_HookBackBarButton{
    objc_setAssociatedObject(self, @selector(x_HookBackBarButton), @(x_HookBackBarButton), OBJC_ASSOCIATION_ASSIGN);
}

-(X_BOOLBlockNil)x_HookBarButtonCallBack{
    return objc_getAssociatedObject(self, _cmd);
}
-(void)setX_HookBarButtonCallBack:(X_BOOLBlockNil)x_HookBarButtonCallBack{
    objc_setAssociatedObject(self, @selector(x_HookBarButtonCallBack), x_HookBarButtonCallBack, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
#pragma 管理Gesture 的 Action
-(BOOL)x_HookGesture{
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}
-(void)setX_HookGesture:(BOOL)x_HookGesture{
    objc_setAssociatedObject(self, @selector(x_HookGesture), @(x_HookGesture), OBJC_ASSOCIATION_ASSIGN);
}

-(X_BlockNil)x_HookGestureWannaBegin{
    return objc_getAssociatedObject(self, _cmd);
}
-(void)setX_HookGestureWannaBegin:(X_BlockNil)x_HookGestureWannaBegin{
    objc_setAssociatedObject(self, @selector(x_HookGestureWannaBegin), x_HookGestureWannaBegin, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end