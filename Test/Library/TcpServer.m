//
//  ICTcpServer.m
//  PCL
//
//  Created by Hichem Boussetta on 24/05/12.
//  Copyright (c) 2012 Ingenico. All rights reserved.
//

#import "TcpServer.h"
#import "communicationThread.h"

#include <CFNetwork/CFSocketStream.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <unistd.h>
#import <arpa/inet.h>


@interface TcpServer ()
-(void)_destroyClientSession;
-(void)_handleConnection:(NSString *)peer inputStream:(NSInputStream *)readStream outputStream:(NSOutputStream *)writeStream;
-(void)_startServerOnComThread;

@end


@implementation TcpServer

@synthesize inputStream = _inputStream;
@synthesize outputStream = _outputStream;
@synthesize peerName = _peerName;
@synthesize delegate;
@synthesize streamDelegate;
@synthesize port;


-(id)init {
    if ((self = [super init])) {
        _peerName       = nil;
        _inputStream    = nil;
        _outputStream   = nil;
        self.delegate   = nil;
        ipsocket        = NULL;
    }
    return self;
}


-(void)dealloc {
    [self stopServer];
    
    [super dealloc];
}


static void ServerAcceptCallBack(CFSocketRef socket, CFSocketCallBackType type, CFDataRef address, const void *data, void *info) {
    NSLog(@"%s", __FUNCTION__);
    
    TcpServer * server = (TcpServer *)info;
    
    //If a client is already connected - Reject the accept request
    if (server.inputStream || server.outputStream) {
        NSLog(@"%s A client is already connected - The connection is refused", __FUNCTION__);
        return;
    } else {
        //Accept the client's request
        if (kCFSocketAcceptCallBack == type) {
            
            // for an AcceptCallBack, the data parameter is a pointer to a CFSocketNativeHandle
            CFSocketNativeHandle nativeSocketHandle = *(CFSocketNativeHandle *)data;
            
            struct sockaddr_in peerAddress;
            socklen_t peerLen = sizeof(peerAddress);
            NSString * peer = nil;
            
            if (getpeername(nativeSocketHandle, (struct sockaddr *)&peerAddress, (socklen_t *)&peerLen) == 0) {
                peer = [NSString stringWithUTF8String:inet_ntoa(peerAddress.sin_addr)];
            } else {
                peer = @"Generic Peer";
            }
            
            CFReadStreamRef readStream = NULL;
            CFWriteStreamRef writeStream = NULL;
            
            CFStreamCreatePairWithSocket(kCFAllocatorDefault, nativeSocketHandle, &readStream, &writeStream);
            
            if (readStream && writeStream) {
                CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
                CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
                [server _handleConnection:peer inputStream:(NSInputStream *)readStream outputStream:(NSOutputStream *)writeStream];
            } else {
                // on any failure, need to destroy the CFSocketNativeHandle since we are not going to use it any more
                close(nativeSocketHandle);
            }
            if (readStream) CFRelease(readStream);
            if (writeStream) CFRelease(writeStream);
        }
    }
}


-(void)_destroyClientSession {
    NSLog(@"%s", __FUNCTION__);
    
    if (_peerName) {
        [_peerName release];
        _peerName = nil;
    }
    
    if (_inputStream) {
        [_inputStream close];
        [_inputStream release];
        _inputStream = nil;
    }
    
    if (_outputStream) {
        [_outputStream close];
        [_outputStream release];
        _outputStream = nil;
    }
}

-(void)_handleConnection:(NSString *)peer inputStream:(NSInputStream *)readStream outputStream:(NSOutputStream *)writeStream {
    NSLog(@"%s", __FUNCTION__);
    
    //Update the peer's information
    [self _destroyClientSession];
    _peerName       = [peer retain];
    _inputStream    = [readStream retain];
    _outputStream   = [writeStream retain];
    
    [_inputStream setDelegate:self];
    [_outputStream setDelegate:self];
    
    [_inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [_outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [_inputStream open];
    [_outputStream open];
    
    //Notify the delegate
    if ([(NSObject *)self.delegate respondsToSelector:@selector(connectionEstablished:)]) {
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(connectionEstablished:) withObject:self waitUntilDone:NO];
    }
}


-(BOOL)startServer {
    NSLog(@"%s", __FUNCTION__);
    
    [self performSelector:@selector(_startServerOnComThread) onThread:[communicationThread sharedCommunicationThread] withObject:nil waitUntilDone:YES];
    
    return YES;
}

-(void)_startServerOnComThread {
    NSLog(@"%s", __FUNCTION__);
    
    //Variables
    struct sockaddr_in serverAddress;
    socklen_t nameLen = 0;
    nameLen = sizeof(serverAddress);
    
    if (ipsocket) {
        NSLog(@"%s Server Socket Already Initialized", __FUNCTION__);
        return;
    } else {
        CFSocketContext socketCtxt = {0, self, NULL, NULL, NULL};
        ipsocket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)&ServerAcceptCallBack, &socketCtxt);
        
        //Socket configuration
        int yes = 1;
        setsockopt(CFSocketGetNative(ipsocket), SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
        setsockopt(CFSocketGetNative(ipsocket), IPPROTO_TCP, TCP_NODELAY, (void *)&yes, sizeof(yes));
        
        
        // set up the IPv4 endpoint; use port 0, so the kernel will choose an arbitrary port for us, which will be advertised using Bonjour
        memset(&serverAddress, 0, sizeof(serverAddress));
        serverAddress.sin_len = nameLen;
        serverAddress.sin_family = AF_INET;
        serverAddress.sin_port = htons(self.port);
        serverAddress.sin_addr.s_addr = htonl(INADDR_ANY);
        NSData * address4 = [NSData dataWithBytes:&serverAddress length:nameLen];
        
        if (kCFSocketSuccess != CFSocketSetAddress(ipsocket, (CFDataRef)address4)) {
            if (ipsocket)
                CFRelease(ipsocket);
            ipsocket = NULL;
            return;
        }
        
        // set up the run loop sources for the sockets
        CFRunLoopRef cfrl = (CFRunLoopRef) CFRunLoopGetCurrent();	// startServer should performed on the runloop on which the socket events will be scheduled
        CFRunLoopSourceRef source = CFSocketCreateRunLoopSource(kCFAllocatorDefault, ipsocket, 0);
        CFRunLoopAddSource(cfrl, source, kCFRunLoopCommonModes);
        CFRelease(source);
    }
}


-(void)stopServer {
    NSLog(@"%s", __FUNCTION__);
    
    //Destroy the client streams
    [self _destroyClientSession];
    
    //Stop the server socket
    if (ipsocket != NULL) {
        CFSocketInvalidate(ipsocket);
        CFRelease(ipsocket);
        ipsocket = NULL;
    }
    
    
    
}

#pragma mark NSStreamDelegate

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    //forward stream events to delegate
    if ([(NSObject *)self.streamDelegate respondsToSelector:@selector(stream:handleEvent:)]) {
        [(id<NSStreamDelegate>)self.streamDelegate stream:aStream handleEvent:eventCode];
    }
}

#pragma mark -

@end

