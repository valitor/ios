//
//  CommunicationManager.m
//
//
//  Created by Jan Plesek on 03/05/16.
//  Copyright Â© 2016 Stokkur s.r.o. All rights reserved.
//

#import "CommunicationManager.h"
#import "TcpServer.h"

#import <iSMP/ICISMPDevice.h>
#import <iSMP/ICISMPDeviceExtension.h>
#import "Constants.h"
#import "VALBaseClass.h"


@interface CommunicationManager() <ICISMPDeviceDelegate, ICPPPDelegate, ICAdministrationStandAloneDelegate, NSStreamDelegate, TcpServerDelegate, ICBarCodeReaderDelegate, ICAdministrationDelegate>

//Posi tengdur
@property(nonatomic, strong) NSMutableArray<VALRequest*> *arrRequests;

@property (strong , nonatomic) NSMutableArray *arrBTConnectedTerminals;
@property (nonatomic, strong) ICPPP *pppChannel; //Instance of the ICPPP Singleton
@property (nonatomic, strong) ICAdministration *configurationChannel; //Instance of the ICAdministration Singleton
@property (nonatomic, strong) TcpServer *tcpServer;
@property (nonatomic, strong) ICISMPDevice *device;
@property (nonatomic, strong) NSMutableString *log;
@property (nonatomic) BOOL deviceReady;
@property (nonatomic) BOOL logToFile;
@property (nonatomic, strong) NSString *strMsgType;
@property (nonnull, strong) NSString *strMsgCode;
@property (nonatomic) unsigned long msgTypeForRandCalculations;
@property (nonatomic, strong) NSMutableArray<VALRequest *> *arrCompletedRequests;
@property (nonatomic, retain) ICBarCodeReader *barcodeReader;
@property (nonatomic) double scanTime;
@property (nonatomic) double scanTimeAverage;
@property (nonatomic) long long barcodeCount;
@property (nonatomic) BOOL gotFirstScan;
@end

@implementation CommunicationManager


+(id)manager{
    static CommunicationManager *manager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
        manager.arrRequests = [NSMutableArray new];
        [manager setTimeoutForRequests:POS_TIMEOUT];
        manager.arrConsoleMsgs = [NSMutableArray new];
        manager.scanTime = 0;
        manager.scanTimeAverage = 0;
        manager.barcodeCount = 0;
        manager.gotFirstScan = NO;
        manager.barcodeReader = [ICBarCodeReader sharedICBarCodeReader];
        manager.barcodeReader.delegate = manager;
        manager.barcodeReader.iscpRetryCount = 100;
        manager.device.delegate = manager;
        manager.shouldReconnectOnAppResume = NO;
    });
    return manager;
}

//Scanner

-(void)accessoryDidConnect:(ICISMPDevice *)sender {
    NSLog(@"AccesoryDidConnect");

}

-(void)shouldOpenTCPConnectionOnAppResume:(BOOL)shouldOpen{
    
    self.shouldReconnectOnAppResume = shouldOpen;
}

-(void)configureScannerForAllSymbols{
    
    [self.barcodeReader enableSymbology:ICBarCode_AllSymbologies enabled:YES];
}

-(void)configureScannerForCustomSymbols{
    
    [self.barcodeReader bufferWriteCommands];
    
    //Below are example on how to use the eICBarCodeSymbologies enum for configuration
    //int symbologies[] = {ICBarCode_EAN13, ICBarCode_UPCA, ICBarCode_GS1_128, ICBarCode_Code39, ICBarCode_Code128 };
    
    int symbologies[] = {ICBarCode_UPCA, ICBarCode_Code128, ICBarCode_GS1_128 };
    
    [self.barcodeReader enableSymbologies:symbologies symbologyCount:sizeof(symbologies)/sizeof(symbologies[0])];
    [self.barcodeReader unbufferSetupCommands];
}

-(void)configureScannerForQRorAztec{
    
    //Examples on how to configure the scanner for Aztec or QR
    
    [self.barcodeReader enableSymbologies:NULL symbologyCount:0];
    //[self.barcodeReader enableSymbology:ICBarCode_Aztec enabled:YES];
    [self.barcodeReader enableSymbology:ICBarCode_QRCode enabled:YES];
}

-(void)startScan{
    
    if([self.barcodeReader powerOn] == ICBarCodeReader_PowerOnSuccess){
        
        /**< The powerOn command was successful */
        [self.barcodeReader startScan];
        NSLog(@"Scanner: %@", self.barcodeReader);
        NSLog(@"Scanner started");
    }
    else if( [self.barcodeReader powerOn] == ICBarCodeReader_PowerOnFailed){
        
        /**< The powerOn command failed due to a synchronization problem */
        NSLog(@"Failed to start barrcode reader");
    }
    else if ( [self.barcodeReader powerOn] == ICBarCodeReader_PowerOnDenied){
        /**< The powerOn command was forbidden. This happens when the device is charging on the craddle */
        NSLog(@"PowerOn denied");
    }
    
    
}

-(void)stopScan{
    
    [self.barcodeReader stopScan];
    NSLog(@"Scanner: %@", self.barcodeReader);
    NSLog(@"Scanner stopped");
}

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender {

    
}

