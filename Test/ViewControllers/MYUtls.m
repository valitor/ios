//
//  MYUtls.m
//  straeto
//
//  Created by Jan Plesek on 28/05/14.
//  Copyright (c) 2014 Jan Plesek. All rights reserved.
//

#import "MYUtls.h"

#import <sys/utsname.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/sysctl.h>



@implementation MYUtls


#pragma mark - Device

+(CGSize)screenSize{
    return [[UIScreen mainScreen] bounds].size;
}

+(MYUtlsDevice)device {

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [MYUtls isRetina]) {
        return MYUtlsDeviceiPadRetina;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && ![MYUtls isRetina]){
        return MYUtlsDeviceiPad; //ipad2
    }
    
    else if ([MYUtls isIPhone4]) {
        return MYUtlsDeviceiPhone4;
    }
    
    else if ([MYUtls isIPhone5]) {
        return MYUtlsDeviceiPhone5;
    }
    else if ([MYUtls isIPhone6]) {
        return MYUtlsDeviceiPhone6;
    }
    else if ([MYUtls isIPhone6Plus]) {
        return MYUtlsDeviceiPhone6plus;
    }
    else return MYUtlsDeviceOther;
}

+(BOOL)isScreenBig{
    return ([MYUtls screenSize].height==568);
}


+(BOOL)isIOS7OrNewer{
    return ([[[UIDevice currentDevice] systemVersion] floatValue]>=7);
}


+(BOOL)isIOS8OrNewer{
	return ([[[UIDevice currentDevice] systemVersion] floatValue]>=8);
}


+(BOOL)isIPad{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}


+(BOOL)isIPhone{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}


+(BOOL)isIPhone4{
	return ([MYUtls screenSize].height==480);
}


+(BOOL)isIPhone5{
	return ([MYUtls screenSize].height==568);
}


+(BOOL)isIPhone6{
	return ([MYUtls screenSize].height==667);
}


+(BOOL)isIPhone6Plus{
	return ([MYUtls screenSize].height==736);
}

+(BOOL)isIPhoneBig {
    return ([MYUtls screenSize].width>320);
}

+(BOOL)isRetina{
    return ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])&&([[UIScreen mainScreen] scale] >= 2);
}


//unique ID for app on device (just hash)
+(NSString*)localUDID{
    
    NSString *ident = [[NSUserDefaults standardUserDefaults] objectForKey:@"udid"];
    if (!ident) {
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        ident = [NSString stringWithString:(__bridge NSString *)uuidStringRef];
        CFRelease(uuidStringRef);
        [[NSUserDefaults standardUserDefaults] setObject:ident forKey:@"udid"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return ident;
}


+(BOOL)isSimulator{
#if TARGET_IPHONE_SIMULATOR
	return YES;
#else
	return NO;
#endif
}


+(UIInterfaceOrientation)orientation{
	
	UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
#ifndef WATCH_KIT_EXTENSION_TARGET
	orientation = [UIApplication sharedApplication].statusBarOrientation;
#endif
	return orientation;
}


+(BOOL)isOrientationPortrait{
	
	return UIInterfaceOrientationIsPortrait([MYUtls orientation]);
}


+(BOOL)isOrientationLandscape{
	
	return UIInterfaceOrientationIsLandscape([MYUtls orientation]);
}


#pragma mark - System

+(float)statusbarHeight{
#ifndef WATCH_KIT_EXTENSION_TARGET
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
#endif
	return 0;
}


+(void)statusbarHidden:(BOOL)isHidden{
#ifndef WATCH_KIT_EXTENSION_TARGET
	[[UIApplication sharedApplication] setStatusBarHidden:isHidden withAnimation:UIStatusBarAnimationSlide];
#endif
}


+(void)badgesRemove{
#ifndef WATCH_KIT_EXTENSION_TARGET
	[MYUtls badgesSetTo:0];
#endif
}


+(void)badgesSetTo:(int)badges{
#ifndef WATCH_KIT_EXTENSION_TARGET
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:badges];
#endif
}


+(void)openInSafariLink:(NSString*)link{
#ifndef WATCH_KIT_EXTENSION_TARGET
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]];
#endif
}


//should be used mostly in macro MY_ LOCALIZED_STRING (...)
+(NSBundle*)languageBundleCurrent{
	
	NSArray *arrPrefLangs = [NSLocale preferredLanguages];
   
    if([arrPrefLangs count]>0){
        
        NSString *langName = [arrPrefLangs objectAtIndex:0];
        
		return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:langName ofType:@"lproj"]];
	}
	return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"is" ofType:@"lproj"]];
}


