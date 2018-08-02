//
//  CYQRCodeContentView.h
//  testRQCode
//
//  Created by dev on 2018/6/22.
//  Copyright © 2018年 dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CYScanView.h"
#import "CYQRCodeManager.h"

@class CYQRCodeContentView;
@protocol CYQRCodeContentViewDelegate <NSObject>
- (void)qrCodeContentView:(CYQRCodeContentView *)contentView viewDidTouch:(id)sender;
- (void)qrCodeContentView:(CYQRCodeContentView *)contentView scanView:(CYScanView *)scanView viewDidTouch:(id)sender;

/** 扫描完成 **/
- (void)qrCodeContentView:(CYQRCodeContentView *)contentView qrCodeManager:(CYQRCodeManager *)qrCodeManager scanFinished:(NSString *)scanString;

@optional

@end

@interface CYQRCodeContentView : UIView
@property (nonatomic, weak) id<CYQRCodeContentViewDelegate> delegate;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *photoButton;
@property (nonatomic, strong) CYScanView *scanView;
@property (nonatomic, strong)  CYQRCodeManager * qrCodeManager;
@property (nonatomic, strong) UIView *preView;
@end