-(void)barcodeData:(id)data ofType:(int)type {
    
    
    if([data isKindOfClass:[NSString class]]){
        
        NSString *strData = data;
        NSLog(@"ScannedData: %@", strData);
        if([self.delegate respondsToSelector:@selector(didReceiveScanData:)]){
            [self.delegate didReceiveScanData:strData];
        }
    }
    [self.barcodeReader startScan];
}

//End of scanner

-(void)setTimeoutForRequests:(int)seconds{
    
    _timeoutInSeconds = seconds;
}

-(NSArray *)getConnectedTerminals{
    
    return [ICISMPDevice getConnectedTerminals];
}

#pragma mark - TCP Start / Stop
-(void)startTcpServer {
    NSLog(@"%s", __FUNCTION__);
    [_arrConsoleMsgs addObject:@"startTcpServer"];
    
    self.tcpServer = [[TcpServer alloc] init];
    self.tcpServer.port = 9599;
    self.tcpServer.delegate = self;
    self.tcpServer.streamDelegate = self;
    [self.tcpServer startServer];
}

-(BOOL)bluetoothOpenChannelResult{
    
    if([[[CommunicationManager manager] pppChannel] openChannel] == ISMP_Result_SUCCESS){
        return YES;
    }
    else return NO;
}

-(void)startTcpServerAgain{
    
    NSLog(@"TcpServerPort: %lu", (unsigned long)_tcpServer.port);
    [_arrConsoleMsgs addObject:[NSString stringWithFormat:@"TcpServerPort: %lu", (unsigned long)_tcpServer.port]];
    [self.tcpServer startServer];
}

-(void)stopTcpServer {
    NSLog(@"%s", __FUNCTION__);
    [_arrConsoleMsgs addObject:@"StopTcpServer"];
    self.tcpServer = nil;
}

-(BOOL)hasTCPConnection{
    
    if(self.tcpServer.peerName){
        if([self.tcpServer.peerName length] > 0){
            return YES;
        }
        else return NO;
        
    }
    else return NO;
}

-(BOOL)hasBTConnection{
    
    if([_pppChannel IP]){
        if([[_pppChannel IP] length]>1){
            return YES;
        }
        else return NO;
    }
    else return NO;
}

#pragma mark - TCPServerDelegate

-(void)connectionEstablished:(TcpServer *)sender {
    NSLog(@"%s", __FUNCTION__);
    
    //Callback from when TCP connection is established
    
    [_arrConsoleMsgs addObject:[NSString stringWithFormat:@"Client Connected [Name:%@]", self.tcpServer.peerName]];
    NSLog(@"Client Connected [Name: %@]", self.tcpServer.peerName);
    
}

-(void)setupChannels{
    
    _pppChannel = [ICPPP sharedChannel];
    _pppChannel.delegate = self;
    _configurationChannel = [ICAdministration sharedChannel];
    _configurationChannel.delegate = self;
}

-(void)closeChannels{
    
    [_pppChannel closeChannel];
    [_configurationChannel close];
    
    //Stop TCP Servers
    [self stopTcpServer];
    
    //Log Activity
    [_arrConsoleMsgs addObject:@"Closing PPP"];
    NSLog(@"Closing PPP");
}

#pragma mark ICPPPDelegate

-(void)pppChannelDidOpen {
    
    //Start listening on port 9599
    [_pppChannel addTerminalToiOSBridgeOnPort:9599];
    
    NSLog(@"%s", __FUNCTION__);
    if ([(NSObject *)_configurationChannel respondsToSelector:@selector(open)]) {
        
        [_arrConsoleMsgs addObject:[NSString stringWithFormat:@"Open session on device : %@", [ICISMPDevice getWantedDevice]]];
        NSLog(@"Open session on device : %@", [ICISMPDevice getWantedDevice]);
        [_configurationChannel open];
        
    }
    
}

-(void)pppChannelDidClose {
    
    NSLog(@"%s", __FUNCTION__);
    [_arrConsoleMsgs addObject:@"PPP Diconnected!"];
    NSLog(@"PPP Disconnected!!");
}

#pragma mark - Request sending/handling

-(void)removeRequestFromQueue:(VALRequest *)requestToRemove{
    
    if([_arrRequests containsObject:requestToRemove]){
        [_arrRequests removeObject:requestToRemove];
    }
}

-(void)emptyRequestQueue{
    
    [_arrRequests removeAllObjects];
}

-(void)processRequest:(VALRequest *)request{
    
    if( request.requestState ==(RequestStateReadyToSend) ){
        [request changeRequestStateTo:RequestStateWaitingForInitialAnswer];
        [self sendStringMessageToPos:request.strRequest];
    }
    else if( request.requestState == RequestStateGotInitialAnswer ){
        [request changeRequestStateTo:RequestSateSentMessageDeliveredConfirmation];
        
        if(request.needsMsgDelivered){
            [request setStrMessageDelivered];
            [self sendStringMessageToPos:request.strMessageDelivered];
        }
    }
    
    else{
        NSLog(@"");
    }
}

