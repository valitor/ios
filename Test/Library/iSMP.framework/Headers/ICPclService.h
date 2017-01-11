//
//  ICPclService.h
//  PCLService Library
//
//  Created by Stephane RABILLER on 04/12/14.
//  Copyright (c) 2014 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ICAdministration.h"
#import "ICAdministration+StandAlone.h"
#import "ICAdministration+iBP.h"
#import "ICPPP.h"

@interface ICSSLParameters : NSObject

@property(nonatomic, assign) BOOL isSSL;

@property(nonatomic, retain) NSMutableString *sslCertificateName;

@property(nonatomic, retain) NSMutableString *sslCertificatePassword;

@end

@interface ICTerminal : NSObject

@property(nonatomic, retain) NSMutableString *terminalName;

@property(nonatomic, retain) NSMutableString *terminalMacAddress;

@property(nonatomic, assign) BOOL isBluetooth;

@property(nonatomic, retain) NSMutableString *terminalIPAddress;

@end

@interface NSString (NSStringHexToBytes)

-(NSData*) hexToBytes;

@end

@protocol ICPclServiceDelegate;

typedef enum {
    PCL_SERVICE_STOPPED = 0,                        /**< The service is stopped */
    PCL_SERVICE_STARTED,                            /**< The service is started but not connected to the Telium device */
    PCL_SERVICE_CONNECTED,                          /**< The service is started and an iDevice is connected to Telium device */
    PCL_SERVICE_FAILED_NO_CNX,                      /**< The service can't start due to no Wi-Fi or local hotspot available */
    PCL_SERVICE_FAILED_INTERNAL                     /**< The service can't start due to internal error */
} pclServiceState;

@interface ICPclService : NSObject <ICAdministrationDelegate, ICISMPDeviceDelegate>

+(id) sharedICPclService;

@property (nonatomic, assign) id<ICPclServiceDelegate> delegate;

-(pclServiceState)startPclServiceWith:(ICTerminal*) terminal andSecurity:(ICSSLParameters *) sslParams;

-(pclServiceState)getPclServiceState;

-(void)stopPclService;

+(void)selectTerminal:(ICTerminal *)wantedDevice;

+(ICTerminal*) getSelectedTerminal;

-(NSMutableArray *)getAvailableTerminals;

-(BOOL)setTerminalTime;

-(NSDate *)getTerminalTime;

-(ICDeviceInformation)getTerminalInfo;

-(NSString*)getFullSerialNumber;

-(void)resetTerminal:(NSUInteger)resetInfo;

-(BOOL)inputSimul:(NSUInteger)key;

-(NSArray *)getTerminalComponents;

-(NSString *)getSpmciVersion;

-(NSString*)getAddonVersion;

-(BOOL)doUpdate;

-(iSMPResult)setTmsInformation:(ICTmsInformation*)tmsInfos;

-(ICTmsInformation*)getTmsInformation;

-(iSMPResult)setLockBacklight:(NSUInteger)lockValue;

-(BOOL)launchM2OSshorcut:(NSString*)shortcutManager;

-(BOOL)sendMessage:(NSData *)data;

-(void)doTransaction:(ICTransactionRequest)request;

-(void)doTransactionEx:(ICTransactionRequest)request withData:(NSData *)extendedData andApplicationNumber:(NSUInteger)appNum;

-(void)setDoTransactionTimeout:(NSUInteger)timeout;

-(NSUInteger)getDoTransactionTimeout;

-(BOOL)submitSignatureWithImage:(UIImage *)image;

-(iBPResult)openPrinter;

-(iBPResult)closePrinter;

/**
 @anchor     printText
 @brief      Request to print the text provided as parameter
 <p>
 The length of the string to be printed should not exceed 512 characters otherwise the call will fail.<br />
 This call is blocking and has a timeout of 15 seconds. Before print text you should choose the font using @ref iBPSetFont. If @ref setPrinterFont is not used the default font is ISO8859-15.
 </p>
 @param      text NSString object of the text to be printed. The  length of this string must be 512 characters at most.
 @result     One of the enumerations of @ref eiBPResult. It is iBPResult_OK when the call succeeds.
 */
