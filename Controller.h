//
//  Controller.h
//  NSPopUpButtonBindings
//
//  Created by Kevin Wojniak on 1/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Controller : NSObject {
    NSMutableArray *gitBranches;
    NSUInteger currentBranch;
    IBOutlet NSPopUpButton *popUpButton;
}

@property (readwrite, retain) NSMutableArray *gitBranches;
@property (nonatomic, retain) IBOutlet NSPopUpButton *popUpButton;

@end
