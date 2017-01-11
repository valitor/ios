//
//  communicationThread.m
//  PCL Library
//
//  Created by Hichem Boussetta on 13/08/10.
//  Copyright 2010 Ingenico. All rights reserved.
//
/*!
 @file    communicationThread.m
 @brief   communicationThread class implementation file
 */

#import "communicationThread.h"


/*!
 @brief    Internal usage only
 */
@interface communicationThread ()


/*!
 @brief   Default initializer
 @result     The initialized receiver
 */
-(id)init;

/*!
 @brief   The communicationThread's main method
 <p>This method configures the thread's runloop to run indefinitely until the property shallRun is set to NO</p>
 */
-(void)main;

/*!
 @brief    When this property is set to NO, the thread exits its main method
 <p>At initialization, shallRun is set to YES, since the communicationThread is meant to run an infinite loop</p>
 */
@property (nonatomic, assign) BOOL shallRun;

/*!
 @brief      communicationThread's runloop
 <p>Use [NSRunLoop communicationRunLoop] instead</p>
 */
@property (nonatomic, readonly) NSRunLoop * runloop;

@end


@implementation communicationThread

@synthesize shallRun, runloop;

static communicationThread * g_sharedCommunicationThread = nil;


+(id) sharedCommunicationThread {
    if(g_sharedCommunicationThread == nil) {
        g_sharedCommunicationThread = [[communicationThread alloc] init];
        [g_sharedCommunicationThread start];
    }
    return g_sharedCommunicationThread;
}

-(id)init {
    if ((self = [super init])) {
        shallRun = YES;
        [self setName:@"communicationThread"];
    }
    return self;
}

-(id) retain {
    return self;
}

-(oneway void) release {
    
}

-(id) autorelease {
    return self;
}

-(NSUInteger) retainCount {
    return NSUIntegerMax;
}

-(void)dealloc {
    [self cancel];
    
    if (self == g_sharedCommunicationThread) {
        g_sharedCommunicationThread = nil;
    }
    [super dealloc];
}

-(void)_debug {
    
}

-(void)main {
    runloop = [NSRunLoop currentRunLoop];
    BOOL isRunning = NO;
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(_debug) userInfo:self repeats:YES];
    
    //Start the runloop
    while (shallRun == YES) {
        //Create an AutoreleasePool
        NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
        isRunning = [runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        if(isRunning == NO)
        {
            shallRun = NO;
        }
        [pool drain];
    }
    [g_sharedCommunicationThread release];
    g_sharedCommunicationThread = nil;
}

@end



@implementation NSRunLoop (communicationThread)

+ (NSRunLoop *)communicationRunLoop {
    return [[communicationThread sharedCommunicationThread] runloop];
}

@end