-(iBPResult)printText:(NSString *)text;

-(iBPResult)printBitmap:(UIImage *)image;

-(iBPResult)printBitmap:(UIImage *)image lastBitmap:(BOOL)isLastBitmap;

-(iBPResult)printBitmap:(UIImage *)image size:(CGSize)bitmapSize alignment:(UITextAlignment)alignment;

-(iBPResult)printBitmap:(UIImage *)image size:(CGSize)bitmapSize alignment:(UITextAlignment)alignment lastBitmap:(BOOL)isLastBitmap;

-(iBPResult)storeLogoWithName:(NSString *)name andImage:(UIImage *)logo;

-(iBPResult)printLogoWithName:(NSString *)name;

-(iBPResult)getPrinterStatus;

/**
 @anchor     setPrinterFont
 @brief      Request to set the font provided as parameter
 <p>
 This call permits to select the font used to print text using @ref printText.
 </p>
 @param      selectedFontToTelium @ref eiBPFont enum encoding format ISO8859 supported by Telium.
 @result     One of the enumerations of @ref eiBPResult. It is iBPResult_OK when the call succeeds.
 */
-(iBPResult)setPrinterFont:(iBPFont *) selectedFontToTelium;

@property (nonatomic, readonly, getter = iBPMaxBitmapWidth) NSUInteger iBPMaxBitmapWidth;

@property (nonatomic, readonly, getter = iBPMaxBitmapHeight) NSUInteger iBPMaxBitmapHeight;

+(NSString*) severityLevelString:(int)level;

-(BOOL)setBacklightTimeout:(NSUInteger)backlightTimeout;

-(BOOL)setSuspendTimeout:(NSUInteger)suspendTimeout;

-(NSInteger)getBacklightTimeout;

-(NSInteger)getSuspendTimeout;

-(NSInteger)getBatteryLevel;

-(void)addDynamicBridge:(NSInteger)port :(int)redirection;

-(void)addDynamicBridgeLocal:(NSInteger)port :(int)redirection;

-(BOOL)setServerConnectionState:(BOOL)connectionState;

-(iSMPResult)setKeepAliveDelay:(int)keepAliveDelay Interval:(int)keepAliveInterVal andCount:(int)keepAliveCount;

@end

@protocol ICPclServiceDelegate

@optional

-(void)notifyConnection:(ICPclService *)sender;

-(void)notifyDisconnection:(ICPclService *)sender;

-(void)pclLogEntry:(NSString*)message withSeverity:(int)severity;

-(void)pclLogSerialData:(NSData*)data incoming:(BOOL)isIncoming;

-(void)shouldDoSignatureCapture:(ICSignatureData)signatureData;

-(void)signatureTimeoutExceeded;

-(void)transactionDidEndWithTimeoutFlag:(BOOL)replyReceived result:(ICTransactionReply)transactionReply andData:(NSData *)extendedData;

-(void)receiveMessage:(NSData *)data;

-(void)shouldPrintText:(NSString *)text withFont:(UIFont *)font alignment:(UITextAlignment)alignment XScaling:(NSInteger)xFactor YScaling:(NSInteger)yFactor underline:(BOOL)underline bold:(BOOL)bold;

-(void)shouldPrintRawText:(char *)text withCharset:(NSInteger)charset withFont:(UIFont *)font alignment:(UITextAlignment)alignment XScaling:(NSInteger)xFactor YScaling:(NSInteger)yFactor underline:(BOOL)underline bold:(BOOL)bold;

-(void)shouldPrintImage:(UIImage *)image;

-(void)shouldFeedPaperWithLines:(NSUInteger)lines;

-(void)shouldCutPaper;

-(NSInteger)shouldStartReceipt:(NSInteger)type;

-(NSInteger)shouldEndReceipt;

-(NSInteger)shouldAddSignature;

@end
