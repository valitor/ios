//
//  VALRequest.m
//  TestProject
//
//  Created by Ivar Johannesson on 04/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import "VALRequest.h"
#import "VALBaseClass.h"
#import "Constants.h"
#import "CommunicationManager.h"

#define KEY_FORMAT @"%@=%@&"

@interface VALRequest()
@property (nonatomic) RequestState requestState;
@property (nonatomic) unsigned long checkValue;
@property (nonatomic) unsigned long randomValue;

@end

@implementation VALRequest

#define PING_TIMEOUT 5

#pragma mark - Accessible Methods

-(instancetype)initWithDict:(NSDictionary *)dict
          needsMsgDelivered:(BOOL)needsMsgDelivered
     needsCheckCalculations:(BOOL)needsCheckCalculations
            completionBlock:(void (^)(BOOL success, NSString * strRawResponse, NSString *strMsgDelivered))blockCompletion
                statusBlock:(void (^)(NSString *strStatusMsg))blockStatus{
    
	self = [super init];
	if(self){
        
        _needsMsgDelivered = needsMsgDelivered;
        _requestState = RequestStateReadyToSend;
        _blockCompletion = blockCompletion;
        _needsCheckCalculations = needsCheckCalculations;
        _blockStatusMsg = blockStatus;
        
        [self generateNewRandomValue];
        NSMutableDictionary *mutValRequestDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        if(needsMsgDelivered || needsCheckCalculations){
            
            mutValRequestDict[VALITOR_KEY_RANDOM_VALUE] = [NSNumber numberWithUnsignedLong:_randomValue];
        }
        _strRequest = [self constructRequestFormattedStringFromDict:mutValRequestDict];
        _requestTimeoutState = RequestTimeoutStateUnknown;
        
        
        NSString *msgType = mutValRequestDict[@"MsgType"];
        NSString *msgCode = mutValRequestDict[@"MsgCode"];
        
        
        if( [msgType isEqualToString:@"0800"] && [msgCode isEqualToString:@"300"]){
            
            //Request is a PING request
            //PING requests have a timeout of 5 seconds
            [VALRequest blockInMainQueueAfterDelay:PING_TIMEOUT
                                      performBlock:^{
                                          
                                          if(_requestTimeoutState==RequestTimeoutStateResponded){
                                          }
                                          else{
                                              _requestTimeoutState = RequestTimeoutStateTimedOut;
                                              _requestState = RequestStateGotConfirmationMessageWithNotApproved;
                                              blockCompletion(NO, @"Timout, iOS side", nil);
                                              [[CommunicationManager manager] removeRequestFromQueue:self];
                                          }
                                      }];
        }
        else{
            [VALRequest blockInMainQueueAfterDelay:[[CommunicationManager manager] timeoutInSeconds]
                                      performBlock:^{
                                          
                                          if(_requestTimeoutState==RequestTimeoutStateResponded){
                                          }
                                          else{
                                              _requestTimeoutState = RequestTimeoutStateTimedOut;
                                              _requestState = RequestStateGotConfirmationMessageWithNotApproved;
                                              blockCompletion(NO, @"Timout, iOS side", nil);
                                              [[CommunicationManager manager] removeRequestFromQueue:self];
                                          }
                                      }];
            
        }
        
        
        
		
	}
	return self;
}

+(void)blockInMainQueueAfterDelay:(float)seconds performBlock:(void (^)(void))block{
    [VALRequest blockInQueue:dispatch_get_main_queue() afterDelay:seconds performBlock:block];
}

+(void)blockInQueue:(dispatch_queue_t)queue afterDelay:(float)seconds performBlock:(void (^)(void))block{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC), queue, block);
}

-(void)checkTimeoutState:(RequestTimeoutState*)timeoutState
        notTimoutedBlock:(void(^)())blockNotTimouted
           timedOutBlock:(void(^)())blockTimeOut{
    
    if(*timeoutState==RequestTimeoutStateTimedOut){
        if(blockTimeOut){
            blockTimeOut();
        }
    }
    else{
        if(blockNotTimouted){
            blockNotTimouted();
        }
    }
}

-(void)callCompletionBlockForRequest:(VALRequest*)request success:(BOOL)success rawResponse:(NSString *)strRawResponse msgDeliveredResponse:(NSString *)strMsgDeliveredResposne{
    
    __block RequestTimeoutState timeoutState = request.requestTimeoutState;
    
    [self checkTimeoutState:&timeoutState
                                     notTimoutedBlock:^{
                                         if([request blockCompletion]){
                                             [request blockCompletion](success,strRawResponse,strMsgDeliveredResposne);
                                         }
                                     }
                                        timedOutBlock:^{
                                            if([request blockCompletion]){
                                                [request blockCompletion](NO, @"Timeout, iOS side", nil);
                                                [[CommunicationManager manager] removeRequestFromQueue:request];
                                            }
                                        }];
    
}