-(void)addRequestToQueue:(VALRequest*)request{
    
    [_arrRequests addObject:request];
    [self checkLastRequest];
}


-(void)checkLastRequest{
    
    //Check for timeout here?
    
    if([_arrRequests count] > 0){
        
        VALRequest *request = [_arrRequests firstObject];
        
        if ( request.requestState == RequestStateReadyToSend){	// (1)
            [self processRequest:request];
        }
        else if ( request.requestState == RequestStateWaitingForInitialAnswer){	// (2)
            //do nothing, waiting for response
        }
        else if ( request.requestState == RequestStateGotInitialAnswer){	// (3)
            [self processRequest:request];
        }
        else if ( request.requestState == RequestSateSentMessageDeliveredConfirmation){	// (4)
            //do nothing, waiting for response
        }
        else if( request.requestState == RequestStateGotConfirmationMessageWithApproved){	// (5) you already get confirmation from device
            
            [_arrRequests removeObject:request];
            
            if([_arrRequests count] > 0){
                [self processRequest:[_arrRequests firstObject]];
            }
        }
        else if( request.requestState == RequestStateGotConfirmationMessageWithNotApproved){
            //Timout has occured, transaction voided, not stored
            
            [_arrRequests removeObject:request];
            if([_arrRequests count] > 0){
                [self processRequest:[_arrRequests firstObject]];
            }
        }

    }
}

#pragma mark - Request Parsers

-(void)demandPingWithCompletionBlock:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                         statusBlock:(void(^)(NSString *strStatusMsg))blockStatus{
    
    //REQ:  MsgType=0800&
    //      MsgCode=300&
    
    //RES:  MsgType=0810&
    //      MsgCode=300&
    NSDictionary *dictPing = @{VALITOR_KEY_MSG_TYPE:VALITOR_MSG_TYPE_BATCH_SENDING,
                               VALITOR_KEY_MSG_CODE:VALITOR_MSG_CODE_FOR_PING};
    
    
    
    VALRequest *request = [[VALRequest alloc] initWithDict:dictPing
                                         needsMsgDelivered:NO
                                    needsCheckCalculations:NO
                                           completionBlock:blockCompletion
                                               statusBlock:blockStatus];
    [self addRequestToQueue:request];
    
    
}



//**************
//There are four types of Authorizations
//I.    Authorization, which is the equavilant of a Sale. MsgType= (Req: 0100/ Resp:0110)
//II.   MOTO-Authorization, which is a phone-payment. MsgType= (Req: 0101 / Resp: 0111)
//III.  AuthorizationONLY, which just checks authorization and doesn't make a sale. MsgType=(Req: 0102/ Resp: 0122)
//IV.   Voice-Authorization, which is "Register payment afterwards" kind of payment. MsgType=(Req: 0103/ Resp: 0113)
//Communication Protocol for authorizations: https://stokkur.atlassian.net/wiki/display/VAL/Valitor+communication+protocol+rules
//**************
-(void)demandAuthorizationWithType:(AuthorizationType)authType
                            Amount:(VALAmount *)amount
                              card:(VALCard *)card
                shouldPrintReceipt:(BOOL)print
             statusMessagesEnabled:(BOOL)statusMsgEnabled
                        completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                    statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus{
    
    
    NSString *strPrint = print?@"1":@"0";
    NSString *strStatusMsgs = statusMsgEnabled?@"1":@"0";
    BOOL needsMsgDelivered = YES;
    
    _strMsgType = [NSString stringWithFormat:@"%04lu",(unsigned long)authType];
    switch (authType) {
        case AuthorizationTypeAuth:
            _msgTypeForRandCalculations = AuthorizationTypeAuth;
            break;
        case AuthorizationTypeAuthOnly:
            _msgTypeForRandCalculations = AuthorizationTypeAuthOnly;
            needsMsgDelivered = NO;
            break;
        case AuhtorizationTypeMOTOAuth:
            _msgTypeForRandCalculations = AuhtorizationTypeMOTOAuth;
            break;
        case AuhtorizationTypeVoiceAuth:
            _msgTypeForRandCalculations = AuhtorizationTypeVoiceAuth;
            break;
        default:
            break;
    }
    
    NSDictionary *dictAuthorization = @{VALITOR_KEY_MSG_TYPE: _strMsgType,
                                        VALITOR_KEY_TRANSACTION_AMOUNT: [NSString stringWithFormat:@"%lu",amount.amountInCents],
                                        VALITOR_KEY_TRANSACTION_CURRENCY: amount.currency,
                                        VALITOR_KEY_POS_PRINT: strPrint,
                                        VALITOR_KEY_CARD_TYPE: card.cardType,
                                        VALITOR_KEY_STATUS: strStatusMsgs};
    
    VALRequest *request = [[VALRequest alloc] initWithDict:dictAuthorization
                                         needsMsgDelivered:needsMsgDelivered
                                    needsCheckCalculations:YES
                                           completionBlock:blockCompletion
                                               statusBlock:blockStatus];
    [self addRequestToQueue:request];
}