+(void)timerStillRun:(NSTimer*)timer{
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


+(void)fontAllToConsole{
    NSMutableArray *fontNames = [[NSMutableArray alloc] init];
    NSArray *fontFamilyNames = [UIFont familyNames];
//    NSLog(@" === FONT FAMILIES ===");
    for (NSString *familyName in fontFamilyNames){
//        NSLog(@"%@",familyName);
        NSArray *names = [UIFont fontNamesForFamilyName:familyName];
        [fontNames addObjectsFromArray:names];
    }
    NSLog(@" === FONT NAMES ===");
    NSArray *arrSortedFonts = [fontNames sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *fontName in arrSortedFonts) {
        NSLog(@"%@",fontName);
    }
}


+(NSString*)strVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}


+(NSString*)strBuild{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}


+(NSString*)strSystemVersion{
	return [[UIDevice currentDevice] systemVersion];
}


+(NSString*)strDeviceName{
	
    struct utsname systemInfo;
    uname(&systemInfo);
	
	NSString *strDeviceCode = [NSString stringWithCString:systemInfo.machine
												 encoding:NSUTF8StringEncoding];
	
	NSDictionary *dictDeviceCodes = @{@"i386"		: @"simulator (32bit)",
									  @"x86_64"		: @"simulator (64bit)",
									  
									  @"iPod1,1"	: @"iPod Touch (1)",		// (Original)
									  @"iPod2,1"	: @"iPod Touch (2)",		// (Second Generation)
									  @"iPod3,1"	: @"iPod Touch (3)",		// (Third Generation)
									  @"iPod4,1"	: @"iPod Touch (4)",		// (Fourth Generation)
									  
									  @"iPhone1,1"	: @"iPhone (1)",			// (Original)
									  @"iPhone1,2"	: @"iPhone 3G",				// (3G)
									  @"iPhone2,1"	: @"iPhone 3GS",			// (3GS)
									  @"iPhone3,1"	: @"iPhone 4",				//
									  @"iPhone4,1"	: @"iPhone 4S",				//
									  @"iPhone5,1"	: @"iPhone 5",				// (model A1428, AT&T/Canada)
									  @"iPhone5,2"	: @"iPhone 5",				// (model A1429, everything else)
									  @"iPhone5,3"	: @"iPhone 5c",				// (model A1456, A1532 | GSM)
									  @"iPhone5,4"	: @"iPhone 5c",				// (model A1507, A1516, A1526 (China), A1529 | Global)
									  @"iPhone6,1"	: @"iPhone 5s",				// (model A1433, A1533 | GSM)
									  @"iPhone6,2"	: @"iPhone 5s",				// (model A1457, A1518, A1528 (China), A1530 | Global)
									  
									  @"iPad1,1"	: @"iPad (1)",				// (Original)
									  @"iPad2,1"	: @"iPad 2",				//
									  @"iPad3,1"	: @"iPad (3)",				// (3rd Generation)
									  @"iPad3,4"	: @"iPad (4)",				// (4th Generation)
									  @"iPad2,5"	: @"iPad Mini (1)",			// (Original)
									  @"iPad4,1"	: @"iPad Air (5) Wifi",		// 5th Generation iPad (iPad Air) - Wifi
									  @"iPad4,2"	: @"iPad Air (5) Cell",		// 5th Generation iPad (iPad Air) - Cellular
									  @"iPad4,4"	: @"iPad Mini (2) Wifi",	// (2nd Generation iPad Mini - Wifi)
									  @"iPad4,5"	: @"iPad Mini (2) Cell"		// (2nd Generation iPad Mini - Cellular)
									  };
	
	
	NSString* deviceName = dictDeviceCodes[strDeviceCode];
	
    if (!deviceName) {	//not in the database, but give me best guest
        if ([strDeviceCode rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"unknown (iPod Touch)";
        }
        else if([strDeviceCode rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"unknown (iPod Touch)";
        }
        else if([strDeviceCode rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"unknown (iPod Touch)";
        }
    }
	
	if(!deviceName){	//not in the database, somethink new, send code
		deviceName = strDeviceCode;
	}
	
    return deviceName;
}


+(UIViewController*)viewControllerTopMost{
#ifndef WATCH_KIT_EXTENSION_TARGET
	return [UIApplication sharedApplication].keyWindow.rootViewController;
#endif
	return nil;
}


+(NSString*)sharedAppGroupDirectory{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *appGroupName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
	NSURL *groupContainerURL = [fm containerURLForSecurityApplicationGroupIdentifier:appGroupName];
	NSString* path = [[groupContainerURL filePathURL] absoluteString];
	return path;
}


#pragma mark - App Specific

+(AppDelegate*)appDelegate{
#ifndef WATCH_KIT_EXTENSION_TARGET
	return (AppDelegate*)[[UIApplication sharedApplication] delegate];
#endif
	return nil;
}

+(NSString*)baseAPI{
	
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"BaseAPI"];
}

+(UIImage *)placeHolderImage {
    return [UIImage imageNamed:@"bgLogin.jpg"];
}

#pragma mark - Drawing and Colors

+(UIImage*)imageOfCircle:(CGSize)size letter:(NSString*)letter font:(UIFont*)font color:(UIColor*)color{
    
    //FIXME: Use MYUtlsDirectionNone for one color
    UIImage *imgGradient = [MYUtls imageWithSize:size
                                      beginColor:color
                                        endColor:color type:MYUtlsDirectionTop];
    
    CGRect tmpRect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(context);
    CGContextAddArc(context, size.width/2, size.height/2, size.width/2, 0, 2*M_PI, 0);
    CGContextClosePath(context);
    
    CGContextClip(context);
    [imgGradient drawInRect:tmpRect];
    
    
    if((font)&&(letter)&&([letter length]>0)&&(![letter isEqualToString:@" "])){
        //FIXME: define font in parameter
//        NSDictionary *dictAttrs = @{NSFontAttributeName: [UIFont fontWithName:@"PTSans-Bold" size:fontSize]};
//        NSDictionary *dictAttrs = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeueLTPro-BdCn" size:fontSize]};
		
		NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
		paragrapStyle.alignment                = NSTextAlignmentCenter;
		
		NSDictionary *dictAttrs = @{NSFontAttributeName: font,
									NSParagraphStyleAttributeName:paragrapStyle};
		float fontSize = [font pointSize];
		
		
        float offsetY = 0;
		offsetY = ((float)(fontSize/15.0)*1.5 - 1.0);
		float offsetX = 0;
		
		if([[font fontName] isEqualToString:@"HelveticaNeueLTPro-BdCn"]){
			offsetY = 2;
		}
		
        CGSize tmpSize;
		
		float padding = 0;
		CGRect tmpRect = [letter boundingRectWithSize:CGSizeMake(size.width-padding, size.height-padding)
									   options:NSStringDrawingUsesLineFragmentOrigin
									attributes:dictAttrs
									   context:nil];
		tmpSize = tmpRect.size;


        NSAttributedString* strLetter = [[NSAttributedString alloc] initWithString:letter attributes:dictAttrs];
        
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [strLetter drawInRect:CGRectMake((size.width-tmpSize.width)/2 + offsetX,
                                         (size.height-tmpSize.height)/2 + offsetY,
                                         tmpSize.width,
                                         tmpSize.height)];
    }
    
    
    UIImage *imgOut = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imgOut;
}


+(UIImage*)imageWithSize:(CGSize)size beginColor:(UIColor*)beginColor endColor:(UIColor*)endColor type:(MYUtlsDirection)direction{
	
	UIImage *image = nil;
	@autoreleasepool {
    //TODO: if(direction==MYUtlsDirectionNone) return solid color
    
		UIGraphicsBeginImageContextWithOptions(size, NO, 0);
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		NSArray *gradientColors = [NSArray arrayWithObjects:(id)beginColor.CGColor, (id)endColor.CGColor, nil];
		
		//   set range 0~1
		//   two value, cause two color
		//   if more color, add more value
		CGFloat gradientLocation[] = {0, 1};
		CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)(gradientColors), gradientLocation);
		
		
		UIBezierPath * bezierPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)];
		CGContextSaveGState(context);
		[bezierPath addClip];
    
		//   set gradient start point and end point
		CGPoint beginPoint = CGPointZero;
		CGPoint endPoint   = CGPointZero;
		
		if((direction==MYUtlsDirectionBottom)||(direction==MYUtlsDirectionTop)){
			beginPoint = CGPointMake(size.width/2, 0);
			endPoint = CGPointMake(size.width/2, size.height);
		}
		else if((direction==MYUtlsDirectionLeft)||(direction==MYUtlsDirectionRight)){
			beginPoint = CGPointMake(0, size.height/2);
			endPoint = CGPointMake(size.width, size.height/2);
		}
		
		if((direction==MYUtlsDirectionTop)||(direction==MYUtlsDirectionLeft)){
			
			CGPoint switchPoint = endPoint;
			endPoint = beginPoint;
			beginPoint = switchPoint;
		}
		
		CGContextDrawLinearGradient(context, gradient, beginPoint, endPoint, 0);
		CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
		[bezierPath setLineWidth:0];
		[bezierPath stroke];
		
		CGContextRestoreGState(context);
		
		
		image = UIGraphicsGetImageFromCurrentImageContext();
		
		CGColorSpaceRelease(colorSpace);
		CGGradientRelease(gradient);
		UIGraphicsEndImageContext();
	}
	
    return image;
}


