//
//  VALAmount.h
//  TestProject
//
//  Created by Ivar Johannesson on 04/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VALAmount : NSObject

@property (nonatomic, strong, readonly) NSString *currency;
@property (nonatomic, readonly) unsigned long amountInISK;
@property (nonatomic, readonly) unsigned long amountInCents;

-(instancetype)initWithAmountInISK:(unsigned long)amountInISK strCurrency:(NSString *)currency;
@end
