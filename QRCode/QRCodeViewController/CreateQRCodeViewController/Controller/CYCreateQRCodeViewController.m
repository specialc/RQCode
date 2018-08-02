//
//  CYCreateQRCodeViewController.m
//  QRCode
//
//  Created by dev on 2018/8/2.
//  Copyright © 2018年 chun. All rights reserved.
//

#import "CYCreateQRCodeViewController.h"
#import "CYQRCodeViewController.h"

@interface CYCreateQRCodeViewController () <CYCreateQRCodeContentViewDelegate>

@end

@implementation CYCreateQRCodeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = @"生成二维码";
    [self addSubviews];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = NO;
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in marr) {
        if ([vc isKindOfClass:[CYQRCodeViewController class]]) {
            [marr removeObject:vc];
            break;
        }
    }
    self.navigationController.viewControllers = marr;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

#pragma -- addSubviews

- (void)addSubviews {
    [self.view addSubview:self.contentView];
    
    self.contentView.qrImage = self.qrImage;
    self.contentView.qrString = self.qrString;
}

- (CYCreateQRCodeContentView *)contentView {
    if (!_contentView) {
        _contentView = [[CYCreateQRCodeContentView alloc] initWithFrame:self.view.bounds];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.delegate = self;
    }
    return _contentView;
}

#pragma mark -- CYCreateQRCodeContentViewDelegate

- (void)createQRCodeContentView:(CYCreateQRCodeContentView *)contentView viewDidTouch:(id)sender {
    if (sender == contentView.qrImageView) {
        [self didTapQrImageView:sender contentView:contentView];
    }
    else if (sender == contentView.urlLabel) {
        [self didTapUrlLabel:sender contentView:contentView];
    }
}

#pragma mark - TouchEvents

- (void)didTapQrImageView:(UIImageView *)sender contentView:(CYCreateQRCodeContentView *)contentView {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contentView.qrString]];
}

- (void)didTapUrlLabel:(UILabel *)sender contentView:(CYCreateQRCodeContentView *)contentView {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:contentView.qrString]];
}

#pragma mark - Setter

- (void)setQrImage:(UIImage *)qrImage {
    _qrImage = qrImage;
}

- (void)setQrString:(NSString *)qrString {
    _qrString = qrString;
}

#pragma mark - Warning

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
