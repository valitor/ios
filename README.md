## Introduction

This is the GitHub repo for the Valitor Posi Tengdur iOS library. This repo contains a library to communicate with Valitor configured Ingenico POS devices, along with an example app that demonstrates the usage of the library.

The example project is the Test.xcodeproj while the library itself can be found under Test/Library

## Code Example

Check out the example app for code examples. The Test/ViewControllers/CompanionSelectorViewController demonstrates how to connect to a specific POS device while the 
Test/ViewControllers/ActionMenu viewcontroller demonstrates how to connect to the POS device on TCP level and send messages to it through Bluetooth+TCP.

## PreReqs
iOS Device  
Ingenico POS Device running the Valitor Posi Tengdur application  
Pairing of the iOS Device and Ingenico POS Device through the settings app.  

## Installation

The example application, Test.xcodeproj, is set up and ready to use for XCode 8.1. It contains sample code on how to use and is strongly recommended as a guide to the library.

The following steps can be taken to reproduce the environment in the test project:

1. Copy all contents of Test/Library into your application. Make sure to mark 'Copy files if needed' and make sure that the files are added to your project's target.
The files needed for the library are:
Constants.h  
CommunicationManager.h/m  
communicationThread.h/m  
iSMP.framework  
TcpServer.h/m  
VALAmount.h/m  
Valitor.a  
VALBaseClass.h (implementation file kept hidden in Valitor.a)  
VALCard.h/m  
VALRequest.h/m  


2. Add the following to your Info.plist:  
\<key\>UISupportedExternalAccessoryProtocols\</key\>  
	&nbsp;\<array\>  
		&nbsp;&nbsp;\<string>com.ingenico.easypayemv.printer\</string\>  
		&nbsp;&nbsp;\<string\>com.ingenico.easypayemv.spm-pppchannel\</string\>  
		&nbsp;&nbsp;\<string\>com.ingenico.easypayemv.barcodereader\</string\>  
		&nbsp;&nbsp;\<string\>com.ingenico.easypayemv.spm-transaction\</string\>  
		&nbsp;&nbsp;\<string\>com.ingenico.easypayemv.spm-configuration\</string\>  
		&nbsp;&nbsp;\<string\>com.ingenico.easypayemv.spm-networkaccess\</string\>  
		&nbsp;&nbsp;\<string\>com.ingenico.easypayemv.spm-sppchannel\</string\>  
	&nbsp;\</array\>  

3. Make sure that the iSMP framework provided in Test/Library is added to the 'Link Binary With Libraries' in your target's Build Phases tab

4. Make sure that the Valitor.a library file provided in Test/Library is added to the 'Link Binary With Libraries' in your target's Build Phases tab

5. Add the following system frameworks to your project:  
SystemConfiguration.framework,  
Foundation.framework,  
UIKit.framework,  
CFNetwork.framework,  
ExternalAccessory.framework,  
CoreGraphics.framework  

