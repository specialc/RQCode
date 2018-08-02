//
//  CYScanView.m
//  QRCode
//
//  Created by dev on 2018/8/2.
//  Copyright © 2018年 chun. All rights reserved.
//

#import "CYScanView.h"

@interface CYScanView ()

// 扫描显示区view
@property (nonatomic, strong) UIView *scanBackgroundView;
// 动画线条
@property (nonatomic,strong) UIImageView *scanBgAnimationImageView;
// 是否正在动画
@property(nonatomic,assign) BOOL isAnimating;
// 中部透明view
@property (nonatomic, strong) UIView *guiderView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
// 四个角view
@property (nonatomic, strong) UIView *scanCornerLineView;
@property (nonatomic, strong) CAShapeLayer *cornerLineLayer;

//网络状态提示语
@property (nonatomic,strong) UILabel * netLabel;
// 扫描方法提示
@property (nonatomic,strong) UILabel * scanMethodTipLabel;
// 菊花等待
@property(nonatomic,strong) UIActivityIndicatorView *activityView;
// 扫描结果处理中
@property(nonatomic,strong) UIView *handlingView;
// 正在处理提示
@property(nonatomic,strong) UILabel *handlingLabel;
@end

@implementation CYScanView

@synthesize animationImage = _animationImage;

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self stopScanAnimation];
        [self finishedHandle];
        [self removeObservers];
    }
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initConfigure];
        [self addSubviews];
        [self addObservers];
    }
    return self;
}

- (void)initConfigure {
    self.isNeedShowRetangle = YES;
    self.scanRetangleRect = CGRectMake(60, 100, self.frame.size.width - 2 * 60, self.frame.size.width - 2 * 60);
    self.rectangleLineWidth = 2;
    self.scanAreaCornerLineWidth = 6;
    self.scanAreaCornerWidth = 20;
    self.scanAreaCornerHeight = 20;
    self.scanAreaCornerColor = [UIColor greenColor];
    self.rectangleLineColor = [UIColor whiteColor];
    self.notIdentificationAreaColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    //    [self drawScanRect];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self reloadShapeLayer];
}

#pragma mark - UI

- (void)addSubviews {
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.guiderView];
    self.guiderView.layer.mask = self.shapeLayer;
    [self.guiderView.layer addSublayer:self.borderLayer];
    
    [self addSubview:self.scanBackgroundView];
    [self.scanBackgroundView addSubview:self.scanBgAnimationImageView];
    
    [self addSubview:self.scanCornerLineView];
    [self.scanCornerLineView.layer addSublayer:self.cornerLineLayer];
    
    [self addSubview:self.scanMethodTipLabel];
    [self addSubview:self.myQRCodeButton];
    [self addSubview:self.flashlightButton];
    
    [self addSubview:self.handlingView];
    [self.handlingView addSubview:self.activityView];
    [self.handlingView addSubview:self.handlingLabel];
}

- (UIView *)scanBackgroundView {
    if (!_scanBackgroundView) {
        _scanBackgroundView = [[UIView alloc] init];
        _scanBackgroundView.clipsToBounds = YES;
    }
    return _scanBackgroundView;
}