-(void)changeRequestStateTo:(RequestState)requestState{
    
    _requestState = requestState;
}

-(void)changeTimeoutStateTo:(RequestTimeoutState)timoutState{
    
    _requestTimeoutState = timoutState;
}

-(void)setStrMessageDelivered{
    
    [self generateNewRandomValue];
    NSDictionary *dictMsgDelivered = @{
                                       VALITOR_KEY_MSG_TYPE : VALITOR_MSG_TYPE_BATCH_SENDING,
                                       VALITOR_KEY_MSG_CODE : VALITOR_MSG_CODE_FOR_MSG_DELIVERED,
                                       VALITOR_KEY_RANDOM_VALUE : [NSString stringWithFormat:@"%lu", _randomValue],
                                       
                                       };
    
    _strMessageDelivered = [self constructRequestFormattedStringFromDict:dictMsgDelivered];
    NSLog(@"");
}

-(void)setStrMessageDeliveredResponse:(NSString *)msgDeliveredResponse{
    
    _strMsgDeliveredResponse = msgDeliveredResponse;
}

-(NSString *)constructRequestFormattedStringFromDict:(NSDictionary *)dict{

    NSMutableArray *arrKeys = [[NSMutableArray alloc] init];
    
    //Add MsgType key as first key, as it always needs to be the first key in the request
    //Then we need to add TransAmount & TransCurrency
    //Then we add all other keys, except Rand&Check value which need to be the last two keys in the request
    for(NSString *key in [dict allKeys]){
        
        if([key isEqualToString:VALITOR_KEY_MSG_TYPE]){
            [arrKeys addObject:[NSString stringWithFormat:KEY_FORMAT, key, dict[key]]];
            break;
        }
    }
    
    //Add all other keys except msgtype, rand, check
    for (NSString *key in [dict allKeys]) {
        if(![key isEqualToString:VALITOR_KEY_MSG_TYPE] &&
           ![key isEqualToString:VALITOR_KEY_RANDOM_VALUE] &&
           ![key isEqualToString:VALITOR_KEY_CHECK_VALUE]){
            
            [arrKeys addObject:[NSString stringWithFormat:KEY_FORMAT, key, dict[key]]];
        }
    }
    
    if(_needsCheckCalculations){
        
        unsigned long msgTypeForCheckValueCalcs = [dict[VALITOR_KEY_MSG_TYPE] intValue];
        unsigned long amountForCheckValueCalcs = dict[VALITOR_KEY_TRANSACTION_AMOUNT] ? ( ([dict[VALITOR_KEY_TRANSACTION_AMOUNT] intValue]) /100) :0;
        unsigned long randomValueForCheckValueCalcs = (unsigned long) [dict[VALITOR_KEY_RANDOM_VALUE] intValue];
        unsigned long checkValue = [VALBaseClass calculateCheckValueWithRandValue:randomValueForCheckValueCalcs
                                                                       passPhrase:0
                                                                          msgType:msgTypeForCheckValueCalcs
                                                                      amountInISK:amountForCheckValueCalcs];

        [arrKeys addObject:[NSString stringWithFormat:KEY_FORMAT, VALITOR_KEY_RANDOM_VALUE, [NSString stringWithFormat:@"%lu", randomValueForCheckValueCalcs]]];
        [arrKeys addObject:[NSString stringWithFormat:KEY_FORMAT, VALITOR_KEY_CHECK_VALUE, [NSString stringWithFormat:@"%lu", checkValue]]];
    }
    
    NSString *strToReturn = [VALRequest encodeArray:arrKeys];
    
    return strToReturn;
}

-(void)setStrResponse:(NSString *)strResponse{
    
    _strResponse = strResponse;
}


-(BOOL)isCheckValueCorrectWithMsgType:(unsigned long)msgType transAmount:(unsigned long)transAmount posCheckValue:(unsigned long)posCheckValue{
	
    return YES;
}

-(void)generateNewRandomValue{
	
	_randomValue = [VALBaseClass getRandomNumber];
}

+(NSString *)encodeArray:(NSArray<NSString *> *)array{
	
	NSString *strToReturn = [array componentsJoinedByString:@""];
	return strToReturn;
}
@end
