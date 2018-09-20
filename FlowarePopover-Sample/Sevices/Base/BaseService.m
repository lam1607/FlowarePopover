//
//  BaseService.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/31/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "BaseService.h"

@implementation BaseService

#pragma mark -
#pragma mark - BaseServiceProtocols implementation
#pragma mark -
- (void)fetchDataFromUrl:(NSURL *)url completion:(void (^)(NSData *data))complete {
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (complete) {
            complete((data && !error) ? data : nil);
        }
    }];
    
    [task resume];
}

- (NSArray<NSDictionary *> *)getMockupDataType:(NSString *)mockType {
    NSMutableArray *mockData = [[NSMutableArray alloc] init];
    NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:FILENAME_DATA_MOCKUP ofType:@"plist"]];
    NSString *dataKey = mockType;
    
    if (![Utils isEmptyObject:[dataDict objectForKey:dataKey]] && [[dataDict objectForKey:dataKey] isKindOfClass:[NSArray class]]) {
        mockData = [[NSMutableArray alloc] initWithArray:[dataDict objectForKey:dataKey]];
    }
    
    return mockData;
}

@end