- (UIView *)scanCornerLineView {
    if (!_scanCornerLineView) {
        _scanCornerLineView = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _scanCornerLineView;
}

- (UIImageView *)scanBgAnimationImageView {
    if (!_scanBgAnimationImageView) {
        //        _scanBgAnimationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.scanRetangleRect.origin.x, self.scanRetangleRect.origin.y, self.scanRetangleRect.size.width, 4)];
        _scanBgAnimationImageView = [[UIImageView alloc] init];
        _scanBgAnimationImageView.image = self.animationImage;
        _scanBgAnimationImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _scanBgAnimationImageView;
}

- (UILabel *)scanMethodTipLabel {
    if (!_scanMethodTipLabel) {
        //        _scanMethodTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.scanRetangleRect.origin.y + self.scanRetangleRect.size.height + 10, self.frame.size.width, 20)];
        _scanMethodTipLabel = [[UILabel alloc] init];
        _scanMethodTipLabel.font = [UIFont systemFontOfSize:12];
        _scanMethodTipLabel.textAlignment = NSTextAlignmentCenter;
        _scanMethodTipLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        _scanMethodTipLabel.text = @"将二维码/条码放入框内，即可自动扫描";
    }
    return _scanMethodTipLabel;
}

- (UIButton *)myQRCodeButton {
    if (!_myQRCodeButton) {
        //        _myQRCodeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.scanRetangleRect.origin.y + self.scanRetangleRect.size.height + 10 + 20 + 10, self.frame.size.width, 20)];
        _myQRCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _myQRCodeButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_myQRCodeButton setTitle:@"我的二维码" forState:UIControlStateNormal];
        [_myQRCodeButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_myQRCodeButton addTarget:self action:@selector(didClickMyQRCodeButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _myQRCodeButton;
}

//正在处理视图
- (UIView *)handlingView {
    if (!_handlingView) {
        //        _handlingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scanRetangleRect.size.width, 40 + 40)];
        _handlingView = [[UIView alloc] init];
        _handlingView.hidden = YES;
    }
    return _handlingView;
}

// 加载中指示器
- (UIActivityIndicatorView *)activityView {
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [_activityView startAnimating];
    }
    return _activityView;
}

- (UILabel *)handlingLabel {
    if (!_handlingLabel) {
        _handlingLabel = [[UILabel alloc] init];
        _handlingLabel.font = [UIFont systemFontOfSize:12];
        _handlingLabel.textAlignment = NSTextAlignmentCenter;
        _handlingLabel.textColor = [UIColor whiteColor];
        _handlingLabel.text = @"正在处理...";
    }
    return _handlingLabel;
}

- (UIButton *)flashlightButton {
    if (!_flashlightButton) {
        //        _flashlightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _flashlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_flashlightButton setImage:[UIImage imageNamed:@"scanFlashlight"] forState:UIControlStateNormal];
        [_flashlightButton addTarget:self action:@selector(didClickFlashlightButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _flashlightButton;
}

- (UIView *)guiderView {
    if (!_guiderView) {
        _guiderView = [[UIView alloc] initWithFrame:self.bounds];
        _guiderView.backgroundColor = self.notIdentificationAreaColor;
    }
    return _guiderView;
}

- (CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
    }
    return _shapeLayer;
}

- (CAShapeLayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
        _borderLayer.strokeColor = [UIColor whiteColor].CGColor;
        _borderLayer.lineWidth = 2;
    }
    return _borderLayer;
}

- (CAShapeLayer *)cornerLineLayer {
    if (!_cornerLineLayer) {
        _cornerLineLayer = [CAShapeLayer layer];
        _cornerLineLayer.strokeColor = self.scanAreaCornerColor.CGColor;
        _cornerLineLayer.fillColor  = nil;   //  默认是black
        _cornerLineLayer.lineWidth = self.scanAreaCornerLineWidth;
    }
    return _cornerLineLayer;
}
#pragma mark -- TouchEvents

// 我的二维码：点击事件
- (void)didClickMyQRCodeButton:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(scanView:viewDidTouch:)]) {
        [_delegate scanView:self viewDidTouch:sender];
    }
}

// 打开/关闭闪光灯：点击事件
- (void)didClickFlashlightButton:(UIButton *)sender{
    if ([_delegate respondsToSelector:@selector(scanView:viewDidTouch:)]) {
        [_delegate scanView:self viewDidTouch:sender];
    }
}

#pragma mark - Method

- (void)reloadShapeLayer {
    // 挖空内部
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:self.guiderView.bounds];
    [bezierPath appendPath:[[UIBezierPath bezierPathWithRect:self.scanRetangleRect] bezierPathByReversingPath]];
    self.shapeLayer.path = bezierPath.CGPath;
    
    // 边部白线，内部透明（clearColor）
    UIBezierPath *borderBezierPath = [[UIBezierPath alloc] init];
    [borderBezierPath appendPath:[[UIBezierPath bezierPathWithRect:self.scanRetangleRect] bezierPathByReversingPath]];
    self.borderLayer.path = borderBezierPath.CGPath;
    self.borderLayer.frame = CGRectMake(0, 0, self.scanRetangleRect.size.width, self.scanRetangleRect.size.height);
    
    // 边角
    UIBezierPath *linePath = [[UIBezierPath alloc] init];
    CGFloat originDistance = self.scanAreaCornerLineWidth / 2 - self.rectangleLineWidth / 2;
    CGFloat leftX = self.scanRetangleRect.origin.x + originDistance;
    CGFloat topY = self.scanRetangleRect.origin.y + originDistance;
    CGFloat bottomY = self.scanRetangleRect.origin.y + self.scanRetangleRect.size.height - originDistance;
    CGFloat rightX = self.scanRetangleRect.origin.x + self.scanRetangleRect.size.width - originDistance;
    // 左上
    [linePath moveToPoint:CGPointMake(leftX + self.scanAreaCornerWidth, topY)];
    [linePath addLineToPoint:CGPointMake(leftX, topY)];
    [linePath addLineToPoint:CGPointMake(leftX, topY + self.scanAreaCornerHeight)];
    // 左下
    [linePath moveToPoint:CGPointMake(leftX, bottomY - self.scanAreaCornerHeight)];
    [linePath addLineToPoint:CGPointMake(leftX, bottomY)];
    [linePath addLineToPoint:CGPointMake(leftX + self.scanAreaCornerWidth, bottomY)];
    // 右下
    [linePath moveToPoint:CGPointMake(rightX - self.scanAreaCornerWidth, bottomY)];
    [linePath addLineToPoint:CGPointMake(rightX, bottomY)];
    [linePath addLineToPoint:CGPointMake(rightX, bottomY - self.scanAreaCornerHeight)];
    // 右上
    [linePath moveToPoint:CGPointMake(rightX, topY + self.scanAreaCornerHeight)];
    [linePath addLineToPoint:CGPointMake(rightX, topY)];
    [linePath addLineToPoint:CGPointMake(rightX - self.scanAreaCornerWidth, topY)];
    self.cornerLineLayer.path = linePath.CGPath;
}

