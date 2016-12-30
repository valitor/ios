//
//  InitialViewController.m
//  TestProject
//
//  Created by Ivar Johannesson on 26/04/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import "ActionMenu.h"
#import "TcpServer.h"
#import "Constants.h"
#import "PseudoModal.h"
#import "MYUtls.h"


@interface ActionMenu () <UITextFieldDelegate, BarrcodeDelegate>

//Framework
@property (nonatomic, strong) TcpServer *tcpServer;

//General
@property (strong , nonatomic) NSMutableArray *arrTerminals;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;
@property (strong, nonatomic) NSString *selectedCompanion;
@property (nonatomic, strong) NSString *msg;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedAction;
@property (nonatomic) NSInteger intResponse;
@property (strong, nonatomic) NSString *strResponse;
@property (strong, nonatomic) NSArray<NSString *> *arrPickerContent;
@property (nonatomic) PickerResponse pickerResponse;

//UI
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedPOS;
@property (weak, nonatomic) IBOutlet UITextField *txtAmount;
@property (weak, nonatomic) IBOutlet UITextField *txtCardNumber;
@property (weak, nonatomic) IBOutlet UITextField *txtMsgID;
@property (weak, nonatomic) IBOutlet UITextField *txtPrint;

//Networking
@property (nonatomic, strong) NSInputStream *inputStream;
@property (nonatomic, strong) NSOutputStream *outputStream;
@property (nonatomic, strong) NSString *peer;
@property (nonatomic, strong) NSMutableArray *arrConsole;
@property (nonatomic, strong) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UITextView *txtView;

@end

