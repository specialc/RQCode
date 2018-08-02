//
//  CYQRCodeManager.m
//  testRQCode
//
//  Created by dev on 2018/6/22.
//  Copyright © 2018年 dev. All rights reserved.
//

#import "CYQRCodeManager.h"
#import "ZXingObjC.h"

@interface CYQRCodeManager()<AVCaptureMetadataOutputObjectsDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession * session;

/**
 扫描中心识别区域范围
 */
@property (nonatomic, assign) CGRect scanFrame;

/**
 展示输出流的视图——即照相机镜头下的内容
 */
@property (nonatomic, strong) UIView *preview;

@end

@implementation CYQRCodeManager

- (instancetype)initWithPreview:(UIView *)preview andScanFrame:(CGRect)scanFrame{
    
    if (self == [super init]) {
        self.preview = preview;
        self.scanFrame = scanFrame;
        [self  configuredScanTool];
    }
    return self;
}

#pragma mark -- Help Methods

//初始化采集配置信息
- (void)configuredScanTool{
    
    AVCaptureVideoPreviewLayer *layer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.preview.layer.bounds;
    [self.preview.layer insertSublayer:layer atIndex:0];
    
}

#pragma mark -- Event Handel

- (void)openFlashSwitch:(BOOL)open{
    if (self.flashlightOpen == open) {
        return;
    }
    self.flashlightOpen = open;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch] && [device hasFlash]){
        
        [device lockForConfiguration:nil];
        if (self.flashlightOpen){
            device.torchMode = AVCaptureTorchModeOn;
            device.flashMode = AVCaptureFlashModeOn;
        }
        else{
            device.torchMode = AVCaptureTorchModeOff;
            device.flashMode = AVCaptureFlashModeOff;
        }
        
        [device unlockForConfiguration];
    }
    
}

- (void)sessionStartRunning{
    [_session startRunning];
}

- (void)sessionStopRunning{
    [_session stopRunning];
}


- (void)scanQRCodeImageWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    UIImage *image;
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    // 原生：编辑后的图：可以识别编辑区内有二维码的图片（优：如果二维码比较小，可以放大），但是经过编辑后，图片可能会被拉伸而无法识别；
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    //        NSArray *features = [detector featuresInImage:[CIImage imageWithData:UIImagePNGRepresentation(image)]];
    if (features.count >= 1){
        CIQRCodeFeature *feature = [features firstObject];
        NSLog(@"二维码地址：%@",feature.messageString);
        if(self.scanFinishedBlock != nil){
            self.scanFinishedBlock(feature.messageString);
        }

        return;
    }

    // 原生：原图：可以识别有大量无码图像的图像
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    if (features.count >= 1){
        CIQRCodeFeature *feature = [features firstObject];
        NSLog(@"二维码地址：%@",feature.messageString);
        if(self.scanFinishedBlock != nil){
            self.scanFinishedBlock(feature.messageString);
        }

        return;
    }
    
    
    image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image){
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    // ZXing：可以识别iOS8；
    ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage];
    ZXHybridBinarizer *binarizer = [[ZXHybridBinarizer alloc] initWithSource:source];
    ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
    NSError *error;
    id<ZXReader> reader;
    if (NSClassFromString(@"ZXMultiFormatReader")) {
        reader = [NSClassFromString(@"ZXMultiFormatReader") performSelector:@selector(reader)];
    }
    ZXDecodeHints *_hints = [ZXDecodeHints hints];
    ZXResult *result = [reader decode:bitmap hints:_hints error:&error];
    if (result != nil) {
        NSLog(@"二维码格式：%u；二维码地址：%@",result.barcodeFormat,result.text);
        if(self.scanFinishedBlock != nil){
            self.scanFinishedBlock(result.text);
        }
        return;
    }
    
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    // ZXing
    source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage];
    binarizer = [[ZXHybridBinarizer alloc] initWithSource:source];
    bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
    
    if (NSClassFromString(@"ZXMultiFormatReader")) {
        reader = [NSClassFromString(@"ZXMultiFormatReader") performSelector:@selector(reader)];
    }
    _hints = [ZXDecodeHints hints];
    result = [reader decode:bitmap hints:_hints error:&error];
    if (result != nil) {
        NSLog(@"二维码格式：%u；二维码地址：%@",result.barcodeFormat,result.text);
        if(self.scanFinishedBlock != nil){
            self.scanFinishedBlock(result.text);
        }
    }
    else {
        NSLog(@"图中没有二维码");
    }
    
    
    
    
    
//    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    version = 8.0;
//    if (version >= 9.0) {
//
//        // 原生
//        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
//        NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
////        NSArray *features = [detector featuresInImage:[CIImage imageWithData:UIImagePNGRepresentation(image)]];
//        if (features.count >= 1){
//            CIQRCodeFeature *feature = [features firstObject];
//            NSLog(@"二维码地址：%@",feature.messageString);
//            if(self.scanFinishedBlock != nil){
//                self.scanFinishedBlock(feature.messageString);
//            }
//        }else{
//            NSLog(@"无法识别图中二维码");
//        }
//    }
//    else {
//
//        // ZXing
//        ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:image.CGImage];
//        ZXHybridBinarizer *binarizer = [[ZXHybridBinarizer alloc] initWithSource:source];
//        ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
//        NSError *error;
//        id<ZXReader> reader;
//        if (NSClassFromString(@"ZXMultiFormatReader")) {
//            reader = [NSClassFromString(@"ZXMultiFormatReader") performSelector:@selector(reader)];
//        }
//        ZXDecodeHints *_hints = [ZXDecodeHints hints];
//        ZXResult *result = [reader decode:bitmap hints:_hints error:&error];
//        if (result != nil) {
//            NSLog(@"二维码格式：%u；二维码地址：%@",result.barcodeFormat,result.text);
//            if(self.scanFinishedBlock != nil){
//                self.scanFinishedBlock(result.text);
//            }
//        }
//        else {
//            NSLog(@"图中没有二维码");
//        }
//    }
    
}