//绘制扫描区域
- (void)drawScanRect {
    //    CGSize sizeRetangle = self.scanRetangleRect.size;
    //    //扫码区域Y轴最小坐标
    //    CGFloat YMinRetangle = self.scanRetangleRect.origin.y;
    //    CGFloat YMaxRetangle = YMinRetangle + sizeRetangle.height;
    //    CGFloat XRetangleLeft = self.scanRetangleRect.origin.x;
    //    CGFloat XRetangleRight = self.frame.size.width - XRetangleLeft;
    //    CGContextRef context = UIGraphicsGetCurrentContext();
    //    //非扫码区域半透明
    //    {
    //        //设置非识别区域颜色
    //        const CGFloat *components = CGColorGetComponents(self.notIdentificationAreaColor.CGColor);
    //        CGContextSetRGBFillColor(context, components[0], components[1], components[2], components[3]);
    //        //填充矩形
    //        //扫码区域上面填充
    //        CGRect rect = CGRectMake(0, 0, self.frame.size.width, YMinRetangle);
    //        CGContextFillRect(context, rect);
    //        //扫码区域左边填充
    //        rect = CGRectMake(0, YMinRetangle, XRetangleLeft,sizeRetangle.height);
    //        CGContextFillRect(context, rect);
    //        //扫码区域右边填充
    //        rect = CGRectMake(XRetangleRight, YMinRetangle, XRetangleLeft,sizeRetangle.height);
    //        CGContextFillRect(context, rect);
    //        //扫码区域下面填充
    //        rect = CGRectMake(0, YMaxRetangle, self.frame.size.width,self.frame.size.height - YMaxRetangle);
    //        CGContextFillRect(context, rect);
    //        //执行绘画
    //        CGContextStrokePath(context);
    //    }
    //    if (self.isNeedShowRetangle){
    //        //中间画矩形(正方形)
    //        CGContextSetStrokeColorWithColor(context, self.rectangleLineColor.CGColor);
    ////        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    //        CGContextSetLineWidth(context, self.rectangleLineWidth);
    //        CGContextAddRect(context, self.scanRetangleRect);
    //        CGContextStrokePath(context);
    //    }
    //    //画矩形框4格外围相框角
    //    //相框角的宽度和高度
    //    int wAngle = self.scanAreaCornerWidth;
    //    int hAngle = self.scanAreaCornerHeight;
    //    //4个角的 线的宽度
    //    CGFloat linewidthAngle = self.scanAreaCornerLineWidth;// 经验参数：6和4
    //    //画扫码矩形以及周边半透明黑色坐标参数
    //    CGFloat diffAngle = 0.0f;
    //    //diffAngle = -linewidthAngle/3; //框外面4个角，与框有缝隙
    //    //diffAngle = linewidthAngle/3;  //框4个角 在线上加4个角效果
    //    //diffAngle = 0;//与矩形框重合
    //    diffAngle = -linewidthAngle/3;
    //    CGContextSetStrokeColorWithColor(context, self.scanAreaCornerColor.CGColor);
    //    CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
    //    CGContextSetLineWidth(context, linewidthAngle);
    //    //顶点位置
    //    CGFloat leftX = XRetangleLeft - diffAngle;
    //    CGFloat topY = YMinRetangle - diffAngle;
    //    CGFloat rightX = XRetangleRight + diffAngle;
    //    CGFloat bottomY = YMaxRetangle + diffAngle;
    //    //左上角水平线
    //    CGContextMoveToPoint(context, leftX-linewidthAngle/2, topY);
    //    CGContextAddLineToPoint(context, leftX + wAngle, topY);
    //    //左上角垂直线
    //    CGContextMoveToPoint(context, leftX, topY-linewidthAngle/2);
    //    CGContextAddLineToPoint(context, leftX, topY+hAngle);
    //    //左下角水平线
    //    CGContextMoveToPoint(context, leftX-linewidthAngle/2, bottomY);
    //    CGContextAddLineToPoint(context, leftX + wAngle, bottomY);
    //    //左下角垂直线
    //    CGContextMoveToPoint(context, leftX, bottomY+linewidthAngle/2);
    //    CGContextAddLineToPoint(context, leftX, bottomY - hAngle);
    //    //右上角水平线
    //    CGContextMoveToPoint(context, rightX+linewidthAngle/2, topY);
    //    CGContextAddLineToPoint(context, rightX - wAngle, topY);
    //    //右上角垂直线
    //    CGContextMoveToPoint(context, rightX, topY-linewidthAngle/2);
    //    CGContextAddLineToPoint(context, rightX, topY + hAngle);
    //    //右下角水平线
    //    CGContextMoveToPoint(context, rightX+linewidthAngle/2, bottomY);
    //    CGContextAddLineToPoint(context, rightX - wAngle, bottomY);
    //    //右下角垂直线
    //    CGContextMoveToPoint(context, rightX, bottomY+linewidthAngle/2);
    //    CGContextAddLineToPoint(context, rightX, bottomY - hAngle);
    //    CGContextStrokePath(context);
    
    
    
    
    
#warning test
    // 挖空内部
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:self.guiderView.bounds];
    [bezierPath appendPath:[[UIBezierPath bezierPathWithRect:self.scanRetangleRect] bezierPathByReversingPath]];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = bezierPath.CGPath;
    self.guiderView.layer.mask = shapeLayer;
    
    // 边部白线，内部透明（clearColor）
    UIBezierPath *borderBezierPath = [[UIBezierPath alloc] init];
    [borderBezierPath appendPath:[[UIBezierPath bezierPathWithRect:self.scanRetangleRect] bezierPathByReversingPath]];
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.path = borderBezierPath.CGPath;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = self.rectangleLineColor.CGColor;
    borderLayer.lineWidth = self.rectangleLineWidth;
    borderLayer.frame = CGRectMake(0, 0, self.scanRetangleRect.size.width, self.scanRetangleRect.size.height);
    [self.guiderView.layer addSublayer:borderLayer];
    
    // 边角
    UIBezierPath *linePath = [[UIBezierPath alloc] init];
    CGFloat leftX = self.scanRetangleRect.origin.x;
    CGFloat topY = self.scanRetangleRect.origin.y;
    CGFloat bottomY = self.scanRetangleRect.origin.y + self.scanRetangleRect.size.height;
    CGFloat rightX = self.scanRetangleRect.origin.x + self.scanRetangleRect.size.width;
    // 左上
    [linePath moveToPoint:CGPointMake(leftX + self.scanAreaCornerWidth, topY)];
    [linePath addLineToPoint:CGPointMake(leftX, topY)];
    [linePath addLineToPoint:CGPointMake(leftX, topY + self.scanAreaCornerHeight)];
    // 左下
    [linePath moveToPoint:CGPointMake(leftX, bottomY - self.scanAreaCornerHeight)];
    [linePath addLineToPoint:CGPointMake(leftX, bottomY)];
    [linePath addLineToPoint:CGPointMake(leftX + self.scanAreaCornerWidth, bottomY)];
    // 右下
    [linePath moveToPoint:CGPointMake(rightX - self.scanAreaCornerWidth, bottomY)];
    [linePath addLineToPoint:CGPointMake(rightX, bottomY)];
    [linePath addLineToPoint:CGPointMake(rightX, bottomY - self.scanAreaCornerHeight)];
    // 右上
    [linePath moveToPoint:CGPointMake(rightX, topY + self.scanAreaCornerHeight)];
    [linePath addLineToPoint:CGPointMake(rightX, topY)];
    [linePath addLineToPoint:CGPointMake(rightX - self.scanAreaCornerWidth, topY)];
    CAShapeLayer *cornerLineLayer = [CAShapeLayer layer];
    cornerLineLayer.path = linePath.CGPath;
    cornerLineLayer.strokeColor = self.scanAreaCornerColor.CGColor;
    cornerLineLayer.fillColor  = nil;   //  默认是black
    cornerLineLayer.lineWidth = self.scanAreaCornerLineWidth;
    [self.guiderView.layer addSublayer:cornerLineLayer];
}

