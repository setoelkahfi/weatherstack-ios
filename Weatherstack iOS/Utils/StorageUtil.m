//
//  StorageUtil.m
//  Weatherstack iOS
//
//  Created by Seto Elkahfi on 11/12/19.
//  Copyright © 2019 Seto Elkahfi. All rights reserved.
//

#import "StorageUtil.h"
#import "APIUtil.h"

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
    NSArray * favorites = [defaults objectForKey:@"favorites"];
    
    return favorites;
}

- (void)addOrUpdateFavorite:(NSDictionary *)city onAdded:(void (^)(NSString * _Nonnull))onAdded onExist:(void (^)(NSString * _Nonnull))onExist {
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

        NSMutableArray * favorites;
        
        if (![self getFavorites]) {
            favorites = [[NSMutableArray alloc] init];
        } else {
            favorites = [[self getFavorites] mutableCopy];
        }
    
        NSNumber * cityId = [city objectForKey:@"id"];
        
        if ([self findCityWith:cityId inArray:favorites]) {
            // Already there
            // Maybe update it?
            dispatch_async(dispatch_get_main_queue(), ^(void){
                onExist(@"This city is already on your favorites list.");
            });
        } else {
            
            NSString * cityName = [city objectForKey:@"name"];
            
            [[APIUtil sharedInstance] getCurrentWeather:cityName withCompletion:^(NSDictionary * _Nonnull dict) {
                
                if (!dict) {
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        onAdded(@"Weather detail cannot be retrived.");
                    });
                    return;
                }
                
                NSMutableDictionary * cityWithWeather = [NSMutableDictionary dictionaryWithDictionary:city];
                
                [cityWithWeather setObject:dict forKey:@"current"];
                [favorites addObject:cityWithWeather];
                [[NSUserDefaults standardUserDefaults] setObject:favorites
                                                          forKey:@"favorites"];

                dispatch_async(dispatch_get_main_queue(), ^(void){
                    onAdded(@"City added as your favorite");
                });
            
            }];
        }
            

    });
    
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

- (void)deleteFavorite:(NSUInteger)row completion:(void (^)(void))completion {
    
    NSMutableArray * favorites = [[self getFavorites] mutableCopy];
    [favorites removeObjectAtIndex:row];
    [[NSUserDefaults standardUserDefaults] setObject:favorites
                                              forKey:@"favorites"];
    completion();
}

- (void)reorderFavoritesAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex completion:( void (^)(void))completion {
    
    NSArray * favorites = [self getFavorites];
    NSMutableArray * reorderedFavorites = [favorites mutableCopy];
    NSDictionary * movedCity = [favorites objectAtIndex:sourceIndex];
    [reorderedFavorites removeObjectAtIndex:sourceIndex];
    [reorderedFavorites insertObject:movedCity atIndex:destinationIndex];
    
    [[NSUserDefaults standardUserDefaults] setObject:reorderedFavorites
                                              forKey:@"favorites"];
    
    completion();
}

- (void)refreshFavoritesWeather:(void (^)(void))completion {
    
    NSArray * favorites = [self getFavorites];
    NSMutableArray * updatedFavorites = [favorites mutableCopy];
    
    dispatch_group_t group = dispatch_group_create();
    
    for (NSDictionary * city in favorites) {
        
        NSString * cityName = [city objectForKey:@"name"];
        NSUInteger index = [favorites indexOfObject:city];
        
        dispatch_group_enter(group);
        
        [[APIUtil sharedInstance] getCurrentWeather:cityName withCompletion:^(NSDictionary * _Nonnull dict) {
            
            if (dict) {
                NSMutableDictionary * cityWithWeather = [city mutableCopy];
                [cityWithWeather setObject:dict forKey:@"current"];
                [updatedFavorites replaceObjectAtIndex:index withObject:cityWithWeather];
            }
            
            dispatch_group_leave(group);
        }];
        
    }
    
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        [[NSUserDefaults standardUserDefaults] setObject:updatedFavorites
                                                  forKey:@"favorites"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    });
    
}

@end