+ (UIImage *)createQRCodeImageWithString:(nonnull NSString *)codeString andSize:(CGSize)size andBackColor:(nullable UIColor *)backColor andFrontColor:(nullable UIColor *)frontColor andCenterImage:(nullable UIImage *)centerImage{
    
    NSData *stringData = [codeString dataUsingEncoding:NSUTF8StringEncoding];
    
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //    NSLog(@"%@",qrFilter.inputKeys);
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    CIImage *qrImage = qrFilter.outputImage;
    //放大并绘制二维码 (上面生成的二维码很小，需要放大)
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    //翻转一下图片 不然生成的QRCode就是上下颠倒的
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
    UIImage *codeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRelease(cgImage);
    
    //绘制颜色
    CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                       keysAndValues:
                             @"inputImage",[CIImage imageWithCGImage:codeImage.CGImage],
                             @"inputColor0",[CIColor colorWithCGColor:frontColor == nil ? [UIColor clearColor].CGColor: frontColor.CGColor],
                             @"inputColor1",[CIColor colorWithCGColor: backColor == nil ? [UIColor blackColor].CGColor : backColor.CGColor],
                             nil];
    
    UIImage * colorCodeImage = [UIImage imageWithCIImage:colorFilter.outputImage];
    
    //中心添加图片
    if (centerImage != nil) {
        
        UIGraphicsBeginImageContext(colorCodeImage.size);
        
        [colorCodeImage drawInRect:CGRectMake(0, 0, colorCodeImage.size.width, colorCodeImage.size.height)];
        
        UIImage *image = centerImage;
        
        CGFloat imageW = 50;
        CGFloat imageX = (colorCodeImage.size.width - imageW) * 0.5;
        CGFloat imgaeY = (colorCodeImage.size.height - imageW) * 0.5;
        
        [image drawInRect:CGRectMake(imageX, imgaeY, imageW, imageW)];
        
        UIImage *centerImageCode = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return centerImageCode;
    }
    return colorCodeImage;
}

#pragma mark -- AVCaptureMetadataOutputObjectsDelegate
//扫描完成后执行
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    
    if (metadataObjects.count > 0){
        AVMetadataMachineReadableCodeObject *metadataObject = [metadataObjects firstObject];
        // 扫描完成后的字符
        //        NSLog(@"扫描出 %@",metadataObject.stringValue);
        if(self.scanFinishedBlock != nil){
            self.scanFinishedBlock(metadataObject.stringValue);
        }
    }
}
#pragma mark- AVCaptureVideoDataOutputSampleBufferDelegate的方法
//扫描过程中执行，主要用来判断环境的黑暗程度
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if (self.monitorLightBlock == nil) {
        return;
    }
    
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
    
    //    NSLog(@"环境光感 ： %f",brightnessValue);
    
    // 根据brightnessValue的值来判断是否需要打开和关闭闪光灯
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    BOOL result = [device hasTorch];// 判断设备是否有闪光灯
    if ((brightnessValue < 0) && result) {
        // 环境太暗，可以打开闪光灯了
    }else if((brightnessValue > 0) && result){
        // 环境亮度可以
    }
    if (self.monitorLightBlock != nil) {
        self.monitorLightBlock(brightnessValue);
    }
    
}

#pragma mark - Getter
- (AVCaptureSession *)session{
    
    if (_session == nil){
        //获取摄像设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //创建输入流
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        if (!input){
            return nil;
        }
        
        //创建二维码扫描输出流
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        //设置代理 在主线程里刷新
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        //设置采集扫描区域的比例 默认全屏是（0，0，1，1）
        //rectOfInterest 填写的是一个比例，输出流视图preview.frame为 x , y, w, h, 要设置的矩形快的scanFrame 为 x1, y1, w1, h1. 那么rectOfInterest 应该设置为 CGRectMake(y1/y, x1/x, h1/h, w1/w)。
        CGFloat x = CGRectGetMinX(self.scanFrame)/ CGRectGetWidth(self.preview.frame);
        CGFloat y = CGRectGetMinY(self.scanFrame)/ CGRectGetHeight(self.preview.frame);
        CGFloat width = CGRectGetWidth(self.scanFrame)/ CGRectGetWidth(self.preview.frame);
        CGFloat height = CGRectGetHeight(self.scanFrame)/ CGRectGetHeight(self.preview.frame);
        output.rectOfInterest = CGRectMake(y, x, height, width);
        
        // 创建环境光感输出流
        AVCaptureVideoDataOutput *lightOutput = [[AVCaptureVideoDataOutput alloc] init];
        [lightOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
        
        _session = [[AVCaptureSession alloc] init];
        //高质量采集率
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        [_session addInput:input];
        [_session addOutput:output];
        [_session addOutput:lightOutput];
        
        //设置扫码支持的编码格式(这里设置条形码和二维码兼容)
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,
                                       AVMetadataObjectTypeEAN13Code,
                                       AVMetadataObjectTypeEAN8Code,
                                       AVMetadataObjectTypeCode128Code];
    }
    
    return _session;
}

@end