- (void)showFlashlightButton:(BOOL)show {
    self.flashlightButton.hidden = !show;
}

- (void)startScan {
    if (self.isAnimating == NO) {
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:3.0 animations:^{
        weakSelf.scanBgAnimationImageView.frame = CGRectMake(weakSelf.scanRetangleRect.origin.x, weakSelf.scanRetangleRect.origin.y + weakSelf.scanRetangleRect.size.height - 2, weakSelf.scanRetangleRect.size.width, 2);
    } completion:^(BOOL finished) {
        if (finished == YES) {
            weakSelf.scanBgAnimationImageView.frame = CGRectMake(weakSelf.scanRetangleRect.origin.x, weakSelf.scanRetangleRect.origin.y, weakSelf.scanRetangleRect.size.width, 2);
            [weakSelf performSelector:@selector(startScan) withObject:nil afterDelay:0.03];
        }
    }];
}

- (void)startScanAnimation {
    if(self.isAnimating){
        return;
    }
    self.isAnimating = YES;
    [self startScan];
}

- (void)stopScanAnimation {
    self.scanBgAnimationImageView.frame = CGRectMake(self.scanRetangleRect.origin.x, self.scanRetangleRect.origin.y, self.scanRetangleRect.size.width, 2);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startScan) object:nil];
    self.isAnimating = NO;
    [self.scanBgAnimationImageView.layer removeAllAnimations];
}

