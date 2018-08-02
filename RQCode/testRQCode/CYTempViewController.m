//
//  CYTempViewController.m
//  testRQCode
//
//  Created by dev on 2018/6/29.
//  Copyright © 2018年 dev. All rights reserved.
//

#import "CYTempViewController.h"
#import "CYQRCodeViewController.h"

//#import <ZXingWidgetController.h>
//#import <QRCodeReader.h>

@interface CYTempViewController ()
@property (nonatomic, strong) UIButton *qrCodeButton;
@end

@implementation CYTempViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"二维码";
    // 细节: 本界面上设置, 下个界面上显示
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.qrCodeButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (UIButton *)qrCodeButton {
    if (!_qrCodeButton) {
        _qrCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _qrCodeButton.titleLabel.font = [UIFont systemFontOfSize:20];
        _qrCodeButton.frame = CGRectMake(0, 0, 150, 50);
        _qrCodeButton.center = CGPointMake(self.view.center.x, self.view.center.y);
        [_qrCodeButton setTitle:@"扫一扫" forState:UIControlStateNormal];
        _qrCodeButton.backgroundColor = [UIColor whiteColor];
        [_qrCodeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //关键语句
        _qrCodeButton.layer.cornerRadius = 2.0;//2.0是圆角的弧度，根据需求自己更改
        _qrCodeButton.layer.borderColor = [UIColor blackColor].CGColor;//设置边框颜色
        _qrCodeButton.layer.borderWidth = 1.0f;//设置边框颜色
        [_qrCodeButton addTarget:self action:@selector(didClickQRCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qrCodeButton;
}

- (void)didClickQRCodeButton:(UIButton *)sender {
    NSLog(@"didClickQRCodeButton");
    
    CYQRCodeViewController *qrCodeViewController = [[CYQRCodeViewController alloc] init];
    qrCodeViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:qrCodeViewController animated:YES];
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
