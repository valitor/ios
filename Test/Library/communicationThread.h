//
//  communicationThread.h
//  PCL Library
//
//  Created by Hichem Boussetta on 13/08/10.
//  Copyright 2010 Ingenico. All rights reserved.
//
/*!
 @file       communicationThread.h
 @brief      Header file for communicationThread interface
 */
#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>


/*!
 @brief    This is a subclass of NSThread in which communication routines are scheduled
 */
@interface communicationThread : NSThread {
    NSRunLoop		* runloop;                              /**< Runloop of communicationThread */
    BOOL			  shallRun;                             /**< Boolean value that indicates whether the thread shall run or exit */
}

/*!
	@brief      Returns the singleton instance of communicationThread
	@result		A pointer to the shared instance
 */
+(id)sharedCommunicationThread; // singleton

@end

/*!
 @abstract    Extension to NSRunLoop class
 @discussion
 */

@interface NSRunLoop (communicationThread)
/*!
 @method
 @abstract   Returns the runloop from the communicationThread singleton
 @discussion
 */
+ (NSRunLoop *)communicationRunLoop;
@end