//MsgType=(Req: 0200/ Resp: 2010)
//Not an authorization
//Difference between a refund and a reversal
//is that a reversal voids a transaction
//That hasn't been registered
//But a refund then you actually see the
//refund on your card bill
-(void)demandRefundWithAmount:(VALAmount *)amount
                         card:(VALCard *)card
           shouldPrintReceipt:(BOOL)print
        statusMessagesEnabled:(BOOL)statusMsgEnabled
                   completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
               statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus{
    
    
    NSString *strPrint = print?@"1":@"0";
    NSString *strStatusMsgs = statusMsgEnabled?@"1":@"0";
    
    
    
    _strMsgType = VALITOR_MSG_TYPE_REFUND;
    _msgTypeForRandCalculations = VALITOR_MSG_TYPE_REFUND_FOR_RAND;
    
    
    NSDictionary *dictRefund = @{VALITOR_KEY_MSG_TYPE: _strMsgType,
                                 VALITOR_KEY_TRANSACTION_AMOUNT: [NSString stringWithFormat:@"%lu",amount.amountInCents],
                                 VALITOR_KEY_TRANSACTION_CURRENCY: amount.currency,
                                 VALITOR_KEY_POS_PRINT: strPrint,
                                 VALITOR_KEY_CARD_TYPE: card.cardType,
                                 VALITOR_KEY_STATUS: strStatusMsgs,
                                 };
    
    
    
    VALRequest *request = [[VALRequest alloc] initWithDict:dictRefund
                                         needsMsgDelivered:YES
                                    needsCheckCalculations:YES
                                           completionBlock:blockCompletion
                                               statusBlock:blockStatus];
    
    
    [self addRequestToQueue:request];
}


//MsgType=(Req: 0400 / Resp: 0410)
//This seems to be the only one that uses cardNumberShort & msgID
//MessageDelivery NOT ALLOWED - need clarification
-(void)demandReversalWithAmount:(VALAmount *)amount
                           card:(VALCard *)card
             shouldPrintReceipt:(BOOL)print
          statusMessagesEnabled:(BOOL)statusMsgEnabled
                          msgID:(NSString*)msgID
                     completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                 statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus{
    
    
    
    NSString *strPrint = print?@"1":@"0";
    NSString *strStatusMsgs = statusMsgEnabled?@"1":@"0";
    
    
    _strMsgType = VALITOR_MSG_TYPE_REVERSE;
    _msgTypeForRandCalculations = VALITOR_MSG_TYPE_REVERSE_FOR_RAND;
    
    NSDictionary *dictReversal = @{VALITOR_KEY_MSG_TYPE: _strMsgType,
                                   VALITOR_KEY_TRANSACTION_AMOUNT: [NSString stringWithFormat:@"%lu",amount.amountInCents],
                                   VALITOR_KEY_TRANSACTION_CURRENCY: amount.currency,
                                   VALITOR_KEY_POS_PRINT: strPrint,
                                   VALITOR_KEY_CARD_TYPE: card.cardType,
                                   VALITOR_KEY_STATUS: strStatusMsgs,
                                   VALITOR_KEY_MSG_ID: msgID,
                                   VALITOR_KEY_CARD_NUMBER_SHORT: card.cardNumberShort
                                   };
    
    
    VALRequest *request = [[VALRequest alloc] initWithDict:dictReversal
                                         needsMsgDelivered:NO
                                    needsCheckCalculations:YES
                                           completionBlock:blockCompletion
                                               statusBlock:blockStatus];
    
    [self addRequestToQueue:request];
}


//Send Batch
-(void)demandBatchSendWithPrintOption:(BOOL)print
                statusMessagesEnabled:(BOOL)statusMsgEnabled
                           completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                       statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus{
    
    NSString *strPrint = print?@"1":@"0";
    NSString *strStatusMsgs = statusMsgEnabled?@"1":@"0";
    
    
    _strMsgType = VALITOR_MSG_TYPE_BATCH_SENDING;
    _strMsgCode = VALITOR_MSG_CODE_POS_SEND_BATCH;
    _msgTypeForRandCalculations = VALITOR_MSG_TYPE_BATCH_SENDING_FOR_RAND;
    
    NSDictionary *dictBatch = @{VALITOR_KEY_MSG_TYPE: _strMsgType,
                                VALITOR_KEY_MSG_CODE: _strMsgCode,
                                VALITOR_KEY_POS_PRINT: strPrint,
                                VALITOR_KEY_STATUS: strStatusMsgs,
                                };
    
    VALRequest *request = [[VALRequest alloc] initWithDict:dictBatch
                                         needsMsgDelivered:NO
                                    needsCheckCalculations:YES
                                           completionBlock:blockCompletion
                                               statusBlock:blockStatus];
    
    [self addRequestToQueue:request];
}



