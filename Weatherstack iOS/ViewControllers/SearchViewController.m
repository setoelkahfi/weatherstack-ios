//
//  SearchViewController.m
//  Weatherstack iOS
//
//  Created by Seto Elkahfi on 10/12/19.
//  Copyright © 2019 Seto Elkahfi. All rights reserved.
//

#import "SearchViewController.h"
#import "CityList.h"
#import "StorageUtil.h"

@interface SearchViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) CityList * cityList;
@property (nonatomic, retain) NSArray * filteredCities;


@end

@implementation SearchViewController

static NSString * CellIdentifier = @"Cell";

#pragma mark - UI lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.cityList = [[CityList alloc] init];
    
    self.searchBar.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)cancelButtonOnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredCities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary * city = [self.filteredCities objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [city objectForKey:@"name"];
    cell.detailTextLabel.text = [city objectForKey:@"country"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary * city = [self.filteredCities objectAtIndex:indexPath.row];
    
    [[StorageUtil sharedInstance] addOrUpdateFavorite:city];
    

    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Saved!"
                                                                    message:[NSString stringWithFormat:@"%@ added as your favorite.", [city objectForKey:@"name"]]
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    
    //[self presentViewController:alert animated:YES completion:nil];
   
    //[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    self.filteredCities = searchText.length >= 3 ? [self.cityList searchCityWith:searchText] : nil;

    [self.tableView reloadData];
}


@end
