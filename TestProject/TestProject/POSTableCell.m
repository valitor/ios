//
//  POSTableCell.m
//  TestProject
//
//  Created by Ivar Johannesson on 23/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import "POSTableCell.h"

@implementation POSTableCell

-(id)init{
    self = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil] firstObject];
    if(self){
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(NSString*)reuseIdentifier{
    return NSStringFromClass([self class]);
}


-(void)setupWithPOSName:(NSString *)posName{
    
    _lblName.text = posName;
}

@end
