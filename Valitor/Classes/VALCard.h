//
//  VALCard.h
//  TestProject
//
//  Created by Ivar Johannesson on 04/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VALCard : NSObject

typedef enum : NSUInteger{
	
    ValCardTypeAll		= 0,	//all cards
    ValCardTypeDebit	= 1,	//debet cards only
    ValCardTypeCredit	= 2,	//credit cards only
    
}ValCardType;

@property (nonatomic, strong, readonly) NSString *cardNumberShort;
@property (nonatomic, strong, readonly) NSString *cardType;

-(instancetype)initWithCardType:(ValCardType)cardType
                cardNumberShort:(NSString *)cardNumberShort;

@end
