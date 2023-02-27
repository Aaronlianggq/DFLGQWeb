//
//  UIImage+QRScale.m
//  DongFuWang
//
//  Created by qianduan2731 on 2021/7/30.
//

#import "UIImage+QRScale.h"
#import "ZXingObjC.h"

@implementation UIImage (QRScale)
-(UIImage *)transformtoSize:(CGSize)Newsize
{
    // 创建一个bitmap的context
    UIGraphicsBeginImageContext(Newsize);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, Newsize.width, Newsize.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage *TransformedImg=UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return TransformedImg;
}

//识别图片的二维码
- (NSString *)decodeQRImageWith:(UIImage*)aImage {
    if (aImage.size.width > 280.0 && aImage.size.height > 280.0) {
//        aImage = [self transformtoSize:CGSizeMake(280.0, 280.0)];
    }
    ZXCGImageLuminanceSource *source = [[ZXCGImageLuminanceSource alloc] initWithCGImage:aImage.CGImage];
    ZXHybridBinarizer *binarizer = [[ZXHybridBinarizer alloc] initWithSource: source];
    ZXBinaryBitmap *bitmap = [[ZXBinaryBitmap alloc] initWithBinarizer:binarizer];
    
    NSError *error = nil;
    
    ZXDecodeHints *hints = [ZXDecodeHints hints];
    ZXMultiFormatReader *forReader = [ZXMultiFormatReader reader];
    ZXResult *result = [forReader decode:bitmap hints:hints error:&error];
    
    NSString *content = result.text;
    return  content;
    
}

@end