@implementation ActionMenu
-(instancetype)initWithSelectedPos:(NSString *)pos{
    
    self = [super init];
    if(self){
        
        _selectedCompanion = pos;
        _arrPickerContent = @[@"Send Ping",
                              @"Send Authorization",
                              @"Send MOTOAuth",
                              @"Send Auth ONLY",
                              @"Send VoiceAuth",
                              @"Send Refund",
                              @"Send Reversal",
                              @"Send Batch",
                              @"Get Last Transaction",
                              @"Get Last Receipt",
                              @"Print Summary List",
                              @"Print Transaction List",
                              @"Send Print String"
                              ];
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _txtMsgID.delegate = self;
    _txtCardNumber.delegate = self;
    _txtAmount.delegate = self;
    _lblSelectedPOS.text = [NSString stringWithFormat:@"Valinn Posi: %@", _selectedCompanion];
    _txtAmount.placeholder = @"Insert Amount";
    _txtCardNumber.placeholder = @"Short Card Nr";
    _txtMsgID.placeholder = @"Insert MsgID";
    _txtCardNumber.hidden = YES;
    _txtAmount.hidden = YES;
    _txtMsgID.hidden = YES;
    _txtPrint.hidden = YES;
    _lblSelectedAction.text = @"Valin Aðgerð: Send Ping";
    _arrConsole = [NSMutableArray new];
    [self startConsoleUpdates];
    CommunicationManager *manager = [CommunicationManager manager];
    manager.delegate = self;
}

-(void)didReceiveScanData:(NSString *)data{
    
    NSLog(@"Data received from scanner: %@", data);
}
- (IBAction)scanOnPressed:(id)sender {
    
    [[CommunicationManager manager] startScan];
}
- (IBAction)scanOffPressed:(id)sender {
    
    [[CommunicationManager manager] stopScan];
}

-(void)startConsoleUpdates{
    
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                              target: self
                                            selector: @selector(getConsoleMessages)
                                            userInfo: nil
                                             repeats: YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

-(void)getConsoleMessages{
    
    __weak ActionMenu *wSelf = self;
    [MYUtls blockInBackgroundQueue:^{
        
        CommunicationManager *manager = [CommunicationManager manager];
        _arrConsole = manager.arrConsoleMsgs;
        
        [MYUtls blockInMainQueue:^{
            [wSelf.timer invalidate];
            
            NSArray *tmpMsgArray = [NSArray arrayWithArray:_arrConsole];
            NSString *messages = [tmpMsgArray componentsJoinedByString:@"\n"];
            wSelf.txtView.text = messages;
            wSelf.timer = [NSTimer scheduledTimerWithTimeInterval:5
                                                           target: self
                                                         selector: @selector(getConsoleMessages)
                                                         userInfo: nil
                                                          repeats: YES];
            [[NSRunLoop mainRunLoop] addTimer:wSelf.timer forMode:NSRunLoopCommonModes];
        }];
        
    }];

}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)tapToSelectActionPressed:(id)sender {
    
    __weak ActionMenu *wSelf = self;
    
    PseudoModal *modalView = [[PseudoModal alloc] initWithSingleComponentPickerWithSelectBlock:^(SingleComponentResponseObject *responseObject) {
        
        wSelf.intResponse = responseObject.intResponse;
        wSelf.strResponse = responseObject.strResponse;
        wSelf.pickerResponse = wSelf.intResponse;
        
        wSelf.lblSelectedAction.text = [NSString stringWithFormat:@"Selected Action: %@", wSelf.strResponse];
        [wSelf setupUIBasedOnPickerResponse];
        
        
    } blockViewClosed:^{
    } arrContent:_arrPickerContent preselectedComponent:0];
    
    [self.view addSubview:modalView];
    [modalView show];
}
- (IBAction)checkIfAvailable:(id)sender {
    
    [self displayDeviceState:[ICISMPDevice isAvailable]];
    NSLog(@"Input Stream Status: %lu", (unsigned long)[[[[CommunicationManager manager] tcpServer] inputStream] streamStatus]);
    NSLog(@"Output Stream Status: %lu", (unsigned long)[[[[CommunicationManager manager] tcpServer] outputStream] streamStatus]);
    NSLog(@"NSStreamStatusNotOpen = 0, NSStreamStatusOpening = 1, NSStreamStatusOpen = 2, NSStreamStatusReading = 3, NSStreamStatusWriting = 4, NSStreamStatusAtEnd = 5, NSStreamStatusClosed = 6, NSStreamStatusError = 7");
}

-(void)setupUIBasedOnPickerResponse{
    
    _txtCardNumber.hidden = YES;
    _txtAmount.hidden = YES;
    _txtMsgID.hidden = YES;
    _txtPrint.hidden = YES;
    
    switch (_pickerResponse) {
        case PickerResponsePing:
            break;
        case PickerResponseAuthorization:
            _txtAmount.hidden = NO;
            break;
        case PickerResponseMOTOAuth:
            _txtAmount.hidden = NO;
            break;
        case PickerResponseAuthONLY:
            _txtAmount.hidden = NO;
            break;
        case PickerResponseVoiceAuth:
            _txtAmount.hidden = NO;
            break;
        case PickerResponseRefund:
            _txtAmount.hidden = NO;
            break;
        case PickerResponseReversal:
            _txtCardNumber.hidden = NO;
            _txtAmount.hidden = NO;
            _txtMsgID.hidden = NO;
            break;
        case PickerResponseBatch:
            break;
        case PickerResponseLastTransAction:
            break;
        case PickerResponseLastReceipt:
            break;
        case PickerResponseSummaryList:
            break;
        case PickerResponseTransactionList:
            break;
        case PickerResponsePrintString:
            _txtPrint.hidden = NO;
            _txtPrint.text = @"[L][C]Halló Heimur;;;;;;";
            break;
        default:
            break;
    }
    
}

- (IBAction)sendActionToPos:(id)sender {
    
    
    switch (_pickerResponse) {
        case PickerResponsePing:
            [self sendPing];
            break;
        case PickerResponseAuthorization:{
            unsigned long amountToSend = [_txtAmount.text intValue];
            [self sendAuthorizationWithAmount:amountToSend];
        }
            break;
        case PickerResponseMOTOAuth:{
            unsigned long amountToSend = [_txtAmount.text intValue];
            [self sendMOTOAuthWithAmount:amountToSend];
        }
            break;
        case PickerResponseAuthONLY:{
            unsigned long amountToSend = [_txtAmount.text intValue];
            [self sendAuthONLYWithAmount:amountToSend];
        }
            break;
        case PickerResponseVoiceAuth:{
            unsigned long amountToSend = [_txtAmount.text intValue];
            [self sendVoiceAuthWithAmount:amountToSend];
        }
            break;
        case PickerResponseRefund:{
            unsigned long amountToSend = [_txtAmount.text intValue];
            [self sendRefundWithAmount:amountToSend];
        }
            break;
        case PickerResponseReversal:{
            
            unsigned long amountToSend = [_txtAmount.text intValue];
            NSString *msgID = _txtMsgID.text;
            NSString *shortCardNumber = _txtCardNumber.text;
            [self sendReversalWithAmount:amountToSend shortCardNumber:shortCardNumber authToReverseMsgID:msgID];
        }
            break;
        case PickerResponseBatch:
            [self sendBatch];
            break;
        case PickerResponseLastTransAction:
            [self getLastTransaction];
            break;
        case PickerResponseLastReceipt:
            [self getLastReceipt];
            break;
        case PickerResponseSummaryList:
            [self printSummaryList];
            break;
        case PickerResponseTransactionList:
            [self printTransactionList];
            break;
        case PickerResponsePrintString:{
            [self sendPrintStringMsg:_txtPrint.text];
        }
            break;
        default:
            break;
    }
    
}

-(void)_backgroundDisplayDeviceState:(NSNumber *)boolReady {
    NSLog(@"%s", __FUNCTION__);
    
    if ([boolReady boolValue] == YES) {
        //DeviceReady
    } else {
        //DeviceNotReady
    }
}

-(void)displayDeviceState:(BOOL)ready {
    
    if ([NSThread isMainThread]) {
        if (ready == YES) {
            //DeviceReady
        } else {
            //DeviceNotReady
        }
        
    } else {
        [self performSelectorOnMainThread:@selector(_backgroundDisplayDeviceState:) withObject:[NSNumber numberWithBool:ready] waitUntilDone:NO];
    }
}

#pragma mark - User Actions
- (IBAction)startBTAndTCP:(id)sender {
    
    [[CommunicationManager manager] setupChannels];
    
    if([[CommunicationManager manager] bluetoothOpenChannelResult]){
        NSLog(@"Starting TCP server in manager");
        CommunicationManager *manager = [CommunicationManager manager];
        [manager.arrConsoleMsgs addObject:@"Starting TCP Server"];
        [[CommunicationManager manager] startTcpServer];
    }
    else{
        NSLog(@"Unable to start TCP Server");
        CommunicationManager *manager = [CommunicationManager manager];
        [manager.arrConsoleMsgs addObject:@"Unable to start TCP Server"];
    }
}


- (IBAction)stopBT:(id)sender {
    
    [[CommunicationManager manager] closeChannels];
}


- (IBAction)checkStreams:(id)sender {
    
    NSLog(@"BlueTooth Connectivity: %@", [[CommunicationManager manager] hasBTConnection] ? @"Has Bluetooth" : @"No BT");
    NSLog(@"TCP Connectivity: %@", [[CommunicationManager manager] hasTCPConnection] ? @"Has TCP" : @"No TCP");
    
    NSLog(@"Input Stream Status: %lu", (unsigned long)[[[[CommunicationManager manager] tcpServer] inputStream] streamStatus]);
    NSLog(@"Output Stream Status: %lu", (unsigned long)[[[[CommunicationManager manager] tcpServer] outputStream] streamStatus]);
    NSLog(@"NSStreamStatusNotOpen = 0, NSStreamStatusOpening = 1, NSStreamStatusOpen = 2, NSStreamStatusReading = 3, NSStreamStatusWriting = 4, NSStreamStatusAtEnd = 5, NSStreamStatusClosed = 6, NSStreamStatusError = 7");
}

-(void)sendPing{
    
    CommunicationManager *manager = [CommunicationManager manager];
    
    [[CommunicationManager manager] demandPingWithCompletionBlock:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);
       
        
        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        NSLog(@"%@", dictRawResponse);
        
        
    } statusBlock:^(NSString *strStatusMsg) {
        NSLog(@"%@", strStatusMsg);
    }];
}