- (void)handlingResultsOfScan {
    self.handlingView.hidden = NO;
    [self.activityView startAnimating];
}

- (void)finishedHandle {
    [self.activityView stopAnimating];
    self.handlingView.hidden = YES;
}

#pragma mark - KVO

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addObservers {
    // app退到后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
    // app进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterPlayGround) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)appWillEnterBackground{
    [self stopScanAnimation];
}

- (void)appWillEnterPlayGround{
    [self startScanAnimation];
}

#pragma mark -- Getter

- (UIImage *)animationImage {
    if (!_animationImage) {
        _animationImage = [UIImage imageNamed:@"scanLine"];
    }
    return _animationImage;
}

#pragma mark -- Setter

- (void)setIsNeedShowRetangle:(BOOL)isNeedShowRetangle {
    _isNeedShowRetangle = isNeedShowRetangle;
}

- (void)setScanAreaCornerLineWidth:(CGFloat)scanAreaCornerLineWidth {
    _scanAreaCornerLineWidth = scanAreaCornerLineWidth;
}

- (void)setNotIdentificationAreaColor:(UIColor *)notIdentificationAreaColor {
    _notIdentificationAreaColor = notIdentificationAreaColor;
    
    self.guiderView.backgroundColor = notIdentificationAreaColor;
}

