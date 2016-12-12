//
//  TcpServer.h
//  PCL
//
//  Created by Hichem Boussetta on 24/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @file	 TcpServer.h
 @brief   Header file of the TcpServer class
 */


@protocol TcpServerDelegate;

/*!
 @anchor	 TcpServer
 @brief      TCP Server Class
 <div align="justify">
 Use this class to create a basic TCP server.
 </div>
 */

@interface TcpServer : NSObject <NSStreamDelegate> {
    
    CFSocketRef ipsocket;                                                       /**< Server socket */
    CFSocketNativeHandle handle;
}

/*!
 @anchor     TcpServerDelegateProperty
 @brief      The delegate of an @ref TcpServer object
 <p>This property should be assigned the reference of a delegate object that will receive the events of @ref TcpServer - This object should implement the @ref TcpServerDelegate protocols</p>
 */
@property (nonatomic, assign) id<TcpServerDelegate>       delegate;

/*!
 @anchor     NSStreamDelegate
 @brief      Delegate of NSStream class
 <p>
 To be notified of  stream events, implement NSStreamDelegate protocol.
 </p>
 */
@property (nonatomic, assign) id<NSStreamDelegate>          streamDelegate;


@property (nonatomic, readonly) NSInputStream   * inputStream;                  /**< Serial input stream */
@property (nonatomic, readonly) NSOutputStream  * outputStream;                 /**< Serial output stream */
@property (nonatomic, readonly) NSString        * peerName;                     /**< IP address of the remote host */
@property (nonatomic, assign)   NSUInteger        port;                         /**< Tcp port of the server */

/*!
 @anchor  startServer
 @brief   start the TCP server
 <p>
 This method starts the TCP server.
 </p>
 @returns YES in all cases
 */
-(BOOL)startServer;

/*!
 @anchor  stopServer
 @brief   stop the TCP server
 <p>
 This method stops the TCP server.
 </p>
 */
-(void)stopServer;

@end

/*!
 @anchor     TcpServerDelegate
 @brief      The TcpServerDelegate method
 <p>
 These methods should be implemented by @ref TcpServerDelegate's delegate to subscribe to be notified of events.
 </p>
 */
@protocol TcpServerDelegate

/*!
 @anchor  connectionEstablished
 @brief   Method called TcpConnection is established
 <p>
 This event is fired when the connection is established between the tcp client and TcpServer calling @ref startServer.
 </p>
 @param		 sender A pointer to the object that fired the @ref connectionEstablished event
 */
-(void)connectionEstablished:(TcpServer *)sender;       //Called on Main Thread

@end