-(void)sendAuthorizationWithAmount:(unsigned long)amount{
    
    
    CommunicationManager *manager = [CommunicationManager manager];
    VALAmount *valAmount = [[VALAmount alloc] initWithAmountInISK:amount strCurrency:VALITOR_ISK_CURRENCY_CODE];
    VALCard *valCard = [[VALCard alloc] initWithCardType:ValCardTypeAll cardNumberShort:nil];
    
    [[CommunicationManager manager] demandAuthorizationWithType:AuthorizationTypeAuth
                                                         Amount:valAmount card:valCard
                                             shouldPrintReceipt:NO statusMessagesEnabled:YES
                                                     completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered){
                                                         
                                                         NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
                                                         NSLog(@"strRawResponse: %@", strRawResponse);
                                                         NSLog(@"strMsgDelivered: %@", strMsgDelivered);
                                                         
                                                         if(success){
                                                             [manager.arrConsoleMsgs addObject:@"Successful"];
                                                         }
                                                         else{
                                                             [manager.arrConsoleMsgs addObject:@"Not Successful"];
                                                         }
                                                         
                                                         NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
                                                         NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
                                                         
                                                         NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
                                                         NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
                                                         [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
                                                         [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
                                                         
                                                     }
                                                 statusMsgBlock:^(NSString *strStatusMsg){
                                                     NSLog(@"StatusMsgAuth: %@", strStatusMsg);
                                                     [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"StatusMsgAuth: %@", strStatusMsg]];
                                                 }];
    
}

