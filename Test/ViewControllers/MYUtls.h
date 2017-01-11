//
//  MYUtls.h
//  WowAir
//
//  Created by Jan Plesek on 28/05/14.
//  Copyright (c) 2014 Jan Plesek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


#pragma mark - Constants

typedef enum : NSUInteger {
    MYUtlsDirectionLeft,
    MYUtlsDirectionRight,
    MYUtlsDirectionTop,
    MYUtlsDirectionBottom,
    MYUtlsDirectionNone,
} MYUtlsDirection;

typedef enum : NSUInteger {
	MYUtlsDeviceiPhone4,
	MYUtlsDeviceiPhone5,
	MYUtlsDeviceiPhone6,
	MYUtlsDeviceiPhone6plus,
	MYUtlsDeviceiPad,
	MYUtlsDeviceiPadRetina,
	MYUtlsDeviceOther,
} MYUtlsDevice;

typedef enum : NSUInteger {
	MYUtlsConfigDev,
	MYUtlsConfigAlok,
	MYUtlsConfigIvar,
	MYUtlsConfigStage,
	MYUtlsConfigProd,
	MYUtlsConfigUnknown,
} MYUtlsConfig;

@class AppDelegate;

@interface MYUtls : NSObject


#pragma mark - Device
+(CGSize)screenSize;
+(BOOL)isScreenBig;
+(BOOL)isIOS7OrNewer;
+(BOOL)isIOS8OrNewer;
+(BOOL)isIPad;
+(BOOL)isIPhone;
+(BOOL)isIPhone4;
+(BOOL)isIPhone5;
+(BOOL)isIPhone6;
+(BOOL)isIPhone6Plus;
+(BOOL)isIPhoneBig;
+(BOOL)isRetina;
+(NSString*)localUDID;
+(BOOL)isSimulator;
+(UIInterfaceOrientation)orientation;
+(BOOL)isOrientationPortrait;
+(BOOL)isOrientationLandscape;
+(MYUtlsDevice)device;
#pragma mark - System
+(float)statusbarHeight;
+(void)statusbarHidden:(BOOL)isHidden;
+(void)badgesRemove;
+(void)badgesSetTo:(int)badges;
+(void)openInSafariLink:(NSString*)link;
+(NSBundle*)languageBundleCurrent;
+(void)timerStillRun:(NSTimer*)timer;
+(void)fontAllToConsole;
+(NSString*)strVersion;
+(NSString*)strBuild;
+(NSString*)strSystemVersion;
+(NSString*)strDeviceName;
+(UIViewController*)viewControllerTopMost;
+(NSString*)sharedAppGroupDirectory;

#pragma mark - App Specific
+(AppDelegate*)appDelegate;
+(NSString*)baseAPI;
+(UIImage*)placeHolderImage;

#pragma mark - Drawing and Colors

+(UIImage*)imageOfCircle:(CGSize)size letter:(NSString*)letter font:(UIFont*)font color:(UIColor*)color;
+(UIImage*)imageWithSize:(CGSize)size beginColor:(UIColor*)beginColor endColor:(UIColor*)endColor type:(MYUtlsDirection)direction;
+(UIImage*)imageMergeOfImageTop:(UIImage*)imageTop imageBottom:(UIImage*)imageBottom isBottomSizeBase:(BOOL)isBottomSizeBase;
+(UIImage*)imageRotatedFromImage:(UIImage*)imageIn angleRad:(float)angle;
+(UIColor*)colorFromHEX:(int)hexCode;
+(UIColor*)colorWithBrightness:(UIColor *)color brightnessPercentage:(float)brightnessPercentage;
+(UIImage*)imageOverlayedByColor:(UIColor*)color fromImage:(UIImage*)image;
+(UIImage*)image:(UIImage*)image scaledToSize:(CGSize)size;
+(UIImage*)imageFromColor:(UIColor*)color;
+(UIColor*)colorHashedFromString:(NSString*)string;
+(UIColor*)colorBlendedWithColor:(UIColor*)color1 color:(UIColor*)color2 alpha:(float)alpha;
+(UIImage*)imageCroppedImage:(UIImage*)image toRect:(CGRect)rect;
+(UIImage*)imageWithText:(NSString*)text font:(UIFont*)font color:(UIColor*)color size:(CGSize)size;
+(UIImage*)imageMaskedWithPolygonFromImage:(UIImage*)image points:(int)points offset:(float)offset;
+(void)addBlurToView:(UIView*)view withStyle:(UIBlurEffectStyle)style;
+(void)removeBlurFromView:(UIView*)view;
+(void)addRoundedCornersTop:(UIView *)view;
+(void)addRoundedCornersBottom:(UIView *)view;
+(void)addRoundedCornersAll:(UIView *)view;

