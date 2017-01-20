//
//  CompanionSelectorViewController.m
//  TestProject
//
//  Created by Ivar Johannesson on 23/05/16.
//  Copyright © 2016 Stokkur. All rights reserved.
//

#import "CompanionSelectorViewController.h"
#import "POSTableCell.h"
#import "ActionMenu.h"


@interface CompanionSelectorViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *lblSelect;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray<NSString *> *arrCompanions;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UILabel *lblNoPos;
@property (weak, nonatomic) IBOutlet UILabel *lblSelectedPos;


@end

@implementation CompanionSelectorViewController

#pragma mark - setup
- (void)viewDidLoad {
    
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.title = @"Companion Selection";
    _lblNoPos.hidden = NO;
    _lblNoPos.text = @"No Pos Devices in range";
    _lblSelect.text = @"Tap to select POS Device & Pull to refresh";
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor whiteColor];
    [_refreshControl addTarget:self action:@selector(refreshCompanionArray:) forControlEvents:UIControlEventValueChanged];
    [_tableView addSubview:_refreshControl];
    
    _arrCompanions = [[CommunicationManager manager] getConnectedTerminals];
    NSLog(@"%@", _arrCompanions);
    if([_arrCompanions count] > 0){
        _lblNoPos.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)btnNavigatePressed:(id)sender {
    ActionMenu *actionMenuViewController = [[ActionMenu alloc] initWithSelectedPos:_selectedCompanion];
    [self.navigationController pushViewController:actionMenuViewController animated:YES];
}

#pragma mark - TableView methods
- (POSTableCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    POSTableCell *cell = [tableView dequeueReusableCellWithIdentifier:[POSTableCell reuseIdentifier]];
    
    if(!cell){
        
        cell = [[POSTableCell alloc] init];
    }
    
    [cell setupWithPOSName:_arrCompanions[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    _selectedCompanion = _arrCompanions[indexPath.row];
    _lblSelectedPos.text = [NSString stringWithFormat:@"Selected POS: %@", _selectedCompanion];
    
    [[CommunicationManager manager] setWantedDevice:_selectedCompanion];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _arrCompanions.count;
}

#pragma mark - General methods

-(void)refreshCompanionArray:(id)sender{
    
    _arrCompanions = [ICISMPDevice getConnectedTerminals];
    
    if([_arrCompanions count] > 0){
        _lblNoPos.hidden = YES;
    }
    else _lblNoPos.hidden = NO;
    
    [_tableView reloadData];
    if(_refreshControl){
        [_refreshControl endRefreshing];
    }
}

@end
