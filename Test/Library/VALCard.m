//
//  VALCard.m
//  TestProject
//
//  Created by Ivar Johannesson on 04/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import "VALCard.h"

@implementation VALCard

-(instancetype)initWithCardType:(ValCardType)cardType cardNumberShort:(NSString *)cardNumberShort {
    
    self = [super init];
    if(self){
		
        int type = cardType;
		
        switch (type) {
            case ValCardTypeAll:
                _cardType = @"0";
                break;
            case ValCardTypeDebit:
                _cardType = @"1";
                break;
            case ValCardTypeCredit:
                _cardType = @"2";
                break;
            default: _cardType = @"0";
                break;
        }
		
        _cardNumberShort = cardNumberShort;
    }
    return self;
}

@end