-(void)sendMOTOAuthWithAmount:(unsigned long)amount{
    
    CommunicationManager *manager = [CommunicationManager manager];
    
    VALAmount *valAmount = [[VALAmount alloc] initWithAmountInISK:amount strCurrency:VALITOR_ISK_CURRENCY_CODE];
    VALCard *valCard = [[VALCard alloc] initWithCardType:ValCardTypeAll cardNumberShort:nil];
    
    [[CommunicationManager manager] demandAuthorizationWithType:AuhtorizationTypeMOTOAuth Amount:valAmount card:valCard shouldPrintReceipt:NO statusMessagesEnabled:YES completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        NSLog(@"strRawResponse: %@", strRawResponse);
        NSLog(@"strMsgDelivered: %@", strMsgDelivered);
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);
        
        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
        
        NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
        NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
        
    }
                                                 statusMsgBlock:^(NSString *strStatusMessage){
                                                     NSLog(@"StatusMsgMOTOAuth: %@", strStatusMessage);
                                                      [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"StatusMsgMOTOAuth: %@", strStatusMessage]];
                                                 }];
    
}

-(void)sendAuthONLYWithAmount:(unsigned long)amount{
    
    CommunicationManager *manager = [CommunicationManager manager];
    VALAmount *valAmount = [[VALAmount alloc] initWithAmountInISK:amount strCurrency:VALITOR_ISK_CURRENCY_CODE];
    VALCard *valCard = [[VALCard alloc] initWithCardType:ValCardTypeAll cardNumberShort:nil];
    
    [[CommunicationManager manager] demandAuthorizationWithType:AuthorizationTypeAuthOnly Amount:valAmount card:valCard shouldPrintReceipt:NO statusMessagesEnabled:YES completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        NSLog(@"strRawResponse: %@", strRawResponse);
        NSLog(@"strMsgDelivered: %@", strMsgDelivered);
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);

        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
        
        NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
        NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
        
    }
                                                 statusMsgBlock:^(NSString *strStatusMsg) {
                                                     NSLog(@"StatusMsgAuthONLY: %@", strStatusMsg);
                                                     [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"StatusMsgAuthONLY: %@", strStatusMsg]];
                                                 }];
}

