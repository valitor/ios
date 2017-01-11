//
//  PseudoModal.h
//  TestProject
//
//  Created by Ivar Johannesson on 23/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SingleComponentPicker.h"

@interface PseudoModal : UIView
-(void)show;
-(void)close;
-(id)initWithSingleComponentPickerWithSelectBlock:(void(^)(SingleComponentResponseObject *responseObject))blockSelect blockViewClosed:(void(^)())blockViewClosed arrContent:(NSArray *)arrContent preselectedComponent:(NSInteger)preselectedComponent;
@end
