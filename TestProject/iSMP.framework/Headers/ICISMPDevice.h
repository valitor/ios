//
//  ICISMPDevice.h
//  PCL Library
//
//  Created by Christophe Fontaine on 21/06/10.
//  Copyright 2010 Ingenico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExternalAccessory/ExternalAccessory.h>

@protocol ICISMPDeviceDelegate;

typedef enum {
    ISMP_Result_Function_Not_Supported = -1,                   /**< The function called is not supported by this type of Terminal */
    ISMP_Result_SUCCESS = 0,                                   /**< The call succeeded */
    ISMP_Result_ISMP_NOT_CONNECTED,                            /**< The call failed because the Companion is not connected */
    ISMP_Result_Failure,                                       /**< The call failed for an unknown reason */
    ISMP_Result_TIMEOUT,                                       /**< The call failed because the timeout was reached. No response was received from the iSMP */

    //Key Injection Error Codes
    ISMP_Result_KEY_INJECTION_ABORTED,                         /**< Key Injection Aborted */
    ISMP_Result_KEY_INJECTION_KEY_NOT_FOUND,                   /**< Key Injection failed because no key was found on the server */
    ISMP_Result_KEY_INJECTION_INVALID_HTTP_FILE,               /**< Key Injection failed because the returned HTTP file is invalid */
    ISMP_Result_KEY_INJECTION_INVALID_HTTP_RESPONSE,           /**< Key Injection failed because the returned HTTP response is not 200 OK */
    ISMP_Result_KEY_INJECTION_INVALID_HTTP_HEADER,             /**< Key Injection failed because the returned HTTP header is invalid */
    ISMP_Result_KEY_INJECTION_SSL_NEW_ERROR,                   /**< Key Injection failed because of an SSL initialization failure */
    ISMP_Result_KEY_INJECTION_SSL_CONNECT_ERROR,               /**< Key Injection failed because the connection to the server can not be established */
    ISMP_Result_KEY_INJECTION_SSL_READ_ERROR,                  /**< Key Injection failed because of an SSL reading error */
    ISMP_Result_KEY_INJECTION_SSL_WRITE_ERROR,                 /**< Key Injection failed because of an SSL writing error */
    ISMP_Result_KEY_INJECTION_SSL_PROFILE_ERROR,               /**< Key Injection failed because of an SSL profile error */
    ISMP_Result_KEY_INJECTION_INTERNAL_ERROR,                  /**< Key Injection failed because of an internal error */

    ISMP_Result_ENCRYPTION_KEY_NOT_FOUND,                      /**< The encryption key does not exist within the Companion */
    ISMP_Result_ENCRYPTION_KEY_INVALID,                        /**< The encryption key is not valid */
    ISMP_Result_ENCRYPTION_DLL_MISSING                         /**< The encryption DLL is missing within the Companion */
} iSMPResult;

@interface ICISMPDevice : NSObject <NSStreamDelegate> {
	// Companion management
	NSString				* protocolName;                             /**< IAP protocol name that the @ref ICISMPDevice uses for communication with the Companion */
	EASession				* _cradleSession;                           /**< The IAP session opened by the @ref ICISMPDevice to the Companion */
	BOOL					  isAvailable;                              /**< Companion connection state */
	
	NSOutputStream			* outStream;                                /**< Serial output stream */
	NSInputStream			* inStream;                                 /**< Serial input stream */
	
	// iSMP Messages Processing
	NSRecursiveLock			* _inDataLock;                              /**< Used to synchronize access to received data buffer */
	NSMutableData			* _inStreamData;                            /**< Data received from Companion */
	NSMutableDictionary		* _actionLookupTable;                       /**< Map TLV tags to selectors */
	BOOL					  mustProcessReceivedDataOnCurrentThread;   /**< Indicates whether data should be processed in the communication thread (NO by default, messages are processed on the main thread) */
	NSArray					* _spmResponseTags;                         /**< List of all Companion's response Tags on a given channel */
	
	NSOperationQueue		* _requestOperationQueue;                   /**< This operation queue serializes the send operations to the Companion */
	
	id<ICISMPDeviceDelegate>	  _delegate;                            /**< Delegate of the @ref ICISMPDevice Class */
	
	NSCondition				* _waitingForResultCondition;               /**< Condition variable  used by subclassed of @ref ICISMPDevice to synchronize their calls */
	NSLock					* _waitingForResultLock;                    /**< Lock used to synchronize the methods of subclasses of @ref ICISMPDevice */
	id						 _requestResult;                            /**< Variable used to store the results of synchronous commands of subclasses of @ref ICISMPDevice. The _waitingForResultCondition should be signalled after this variable is set */
	NSMutableArray			* _pendingRequests;                         /**< Array of requests sent but that were not responded to by the terminal */
	
	SEL _processReceivedDataSEL;                                        /**< Selector called to process received data */
	IMP _processReceivedDataIMP;                                        /**< Used to optimize the call of _processReceivedDataSEL */
	SEL _simulateEventBytesAvailableforStreamSEL;                       /**< Selector called to simulate a byte available event */
}

@property (nonatomic, readonly) NSString    *protocolName;
@property (readonly) BOOL isAvailable;

@property (readonly) NSInputStream   *inStream;

@property (readonly) NSOutputStream  *outStream;

@property(nonatomic, assign) id<ICISMPDeviceDelegate> delegate;

//------------------------------------------------------------------------------

-(id)initWithProtocolString:(NSString*)protocolString;

-(id)initWithStreamIn:(NSInputStream*)inStream
		 andStreamOut:(NSOutputStream*)outStream;

// The following methods reads values returned in the authentication process
+(BOOL) isAvailable;

+(NSString *)getRevisionString;

+(NSString *)getVersionString;

+(NSString*) serialNumber;

+(NSString*) modelNumber;

+(NSString*) firmwareRevision;

+(NSString*) hardwareRevision;

+(NSString*) name;

+(void)setWantedDevice:(NSString *)wantedDevice;

+(NSString*) getWantedDevice;

+(NSMutableArray *)getConnectedTerminals;

enum SEVERITY_LOG_LEVELS {
	SEV_DEBUG=0,                                        /**< Debug Message */
	SEV_INFO,                                           /**< Information Message */
	SEV_TRACE,                                          /**< Trace Message */
	SEV_WARN,                                           /**< Warning Message */
	SEV_ERROR,                                          /**< Error Message */
	SEV_FATAL,                                          /**< Fatal Error Message */
	SEV_UNKOWN                                          /**< Unknown-Severity Message */
};

+(NSString*) severityLevelString:(int)level;

+(const char*) severityLevelStringA:(int)level;

@end

#pragma mark -
@protocol ICISMPDeviceDelegate
@optional

-(void)accessoryDidConnect:(ICISMPDevice*)sender;

-(void)accessoryDidDisconnect:(ICISMPDevice *)sender;

@optional

// log : you may implement either logEntry / logSerialData or implement the device specific --> only one call is made.

-(void) logEntry:(NSString*)message withSeverity:(int)severity;

-(void) logSerialData:(NSData*)data incomming:(BOOL)isIncoming;

@end

