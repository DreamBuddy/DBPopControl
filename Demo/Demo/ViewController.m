//
//  ViewController.m
//  Demo
//
//  Created by mt on 16/5/28.
//  Copyright © 2016年 X. All rights reserved.
//

#import "ViewController.h"

#import <objc/runtime.h>

#import "UINavigationController+XPopControl.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.title = @"XPopControl Demo";
    
    NSInteger count = self.navigationController.viewControllers.count;
    if (count > 1) {
        self.title = @(count).stringValue;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:pushButton];
    
    pushButton.frame = CGRectMake(0, 0, 100, 100);
    pushButton.center = self.view.center;
    
    [pushButton setTitle:@"pushButton" forState:UIControlStateNormal];
    [pushButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [pushButton addTarget:self action:sel_registerName("push") forControlEvents:UIControlEventAllEvents];
    
    __weak typeof(self) weakSelf = self;
    
    /**
     *  拦截 返回按钮
     */
    [self setX_HookBarButton:^{
        
        [weakSelf pop];
        
        return NO;
    }];
    
    /**
     *  拦截 手势
     */
    [self setX_HookGesture:^{
        
        [weakSelf pop];
        
        return NO;
    }];
}

-(void)pop{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"真的要离开吗?" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"是的" style:0 handler:^(UIAlertAction * _Nonnull action) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"不" style:0 handler:^(UIAlertAction * _Nonnull action) {
        
        
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)push{
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
