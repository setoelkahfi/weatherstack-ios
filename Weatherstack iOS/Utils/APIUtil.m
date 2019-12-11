//
//  APIUtil.m
//  Weatherstack iOS
//
//  Created by Seto Elkahfi on 11/12/19.
//  Copyright © 2019 Seto Elkahfi. All rights reserved.
//

#import "APIUtil.h"

@interface APIUtil ()

@property (strong, nonatomic) NSMutableDictionary * weatherIcons;

@end

@implementation APIUtil

+ (instancetype)sharedInstance {
    
    static APIUtil *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[APIUtil alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (void)getCurrentWeather:(NSString *)city withCompletion:(void (^)(NSDictionary * _Nullable))completion {
    
    NSString * accessKey = @"9350ec4293192336ba5aed587b59e08d";

    NSString * restUrl = [NSString stringWithFormat:@"http://api.weatherstack.com/current?access_key=%@&query=%@", accessKey, [self URLEncodedString_ch:city]];
    NSURL * url = [NSURL URLWithString:restUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    
    NSURLSession * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (data.length > 0 && error == nil) {
            
            NSDictionary * weatherData = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion([weatherData objectForKey:@"current"]);
            });
        }
    }] resume];
}

- (NSString *)URLEncodedString_ch:(NSString *)url {
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[url UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (UIImage *)imageForKey:(NSString *)url {
    return [self.weatherIcons objectForKey:url];
}

- (void)setImage:(UIImage *)image forKey:(NSString *)url {
    [self.weatherIcons setObject:image forKey:url];
}

@end
