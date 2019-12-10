//
//  CityList.m
//  Weatherstack iOS
//
//  Created by Seto Elkahfi on 10/12/19.
//  Copyright © 2019 Seto Elkahfi. All rights reserved.
//

#import "CityList.h"

@interface CityList ()

@property (nonatomic, retain) NSArray * cities;

@end

@implementation CityList

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString * path = [[NSBundle mainBundle] pathForResource:@"citylist" ofType:@"json"];
        NSString * jsonString = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        NSError * jsonError;
        self.cities = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    }
    return self;
}


- (NSArray<NSDictionary *> *)searchCityWith:(NSString *)keywords {
    NSPredicate * filter = [NSPredicate predicateWithFormat:@"name contains[c] %@ ", keywords];
    NSArray * filteredCities = [self.cities filteredArrayUsingPredicate:filter];
    return filteredCities;
}

@end
