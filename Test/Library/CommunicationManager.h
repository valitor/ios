//
//  CommunicationManager.h
//
//
//  Created by Jan Plesek on 03/05/16.
//  Copyright Â© 2016 Stokkur s.r.o. All rights reserved.
//
 

#import <Foundation/Foundation.h>
#import "VALAmount.h"
#import "VALCard.h"
#import "VALRequest.h"
#import <iSMP/iSMP.h>

@protocol BarrcodeDelegate <NSObject>
@optional
//barrcode data is given as NSString through this delegate method
-(void)didReceiveScanData:(NSString *)data;
@end


@interface CommunicationManager : NSObject{
}

#pragma mark - Scanner
//Scanner reads barrcodes
//And
@property (nonatomic, assign) id <BarrcodeDelegate> delegate;
//Starts the barrcode scanner
-(void)startScan;
//Stops the barrcode scanner
-(void)stopScan;

-(void)configureScannerForAllSymbols;
-(void)configureScannerForCustomSymbols;
-(void)configureScannerForQRorAztec;

#pragma mark - Macros for requests sending types
typedef enum : NSUInteger{
    
    AuthorizationTypeAuth =         100,
    AuhtorizationTypeMOTOAuth =     101,
    AuthorizationTypeAuthOnly =     102,
    AuhtorizationTypeVoiceAuth =    103,
}AuthorizationType;

typedef enum : NSUInteger{
    
    posPrintOptionSummaryList = 201,
    posPrintOptiontransactionList = 202,
}posPrintOption;

#pragma mark - General

//This class is used to manage communications with an Ingenico POS-Device running a Valitor Posi-Tengdur application. It contains methods to establish and teardown a TCP/IP connection on port 9599 with an Ingenico POS device through Bluetooth. Contains methods to both send an receive messages to the POS Device through NSStream.
+(id)manager;

@property (nonatomic, strong) NSMutableArray <NSString *> *arrConsoleMsgs;

//Specifies if the application should try Bluetooth+TCP connection when
//Application is resumed from background
@property (nonatomic) BOOL shouldReconnectOnAppResume;
-(void)shouldOpenTCPConnectionOnAppResume:(BOOL)shouldOpen;

//The current timeout value for requests sent from iOS POS. Default value is 180 seconds.
@property (nonatomic, readonly) int timeoutInSeconds;

//Changes the timeout value on the iOS side for requests sent from the iOS to POS.
-(void)setTimeoutForRequests:(int)seconds;

//Returns an array of paired bluetooth POS devices.
-(NSArray *)getConnectedTerminals;

#pragma mark - RequestQueue manipulation
//Empties the requestQueue, by removing all objects from the _arrRequests array. This method could come in handy if, for some reason, you need to clear pending requests to the POS device.
-(void)emptyRequestQueue;

//If the requestQueue contains the *requestToRemove, this method removes the *requestToRemove from the request queue.
-(void)removeRequestFromQueue:(VALRequest *)requestToRemove;



#pragma mark - Setup/teardown of ICPPP & ICAdministration shared instances
//Tries to open necessary bluetooth communication channels that are used to establish a TCP/IP connection through bluetooth.
-(void)setupChannels;

-(BOOL)bluetoothOpenChannelResult;

//Closes BT communication channels and stops the TCP server.
//NOTE:
//This method is also called in AppDelegate
//When the application is becoming inactive
//In order to gracefully disconnect from the POS device
-(void)closeChannels;

#pragma mark - TCP Server
//Starts a TCP server running on port 9599.
-(void)startTcpServer;


#pragma mark - Connectivety
//Checks wether or not the iOS device has a Bluetooth IP address. YES if iOS device has a Bluetooth IP Address, NO otherwise.
-(BOOL)hasBTConnection;

//Checks wether or not the POS device has been allocated an IP Address from the iOS device. YES if POS device has an IP Address, NO otherwise.
-(BOOL)hasTCPConnection;

#pragma mark - Send Ping
//Send a ping request to the POS device.
-(void)demandPingWithCompletionBlock:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                         statusBlock:(void(^)(NSString *strStatusMsg))blockStatus;

#pragma mark - Sales and authorizations requests
//Sends an authorization request to the POS device
-(void)demandAuthorizationWithType:(AuthorizationType)authType
                            Amount:(VALAmount *)amount
                              card:(VALCard *)card
                shouldPrintReceipt:(BOOL)print
             statusMessagesEnabled:(BOOL)statusMsgEnabled
                        completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                    statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus;

#pragma mark - Refund and Reverse requests
//Send a refund request to the POS device
-(void)demandRefundWithAmount:(VALAmount *)amount
                         card:(VALCard *)card
           shouldPrintReceipt:(BOOL)print
        statusMessagesEnabled:(BOOL)statusMsgEnabled
                   completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
               statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus;

//Sends a reversal request to the POS device, for a specific cardnumber and a specific authorization (via authToReverseMsgID parameter).
-(void)demandReversalWithAmount:(VALAmount *)amount
                           card:(VALCard *)card
             shouldPrintReceipt:(BOOL)print
          statusMessagesEnabled:(BOOL)statusMsgEnabled
                          msgID:(NSString*)msgID
                     completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                 statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus;

//Sends a 'send Batch' request to the POS Device.
-(void)demandBatchSendWithPrintOption:(BOOL)print
                statusMessagesEnabled:(BOOL)statusMsgEnabled
                           completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                       statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus;

//Gets last transaction. Passed via strRawResponse.
-(void)demandLastTransactionWithPosPrint:(BOOL)print
                   statusMessagesEnabled:(BOOL)statusMsgEnabled
                              completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                          statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus;

//Prints last receipt. Passed via strRawResponse
-(void)demandLastReceiptWithPosPrint:(BOOL)print
               statusMessagesEnabled:(BOOL)statusMsgEnabled
                          completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                      statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus;

//Prints summaryList or transactionList based on the posPrintOption parameter.
-(void)demandPrintListWithPosPrintOption:(posPrintOption)printOptionType
                         posPrintEnabled:(BOOL)print
                   statusMessagesEnabled:(BOOL)statusMsgEnabled
                              completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                          statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus;

//Sends a print command to the terminal. Refer to AmountToPos PDF for string formatting of print string.
-(void)demandLinePrintingWithPosPrintEnabled:(BOOL)print
                       statusMessagesEnabled:(BOOL)statusMsgEnabled
                                  strMessage:(NSString *)strMsg
                                  completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                              statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus;

#pragma mark - Class methods
//Parses the response message from the POS device into an NSDictionary. Supports for raw response & status messages.
+(NSDictionary *)parse:(NSString *)message;

@end
