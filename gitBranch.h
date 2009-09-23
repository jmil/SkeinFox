//
//  Thing.h
//  NSPopUpButtonBindings
//
//  Created by Kevin Wojniak on 1/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface gitBranch : NSObject {
    NSString *name;
    NSString *lastModified;
}

@property (readwrite, retain) NSString *name;
@property (readwrite, retain) NSString *lastModified;

@end