-(void)demandLastTransactionWithPosPrint:(BOOL)print
                   statusMessagesEnabled:(BOOL)statusMsgEnabled
                              completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                          statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus{
    
    NSString *strPrint = print?@"1":@"0";
    NSString *strStatusMsgs = statusMsgEnabled?@"1":@"0";
    
    _strMsgType = VALITOR_MSG_TYPE_BATCH_SENDING;
    _strMsgCode = VALITOR_MSG_CODE_GET_LAST_TRANSACTION;
    _msgTypeForRandCalculations = VALITOR_MSG_TYPE_BATCH_SENDING_FOR_RAND;
    
    NSDictionary *lastTransactionDict = @{VALITOR_KEY_MSG_TYPE: _strMsgType,
                                          VALITOR_KEY_MSG_CODE: _strMsgCode,
                                          VALITOR_KEY_POS_PRINT: strPrint,
                                          VALITOR_KEY_STATUS: strStatusMsgs
                                          };
    
    
    VALRequest *request = [[VALRequest alloc] initWithDict:lastTransactionDict
                                         needsMsgDelivered:NO
                                    needsCheckCalculations:YES
                                           completionBlock:blockCompletion
                                               statusBlock:blockStatus];
    [self addRequestToQueue:request];
    
}



-(void)demandLastReceiptWithPosPrint:(BOOL)print
               statusMessagesEnabled:(BOOL)statusMsgEnabled
                          completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                      statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus{
    
    NSString *strPrint = print?@"1":@"0";
    NSString *strStatusMsgs = statusMsgEnabled?@"1":@"0";
    
    _strMsgType = VALITOR_MSG_TYPE_BATCH_SENDING;
    _strMsgCode = VALITOR_MSG_CODE_GET_LAST_RECEIPT;
    
    NSDictionary *lastReceiptDict = @{VALITOR_KEY_MSG_TYPE: _strMsgType,
                                      VALITOR_KEY_MSG_CODE: _strMsgCode,
                                      VALITOR_KEY_POS_PRINT: strPrint,
                                      VALITOR_KEY_STATUS: strStatusMsgs
                                      };
    
    
    VALRequest *request = [[VALRequest alloc] initWithDict:lastReceiptDict
                                         needsMsgDelivered:NO
                                    needsCheckCalculations:YES
                                           completionBlock:blockCompletion
                                               statusBlock:blockStatus];
    [self addRequestToQueue:request];
}



-(void)demandPrintListWithPosPrintOption:(posPrintOption)printOptionType
                         posPrintEnabled:(BOOL)print
                   statusMessagesEnabled:(BOOL)statusMsgEnabled
                              completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                          statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus{
    
    
    NSString *strPrint = print?@"1":@"0";
    NSString *strStatusMsgs = statusMsgEnabled?@"1":@"0";
    _strMsgType = VALITOR_MSG_TYPE_BATCH_SENDING;
    _strMsgCode = [NSString stringWithFormat:@"%03lu", (unsigned long)printOptionType];
    
    NSDictionary *printListDict = @{VALITOR_KEY_MSG_TYPE: _strMsgType,
                                    VALITOR_KEY_MSG_CODE: _strMsgCode,
                                    VALITOR_KEY_POS_PRINT: strPrint,
                                    VALITOR_KEY_STATUS: strStatusMsgs
                                    };
    
    VALRequest *request = [[VALRequest alloc] initWithDict:printListDict
                                         needsMsgDelivered:NO
                                    needsCheckCalculations:YES
                                           completionBlock:blockCompletion
                                               statusBlock:blockStatus];
    [self addRequestToQueue:request];
    
}

-(void)demandLinePrintingWithPosPrintEnabled:(BOOL)print
                       statusMessagesEnabled:(BOOL)statusMsgEnabled
                                  strMessage:(NSString *)strMsg
                                  completion:(void(^)(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered))blockCompletion
                              statusMsgBlock:(void(^)(NSString *strStatusMsg))blockStatus{
    
    
    NSString *strPrint = print?@"1":@"0";
    NSString *strStatusMsgs = statusMsgEnabled?@"1":@"0";
    
    _strMsgType = VALITOR_MSG_TYPE_BATCH_SENDING;
    _strMsgCode = VALITOR_MSG_CODE_POS_LINE_PRINT;
    
    NSDictionary *linePrintDict = @{VALITOR_KEY_MSG_TYPE: _strMsgType,
                                    VALITOR_KEY_MSG_CODE: _strMsgCode,
                                    VALITOR_KEY_POS_PRINT: strPrint,
                                    VALITOR_KEY_STATUS: strStatusMsgs,
                                    VALITOR_KEY_MISC_PRINT: strMsg
                                    };
    
    
    
    VALRequest *request = [[VALRequest alloc] initWithDict:linePrintDict
                                         needsMsgDelivered:NO
                                    needsCheckCalculations:YES
                                           completionBlock:blockCompletion
                                               statusBlock:blockStatus];
    
    [self addRequestToQueue:request];
}



