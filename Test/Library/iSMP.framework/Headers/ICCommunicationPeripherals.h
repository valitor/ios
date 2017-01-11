//
//  ICCommunicationPeripherals.h
//  PCL Library
//
//  Created by Hichem Boussetta on 02/09/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

enum NetworkStatus{
    NotReachable = 0,                                   /**< No network is reachable */
    ReachableViaWiFi,                                   /**< The network is reachable through the wireless interface */
    ReachableViaWWAN                                    /**< The network is reachable through the cellular interface */
};

@protocol ICCommunicationPeripheralsDelegate;

@interface ICCommunicationPeripherals : NSObject {
	
	//GPRS Device Information
	BOOL			  gprsIsConnected;                      /**< GPRS Connection State */
	NSData			* gprsMacAddress;                       /**< GPRS MAC Address */
	NSData			* gprsSimCardNumber;                    /**< GPRS Card Sim Number (There is no iOS API to retrieve this value) */
	
	//WLAN Device Information
	BOOL			  wlanIsConnected;                      /**< WLAN Connection State */
	NSData			* wlanMacAddress;                       /**< WLAN MAC Address */
	
	//Host information
	NSString		* hostName;                             /**< Host Name */
	NSString		* hostIP;                               /**< Host IP */
	
	//Reachability status
	NSUInteger		  reachabilityStatus;                   /**< Reachability Status */
	
	SCNetworkReachabilityRef reachabilityRef;               /**< ReachabilityRef Variable */
	
	id<ICCommunicationPeripheralsDelegate>		delegate;   /**< Delegate Object of ICCommunicationPeripherals */
}

-(id)init;

-(id)initWithHostName:(NSString *)host;

-(id)initWithHostAddress:(NSString *)ip;

@property (nonatomic, readonly) BOOL gprsIsConnected;

@property (nonatomic, readonly) NSData * gprsMacAddress;

@property (nonatomic, readonly) NSData * gprsSimCardNumber;

@property (nonatomic, readonly) BOOL wlanIsConnected;

@property (nonatomic, readonly) NSData * wlanMacAddress;

@property (nonatomic, readonly) NSUInteger reachabilityStatus;

@property (nonatomic, assign) id<ICCommunicationPeripheralsDelegate> delegate;

-(void)currentReachabilityStatus;

-(void)getMacAddresses;

@end

@protocol ICCommunicationPeripheralsDelegate
@optional

-(void)networkReachabilityDidChanged;

@end
