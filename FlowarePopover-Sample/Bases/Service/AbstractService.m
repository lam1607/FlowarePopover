//
//  AbstractService.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 1/3/19.
//  Copyright © 2019 Floware Inc. All rights reserved.
//

#import "AbstractService.h"

@implementation AbstractService

#pragma mark - AbstractServiceProtocols implementation

- (void)fetchDataFromUrl:(NSURL *)url completion:(void (^)(NSData *data))complete
{
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (complete)
        {
            complete((data && !error) ? data : nil);
        }
    }];
    
    [task resume];
}

- (NSArray<NSDictionary *> *)getMockupDataType:(NSString *)mockType
{
    NSMutableArray *mockData = [[NSMutableArray alloc] init];
    NSDictionary *dataDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:FILENAME_DATA_MOCKUP ofType:@"plist"]];
    NSString *dataKey = mockType;
    
    if ([[dataDict objectForKey:dataKey] isKindOfClass:[NSArray class]])
    {
        mockData = [[NSMutableArray alloc] initWithArray:[dataDict objectForKey:dataKey]];
    }
    
    return mockData;
}

@end
