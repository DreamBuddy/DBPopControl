//
//  UINavigationController+OJAOP.h
//  OpenJoySDK
//
//  Created by jiaying on 16/3/14.
//  Copyright © 2016年 imakejoy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL(^ONE_BoolBlockNil)(void);

@interface UINavigationController (BackBarButton)

//是否 拦截 返回键 的 action
@property (nonatomic ,assign) BOOL one_SwapBackBarButton;

@property (nonatomic ,copy) ONE_BoolBlockNil one_backBarButtonCallBack;

@end
