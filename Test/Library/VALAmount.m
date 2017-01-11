//
//  VALAmount.m
//  TestProject
//
//  Created by Ivar Johannesson on 04/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import "VALAmount.h"

@implementation VALAmount


-(instancetype)initWithAmountInISK:(unsigned long)amountInISK strCurrency:(NSString *)currency{
    
    self = [super init];
    if(self){
        
        _amountInISK = amountInISK;
        _amountInCents = _amountInISK * 100;
        _currency = currency;
    }
    return self;
}

@end
