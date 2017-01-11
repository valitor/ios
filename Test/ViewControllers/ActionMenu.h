//
//  InitialViewController.h
//  TestProject
//
//  Created by Ivar Johannesson on 26/04/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommunicationManager.h"

@interface ActionMenu : UIViewController
-(instancetype)initWithSelectedPos:(NSString *)pos;

typedef enum : NSUInteger{
    
    PickerResponsePing = 0,
    PickerResponseAuthorization = 1,
    PickerResponseMOTOAuth = 2,
    PickerResponseAuthONLY = 3,
    PickerResponseVoiceAuth = 4,
    PickerResponseRefund = 5,
    PickerResponseReversal = 6,
    PickerResponseBatch = 7,
    PickerResponseLastTransAction = 8,
    PickerResponseLastReceipt = 9,
    PickerResponseSummaryList = 10,
    PickerResponseTransactionList = 11,
    PickerResponsePrintString = 12,
    PickerResponseAuthorizationWithPing = 13
}PickerResponse;


@end
