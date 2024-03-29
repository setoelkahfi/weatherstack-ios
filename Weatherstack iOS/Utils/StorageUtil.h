//
//  StorageUtil.h
//  Weatherstack iOS
//
//  Created by Seto Elkahfi on 11/12/19.
//  Copyright © 2019 Seto Elkahfi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface StorageUtil : NSObject


+(instancetype)sharedInstance;

-(NSArray<NSDictionary *> *)getFavorites;
-(void)addOrUpdateFavorite:(NSDictionary *)city onAdded:(void ( ^ )( NSString * ) )onAdded onExist:(void ( ^ )( NSString * ) )onExist;
-(void)deleteFavorite:(NSUInteger)row completion:(void ( ^ )( void ) )completion;
-(void)reorderFavoritesAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex completion:(void ( ^ )( void ) )completion;
- (void)refreshFavoritesWeather:(void ( ^ )( void ) )completion;

@end

NS_ASSUME_NONNULL_END
