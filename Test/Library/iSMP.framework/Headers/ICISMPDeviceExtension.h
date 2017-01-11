//
//  ICISMPDeviceExtension.h
//  PCL Library
//
//  Created by Boris LECLERE on 7/18/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICISMPDevice.h"

@protocol ICISMPDeviceExtensionDelegate;

@interface ICISMPDeviceExtension : ICISMPDevice
{
	NSMutableArray * m_SendList;        /**< List to send */
}

@property(nonatomic, assign) id<ICISMPDeviceDelegate, ICISMPDeviceExtensionDelegate> delegate;

-(int)SendData:(NSData *)Data;

-(bool)SendDataAsync:(NSData *)Data;

-(int)SendString:(NSString *)String;

-(bool)SendStringAsync:(NSString *)String;

// Reception
@property(getter = TotalNbFrameReceived) unsigned int m_TotalNbFrameReceived;                               /**< Number of frame received */

// Reception Property
@property(getter = ReceiveBufferSize, setter = SetReceiveBufferSize:) unsigned int m_ReceiveBufferSize;     /**< Size of received buffer */

// Sent
@property(getter = TotalNbFrameSent) unsigned int m_TotalNbFrameSent;                                       /**< Number of frame sent */

@end

@protocol ICISMPDeviceExtensionDelegate <ICISMPDeviceDelegate>

@optional

-(void)didReceiveData:(NSData *)Data fromICISMPDevice:(ICISMPDevice *)Sender;

-(void)willReceiveData:(ICISMPDevice *)Sender;

-(void)willSendData:(ICISMPDevice *)Sender;

-(void)didSendData:(NSData *)Data withNumberOfBytesSent:(unsigned int) NbBytesSent fromICISMPDevice:(ICISMPDevice *)Sender;

@end
