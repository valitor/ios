//
//  TestProjectUnitTests.m
//  TestProjectUnitTests
//
//  Created by Ivar Johannesson on 03/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VALBaseClass.h"
#import "CommunicationManager.h"
#import "TcpServer.h"

@interface TestProjectUnitTests : XCTestCase
@end

@interface VALBaseClass (Test)
+(unsigned long)calculateCheckValueWithRandValue:(unsigned long)rand
                                      passPhrase:(unsigned long)passPhrase
                                         msgType:(unsigned long)msgType
                                   amountInCents:(unsigned long)amount;
@end

@implementation TestProjectUnitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testReturnCheckValue5608WhenRandIs485AndPassPhraseIs4444WithActionCode100AndAmount123{
    
    unsigned long checkValue = [VALBaseClass calculateCheckValueWithRandValue:485 passPhrase:6789 msgType:100 amountInISK:123];
    XCTAssertEqual(checkValue, 5608);
}

-(void)testReturnCheckValue2759WhenRandIs492andPassPhraseIs4444WithActionCode100AndAmount123{
    
    unsigned long checkValue = [VALBaseClass calculateCheckValueWithRandValue:492 passPhrase:4444 msgType:100 amountInISK:123];
    
    XCTAssertEqual(checkValue, 2759);
}

@end
