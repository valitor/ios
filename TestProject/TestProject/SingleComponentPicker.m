//
//  SingleComponentPicker.m
//  ValitorTest
//
//  Created by Ivar Johannesson on 13/04/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import "SingleComponentPicker.h"

@interface SingleComponentPicker () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, strong) NSArray<NSString*> *arrContent;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic) NSString *selectedTitle;
@property (strong, nonatomic) void (^blockSelect)(SingleComponentResponseObject *);
@property (strong, nonatomic) SingleComponentResponseObject *responseObject;

@end

@implementation SingleComponentPicker

#define HEADER_HEIGHT 50

-(id)initWithFrame:(CGRect)frame selectionBlock:(void(^)(SingleComponentResponseObject *responseObject))blockSelect arrContent:(NSArray *)arrContent preselectedComponent:(NSInteger)preselectedComponent{
    
    self = [super initWithFrame:frame];
    if(self){
        
        _blockSelect = blockSelect;
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        [_pickerView setFrame:CGRectMake(0, HEADER_HEIGHT, self.frame.size.width, self.frame.size.height - HEADER_HEIGHT)];
        
        
        
        
        UIButton *btnSelect = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 50)];
        [btnSelect setTitle:@"Select and close" forState:UIControlStateNormal];
        [self addSubview:btnSelect];
        [self bringSubviewToFront:btnSelect];
        [btnSelect setBackgroundColor:[UIColor blackColor]];
        [btnSelect setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[btnSelect titleLabel] setFont:[UIFont systemFontOfSize:15]];
        [btnSelect addTarget:self action:@selector(titlePicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:btnSelect];
        [self bringSubviewToFront:btnSelect];
        
        _pickerView.backgroundColor = [UIColor whiteColor];
        
        _arrContent = arrContent;
        _responseObject = [[SingleComponentResponseObject alloc] init];
        
        if(preselectedComponent){
            _selectedTitle = _arrContent[preselectedComponent];
            _responseObject.strResponse = _arrContent[preselectedComponent];
            _responseObject.intResponse = preselectedComponent;
            [_pickerView selectRow:preselectedComponent inComponent:0 animated:YES];
        }
        else{
            if([_arrContent count] > 0){
                _selectedTitle = _arrContent[0];
                _responseObject.strResponse = _selectedTitle;
                _responseObject.intResponse = 0;
                [_pickerView selectRow:0 inComponent:0 animated:YES];
            }
        }
        
        [self addSubview:_pickerView];
        
        
    }
    return self;
}

-(void)titlePicked:(id)sender{
    
    _blockSelect(_responseObject);
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return [_arrContent count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel* lblRow = (UILabel*)view;
    if (!lblRow){
        lblRow = [[UILabel alloc] init];
        lblRow.font = [UIFont systemFontOfSize:15];
        lblRow.textColor = [UIColor blackColor];
        lblRow.textAlignment = NSTextAlignmentCenter;
    }
    
    lblRow.text = _arrContent[row];
    
    return lblRow;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _responseObject.strResponse = _arrContent[row];
    _responseObject.intResponse = row;
}

- (void)selectAndClose {
    
    _blockSelect(_responseObject);
    
}

@end
