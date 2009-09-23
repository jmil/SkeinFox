//
//  Copyright 2009 Jordan Miller, Hive76. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface gitBranch : NSObject {
    NSString *name;
    NSString *lastModified;
}

@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSString *lastModified;

@end
