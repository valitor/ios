## Introduction

This is the GitHub repo for the Valitor Posi Tengdur iOS library. This repo contains a library to communicate with Valitor configured Ingenico applications, along with an example app that demonstrates the usage of the library.

The example project is the Test.xcodeproj while the library itself can be found under Test/Library

## Code Example

Check out the example app for code examples. The Test/ViewControllers/CompanionSelectorViewController demonstrates how to connect to a specific POS device while the 
Test/ViewControllers/ActionMenu viewcontroller demonstrates how to connect to the POS device on TCP level and send messages to it through Bluetooth+TCP.

## Installation

1. Copy all contents of Test/Library into your application. Make sure to mark 'Cope files if needed' and make sure that the files are added to your project's target.

2. Add the following to your Info.plist:
<key>UISupportedExternalAccessoryProtocols</key>
	<array>
		<string>com.ingenico.easypayemv.printer</string>
		<string>com.ingenico.easypayemv.spm-pppchannel</string>
		<string>com.ingenico.easypayemv.barcodereader</string>
		<string>com.ingenico.easypayemv.spm-transaction</string>
		<string>com.ingenico.easypayemv.spm-configuration</string>
		<string>com.ingenico.easypayemv.spm-networkaccess</string>
		<string>com.ingenico.easypayemv.spm-sppchannel</string>
	</array>

## Author

Ívar Húni Jóhannesson
ivarhuni@stokkur.is

## Contact

Thordurig@valitor.is
simonov@valitor.is
