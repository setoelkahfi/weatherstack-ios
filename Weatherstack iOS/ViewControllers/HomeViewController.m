//
//  ViewController.m
//  Weatherstack iOS
//
//  Created by Seto Elkahfi on 10/12/19.
//  Copyright © 2019 Seto Elkahfi. All rights reserved.
//

#import "HomeViewController.h"
#import "StorageUtil.h"
#import "SearchViewController.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
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
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"searchSegue"]) {
        
        SearchViewController * viewController = (SearchViewController *) segue.destinationViewController;
        viewController.onCityAddedCallback = ^() {
            [self.tableView reloadData];
        };
        
    }
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
        
    NSString * name = [city objectForKey:@"name"];
    NSString * country = [city objectForKey:@"country"];
    NSDictionary * weather = [city objectForKey:@"current"];
    NSString * temperature = [weather objectForKey:@"temperature"];
    NSString * windSpeed = [weather objectForKey:@"wind_speed"];
    NSString * windDir = [weather objectForKey:@"wind_dir"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, Temp: %@ degrees, Wind speed/direction: %@/%@", name, temperature, windSpeed, windDir];
    cell.detailTextLabel.text = country;
        
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [[StorageUtil sharedInstance] deleteFavorite:indexPath.row completion:^{

            [self.tableView reloadData];
        }];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
    [[StorageUtil sharedInstance] reorderFavoritesAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row completion:^{
       // Do nothing
    }];
}

- (IBAction)editButtonOnClicked:(id)sender {
    
    if ([self.tableView isEditing]) {
        self.editButton.title = @"Edit";
        [self.tableView setEditing:NO animated:YES];
    } else {
        self.editButton.title = @"Done";
        [self.tableView setEditing:YES animated:YES];
    }
}

- (IBAction)searchOrCancelButtonOnClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"searchSegue" sender:nil];
}

@end
