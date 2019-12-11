//
//  ViewController.m
//  Weatherstack iOS
//
//  Created by Seto Elkahfi on 10/12/19.
//  Copyright © 2019 Seto Elkahfi. All rights reserved.
//

#import "HomeViewController.h"
#import "StorageUtil.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation HomeViewController

static NSString * CellIdentifier = @"HomeCell";

#pragma mark - UI lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[StorageUtil sharedInstance] getFavorites] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
        
    NSDictionary * city = [[[StorageUtil sharedInstance] getFavorites] objectAtIndex:indexPath.row];
        
    cell.textLabel.text = [city objectForKey:@"name"];
    cell.detailTextLabel.text = [city objectForKey:@"country"];
        
    return cell;
}

@end
