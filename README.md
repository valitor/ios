# Valitor

#Prereqs
Add the following to your info.plist document: 
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

 Then add the iSMP framework found in the repo to your project

 Physical device running ios8+ (Bluetooth doesn't work for simulator)

List of frameworks that are needed (Should be automatically added via CocoaPods):
Security, AVFoundation, CoreAudio, AudioToolbox, MessageUI, CoreBluetooth, CFNetwork, ExternalAccessory, SystemConfiguration, CoreGraphics, UIKit, Foundation.

 ## Installation
Add the following to your podfile:

```ruby
pod 'Valitor', :git => 'https://bitbucket.org/stokkur/valitorcocoapod.git'
```

## Example

Example project that uses the CocoaPod can be found in TestProject folder

## Author
Ivar, ivarhuni@stokkur.is