//size of bottom image is base
//top image is centered
+(UIImage*)imageMergeOfImageTop:(UIImage*)imageTop imageBottom:(UIImage*)imageBot isBottomSizeBase:(BOOL)isBottomSizeBase{
    
	
    CGSize botSize = [imageBot size];
    CGSize topSize = [imageTop size];
	
    CGSize newSize = topSize;
	if(isBottomSizeBase){
		newSize = botSize;
	}
	
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    
    [imageBot drawInRect:CGRectMake((newSize.width  - botSize.width)/2,
									(newSize.height - botSize.height)/2,
									botSize.width, botSize.height)];
    
    [imageTop drawInRect:CGRectMake((newSize.width  - topSize.width)/2,
									(newSize.height - topSize.height)/2,
									topSize.width, topSize.height)
			   blendMode:kCGBlendModeNormal
				   alpha:1.0];
    
    UIImage *imageOut = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return imageOut;
}


+(UIImage*)imageRotatedFromImage:(UIImage*)imageIn angleRad:(float)angle{
	
	UIImage *image = nil;
	
	@autoreleasepool {
		CGSize newSize = imageIn.size;
		UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextTranslateCTM(context, +newSize.width/2, +newSize.height/2);
		CGContextRotateCTM (context, angle);
		CGContextTranslateCTM(context, -newSize.width/2, -newSize.height/2);
		
		
		[imageIn drawAtPoint:CGPointZero];
		
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
    return image;
}


+(UIColor*)colorFromHEX:(int)hexCode{
    
    return [UIColor colorWithRed:((float)((hexCode & 0xFF0000) >> 16))/255.0 green:((float)((hexCode & 0xFF00) >> 8))/255.0 blue:((float)(hexCode & 0xFF))/255.0 alpha:1.0];
}


+(UIColor*)colorWithBrightness:(UIColor *)color brightnessPercentage:(float)brightnessPercentage{
    
    CGFloat h, s, b, a;
    if([color getHue:&h saturation:&s brightness:&b alpha:&a]) {
        return [UIColor colorWithHue:h saturation:s brightness:b * brightnessPercentage alpha:a];
    }
    return nil;
}


+(UIImage*)imageOverlayedByColor:(UIColor*)color fromImage:(UIImage*)image{
	
	UIImage *imageOut = nil;
	
	@autoreleasepool {
		UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
		CGContextRef context = UIGraphicsGetCurrentContext();
		[color setFill];
		
		CGContextTranslateCTM(context, 0, image.size.height);
		CGContextScaleCTM(context, 1.0, -1.0);
		
		CGContextSetBlendMode(context, kCGBlendModeNormal);
		CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
		CGContextDrawImage(context, rect, image.CGImage);
		
		CGContextClipToMask(context, rect, image.CGImage);
		CGContextAddRect(context, rect);
		CGContextDrawPath(context,kCGPathFill);
		
		imageOut = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	
	return imageOut;
	
}


+(UIImage*)image:(UIImage*)image scaledToSize:(CGSize)size{
	
	UIImage *newImage = nil;
	@autoreleasepool {
		UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
		[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
		
		newImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	return newImage;
}


+(UIImage*)imageFromColor:(UIColor*)color{
	
	UIImage *image = nil;
	@autoreleasepool {
		CGRect rect = CGRectMake(0,0,1,1);
		UIGraphicsBeginImageContext(rect.size);
		CGContextRef context = UIGraphicsGetCurrentContext();
		
		CGContextSetFillColorWithColor(context, [color CGColor]);
		CGContextFillRect(context, rect);
		
		image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}
	
	return image;
}


+(UIColor*)colorHashedFromString:(NSString*)string{
	
	//transform to ASCII
	NSData *asciiEncoded = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	string = [[NSString alloc] initWithData:asciiEncoded encoding:NSASCIIStringEncoding];
	
	//remove all white spaces
	NSArray* words = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	string = [words componentsJoinedByString:@""];
	
	//lower case
	string = [string lowercaseString];
	
	//hashing
	const unsigned int kMaxColor = 16777216;
	unsigned int hash = [string hash]%kMaxColor;
	
	int r = (hash & 0xFF0000) >> 16;
	int g = (hash & 0x00FF00) >> 8;
	int b = (hash & 0x0000FF) >> 0;
	
	UIColor *color = [UIColor colorWithRed:r/255.0
									 green:g/255.0
									  blue:b/255.0
									 alpha:1.0];
	
	CGFloat hue, saturation, brightness, alpha;
	[color getHue:&hue
	   saturation:&saturation
	   brightness:&brightness
			alpha:&alpha];
	
	//nice to look
	//	if(brightness>0.9){
	//		brightness = 0.0;
	//	}
	//	else if(brightness<0.7){
	//		brightness = 0.7;
	//	}
	brightness = 0.95;
	if(saturation<0.5){
		saturation = 0.5;
	}
	color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
	
	return color;
}


+(UIColor*)colorBlendedWithColor:(UIColor*)color1 color:(UIColor*)color2 alpha:(float)alpha{
	
	alpha = MIN( 1.f, MAX( 0.f, alpha ) );
	float beta = 1.f - alpha;
	CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
	[color1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
	[color2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
	CGFloat r = r1 * beta + r2 * alpha;
	CGFloat g = g1 * beta + g2 * alpha;
	CGFloat b = b1 * beta + b2 * alpha;
	return [UIColor colorWithRed:r green:g blue:b alpha:1.f];
}


+(UIImage*)imageCroppedImage:(UIImage*)image toRect:(CGRect)rect{
	
	rect.origin.x *= [[UIScreen mainScreen] scale];
	rect.origin.y *= [[UIScreen mainScreen] scale];
	rect.size.width  *= [[UIScreen mainScreen] scale];
	rect.size.height *= [[UIScreen mainScreen] scale];
	
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
	UIImage *imageOut = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return imageOut;
}


+(UIImage*)imageWithText:(NSString*)text font:(UIFont*)font color:(UIColor*)color size:(CGSize)size{
	
	@autoreleasepool {
		
		UIImage *imgOut = nil;
		UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
		
		NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
		paragrapStyle.alignment                = NSTextAlignmentCenter;
		
		NSDictionary *dictAttrs = @{NSFontAttributeName: font,
									NSParagraphStyleAttributeName:paragrapStyle,
									NSForegroundColorAttributeName : color};
		float offsetY = 0;
		float offsetX = 0;
		
		CGSize tmpSize;
		
		float padding = 0;
		CGRect tmpRect = [text boundingRectWithSize:CGSizeMake(size.width-padding, size.height-padding)
											  options:NSStringDrawingUsesLineFragmentOrigin
										   attributes:dictAttrs
											  context:nil];
		tmpSize = tmpRect.size;
		
		NSAttributedString* strText = [[NSAttributedString alloc] initWithString:text attributes:dictAttrs];
		
		[strText drawInRect:CGRectMake((size.width-tmpSize.width)/2   + offsetX,
									   (size.height-tmpSize.height)/2 + offsetY,
									   tmpSize.width,
									   tmpSize.height)];
		
		imgOut = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return imgOut;
	}
}


+(UIImage*)imageMaskedWithPolygonFromImage:(UIImage*)image points:(int)points offset:(float)offset{
	
	UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	float delta = 2*M_PI/points;
	float radius = MIN([image size].width/2, [image size].height/2);
	
	UIBezierPath *path = [[UIBezierPath alloc] init];
	for (int i=0; i<=points; i++) {
		
		float angle = offset+delta*i;
		CGPoint point = CGPointMake([image size].width/2 + cosf(angle)*radius,
									[image size].height/2+ sinf(angle)*radius);
		if(i==0){
			[path moveToPoint: point];
		}
		else{
			[path addLineToPoint: point];
		}
	}
	
	CGContextSaveGState(ctx);
	[path addClip];
	[image drawAtPoint:CGPointMake(0, 0)];
	CGContextRestoreGState(ctx);
	
	CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
	CGContextSetLineWidth(ctx, 4.0);
	CGContextSetLineCap(ctx, kCGLineCapRound);
	CGContextSetLineJoin(ctx, kCGLineJoinRound);
	CGContextBeginPath(ctx);
	CGContextAddPath(ctx, [path CGPath]);
	CGContextDrawPath(ctx, kCGPathStroke);
	
	
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return retImage;
}

+(void)addBlurToView:(UIView*)view withStyle:(UIBlurEffectStyle)style {
    UIView *blurView = nil;
    if([UIBlurEffect class]) { // iOS 8
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:style];
        blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurView.frame = view.frame;
    } else { // workaround for iOS 7
        blurView = [[UIToolbar alloc] initWithFrame:view.bounds];
    }
    
    [blurView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [view addSubview:blurView];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[blurView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(blurView)]];
    [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[blurView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(blurView)]];
}

+(void)removeBlurFromView:(UIView*)view {
    
    for (UIView *subview in [view subviews]) {
        if ([subview isKindOfClass:[UIVisualEffectView class]] || [subview isKindOfClass:[UIToolbar class]]) {
            [subview removeFromSuperview];
        }
    }
}

#define kCornerRadius 5.0

+(void)addRoundedCornersTop:(UIView *)view {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight
                                                         cornerRadii:CGSizeMake(kCornerRadius, kCornerRadius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    view.layer.mask = maskLayer;
    
}

+(void)addRoundedCornersBottom:(UIView *)view {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(kCornerRadius, kCornerRadius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    view.layer.mask = maskLayer;
}

+(void)addRoundedCornersAll:(UIView *)view {
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds
                                                   byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight | UIRectCornerBottomLeft | UIRectCornerBottomRight
                                                         cornerRadii:CGSizeMake(kCornerRadius, kCornerRadius)];
    
    // Create the shape layer and set its path
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    
    // Set the newly created shape layer as the mask for the view's layer
    view.layer.mask = maskLayer;
}



#pragma mark - Text

+(id)checkDict:(NSDictionary*)dict forKey:(NSString*)key{
	
    if(dict==nil){
        return nil;
    }
	
    if(key==nil){
        return nil;
    }
	
    if(dict[key]==nil){
        return nil;
    }
    
    if(dict[key]==nil){
        return nil;
    }
    
	if([dict[key] isEqual:[NSNull null]]){
		return nil;
	}
	
    return dict[key];
}


+(BOOL)isMailAddressValid:(NSString *)string{
    
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:string];
}


+(BOOL)string:(NSString*)string contains:(NSString*)otherString{
    return [string rangeOfString:otherString].location != NSNotFound;
}


+(NSString*)stringByStrippingHTMLFromString:(NSString*)text{
	NSRange range;
	while ((range = [text rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
		text = [text stringByReplacingCharactersInRange:range withString:@""];
	return text;
}


+(NSString*)stringAsPhoneNumber:(NSString*)text{
	
	NSMutableArray *arrTmp = [[NSMutableArray alloc] init];
	
	const int kChunkSize = 3;
	int chunks = ceilf([text length]/(float)kChunkSize);
	for (int i=0; i<chunks; i++) {
		
		NSString *chunk = [text substringWithRange:NSMakeRange(MAX((int)[text length]-(i+1)*kChunkSize,0),
															   MIN((int)[text length]-(i)*kChunkSize,kChunkSize))];
		[arrTmp insertObject:chunk atIndex:0];
	}
	
	return [arrTmp componentsJoinedByString:@" "];
}


+(NSString*)stringFromAmountText:(NSString*)text{
	
	NSString *onlyNumber = [[text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
	int value = [onlyNumber intValue];
	
	return [MYUtls stringFromAmountValue:value];
}


+(NSString*)stringFromAmountValue:(int)value{
	
	NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
	[formatter setNumberStyle:NSNumberFormatterDecimalStyle];
	[formatter setGroupingSeparator:@"."];
	[formatter setGroupingSize:3];
	return [formatter stringFromNumber:@(value)];
}


#pragma mark - Networking
+(NSString*)IPAddressLocal{
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

+(NSString*)IPAddressPublic {
    NSUInteger  an_Integer;
    NSArray * ipItemsArray;
    NSString *externalIP;
    
    NSURL *iPURL = [NSURL URLWithString:@"http://www.dyndns.org/cgi-bin/check_ip.cgi"];
    
    if (iPURL) {
        NSError *error = nil;
        NSString *theIpHtml = [NSString stringWithContentsOfURL:iPURL encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
            NSScanner *theScanner;
            NSString *text = nil;
            
            theScanner = [NSScanner scannerWithString:theIpHtml];
            
            while ([theScanner isAtEnd] == NO) {
                
                // find start of tag
                [theScanner scanUpToString:@"<" intoString:NULL] ;
                
                // find end of tag
                [theScanner scanUpToString:@">" intoString:&text] ;
                
                // replace the found tag with a space
                //(you can filter multi-spaces out later if you wish)
                theIpHtml = [theIpHtml stringByReplacingOccurrencesOfString:
                             [ NSString stringWithFormat:@"%@>", text]
                                                                 withString:@" "] ;
                ipItemsArray =[theIpHtml  componentsSeparatedByString:@" "];
                an_Integer=[ipItemsArray indexOfObject:@"Address:"];
                externalIP =[ipItemsArray objectAtIndex:  ++an_Integer];
            }
            NSLog(@"%@",externalIP);
        } else {
            NSLog(@"Oops... g %ld, %@", (long)[error code], [error localizedDescription]);
        }
    }
    return externalIP;
}

#pragma mark - Delay and threads

+(void)blockInMainQueueAfterDelay:(float)seconds performBlock:(void (^)(void))block{
    [MYUtls blockInQueue:dispatch_get_main_queue() afterDelay:seconds performBlock:block];
}


+(void)blockInQueue:(dispatch_queue_t)queue afterDelay:(float)seconds performBlock:(void (^)(void))block{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), queue, block);
}


+(void)blockInMainQueue:(void (^)(void))block{
    dispatch_async(dispatch_get_main_queue(), block);
}


+(void)blockInBackgroundQueue:(void (^)(void))block{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}


#pragma mark - Mathematics

+(float)radFromDeg:(float)deg{
    
    return deg*(M_PI/180.0);
}


+(float)degFromRad:(float)rad{
    
    return rad*(180/M_PI);
}


+(float)smallerAngleBetweenAngle:(float)x andAngle:(float)y{
    return atan2(sin(x-y), cos(x-y));
}


#pragma mark - Geometry

+(CGRect)rectFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2{
    return CGRectMake(MIN(point1.x,point2.x), MIN(point1.y,point2.y), fabs(point1.x-point2.x), fabs(point1.y-point2.y));
}


+(CGRect)rectSubtractionWithRect:(CGRect)rect1 minusRect:(CGRect)rect2 byEdge:(CGRectEdge)edge{
	// Find how much r1 overlaps r2
	CGRect intersection = CGRectIntersection(rect1, rect2);
	
	// If they don't intersect, just return r1. No subtraction to be done
	if (CGRectIsNull(intersection)) {
		return rect1;
	}
	
	// Figure out how much we chop off r1
	float chopAmount = (edge == CGRectMinXEdge || edge == CGRectMaxXEdge)
	? intersection.size.width
	: intersection.size.height;
	
	CGRect rect3, throwaway;
	// Chop
	CGRectDivide(rect1, &throwaway, &rect3, chopAmount, edge);
	return rect3;
}


#pragma mark - Geography

+(float)distanceBetweenGPSposition:(CLLocationCoordinate2D)beginGPS andGPSposition:(CLLocationCoordinate2D)endGPS{
    
    float R = 6371; // km
    
    float dLat = [MYUtls radFromDeg:(endGPS.latitude - beginGPS.latitude)];
    float dLon = [MYUtls radFromDeg:(endGPS.longitude - beginGPS.longitude)];
    float lat1 = [MYUtls radFromDeg:beginGPS.latitude];
    float lat2 = [MYUtls radFromDeg:endGPS.latitude];
    
    float a = sinf(dLat/2.0) * sinf(dLat/2.0) + sinf(dLon/2.0) * sinf(dLon/2.0) * cosf(lat1) * cosf(lat2);
    float c = 2.0 * atan2f(sqrtf(a),sqrtf(1.0-a));
    float d = R * c;
    
    return d;
}


+(CLLocationCoordinate2D)interpolateBetweenGPSposition:(CLLocationCoordinate2D)beginGPS andGPSposition:(CLLocationCoordinate2D)endGPS forRatio:(float)ratio{
    
    CLLocationCoordinate2D delta  = CLLocationCoordinate2DMake(endGPS.latitude   - beginGPS.latitude,    endGPS.longitude   - beginGPS.longitude);
    CLLocationCoordinate2D result = CLLocationCoordinate2DMake(beginGPS.latitude + ratio*delta.latitude, beginGPS.longitude + ratio*delta.longitude);
    
    return result;
}


+(BOOL)isCoordinate:(CLLocationCoordinate2D)coordinate insideRegion:(MKCoordinateRegion)region{
	
    CLLocationCoordinate2D center   = region.center;
    CLLocationCoordinate2D northWestCorner, southEastCorner;
    
    northWestCorner.latitude  = center.latitude  - (region.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = center.longitude - (region.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = center.latitude  + (region.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = center.longitude + (region.span.longitudeDelta / 2.0);
    
    return((coordinate.latitude  >= northWestCorner.latitude)&&
           (coordinate.latitude  <= southEastCorner.latitude)&&
           (coordinate.longitude >= northWestCorner.longitude)&&
           (coordinate.longitude <= southEastCorner.longitude));
}


+(float)kmhFromMs:(float)speed{
    // km/h to m/sec
    return speed/3.6;
}


+(float)msFromKmh:(float)speed{
    // m/sec to km/h
    return speed*3.6;
}


+(NSArray*)polylineWithEncodedString:(NSString *)encodedString{
    const char *bytes = [encodedString UTF8String];
    NSUInteger length = [encodedString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    NSUInteger idx = 0;
	
    NSUInteger count = length / 4;
    CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
    NSUInteger coordIdx = 0;
	NSMutableArray *arrCoords = [[NSMutableArray alloc] init];
	
    float latitude = 0;
    float longitude = 0;
    while (idx < length) {
        char byte = 0;
        int res = 0;
        char shift = 0;
		
        do {
            byte = bytes[idx++] - 63;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
		
        float deltaLat = ((res & 1) ? ~(res >> 1) : (res >> 1));
        latitude += deltaLat;
		
        shift = 0;
        res = 0;
		
        do {
            byte = bytes[idx++] - 0x3F;
            res |= (byte & 0x1F) << shift;
            shift += 5;
        } while (byte >= 0x20);
		
        float deltaLon = ((res & 1) ? ~(res >> 1) : (res >> 1));
        longitude += deltaLon;
		
        float finalLat = latitude * 1E-5;
        float finalLon = longitude * 1E-5;
		
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(finalLat, finalLon);
        coords[coordIdx++] = coord;
		
		//		[arrCoords addObject:[NSValue valueWithMKCoordinate:coord]];
		[arrCoords addObject:[[CLLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude]];
		
        if (coordIdx == count) {
            NSUInteger newCount = count + 10;
            coords = realloc(coords, newCount * sizeof(CLLocationCoordinate2D));
            count = newCount;
        }
    }
	
    free(coords);
	
	return [NSArray arrayWithArray:arrCoords];
}


#pragma mark - Time

+(NSTimeInterval)timeIntervalSinceSystemBoot{
    
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    time_t now;
    time_t uptime = -1;
    
    (void)time(&now);
    
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0){
        uptime = now - boottime.tv_sec;
    }
    return uptime;
}


+(NSDate*)dateWithTimeSinceSystemBoot{
    
    struct timeval boottime;
    int mib[2] = {CTL_KERN, KERN_BOOTTIME};
    size_t size = sizeof(boottime);
    
    if (sysctl(mib, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0){
        return [NSDate dateWithTimeIntervalSince1970:boottime.tv_sec];
    }
    return [NSDate date];
}

+(NSDate*)absoluteDate:(NSDate *)date {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    theCalendar.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    dayComponent = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSDate *absDate = [theCalendar dateFromComponents:dayComponent];
    return absDate;
}

+(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime {
    
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSCalendarUnitDay startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSCalendarUnitDay
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

+ (BOOL)datesAreSame:(NSDate *)dateA and:(NSDate *)dateB {
    
    if ([dateA compare:dateB] == NSOrderedDescending || [dateA compare:dateB] == NSOrderedAscending) {
        return NO;
    } else {
      //  NSLog(@"dates are the same");
        return YES;
    }
}


#pragma mark - Easings

+(float)easyIn:(float)x{
    
    const float from = 0.0;
    const float to   = 1.0;
    
    x *= (M_PI/2.0);
    return to*sin(x)+from;
}


#pragma mark - Conversions

+(float)poundFromKg:(float)kg{
	
	return kg *2.20462;
}


+(float)feetFromMeter:(float)meter{
	
	return meter *3.28084;
}


+(float)inchFromMeter:(float)meter{
	
	return meter *39.3701;
}

+(float)kgFromPound:(float)pounds{
	
	return pounds /2.20462;
}


+(float)meterFromFeet:(float)feet{
	
	return feet /3.28084;
}


+(float)meterFromInch:(float)inch{
	
	return inch /39.3701;
}



@end


