//
//  StorageUtil.m
//  Weatherstack iOS
//
//  Created by Seto Elkahfi on 11/12/19.
//  Copyright © 2019 Seto Elkahfi. All rights reserved.
//

#import "StorageUtil.h"

@implementation StorageUtil

+ (instancetype)sharedInstance {
    
    static StorageUtil *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[StorageUtil alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (NSArray<NSDictionary *> *)getFavorites {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray * favorites = [defaults objectForKey:@"favorites"];
    
    return favorites;
}

- (void)addOrUpdateFavorite:(NSDictionary *)city onAdded:(void (^)(NSString * _Nonnull))onAdded onExist:(void (^)(NSString * _Nonnull))onExist {
    
    NSMutableArray * favorites;
    
    if (![self getFavorites]) {
        favorites = [[NSMutableArray alloc] init];
    } else {
        favorites = [NSMutableArray arrayWithArray:[self getFavorites]];
    }
    
    NSNumber * cityId = [city objectForKey:@"id"];
    
    if ([self findCityWith:cityId inArray:favorites]) {
        // Already there
        // Maybe update it?
        onExist(@"City already added on your favorite!");
    } else {
        [favorites addObject:city];
        [[NSUserDefaults standardUserDefaults] setObject:favorites
                                                  forKey:@"favorites"];
        onAdded(@"City added as your favorite");
    }
    
}

- (BOOL)findCityWith:(NSNumber *)cityId inArray:(NSArray *)cities {

    __block BOOL found = NO;
    __block NSDictionary *dict = nil;

    [cities enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        dict = (NSDictionary *)obj;
        NSNumber * cityIdTemp = [dict valueForKey:@"id"];
        if ([cityIdTemp isEqualToNumber:cityId]) {
            found = YES;
            *stop = YES;
        }
    }];

    return found;
}

@end
