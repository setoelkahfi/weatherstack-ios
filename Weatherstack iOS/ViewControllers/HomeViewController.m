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
#import "FavoriteTableViewCell.h"
#import "APIUtil.h"

@interface HomeViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIRefreshControl * refreshControl;

@end

@implementation HomeViewController

static NSString * CellIdentifier = @"FavoriteTableViewCell";

#pragma mark - UI lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

    if (@available(iOS 10.0, *)) {
        self.tableView.refreshControl = self.refreshControl;
    } else {
        [self.tableView addSubview:self.refreshControl];
    }
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"FavoriteTableViewCell" bundle:nil]
         forCellReuseIdentifier:CellIdentifier];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FavoriteTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
    if (!cell) {
        cell = [[FavoriteTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
        
    NSDictionary * city = [[[StorageUtil sharedInstance] getFavorites] objectAtIndex:indexPath.row];
        
    NSString * name = [city objectForKey:@"name"];
    NSString * country = [city objectForKey:@"country"];
    NSDictionary * weather = [city objectForKey:@"current"];
    NSString * temperature = [weather objectForKey:@"temperature"];
    NSString * windSpeed = [weather objectForKey:@"wind_speed"];
    NSString * windDir = [weather objectForKey:@"wind_dir"];
    NSString * weatherDescriptions = [[weather objectForKey:@"weather_descriptions"] componentsJoinedByString:@", "];
    // For simplification, only take first element
    NSString * weatherIcon = [[weather objectForKey:@"weather_icons"] firstObject];
    
    cell.cityLabel.text = [NSString stringWithFormat:@"%@, %@", name, country];
    cell.windSpeedLabel.text = [NSString stringWithFormat:@"Wind speed: %@", windSpeed];
    cell.windDirectionLabel.text = [NSString stringWithFormat:@"Wind direction: %@", windDir];
    cell.temperatureLabel.text = [NSString stringWithFormat:@"%@%@", temperature, @"\u00B0"];
    cell.weatherDescription.text = weatherDescriptions;
    
    if (weatherIcon) {
        UIImage * image = [[APIUtil sharedInstance] imageForKey:weatherIcon];
        if (image) {
            [cell.weatherIcon setImage:image];
        } else {
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            
            dispatch_async(queue, ^{
                UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:weatherIcon]]];
                [[APIUtil sharedInstance] setImage:image forKey:weatherIcon];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [cell.weatherIcon setImage:image];
                    [cell setNeedsLayout];
                });
            });
        }
    }
        
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

#pragma mark - IBActions

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

- (void)refreshTable {
    [[StorageUtil sharedInstance] refreshFavoritesWeather:^{
        
        [self.refreshControl endRefreshing];
        [self.tableView reloadData];
    }];
}

@end
