//
//  VALRequest.h
//  TestProject
//
//  Created by Ivar Johannesson on 04/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VALRequest : NSObject

typedef enum : NSUInteger{
    
    RequestStateReadyToSend = 1,
    RequestStateWaitingForInitialAnswer = 2,
    RequestStateGotInitialAnswer = 3,
    RequestSateSentMessageDeliveredConfirmation = 4,
    RequestStateGotConfirmationMessageWithApproved = 5,
    RequestStateGotConfirmationMessageWithNotApproved = 6,
}RequestState;

typedef enum : NSUInteger{
    
    RequestTimeoutStateUnknown,
    RequestTimeoutStateTimedOut,
    RequestTimeoutStateResponded
}RequestTimeoutState;

//Request properties
@property (nonatomic, readonly) RequestState requestState;
@property (nonatomic, readonly) RequestTimeoutState requestTimeoutState;
@property (nonatomic, strong, readonly) NSString *strRequest;
@property (nonatomic, strong, readonly) NSString *strMsgDeliveredResponse;
@property (nonatomic, readonly) BOOL needsMsgDelivered;
@property (nonatomic, readonly) BOOL needsCheckCalculations;

//Response properties
@property (nonatomic, strong, readonly) NSString *strResponse;
@property (nonatomic, strong, readonly) void (^blockCompletion)(BOOL success, NSString *strRawResponse, NSString *strMsgDeliveredResposne);
@property (nonatomic, strong, readonly) void (^blockStatusMsg)(NSString *strStatusMsg);
@property (nonatomic, strong, readonly) NSString *strMessageDelivered;

-(void)setStrResponse:(NSString *)strResponse;
-(void)changeRequestStateTo:(RequestState)requestState;
-(void)changeTimeoutStateTo:(RequestTimeoutState)timoutState;
-(void)setStrMessageDeliveredResponse:(NSString *)msgDeliveredResponse;


-(instancetype)initWithDict:(NSDictionary *)dict
          needsMsgDelivered:(BOOL)needsMsgDelivered
     needsCheckCalculations:(BOOL)needsCheckCalculations
            completionBlock:(void (^)(BOOL success, NSString * strRawResponse, NSString *strMsgDelivered))blockCompletion
                statusBlock:(void (^)(NSString *strStatusMsg))blockStatus;

-(void)callCompletionBlockForRequest:(VALRequest*)request success:(BOOL)success rawResponse:(NSString *)strRawResponse msgDeliveredResponse:(NSString *)strMsgDeliveredResposne;

-(BOOL)isCheckValueCorrectWithMsgType:(unsigned long)msgType transAmount:(unsigned long)transAmount posCheckValue:(unsigned long)posCheckValue;
-(void)generateNewRandomValue;
-(void)setStrMessageDelivered;

@end