#pragma mark - Text
+(id)checkDict:(NSDictionary*)dict forKey:(NSString*)key;
+(BOOL)isMailAddressValid:(NSString *)string;
+(BOOL)string:(NSString*)string contains:(NSString*)otherString;
+(NSString*)stringByStrippingHTMLFromString:(NSString*)text;
+(NSString*)stringAsPhoneNumber:(NSString*)text;
+(NSString*)stringFromAmountText:(NSString*)text;
+(NSString*)stringFromAmountValue:(int)value;

#pragma mark - Networking
+(NSString*)IPAddressLocal;
+(NSString*)IPAddressPublic;
#pragma mark - Delay and threads
+(void)blockInMainQueueAfterDelay:(float)seconds performBlock:(void (^)(void))block;
+(void)blockInQueue:(dispatch_queue_t)queue afterDelay:(float)seconds performBlock:(void (^)(void))block;
+(void)blockInMainQueue:(void (^)(void))block;
+(void)blockInBackgroundQueue:(void (^)(void))block;

#pragma mark - Mathematics
+(float)radFromDeg:(float)deg;
+(float)degFromRad:(float)rad;
+(float)smallerAngleBetweenAngle:(float)x andAngle:(float)y;

#pragma mark - Geometry
+(CGRect)rectFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2;
+(CGRect)rectSubtractionWithRect:(CGRect)rect1 minusRect:(CGRect)rect2 byEdge:(CGRectEdge)edge;

#pragma mark - Geography
+(float)distanceBetweenGPSposition:(CLLocationCoordinate2D)beginGPS andGPSposition:(CLLocationCoordinate2D)endGPS;
+(CLLocationCoordinate2D)interpolateBetweenGPSposition:(CLLocationCoordinate2D)beginGPS andGPSposition:(CLLocationCoordinate2D)endGPS forRatio:(float)ratio;
+(BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate insideRegion:(MKCoordinateRegion)region;
+(float)kmhFromMs:(float)speed;
+(float)msFromKmh:(float)speed;
+(NSArray*)polylineWithEncodedString:(NSString*)encodedString;

#pragma mark - Time
+ (NSTimeInterval)timeIntervalSinceSystemBoot;
+ (NSDate*)dateWithTimeSinceSystemBoot;
+ (NSDate*)absoluteDate:(NSDate *)date;
+ (NSInteger)daysBetweenDate:(NSDate*)fromDate andDate:(NSDate*)toDate;
+ (BOOL)datesAreSame:(NSDate *)dateA and:(NSDate *)dateB;
#pragma mark - Easings
+(float)easyIn:(float)x;

#pragma mark - Conversions
+(float)poundFromKg:(float)kg;
+(float)feetFromMeter:(float)meter;
+(float)inchFromMeter:(float)meter;
+(float)kgFromPound:(float)pounds;
+(float)meterFromFeet:(float)feet;
+(float)meterFromInch:(float)inch;

@end


#pragma mark - Macros
#define MY_LOG  NSLog(@"[Line %d] %s", __LINE__, __PRETTY_FUNCTION__);

#define MY_LOCALIZED_STRING(key, comment)	key


//#define MY_LOCALIZED_STRING(key, comment)	NSLocalizedStringFromTableInBundle(key, nil, [MYUtls languageBundleCurrent], comment)
//find . -name "*.m" | xargs genstrings -o en.lproj -s MY_LOCALIZED_STRING