#pragma mark - Send / Receive messages via TCP/IP
//Send
-(void)sendStringMessageToPos:(NSString *)msg {
    NSLog(@"%s", __FUNCTION__);
    [_arrConsoleMsgs addObject:@"Trying to send Message to POS"];
    
    uint8_t * buffer = (uint8_t *)[msg UTF8String];
    NSInteger offset = 0, len = 0, messageLen = [msg lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    if ([self.tcpServer.outputStream streamStatus] == NSStreamStatusOpen) {
        while (offset < messageLen) {
            len = [self.tcpServer.outputStream write:&buffer[offset] maxLength:messageLen - len];
            
            if(msg){
                [_arrConsoleMsgs addObject:[NSString stringWithFormat:@"Message sent to POS: %@", msg]];
                NSLog(@"Message sent to POS: %@", msg);
            }
            if (len > 0) {
                offset += len;
            } else if (len < 0) {
                [_arrConsoleMsgs addObject:@"Error occured while sending messages"];
                NSLog(@"Error occured while sending messages");
                break;
            }
        }
    }
    else{
        [_arrConsoleMsgs addObject:@"TCP streams aren't open, unable to send message"];
    }
}


+(NSDictionary *)parse:(NSString *)message{
    
#define DICT_VALUE 1
#define DICT_KEY 0
    
    
    if(message){
        NSArray<NSString *> *arrKeyAndValue = [message componentsSeparatedByString:@"&"];
        NSMutableArray *arrMutable = [NSMutableArray new];
        NSMutableDictionary *mutDict = [NSMutableDictionary new];
        
        for(NSString *str in arrKeyAndValue){
            
            [arrMutable addObject:[str componentsSeparatedByString:@"="]];
        }
        
        for(NSArray *arr in arrMutable){
            
            if([arr count] >1){
                
                [mutDict setValue:arr[DICT_VALUE] forKey:arr[DICT_KEY]];
            }
        }
        return [NSDictionary dictionaryWithDictionary:mutDict];
    }
    else{
        return nil;
    }
    
}

#pragma mark - NSStreamDelegate
#define BUFFER_SIZE     16392
//Receive
-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
    uint8_t buffer[BUFFER_SIZE];
    
    int len = 0;
    
    switch (eventCode) {
        case NSStreamEventOpenCompleted:
            break;
        case NSStreamEventHasBytesAvailable:
            //Display the received data
            if (aStream == self.tcpServer.inputStream) {
                len = (int)[self.tcpServer.inputStream read:buffer maxLength:sizeof(buffer)];
                if (len > 0) {
                    
                    NSString *message = [[NSString alloc] initWithBytes:buffer length:len encoding:NSISOLatin1StringEncoding];
                    if (message != nil) {
                        
                        [self handleMessageFromPos:message];
                    }
                }
            }
            break;
        case NSStreamEventHasSpaceAvailable:{
            if(aStream == _tcpServer.outputStream){
            }
            break;
        }
            break;
        case NSStreamEventEndEncountered:
            if ((aStream == self.tcpServer.inputStream) || (aStream == self.tcpServer.outputStream)) {
                [_arrConsoleMsgs addObject:@"Tcp Server Streams did close"];
                NSLog(@"Tcp Server Streams did close");
            }
            break;
        case NSStreamEventErrorOccurred:
            if ((aStream == self.tcpServer.inputStream) || (aStream == self.tcpServer.outputStream)) {
                [_arrConsoleMsgs addObject:@"Tcp server streams encountered an Error"];
                NSLog(@"Tcp Server Streams Encountered an Error");
            }
            break;
        default:
            break;
    }
}

-(BOOL)isMessageStatusMessage:(NSDictionary *)dictMsg{
    
    if([dictMsg[VALITOR_KEY_MSG_CODE] isEqualToString:VALITOR_MSG_CODE_STATUS]){
        return YES;
    }
    else{
        return NO;
    }
}

-(BOOL)isMessageConfirmationOfMessageDelivered:(NSDictionary *)dictMsg{
    
    if([dictMsg[@"MsgType"] isEqualToString:VALITOR_MSG_TYPE_BATCH_RESPONSE] && [dictMsg[VALITOR_KEY_MSG_CODE] isEqualToString:VALITOR_MSG_CODE_FOR_MSG_DELIVERED]){
        return YES;
    }
    else{
        return NO;
    }
}

-(BOOL)isMessageContinuationOfAnotherMsg:(NSString *)msg{
    
    //If message doesn't start with 'MsgType=...."
    //Then we can assume the message is a continuation of another message
    //This can happen when, for example, a receipt is really long
    
    NSArray<NSString *>  *arrMsg = [msg componentsSeparatedByString:@"="];
    
    if([arrMsg count] >0){
        
        if(! [[arrMsg firstObject] isEqualToString:@"MsgType"]){
            return YES;
        }
        else{
            return NO;
        }
    }
    else{
        return NO;
    }
}


-(BOOL)isMsgACompleteMsg:(NSString *)msg{
    
    //The last key in a message, in a request that needs message delivered
    //is the CheckValue key
    //Therefore we can check wether or not the message is a complete message, if and only if the request response
    //Has the check value key included in the message
    //In the unlikely event that the string contains the CheckValue, but is cut off after the
    //Check string, we can check if the msg ends with an '&' char
    //Because the check value key has the format
    //Check=XXXX&
    NSArray *arrMsg = [msg componentsSeparatedByString:@"="];
    
    if([msg containsString:@"Check"] && [msg hasSuffix:@"&"]){
        if([arrMsg count] > 0){
            if([[arrMsg firstObject] isEqualToString:VALITOR_KEY_MSG_TYPE]){
                return YES;
            }
            else{
                return NO;
            }
        }
        return NO;
    }
    else{
        return NO;
    }
}

