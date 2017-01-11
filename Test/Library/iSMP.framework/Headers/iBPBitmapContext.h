//
//  iBPBitmapContext.h
//  PCL
//
//  Created by Hichem Boussetta on 01/02/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iBPBitmapContext : NSObject

@property (nonatomic, copy)     NSString *      textFont;

@property (nonatomic, assign)   NSUInteger      textSize;

@property (nonatomic, assign)   NSUInteger      alignment;

@property (nonatomic, assign)   NSUInteger      characterSpacing;

@property (nonatomic, assign)   NSUInteger      lineFeedStep;

-(id)initWithWidth:(CGFloat)width andHeight:(CGFloat)height;

-(void)drawText:(NSString *)text;

-(void)drawBitmapWithImage:(UIImage *)image;

-(void)drawBitmapWithImage:(UIImage *)image andSize:(CGSize)bitmapSize;

-(void)clearContext;

-(void)lineFeed;

-(UIImage *)getImage;

-(UIImage *)getImageAt:(int)yPosition maxHeight:(int)maxHeight;

-(CGFloat)drawingPosition;

@end
