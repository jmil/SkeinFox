//
//  Controller.m
//  NSPopUpButtonBindings
//
//  Created by Kevin Wojniak on 1/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

//Jordan Says:
/*
 This project and websites were from:
 http://forums.macrumors.com/showthread.php?t=420530
 http://www.cocoabuilder.com/archive/message/cocoa/2006/5/31/164724
 http://att.macrumors.com/attachment.php?attachmentid=99500&d=1201413221
 
 
 */

#import "Controller.h"
#import "gitBranch.h"
#import "ShellTask.h"


@implementation Controller

@synthesize gitBranches, popUpButton, myArrayController;

- (void)awakeFromNib {
    
    // Check if git is installed!
    
    
    // Populate pop-up with Git branches for .skeinforge directory!
    
    NSString *branchesRaw = [ShellTask executeShellCommandSynchronously:@"cd ~/.skeinforge; git branch"];
    NSLog(branchesRaw);
    
    NSArray *namesTemp = [branchesRaw componentsSeparatedByString:@"\n"];
    NSMutableArray *names = [NSMutableArray arrayWithArray:namesTemp];
    
    
    //Set the current branch to 0
    currentBranch = 0;
    
    
    // Cleanup the Array to both mark the currently selected branch and also to remove leading and lagging whitespace
    NSInteger index = 0;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSString *element in names) {
        // Remove last return character! -- remove lagging whitespace == last newline
        if (index != ([names count] - 1)) {
            
            // Check whether 2nd character is *, therefore this is the current branch
            if ([[element substringToIndex:1] isEqualToString: @"*"] ) {
                NSLog(@"I am the current branch, and my name is %@", element);
                currentBranch = index;                
            }
            
            
            // Remove first 3 characters
            [tempArray addObject:[element substringFromIndex:2]];
            
            
        }
        index++;
    }
    
    [names setArray:tempArray];
    [tempArray release];
    
    
    
    
    
    
    //NSArray *names = [NSArray arrayWithObjects:@"Bird", @"Chair", @"Song", @"Computer", nil];
    gitBranches = [NSMutableArray array];
    for (NSString *name in names)
    {
        gitBranch *branch = [[[gitBranch alloc] init] autorelease];
        branch.name = name;
        branch.lastModified = @"last modified on XXXXX";
        [gitBranches addObject:branch];
    }
    
    self.gitBranches = gitBranches;
    
    NSLog(@"my currentBranch is %i", currentBranch);
    
    [myArrayController setSelectionIndex:currentBranch];
}

@end