6. Your 'Link Binary With Libraries' section should look something like this:
![Alt text](http://i.imgur.com/ZM6K6Pt.png "Optional title attribute")

7. Add

-ObjC  
-all_load

to Target -> Build Settings -> Linking -> Other Linker Flags

![Alt text](http://i.imgur.com/ew0bGft.png "Optional title attribute")

Complete!

## Quick Start Guide (In the context of the example app)

Communicating with the POSI Tengdur application that runs on the POS Device:

The CompanionSelectorViewController displays a table of all bluetooth paired POS devices. In the delegate method didSelectRowAtIndexPath you specify which POS device you actually want to communicate with. Selecting a specific POS device out of the paired devices list is not required, but is heavily recommended. If you don't specify a POS device to communicate with, the Ingenico library will choose a random POS device out of all paired devices to communicate with.

The ActionMenu ViewController is meant as a simple example to start TCP communication with a POS device, along with barcode scanner start/stop functionality. The action that can be sent to the POS device are all the available methods in the Posi Tengdur application that is running on the POS device, along with starting/stopping the barcode scanner.

The usual workflow used in the ActionMenu to send messages to the POS device is:

1. Start TCP over bluetooth by pressing the 'Kveikja á TCP og BT' button, which executes the method startBTAndTCP. This will establish TCP bridge between the iOS and the POS device and able you to send NSString messages to the ValitorPosiTengdur application that is running on the POS device.
2. Select an action from the dropdown list by pressing the 'Ýttu til að velja posa aðgerð' button. What you select in this list will determine what actions you send to the POS device.
3. After 'Senda til Posa' button is pressed, the example application will try to send an NSString over TCP to the POS device. One thing to note here is that there is both a timeout on the iOS side and the POS side. This timeout is 180 seconds by default for all messages except the PING message, which has a 5 second timeout. This value can be overwritten on the iOS side but is not recommended. Simple example of the timeout:

Timout (iOS side)

- iOS sends message to POS, adds request to processing queue   
- POS doesn't respond within timeout  
- The request is removed from the request processing queue due to timeout  

Timeout (POS side)    

- POS receives message from iOS  
- POS sends response message to iOS  
- No confirmation of message delivered from the iOS application  
- Timeout on POS side, terminates the action and voids the transaction.  

The request processing queue of the communication manager is a FIFO system. If for some reasons your requests aren't being processed (for example if the TCP connection drops) your request queue might get clogged if you continue to send message requests before you get responses back. You can flush the requests processing queue with the  
  
-(void)emptyRequestQueue  

or remove certain requests from the queue by  

-(void)removeRequestFromQueue:(VALRequest *)requestToRemove    

Note: An example of the string messages sent back and forth between iOS and the POS can be found under Test/Library/VALResponses.


A known problem with POS devices running bluetooth applications is that the network connectivity managers on the POS devices are bad, meaning that they often don't detect a connection drop. This can lead to connectivity problems and incorrect states in applications trying to communicate with the POS devices. Although there is no perfect method to prevent this, there are remedies. 

- Before you send a transaction to the POS device, try sending a PING message first. If the PING message prevails, send the authorization request in the successblock of the PING message. By doing so you confirm that you have a connection to the POS device (since it responds to PING) and you can be relatively sure that your transaction request is actually sent to the POS device. An example of this usage pattern can be found in the method  
-(void)sendAuthWithPing in ActionMenu.m  

- You can also set up the TCP connection before each transaction, and tearing the connection down after each transaction. This pattern could come in handy when the POS device is not in close proximity with the iOS device at all times, but might be an overkill if the iOS and POS are side by side at all times.

- When the application enters background, iOS tears down the TCP connection. To handle this gracefully we disconnect the TCP bridge in AppDelegate:

- (void)applicationWillResignActive:(UIApplication *)application
  


## Barcode Reader
The barcode reader is not a part of the ValitorPosiTengdur application that is running on the POS devices. Instead it communicates directly with the OS on the POS device. This means that you only need to pair the POS device and the iOS device in the settings app and DON'T need to establish TCP communications to use the barcode scanner. See methods scanOnPressed and scanOffPressed in ActionMenu.m on how to start/stop the barcode scanner. It's recommended by Ingenico to call [[CommunicationManager manager] stopScan]] when your application enters background, and therefore code is in place in the AppDelegate to take care of that. I recommend that you do the same in your business application.

When a user selects a device to communicate with in CompanionSelectorViewController.m (didSelectRowAtIndexPath), the communication manager clears the memory reference to the barcode scanner before setting the wanted device on the barcode communication channel. This is done to clear out any possible previous connection to another barcode scanner. Specifying a wanted device for the [ICBarCodeReader sharedICBarCodeReader] without clearing the memory reference to [ICBarCodeReader sharedICBarCodeReader] doesn't seem to work and is most likely a bug in the Ingenico library itself, hence we clear the memory reference before setting the wanted device.

Note: You can setup a TCP+BT connection and then start the barcode scanner OR you can start the scanner and then start TCP+BT connectivity. The order does not matter. However, memory reference to the barcode reader must be cleared when TCP+BT connections are teared down in order to be able to start TCP+BT communications again. This is most likely due to a bug in the Ingenico library.

The CommunicationManager uses the delegate pattern to notify when the scanner has scanned data. See methods:

-(void)didReceiveScanData:(NSString *)data  (ActionMenu.m)

-(void)barcodeData:(id)data ofType:(int)type (CommunicationManager.m)

When you try to start the barcode scanner, three things can happen:
- Success
- Fail due to synchronization problems
- Denided due to POS device not being able to start scan, for example if it doesn't have enough power or an electric cord is plugged in which can lead to scan start failure.

Sometimes the ScanOn functionality fails in the first try, but usually works during in the second try.

The barcode reader can be configured for all kinds of symbols, see methods 

-(void)configureScannerForAllSymbols  

-(void)configureScannerForCustomSymbols  

for example on how to configure the scanner.


## Author

Ívar Húni Jóhannesson
ivarhuni@stokkur.is

## Contact

Thordurig@valitor.is
simonov@valitor.is
