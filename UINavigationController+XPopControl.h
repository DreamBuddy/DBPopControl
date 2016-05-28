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
 *  侧滑手势 (取代了系统默认的gesture)
 */
@property (nonatomic ,retain ,readonly) UIPanGestureRecognizer *x_popGesture;

@end

@interface UIViewController (XPopControl)

/**
 *  实现Block达到控制BackBarButton
 *  return 返回值 YES 允许 ， NO 不允许 在Block代码块中 设置 逻辑
 */
@property (nonatomic ,copy) X_BOOLBlockNil x_HookBarButton;

/**
 *  实现Block达到控制侧滑手势
 *  return 返回值 YES 允许 ， NO 不允许 在Block代码块中 设置 逻辑
 */
@property (nonatomic ,copy) X_BOOLBlockNil x_HookGesture;

/**
 *  设置 侧滑最大区域 (从左到右)
 */
@property (nonatomic, assign) CGFloat x_interactivePopMaxAllowedInitialDistanceToLeftEdge;

@end
