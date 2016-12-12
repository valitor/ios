//
//  PseudoModal.m
//  TestProject
//
//  Created by Ivar Johannesson on 23/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//
#import "PseudoModal.h"
#import "MYUtls.h"



@interface PseudoModal ()
@property(nonatomic, strong) void (^blockClose)(id);
@property(nonatomic, strong) void (^blockViewClosed)();
@property(nonatomic,strong) id responseObject;
@property(nonatomic,strong) UIView *viewDisplayed;

@property (nonatomic, strong) SingleComponentPicker *singleComponentPicker;
@property (nonatomic) NSInteger preselectedComponent;

@end

#define UIPICKER_HEADER_HEIGHT 50

@implementation PseudoModal

-(id)initWithSingleComponentPickerWithSelectBlock:(void(^)(SingleComponentResponseObject *responseObject))blockSelect blockViewClosed:(void(^)())blockViewClosed arrContent:(NSArray *)arrContent preselectedComponent:(NSInteger)preselectedComponent{
    
    self = [super initWithFrame:CGRectMake(0, 0, [MYUtls screenSize].width, [MYUtls screenSize].height)];
    if(self){
        
        _blockClose = blockSelect;
        _blockViewClosed = blockViewClosed;
        
        UIPickerView *dummyPickerView = [[UIPickerView alloc] init];
        float pickerViewHeight = dummyPickerView.frame.size.height;
        dummyPickerView = nil;
        
        __weak PseudoModal *wSelf = self;
        
        _singleComponentPicker = [[SingleComponentPicker alloc] initWithFrame:CGRectMake(0, [MYUtls screenSize].height, [MYUtls screenSize].width, pickerViewHeight+UIPICKER_HEADER_HEIGHT)
                                                               selectionBlock:^(SingleComponentResponseObject *responseObject){
                                                                   wSelf.responseObject = responseObject;
                                                                   [wSelf close];
                                                                   wSelf.blockViewClosed();
                                                               } arrContent:arrContent
                                                         preselectedComponent:preselectedComponent];
        [self bringSubviewToFront:_singleComponentPicker];
        [self addSubview:_singleComponentPicker];
        
        _viewDisplayed = _singleComponentPicker;
        
    }
    return self;
}

-(void)show{
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [_viewDisplayed setFrame:CGRectMake(0,([MYUtls screenSize].height - [_viewDisplayed bounds].size.height),
                                                             [MYUtls screenSize].width, [_viewDisplayed bounds].size.height)];
                         
                         
                     } completion:^(BOOL finished) {
                         
                     }];
}


-(void)close{
    
    if(_blockClose){
        if(_responseObject){
            _blockClose(_responseObject);
        }
    }
    
    [UIView animateWithDuration:0.75
                     animations:^{
                         [_viewDisplayed setFrame:CGRectMake(0, [MYUtls screenSize].height,
                                                             [MYUtls screenSize].width, [_viewDisplayed bounds].size.height)];
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
