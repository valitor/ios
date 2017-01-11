//
//  AppDelegate.m
//  TestProject
//
//  Created by Ivar Johannesson on 19/04/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import "AppDelegate.h"
#import "ActionMenu.h"
#import "CompanionSelectorViewController.h"
#import "CommunicationManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    CompanionSelectorViewController *companionSelectorViewController = [[CompanionSelectorViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:companionSelectorViewController];
    [_window setRootViewController:navController];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //The Ingenico library recommends stopping the scanner when application goes inactive
    [[CommunicationManager manager] stopScan];
    
    //Close the BT+TCP connection gracefully
    [[CommunicationManager manager] closeChannels];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    //This code can be uncommented if the user wants to immidietly connect
    //when the application becomes active
    //However there are some problems with this approach, for example
    //You have to have set an active Companion in order to connect
    //To a specific POS device and not a random POS device that is available to the iOS device.
    //This can be done for example when the application has been alive before
    //And the application has already set an active companion (See CompanionSelectorVC for examples on how to set an active
    //companion).
    //This is the same code as in the example app when the
    //BT+TCP connection is going live
    
//    [[CommunicationManager manager] setupChannels];
//    
//    if([[CommunicationManager manager] bluetoothOpenChannelResult]){
//        NSLog(@"Starting TCP server in manager");
//        CommunicationManager *manager = [CommunicationManager manager];
//        [manager.arrConsoleMsgs addObject:@"Starting TCP Server"];
//        [[CommunicationManager manager] startTcpServer];
//    }
//    else{
//        NSLog(@"Unable to start TCP Server");
//        CommunicationManager *manager = [CommunicationManager manager];
//        [manager.arrConsoleMsgs addObject:@"Unable to start TCP Server"];
//    }

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
