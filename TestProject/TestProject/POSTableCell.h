//
//  POSTableCell.h
//  TestProject
//
//  Created by Ivar Johannesson on 23/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POSTableCell : UITableViewCell

@property (weak, nonatomic, readwrite) IBOutlet UILabel *lblName;

-(void)setupWithPOSName:(NSString *)posName;
+(NSString*)reuseIdentifier;
@end
