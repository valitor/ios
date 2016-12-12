//
//  ValitorBaseClass.h
//  TestProject
//
//  Created by Ivar Johannesson on 03/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VALBaseClass : NSObject

+(unsigned long)calculateCheckValueWithRandValue:(unsigned long)rand
                                      passPhrase:(unsigned long)passPhrase
                                         msgType:(unsigned long)msgType
                                     amountInISK:(unsigned long)amount;

+(NSString *)getMessageDeliveredString;
+(unsigned long)getRandomNumber;
@end
