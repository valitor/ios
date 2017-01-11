//
//  SingleComponentResponseObject.h
//  ValitorTest
//
//  Created by Ivar Johannesson on 13/04/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleComponentResponseObject : NSObject
@property (nonatomic, strong) NSString *strResponse;
@property (nonatomic) NSInteger intResponse;
-(id)initWithStrResponse:(NSString *)strResponse intResponse:(NSInteger)intResponse;
@end
