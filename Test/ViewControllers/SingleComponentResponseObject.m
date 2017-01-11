//
//  SingleComponentResponseObject.m
//  ValitorTest
//
//  Created by Ivar Johannesson on 13/04/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import "SingleComponentResponseObject.h"

@implementation SingleComponentResponseObject
-(id)initWithStrResponse:(NSString *)strResponse intResponse:(NSInteger)intResponse{
    
    self = [super init];
    if(self){
        _strResponse = strResponse;
        _intResponse = intResponse;
    }
    return self;
}

@end
