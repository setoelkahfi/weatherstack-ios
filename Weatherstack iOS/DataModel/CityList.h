//
//  CityList.h
//  Weatherstack iOS
//
//  Created by Seto Elkahfi on 10/12/19.
//  Copyright © 2019 Seto Elkahfi. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CityList : NSObject


-(NSArray<NSDictionary *> *)searchCityWith:(NSString *)keywords;

@end

NS_ASSUME_NONNULL_END
