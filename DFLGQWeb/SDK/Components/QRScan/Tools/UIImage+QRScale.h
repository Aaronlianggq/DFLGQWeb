//
//  UIImage+QRScale.h
//  DongFuWang
//
//  Created by qianduan2731 on 2021/7/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (QRScale)
//缩放图片
-(UIImage *)transformtoSize:(CGSize)Newsize;

//识别图片的二维码
- (NSString *)decodeQRImageWith:(UIImage*)aImage;
@end

NS_ASSUME_NONNULL_END