-(void)sendVoiceAuthWithAmount:(unsigned long)amount{
    
    CommunicationManager *manager = [CommunicationManager manager];

    VALAmount *valAmount = [[VALAmount alloc] initWithAmountInISK:amount strCurrency:VALITOR_ISK_CURRENCY_CODE];
    VALCard *valCard = [[VALCard alloc] initWithCardType:ValCardTypeAll cardNumberShort:nil];
    
    [[CommunicationManager manager] demandAuthorizationWithType:AuhtorizationTypeVoiceAuth Amount:valAmount card:valCard shouldPrintReceipt:NO statusMessagesEnabled:YES completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        NSLog(@"strRawResponse: %@", strRawResponse);
        NSLog(@"strMsgDelivered: %@", strMsgDelivered);
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);
        
        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
        
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
        
        NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
        NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
        
    }
                                                 statusMsgBlock:^(NSString *strStatusMsg) {
                                                     NSLog(@"StatusMsgVoiceAuth: %@", strStatusMsg);
                                                     [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"StatusMsgVoiceAuth: %@", strStatusMsg]];
                                                 }];
}


-(void)sendRefundWithAmount:(unsigned long)amount{
    
     CommunicationManager *manager = [CommunicationManager manager];
    
    VALAmount *valAmount = [[VALAmount alloc] initWithAmountInISK:amount strCurrency:VALITOR_ISK_CURRENCY_CODE];
    VALCard *valCard = [[VALCard alloc] initWithCardType:ValCardTypeAll cardNumberShort:nil];
    
    [[CommunicationManager manager] demandRefundWithAmount:valAmount card:valCard shouldPrintReceipt:NO statusMessagesEnabled:YES completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        NSLog(@"strRawResponse: %@", strRawResponse);
        NSLog(@"strMsgDelivered: %@", strMsgDelivered);
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);
        
        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
        
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
        
        NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
        NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
        
    }
                                            statusMsgBlock:^(NSString *strStatusMsg) {
                                                NSLog(@"StatusMsgRefund: %@", strStatusMsg);
                                                [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"StatusMsgRefund: %@", strStatusMsg]];
                                            }];
}

-(void)sendReversalWithAmount:(unsigned long)amount shortCardNumber:(NSString *)cardNumber authToReverseMsgID:(NSString *)msgID{
    
    CommunicationManager *manager = [CommunicationManager manager];
    
    VALAmount *valAmount = [[VALAmount alloc] initWithAmountInISK:amount strCurrency:VALITOR_ISK_CURRENCY_CODE];
    VALCard *valCard = [[VALCard alloc] initWithCardType:ValCardTypeAll cardNumberShort:cardNumber];
    
    [[CommunicationManager manager] demandReversalWithAmount:valAmount card:valCard shouldPrintReceipt:NO statusMessagesEnabled:YES msgID:msgID completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        NSLog(@"strRawResponse: %@", strRawResponse);
        NSLog(@"strMsgDelivered: %@", strMsgDelivered);
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);
        
        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
        
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
        
        NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
        NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
        
    }
                                              statusMsgBlock:^(NSString *strStatusMsg) {
                                                  NSLog(@"StatusMsgReversal: %@", strStatusMsg);
                                                  [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"StatusMsgRefund: %@", strStatusMsg]];
                                              }];
}

-(void)sendBatch{
    CommunicationManager *manager = [CommunicationManager manager];
    
    [[CommunicationManager manager] demandBatchSendWithPrintOption:NO statusMessagesEnabled:NO completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        NSLog(@"strRawResponse: %@", strRawResponse);
        NSLog(@"strMsgDelivered: %@", strMsgDelivered);
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);
        
        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
        
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
        
        NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
        NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
        
    }
                                                    statusMsgBlock:^(NSString *strStatusMsg) {
                                                        NSLog(@"StatusMsgBatch: %@", strStatusMsg);
                                                        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"StatusMsgBatch: %@", strStatusMsg]];
                                                    }];
}

-(void)getLastReceipt{
    
    CommunicationManager *manager = [CommunicationManager manager];
    
    [[CommunicationManager manager] demandLastReceiptWithPosPrint:NO statusMessagesEnabled:YES completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        NSLog(@"strRawResponse: %@", strRawResponse);
        NSLog(@"strMsgDelivered: %@", strMsgDelivered);
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);
        
        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
        
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
        
        NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
        NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
        
    }
                                                   statusMsgBlock:^(NSString *strStatusMsg) {
                                                       NSLog(@"StatusMsgLastReceipt: %@", strStatusMsg);
                                                   }];
}

