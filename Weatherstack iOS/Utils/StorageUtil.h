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
-(void)addOrUpdateFavorite:(NSDictionary *)city;

@end

NS_ASSUME_NONNULL_END
