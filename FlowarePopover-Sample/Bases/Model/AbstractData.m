//
//  AbstractData.m
//  FlowarePopover-Sample
//
//  Created by lamnguyen on 8/30/18.
//  Copyright © 2018 Floware Inc. All rights reserved.
//

#import "AbstractData.h"

@interface AbstractData ()
{
    NSMutableDictionary *_imageDictionary;
}

/// @property
///

@end

@implementation AbstractData

#pragma mark - Initialize

- (instancetype)initWithContent:(NSDictionary *)contentDict
{
    if (self = [super init])
    {
        if ([contentDict isKindOfClass:[NSDictionary class]])
        {
            NSString *name = [contentDict objectForKey:@"name"];
            NSString *title = [contentDict objectForKey:@"title"];
            NSString *imageUrl = [contentDict objectForKey:@"imageUrl"];
            NSString *pageUrl = [contentDict objectForKey:@"pageUrl"];
            
            if ([name isKindOfClass:[NSString class]])
            {
                return [self initWithName:name imageUrl:imageUrl pageUrl:pageUrl];
            }
            
            return [self initWithTitle:title imageUrl:imageUrl pageUrl:pageUrl];
        }
    }
    
    return self;
}

- (instancetype)initWithName:(NSString *)name imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl
{
    if (self = [super init])
    {
        self.name = name;
        self.imageUrl = imageUrl;
        self.pageUrl = pageUrl;
    }
    
    return self;
}

- (instancetype)initWithTitle:(NSString *)title imageUrl:(NSString *)imageUrl pageUrl:(NSString *)pageUrl
{
    if (self = [super init])
    {
        self.title = title;
        self.imageUrl = imageUrl;
        self.pageUrl = pageUrl;
    }
    
    return self;
}

#pragma mark - NSCoding implementation

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init])
    {
        [self decode:aDecoder];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self encode:aCoder];
}

#pragma mark - NSCopying, NSMutableCopying implementation

- (id)copyWithZone:(nullable NSZone *)zone
{
    typeof(self) copy = [[[self class] allocWithZone:zone] init];
    
    [copy copy:self zone:zone];
    
    return copy;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    typeof(self) copy = [[[self class] allocWithZone:zone] init];
    
    [copy mutableCopy:self zone:zone];
    
    return copy;
}

#pragma mark - NSPasteboardWriting implementation

/**
 * Returns an array of UTI strings of data types the receiver can write to the pasteboard.  By default, data for the first returned type is put onto the pasteboard immediately, with the remaining types being promised.  To change the default behavior, implement -writingOptionsForType:pasteboard: and return NSPasteboardWritingPromised to lazily provided data for types, return no option to provide the data for that type immediately.  Use the pasteboard argument to provide different types based on the pasteboard name, if desired.  Do not perform other pasteboard operations in the method implementation.
 */
- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return [NSArray arrayWithObjects:(NSPasteboardType)kUTTypeData, nil];
}

/**
 * Returns options for writing data of a type to a pasteboard.  Use the pasteboard argument to provide different options based on the pasteboard name, if desired.  Do not perform other pasteboard operations in the method implementation.
 */
- (NSPasteboardWritingOptions)writingOptionsForType:(NSPasteboardType)type pasteboard:(NSPasteboard *)pasteboard
{
    return 0;
}

/**
 * Returns the appropriate property list object for the provided type.  This will commonly be the NSData for that data type.  However, if this method returns either a string, or any other property-list type, the pasteboard will automatically convert these items to the correct NSData format required for the pasteboard.
 */
- (nullable id)pasteboardPropertyListForType:(NSPasteboardType)type
{
    if ([type isEqualToString:(NSPasteboardType)kUTTypeData])
    {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    return nil;
}

#pragma mark - NSPasteboardReading implementation

/**
 * Returns an array of data types as UTI strings that the receiver can read from the pasteboard and be initialized from.  By default, the NSData for the type is provided to -initWithPasteboardPropertyList:ofType:.  By implementing -readingOptionsForType:pasteboard: and specifying a different option, the NSData for that type can be automatically converted to an NSString or property list object before being passed to -readingOptionsForType:pasteboard:.  Use the pasteboard argument to provide different types based on the pasteboard name, if desired.  Do not perform other pasteboard operations in the method implementation.
 */
+ (NSArray<NSPasteboardType> *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return [NSArray arrayWithObjects:(NSPasteboardType)kUTTypeData, nil];
}

/**
 * Returns options for reading data of a type from a pasteboard.  Use the pasteboard argument to provide different options based on the pasteboard name, if desired.  Do not perform other pasteboard operations in the method implementation.
 */
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type pasteboard:(NSPasteboard *)pasteboard
{
    if ([type isEqualToString:(NSPasteboardType)kUTTypeData])
    {
        return NSPasteboardReadingAsKeyedArchive;
    }
    
    return 0;
}

/**
 * Initializes an instance with a property list object and a type string.  By default, the property list object is the NSData for that type on the pasteboard.  By specifying an NSPasteboardReading option for a type, the data on the pasteboard can be retrieved and automatically converted to a string or property list instead.  This method is considered optional because if there is a single type returned from +readableTypesForPasteboard, and that type uses the NSPasteboardReadingAsKeyedArchive reading option, then initWithCoder: will be called to initialize a new instance from the keyed archive.
 */
- (nullable id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSPasteboardType)type
{
    if ([type isEqualToString:(NSPasteboardType)kUTTypeData])
    {
        return [NSKeyedUnarchiver unarchiveObjectWithData:propertyList];
    }
    
    return nil;
}

#pragma mark - Public methods

- (void)setImage:(NSImage *)image forURL:(NSString *)url
{
    if (_imageDictionary == nil)
    {
        _imageDictionary = [[NSMutableDictionary alloc] init];
    }
    
    if (image && ([_imageDictionary objectForKey:url] == nil))
    {
        [_imageDictionary setObject:image forKey:url];
    }
}

- (NSImage *)getImageForURL:(NSString *)url
{
    return (_imageDictionary && url) ? [_imageDictionary objectForKey:url] : nil;
}

@end
