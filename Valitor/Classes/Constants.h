//
//  Constants.h
//  TestProject
//
//  Created by Ivar Johannesson on 03/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#ifndef Constants_h
#define Constants_h
//*************
//MsgType


//#define AL_URL_INT_TO_STR(x)					[NSString stringWithFormat:@"%04d", x]

#define POS_TIMEOUT 180
#define VALITOR_ISK_CURRENCY_CODE                                       @"352"

//MsgType codes for Authorization
#define VALITOR_MSG_TYPE_AUTHORIZATION_FOR_RAND (unsigned long)         100
#define VALITOR_MSG_TYPE_AUTHORIZATION                                  [NSString stringWithFormat:@"%04lu", VALITOR_MSG_TYPE_AUTHORIZATION_FOR_RAND]
#define VALITOR_MSG_TYPE_AUTHORIZATION_RESPONSE                         @"0110"

//MsgType codes for MOTOAuthorization (PhonePayment)
#define VALITOR_MSG_TYPE_MOTO_AUTHORIZATION_FOR_RAND (unsigned long)    101
#define VALITOR_MSG_TYPE_MOTO_AUTHORIZATION                             [NSString stringWithFormat:@"%04lu", VALITOR_MSG_TYPE_MOTO_AUTHORIZATION_FOR_RAND]
#define VALITOR_MSG_TYPE_MOTO_AUTHORIZATION_RESPONSE                    @"0111"

//MsgType codes for AuthorizationONLY
#define VALITOR_MSG_TYPE_AUTHORIZATION_ONLY_FOR_RAND (unsigned long)    102
#define VALITOR_MSG_TYPE_AUTHORIZATION_ONLY                             [NSString stringWithFormat:@"%04lu", VALITOR_MSG_TYPE_AUTHORIZATION_ONLY_FOR_RAND]
#define VALITOR_MSG_TYPE_AUTHORIZATIONON_ONLY_RESPONSE                  @"0122"

//MsgType codes for Voice-Authorization
#define VALITOR_MSG_TYPE_VOICE_AUTHORIZATION_FOR_RAND (unsigned long)   103
#define VALITOR_MSG_TYPE_VOICE_AUTHORIZATION                            [NSString stringWithFormat:@"%04lu", VALITOR_MSG_TYPE_VOICE_AUTHORIZATION_FOR_RAND]
#define VALITOR_MSG_TYPE_VOICE_AUTHORIZATION_RESPONSE                   @"0133"

//MsgType codes for Reverse
#define VALITOR_MSG_TYPE_REVERSE_FOR_RAND (unsigned long)               400
#define VALITOR_MSG_TYPE_REVERSE                                        [NSString stringWithFormat:@"%04lu", VALITOR_MSG_TYPE_REVERSE_FOR_RAND]
#define VALITOR_MSG_TYPE_REVERSE_RESPONSE                               @"0410"

//MsgType codes for Refund
#define VALITOR_MSG_TYPE_REFUND_FOR_RAND (unsigned long)                200
#define VALITOR_MSG_TYPE_REFUND                                         [NSString stringWithFormat:@"%04lu", VALITOR_MSG_TYPE_REFUND_FOR_RAND]
#define VALITOR_MSG_TYPE_REFUND_RESPONSE                                @"2010"

//MsgType codes for Batch Sending
#define VALITOR_MSG_TYPE_BATCH_SENDING_FOR_RAND (unsigned long)         800
#define VALITOR_MSG_TYPE_BATCH_SENDING                                  [NSString stringWithFormat:@"%04lu", VALITOR_MSG_TYPE_BATCH_SENDING_FOR_RAND]
#define VALITOR_MSG_TYPE_BATCH_RESPONSE                                 @"0810"
#define VALITOR_MSG_TYPE_ERROR                                          @"0000"

//END OF MsgType
//*************

//*************
//MsgCode

#define VALITOR_MSG_CODE_POS_SEND_BATCH                                 @"100"
#define VALITOR_MSG_CODE_SEND_LAST_RECEIPT                              @"200"
#define VALITOR_MSG_CODE_TERMINAL_PRINT_TRANSACTION_SUMMARTY            @"201"
#define VALITOR_MSG_CODE_TERMINAL_PRINT_TRANSACTION_LIST                @"202"
#define VALITOR_MSG_CODE_GET_LAST_RECEIPT                               @"203"
#define VALITOR_MSG_CODE_FOR_PING                                       @"300"
#define VALITOR_MSG_CODE_POS_LINE_PRINT                                 @"500"
#define VALITOR_MSG_CODE_GET_LAST_TRANSACTION_FOR_RAND                  600
#define VALITOR_MSG_CODE_GET_LAST_TRANSACTION                           [NSString stringWithFormat:@"%03d", VALITOR_MSG_CODE_GET_LAST_TRANSACTION_FOR_RAND]
#define VALITOR_MSG_CODE_FOR_MSG_DELIVERED                              @"700"
#define VALITOR_MSG_CODE_STATUS                                         @"900"

//END OF MsgCode
//*************

//*************
//Macros for dictKeys
#define VALITOR_KEY_MSG_CODE                                            @"MsgCode"
#define VALITOR_KEY_MSG_TYPE                                            @"MsgType"
#define VALITOR_KEY_TRANSACTION_AMOUNT                                  @"TransAmount"
#define VALITOR_KEY_TRANSACTION_CURRENCY                                @"TransactionCurrency"
#define VALITOR_KEY_POS_PRINT                                           @"PosPrint"
#define VALITOR_KEY_CARD_TYPE                                           @"CardType"
#define VALITOR_KEY_STATUS                                              @"Status"
#define VALITOR_KEY_RANDOM_VALUE                                        @"Rand"
#define VALITOR_KEY_CHECK_VALUE                                         @"Check"
#define VALITOR_KEY_CARD_NUMBER_SHORT                                   @"CardNumberShort"
#define VALITOR_KEY_MSG_ID                                              @"MsgID"
#define VALITOR_KEY_MISC_PRINT                                          @"MiscPrint"
//END OF dictKeys Macros
//*************
#endif