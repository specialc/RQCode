//
//  CYBaseNavigationViewController.m
//  testRQCode
//
//  Created by dev on 2018/7/4.
//  Copyright © 2018年 dev. All rights reserved.
//

#import "CYBaseNavigationViewController.h"

@interface CYBaseNavigationViewController ()

@end

@implementation CYBaseNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
