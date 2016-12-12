//
//  SingleComponentPicker.h
//  ValitorTest
//
//  Created by Ivar Johannesson on 13/04/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SingleComponentResponseObject.h"

@interface SingleComponentPicker : UIView
-(id)initWithFrame:(CGRect)frame selectionBlock:(void(^)(SingleComponentResponseObject *responseObject))blockSelect arrContent:(NSArray *)arrContent preselectedComponent:(NSInteger)preselectedComponent;

- (void)selectAndClose;

@end
