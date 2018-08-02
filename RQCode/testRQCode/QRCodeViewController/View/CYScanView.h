//
//  CYScanView.h
//  testRQCode
//
//  Created by dev on 2018/6/22.
//  Copyright © 2018年 dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYScanView;
@protocol CYScanViewDelegate <NSObject>
- (void)scanView:(CYScanView *)contentView viewDidTouch:(id)sender;

@optional

@end

@interface CYScanView : UIView
@property (nonatomic, weak) id<CYScanViewDelegate> delegate;

#pragma mark - 扫码区域

/**
 扫码区域 默认为正方形,x = 75, y = 172
 */
@property (nonatomic,assign)CGRect scanRetangleRect;
/**
 @brief  是否需要绘制扫码矩形框，默认YES
 */
@property (nonatomic, assign) BOOL isNeedShowRetangle;
/**
 @brief  矩形框线条颜色
 */
@property (nonatomic, strong, nullable) UIColor *rectangleLineColor;
// 矩形框线条宽度
@property (nonatomic, assign) CGFloat rectangleLineWidth;

#pragma mark - 矩形框(扫码区域)周围4个角

//4个角的颜色
@property (nonatomic, strong, nullable) UIColor *scanAreaCornerColor;
//扫码区域4个角的宽度和高度 默认都为20
@property (nonatomic, assign) CGFloat scanAreaCornerWidth;
@property (nonatomic, assign) CGFloat scanAreaCornerHeight;
/**
 @brief  扫码区域4个角的线条宽度,默认6
 */
@property (nonatomic, assign) CGFloat scanAreaCornerLineWidth;

#pragma mark --动画效果

/**
 *  动画效果的图像
 */
@property (nonatomic,strong, nullable) UIImage * animationImage;
/**
 非识别区域颜色,默认 RGBA (0,0,0,0.5)
 */
@property (nonatomic, strong, nullable) UIColor *notIdentificationAreaColor;

// 我的二维码
@property (nonatomic, strong,) UIButton *myQRCodeButton;
//手电筒开关
@property(nonatomic,strong) UIButton * flashlightButton;
/**
 闪光灯开关的状态
 */
@property (nonatomic, assign) BOOL flashlightOpen;

/**
 *  开始扫描动画
 */
- (void)startScanAnimation;
/**
 *  结束扫描动画
 */
- (void)stopScanAnimation;

/**
 正在处理扫描到的结果
 */
- (void)handlingResultsOfScan;

/**
 完成扫描结果处理
 */
- (void)finishedHandle;


/**
 是否显示闪光灯开关
 @param show YES or NO
 */
- (void)showFlashlightButton:(BOOL)show;

@end
