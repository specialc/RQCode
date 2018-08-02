//
//  CYQRCodeContentView.m
//  QRCode
//
//  Created by dev on 2018/8/2.
//  Copyright © 2018年 chun. All rights reserved.
//

#import "CYQRCodeContentView.h"

@interface CYQRCodeContentView () <CYScanViewDelegate>

@end

@implementation CYQRCodeContentView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
    }
    return self;
}

#pragma mark - UI

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)addSubviews {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backButton];
    [self addSubview:self.photoButton];
    [self insertSubview:self.preView atIndex:0];
    [self insertSubview:self.scanView atIndex:1];
    
    [self addMasonry];
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_backButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        _backButton.contentMode = UIViewContentModeScaleAspectFit;
        //        [_backButton setImage:[[UIManager sharedInstance] imageNamed:@"Common/add"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(didClickBackButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)photoButton {
    if (!_photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_photoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_photoButton setTitle:@"相册" forState:UIControlStateNormal];
        _photoButton.contentMode = UIViewContentModeScaleAspectFit;
        //        [_photoButton setImage:[[UIManager sharedInstance] imageNamed:@"Common/add"] forState:UIControlStateNormal];
        [_photoButton addTarget:self action:@selector(didClickPhotoButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoButton;
}

- (UIView *)preView {
    if (!_preView) {
        _preView = [[UIView alloc] init];
        _preView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _preView.backgroundColor = [UIColor blackColor];
    }
    return _preView;
}

- (CYScanView *)scanView {
    if (!_scanView) {
        _scanView = [[CYScanView alloc] initWithFrame:self.bounds];
        _scanView.delegate = self;
        _scanView.scanRetangleRect = CGRectMake(60, 120, (self.frame.size.width - 2 * 60),  (self.frame.size.width - 2 * 60));
        _scanView.scanAreaCornerColor = [UIColor greenColor];
        _scanView.scanAreaCornerWidth = 20;
        _scanView.scanAreaCornerHeight = 20;
        _scanView.scanAreaCornerLineWidth = 2;
        _scanView.isNeedShowRetangle = YES;
        _scanView.rectangleLineColor = [UIColor whiteColor];
        _scanView.rectangleLineWidth = 2;
        _scanView.notIdentificationAreaColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _scanView.animationImage = [UIImage imageNamed:@"scanLine"];
    }
    return _scanView;
}

- (CYQRCodeManager *)qrCodeManager {
    if (!_qrCodeManager) {
        //初始化扫描工具
        _qrCodeManager = [[CYQRCodeManager alloc] initWithPreview:self.preView andScanFrame:_scanView.scanRetangleRect];
        @weakify(self);
        _qrCodeManager.scanFinishedBlock = ^(NSString *scanString) {
            @strongify(self);
            NSLog(@"扫描结果：\n%@",scanString);
            
            [self scanFinished:scanString];
        };
        _qrCodeManager.monitorLightBlock = ^(float brightness) {
            @strongify(self);
            NSLog(@"环境光感 ： %f",brightness);
            
            [self monitorLight:brightness];
        };
    }
    return _qrCodeManager;
}


#pragma mark - addMasonry

- (void)addMasonry {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(20);
        make.left.equalTo(self).offset(0);
        make.width.equalTo(44);
        make.height.equalTo(44);
    }];
    [self.photoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton.mas_centerY);
        make.right.equalTo(self).offset(0);
        make.width.equalTo(44);
        make.height.equalTo(44);
    }];
    //    [self.scanView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self);
    //        make.left.equalTo(self);
    //        make.bottom.equalTo(self);
    //        make.right.equalTo(self);
    //    }];
}

#pragma mark -- CYScanViewDelegate

- (void)scanView:(CYScanView *)contentView viewDidTouch:(id)sender {
    if (sender == contentView.myQRCodeButton) {
        [self didClickMyQRCodeButton:contentView.myQRCodeButton contentView:contentView];
    }
    else if (sender == contentView.flashlightButton) {
        [self didClickFlashlightButton:contentView.flashlightButton contentView:contentView];
    }
}

#pragma mark - TouchEvents

- (void)didClickBackButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(qrCodeContentView:viewDidTouch:)]) {
        [_delegate qrCodeContentView:self viewDidTouch:sender];
    }
}

- (void)didClickPhotoButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(qrCodeContentView:viewDidTouch:)]) {
        [_delegate qrCodeContentView:self viewDidTouch:sender];
    }
}

- (void)didClickMyQRCodeButton:(UIButton *)sender contentView:(CYScanView *)contentView{
    if ([_delegate respondsToSelector:@selector(qrCodeContentView:scanView:viewDidTouch:)]) {
        [_delegate qrCodeContentView:self scanView:contentView viewDidTouch:sender];
    }
}

- (void)didClickFlashlightButton:(UIButton *)sender contentView:(CYScanView *)contentView{
    if ([_delegate respondsToSelector:@selector(qrCodeContentView:scanView:viewDidTouch:)]) {
        [_delegate qrCodeContentView:self scanView:contentView viewDidTouch:sender];
    }
}

#pragma mark - Methods

- (void)scanFinished:(NSString *)scanString {
    if ([self.delegate respondsToSelector:@selector(qrCodeContentView:qrCodeManager:scanFinished:)]) {
        [self.delegate qrCodeContentView:self qrCodeManager:self.qrCodeManager scanFinished:scanString];
    }
}

- (void)monitorLight:(float)brightness {
    if (brightness <= 0) {
        // 环境太暗，显示闪光灯开关按钮
        [self.scanView showFlashlightButton:YES];
    }
    else {
        // 环境亮度可以,且闪光灯处于关闭状态时，隐藏闪光灯开关
        if(!self.qrCodeManager.flashlightOpen){
            [self.scanView showFlashlightButton:NO];
        }
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