-(BOOL)doesMsgContainFirstPartOfMsg:(NSString *)msg{
    
    NSArray *arrMsg = [msg componentsSeparatedByString:@"="];
    if([arrMsg count] > 0){
        if([[arrMsg firstObject] isEqualToString:VALITOR_KEY_MSG_TYPE]){
            return YES;
        }
        else{
            return NO;
        }
    }
    else{
        return NO;
    }
}

-(void)handleMessageFromPos:(NSString *)message{
    
    VALRequest *request = [_arrRequests firstObject];
    //If the message is a status message or a message delivered message we don't have to respond to those messages
    
    if( ! [self isMessageStatusMessage:[CommunicationManager parse:message]]){
        
        if(request.needsMsgDelivered){
            //Types that require MessageDelivered: Authorization, MOTOAuthorization, VoiceAuthorization
            
            
            if( request.requestState == RequestStateWaitingForInitialAnswer ){
                
                if([[CommunicationManager parse:message][VALITOR_KEY_MSG_TYPE] isEqualToString:VALITOR_MSG_TYPE_ERROR]){
                    //error
                    // case (A) - iOS integrity corrupted
                    // case (C) - semantic error
                    [request changeTimeoutStateTo:RequestTimeoutStateResponded];
					[request callCompletionBlockForRequest:request
                                                   success:NO
                                                    rawResponse:message
												   msgDeliveredResponse:nil];
                    [request changeRequestStateTo:RequestStateGotConfirmationMessageWithNotApproved];
                }
                else if( ![request isCheckValueCorrectWithMsgType:[[CommunicationManager parse:message][VALITOR_KEY_MSG_TYPE] intValue]
                                                      transAmount:[[CommunicationManager parse:message][VALITOR_KEY_TRANSACTION_AMOUNT] intValue]
                                                    posCheckValue:[[CommunicationManager parse:message][VALITOR_KEY_CHECK_VALUE] intValue]] ){
                    //case (B) - POS integrity corrupted
                    [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                    [request callCompletionBlockForRequest:request
                                                   success:NO
                                               rawResponse:nil
                                      msgDeliveredResponse:nil];
                    [request changeRequestStateTo:RequestStateGotConfirmationMessageWithNotApproved];
                }
                
                else{
                    [request setStrResponse:message];
                    [request changeRequestStateTo:RequestStateGotInitialAnswer];
                    [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                }
            }
            else if( request.requestState == RequestSateSentMessageDeliveredConfirmation ){
                
                if(![request isCheckValueCorrectWithMsgType:[[CommunicationManager parse:message][VALITOR_KEY_MSG_TYPE] intValue]
                                                transAmount:[[CommunicationManager parse:message][VALITOR_KEY_TRANSACTION_AMOUNT] intValue]
                                              posCheckValue:[[CommunicationManager parse:message][VALITOR_KEY_CHECK_VALUE] intValue]]){
                    //case (B) - POS integrity corrupted
                    [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                    [request callCompletionBlockForRequest:request
                                                   success:NO
                                               rawResponse:nil
                                      msgDeliveredResponse:nil];
                    [request changeRequestStateTo:RequestStateGotConfirmationMessageWithNotApproved];
                }
                else if([[CommunicationManager parse:message][VALITOR_KEY_MSG_TYPE] isEqualToString:VALITOR_MSG_TYPE_ERROR]){	//error
                    // case (A) - iOS integrity corrupted
                    // case (C) - semantic error
                    [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                    [request callCompletionBlockForRequest:request
                                                   success:NO
                                               rawResponse:message
                                      msgDeliveredResponse:nil];
                    [request changeRequestStateTo:RequestStateGotConfirmationMessageWithNotApproved];
                }
                else{
                    
                    [request setStrMessageDeliveredResponse:message];
                    [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                    [request callCompletionBlockForRequest:request
                                                   success:YES
                                               rawResponse:[request strResponse]
                                      msgDeliveredResponse:[request strMsgDeliveredResponse]];
                    [request changeRequestStateTo:RequestStateGotConfirmationMessageWithApproved];
                }
            }
            else{
                //error
                //TODO: some log
            }
        }
        else{
            //Types that dont need Message Delivered: PING, AuthorizationONLY, Reversal, Batch sending, LastReceipt, LastTransaction, PrintSummaryList, PrintTransactionList
            
            if(request.needsCheckCalculations){
                
                if(request.requestState == RequestStateWaitingForInitialAnswer){
                    
                    if([[CommunicationManager parse:message][VALITOR_KEY_MSG_TYPE] isEqualToString:VALITOR_MSG_TYPE_ERROR]){
                        //error
                        // case (A) - iOS integrity corrupted
                        // case (C) - semantic error
                        [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                        [request callCompletionBlockForRequest:request
                                                       success:NO
                                                   rawResponse:message
                                          msgDeliveredResponse:nil];
                        [request changeRequestStateTo:RequestStateGotConfirmationMessageWithNotApproved];
                    }
                    else{
                        
                        //Batch Sending and SummarList actions can trigger a response that
                        //comes in multiple part from the delegate
                        
                        //1. Check if message is a complete message
                        //
                        //2. If it's a complete message, process it and call request block, change state to last state
                        //
                        //3. If message is not a complete message we need to
                        //   i)Check if it is the first part of the non-complete message
                        //     and if so, we set the strRequest property of a VALRequest to that string. Don't call the completion
                        //     block and don't change the state of the request.
                        //
                        //   ii)If it's not the first part of the complete message we need to combine it with the first
                        //      non-complete message. After that has been done we need to check if that combined message
                        //      is a complete message. If it's a complete message we change the request state and run the completion block
                        //      If that combined message is NOT a complete message, we set the strRequest property of the request to that string,
                        //      don't call the completion block and don't change the state
                        //
                        //      This ensures that when next message comes through the delegate (part nr 3,4,5...)
                        //      The request.strRequest property contains the earlier arrived messages
                        //      And the state of the requests still hasn't been set to final state which which will allow further processing
                        //
                        if([self isMsgACompleteMsg:message]){
                            
                            [request setStrResponse: message];
                            [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                            [request callCompletionBlockForRequest:request
                                                           success:YES
                                                       rawResponse:[request strResponse]
                                              msgDeliveredResponse:nil];
                            [request changeRequestStateTo:RequestStateGotConfirmationMessageWithApproved];
                        }
                        else{
                            [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                            if([self doesMsgContainFirstPartOfMsg:message]){
                                [request setStrResponse:message];
                            }
                            else{
                                NSString *combinedFirstPartAndOtherPart = [NSString stringWithFormat:@"%@%@", [request strResponse], message];
                                if([self isMsgACompleteMsg:combinedFirstPartAndOtherPart]){
                                    
                                    [request setStrResponse: combinedFirstPartAndOtherPart];
                                    [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                                    
                                    [request callCompletionBlockForRequest:request
                                                                   success:YES
                                                               rawResponse:[request strResponse]
                                                      msgDeliveredResponse:nil];
                                    [request changeRequestStateTo:RequestStateGotConfirmationMessageWithApproved];
                                }
                                else{
                                    
                                    [request setStrResponse: combinedFirstPartAndOtherPart];
                                    [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                                }
                            }
                        }
                        
                    }
                }
                else if (request.requestState == RequestStateGotConfirmationMessageWithApproved){
                    
                    if([[CommunicationManager parse:message][VALITOR_KEY_MSG_TYPE] isEqualToString:VALITOR_MSG_TYPE_ERROR]){
                        //error
                        // case (A) - iOS integrity corrupted
                        // case (C) - semantic error
                        [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                        [request callCompletionBlockForRequest:request
                                                       success:NO
                                                   rawResponse:message
                                          msgDeliveredResponse:nil];
                        [request changeRequestStateTo:RequestStateGotConfirmationMessageWithNotApproved];
                    }
                    else{
                        
                        //If another message arrives through the delegate
                        //And it doesn't start with 'MsgType=...'
                        //It is a continuation of the previously received message from the delegate
                        //And therefor we have to update the request's strResponse property
                        
                        if( [self isMessageContinuationOfAnotherMsg:message]){
                            NSString *combinedFirstAndContinuationMsg = [NSString stringWithFormat:@"%@%@", request.strResponse, message];
                            [request setStrResponse:combinedFirstAndContinuationMsg];
                        }
                        else{
                            [request setStrResponse: message];
                        }
                        
                        [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                        [request callCompletionBlockForRequest:request
                                                       success:YES
                                                   rawResponse:[request strResponse]
                                          msgDeliveredResponse:nil];
                        [request changeRequestStateTo:RequestStateGotConfirmationMessageWithApproved];
                    }
                }
            }
            else{
                //Ping&LastTransaction, dont require checkvalue calcs
                if(request.requestState == RequestStateWaitingForInitialAnswer){
                    
                    if([[CommunicationManager parse:message][VALITOR_KEY_MSG_TYPE] isEqualToString:VALITOR_MSG_TYPE_ERROR]){
                        //(C) - Semantic error. Since no check calcs are used, (A) doesn't apply here
                        [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                        [request callCompletionBlockForRequest:request
                                                       success:NO
                                                   rawResponse:message
                                          msgDeliveredResponse:nil];
                        [request changeRequestStateTo:RequestStateGotConfirmationMessageWithNotApproved];
                    }
                    else{
                        //Since we only get one response back
                        //And we don't need to respond to that message
                        //We set the status of the request as RequestStateGotConfirmationMessageWithApproved
                        
                        [request setStrResponse: message];
                        [request changeTimeoutStateTo:RequestTimeoutStateResponded];
                        
                        [request callCompletionBlockForRequest:request
                                                       success:YES
                                                   rawResponse:[request strResponse]
                                          msgDeliveredResponse:nil];
                        [request changeRequestStateTo:RequestStateGotConfirmationMessageWithApproved];
                    }
                }
            }
        }
        [self checkLastRequest];
    }
    else{
        
        if([request blockStatusMsg]){
            [request blockStatusMsg](message);
        }
    }
}
@end
