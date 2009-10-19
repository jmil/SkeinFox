//
//  TableView.m
//  SkeinFox
//
//  Created by Jordan on 10/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableView.h"
#import "Controller.h"

@implementation TableView

@synthesize myController;

// make return and tab only end editing, and not cause other cells to edit

- (BOOL) textShouldEndEditing:(NSNotification *)notification {
    //NSLog(@"tableView textShouldEndEditing");
    return YES;
}

- (void)textDidChange:(NSNotification *)aNotification {
    //NSLog(@"tableView textDidChange!");
    
}



- (void) textDidEndEditing:(NSNotification *)notification
{
    NSLog(@"tableview textDidEndEditing!!!!!!");

    
    NSString *newGitBranchName = [[[notification object] textStorage] string];

    NSDictionary *userInfo = [notification userInfo];
    
    
    int textMovement = [[userInfo valueForKey:@"NSTextMovement"] intValue];
    
    if (textMovement == NSReturnTextMovement
        || textMovement == NSTabTextMovement
        || textMovement == NSBacktabTextMovement) {
        
        NSMutableDictionary *newInfo;
        newInfo = [NSMutableDictionary dictionaryWithDictionary: userInfo];
        
        [newInfo setObject: [NSNumber numberWithInt: NSIllegalTextMovement]
                    forKey: @"NSTextMovement"];
        
        notification =
        [NSNotification notificationWithName: [notification name]
                                      object: [notification object]
                                    userInfo: newInfo];
        
    }
    
    [super textDidEndEditing: notification];
    [[self window] makeFirstResponder:self];
    
    [myController didRenameGitBranch:newGitBranchName];
    
    
    
} // textDidEndEditing




@end
