//
//  UINavigationController+XPopControl.h
//  XPopControl
//
//  Created by xmt0615 on 16/3/14.
//  Copyright © 2016年 xmt0615. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL(^X_BOOLBlockNil)(void);
typedef void(^X_BlockNil)(void);

@interface UINavigationController (XPopControl)

/**
 *  侧滑手势 通过控制 enable 来达到是否可以侧滑
 */
@property (nonatomic ,retain ,readonly) UIPanGestureRecognizer *x_popGesture;

@end

@interface UIViewController (XPopControl)

@property (nonatomic ,assign) BOOL x_HookBackBarButton;
@property (nonatomic ,copy) X_BOOLBlockNil x_HookBarButtonCallBack;

@property (nonatomic ,assign) BOOL x_HookGesture;
@property (nonatomic ,copy) X_BlockNil x_HookGestureWannaBegin;

@end