- (void)setScanRetangleRect:(CGRect)scanRetangleRect {
    _scanRetangleRect = scanRetangleRect;
    
    self.scanBgAnimationImageView.frame = CGRectMake(self.scanRetangleRect.origin.x, self.scanRetangleRect.origin.y, self.scanRetangleRect.size.width, 4);
    self.scanMethodTipLabel.frame = CGRectMake(0, self.scanRetangleRect.origin.y + self.scanRetangleRect.size.height + 10, self.frame.size.width, 20);
    self.myQRCodeButton.frame = CGRectMake(0, self.scanRetangleRect.origin.y + self.scanRetangleRect.size.height + 10 + 20 + 10, self.frame.size.width, 20);
    
    self.handlingView.frame = CGRectMake(0, 0, self.scanRetangleRect.size.width, 40 + 40);
    self.handlingView.center = CGPointMake(self.frame.size.width / 2.0, self.scanRetangleRect.origin.y + self.scanRetangleRect.size.height / 2);
    self.activityView.frame = CGRectMake(0, 0, self.handlingView.frame.size.width, 40);
    self.handlingLabel.frame = CGRectMake(0, 40, self.handlingView.frame.size.width, 40);
    self.flashlightButton.frame = CGRectMake(0, 0, 40, 40);
    self.flashlightButton.center = CGPointMake(self.frame.size.width/2.0, self.scanRetangleRect.origin.y + self.scanRetangleRect.size.height - 40);
}

- (void)setScanAreaCornerWidth:(CGFloat)scanAreaCornerWidth {
    _scanAreaCornerWidth = scanAreaCornerWidth;
}

- (void)setScanAreaCornerHeight:(CGFloat)scanAreaCornerHeight {
    _scanAreaCornerHeight = scanAreaCornerHeight;
}

- (void)setScanAreaCornerColor:(UIColor *)scanAreaCornerColor {
    _scanAreaCornerColor = scanAreaCornerColor;
}

- (void)setRectangleLineColor:(UIColor *)rectangleLineColor {
    _rectangleLineColor = rectangleLineColor;
}

- (void)setRectangleLineWidth:(CGFloat)rectangleLineWidth {
    _rectangleLineWidth = rectangleLineWidth;
}

- (void)setAnimationImage:(UIImage *)animationImage {
    _animationImage = animationImage;
    self.scanBgAnimationImageView.image = animationImage;
}

- (void)setIsAnimating:(BOOL)isAnimating {
    _isAnimating = isAnimating;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
