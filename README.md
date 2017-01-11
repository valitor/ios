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

## Author

Ívar Húni Jóhannesson
ivarhuni@stokkur.is

## Contact

Thordurig@valitor.is
simonov@valitor.is