-(void)printSummaryList{
    
    CommunicationManager *manager = [CommunicationManager manager];
    
    [[CommunicationManager manager] demandPrintListWithPosPrintOption:posPrintOptionSummaryList posPrintEnabled:NO statusMessagesEnabled:YES completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        NSLog(@"strRawResponse: %@", strRawResponse);
        NSLog(@"strMsgDelivered: %@", strMsgDelivered);
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);
        
        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
        
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
        
        NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
        NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
        
    }
                                                       statusMsgBlock:^(NSString *strStatusMsg) {
                                                           NSLog(@"StatusMsgPrintSummaryList: %@", strStatusMsg);
                                                           NSLog(@"StatusMsgLastReceipt: %@", strStatusMsg);
                                                       }];
}

-(void)printTransactionList{
    
    CommunicationManager *manager = [CommunicationManager manager];
    
    [[CommunicationManager manager] demandPrintListWithPosPrintOption:posPrintOptiontransactionList posPrintEnabled:NO statusMessagesEnabled:YES completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        NSLog(@"strRawResponse: %@", strRawResponse);
        NSLog(@"strMsgDelivered: %@", strMsgDelivered);
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);
        
        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
        
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
        
        NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
        NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
        
    }
                                                       statusMsgBlock:^(NSString *strStatusMsg) {
                                                           NSLog(@"StatusMsgPrintTransactionList: %@", strStatusMsg);
                                                           NSLog(@"StatusMsgLastReceipt: %@", strStatusMsg);
                                                       }];
}


-(void)sendPrintStringMsg:(NSString *)strToPrint{
    
    CommunicationManager *manager = [CommunicationManager manager];
    
    [[CommunicationManager manager] demandLinePrintingWithPosPrintEnabled:NO statusMessagesEnabled:YES strMessage:strToPrint completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        NSLog(@"strRawResponse: %@", strRawResponse);
        NSLog(@"strMsgDelivered: %@", strMsgDelivered);
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);
        
        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
        
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
        
        NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
        NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
    }
                                                           statusMsgBlock:^(NSString *strStatusMsg) {
                                                               NSLog(@"StatusMsgPrintStringMsg: %@", strStatusMsg);
                                                               NSLog(@"StatusMsgLastReceipt: %@", strStatusMsg);
                                                           }];
}

-(void)getLastTransaction{
    
    CommunicationManager *manager = [CommunicationManager manager];
    
    [[CommunicationManager manager] demandLastTransactionWithPosPrint:NO statusMessagesEnabled:YES completion:^(BOOL success, NSString *strRawResponse, NSString *strMsgDelivered) {
        NSLog(success ? @"BlockCompletion: SUCCESSFUL" : @"BlockCompletion: NOT SUCCESSFUL" );
        NSLog(@"strRawResponse: %@", strRawResponse);
        NSLog(@"strMsgDelivered: %@", strMsgDelivered);
        
        if(success){
            [manager.arrConsoleMsgs addObject:@"Successful"];
        }
        else{
            [manager.arrConsoleMsgs addObject:@"Not Successful"];
        }
        
        NSLog(@"Raw Response: %@", strRawResponse);
        
        NSDictionary *dictRawResponse = [CommunicationManager parse:strRawResponse];
        NSDictionary *dictMsgDelivered = [CommunicationManager parse:strMsgDelivered];
        
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictRawResponse]];
        [manager.arrConsoleMsgs addObject:[NSString stringWithFormat:@"RawResponse: %@", dictMsgDelivered]];
        
        NSLog(@"DICTRAWRESPONSE %@", dictRawResponse);
        NSLog(@"DICTMSGDELIVERED %@", dictMsgDelivered);
    }
                                                       statusMsgBlock:^(NSString *strStatusMsg) {
                                                           NSLog(@"StatusMsgLastTransaction: %@", strStatusMsg);
                                                           NSLog(@"StatusMsgLastReceipt: %@", strStatusMsg);
                                                       }];
}
@end
