//
//  Copyright 2009 Jordan Miller, Hive76. All rights reserved.
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

@synthesize gitBranches, myArrayController;
@synthesize stlFileToGCode;
//@synthesize notificationCenter;
//@synthesize popUpButton;

- (void)awakeFromNib {
    
    // Check if git is installed!
    
    
    // Turn off interface buttons!
    //[popUpButton setEnabled:NO];
    [gCodeMeButton setEnabled:NO];
    [launchButton setEnabled:NO];
    
    
    
    // Register for Dragtypes so that we can accept drag-and-dropped .stl files!
//    NSArray *dragTypes = [NSArray arrayWithObjects:<#(id)firstObj#>];
//    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSColorPboardType,NSFilenamesPboardType, nil]];    

    NSArray *dragTypes = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
    
    [window registerForDraggedTypes:dragTypes];
    
    
    
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


- (void)processFile:(NSString *)filename {
    [popUpButton setEnabled:NO];
    [gCodeMeButton setEnabled:NO];
    [launchButton setEnabled:NO];
    //[openFile setEnabled:NO];
}






// Drag and drop .stl files!
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    NSLog(@"dragging entered and started!!");
    
    NSView *view = [window contentView];
    
    if (![self dragIsFile:sender]) {
        return NSDragOperationNone;
    }
    
    [view lockFocus];
    
    [[NSColor selectedControlColor] set];
    [NSBezierPath setDefaultLineWidth:5];
    [NSBezierPath strokeRect:[view bounds]];
    
    [view unlockFocus];
    
    [window flushWindow];    
    
    return NSDragOperationGeneric;
}

//- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
//    NSLog(@"dragging updated!!");
//    return NSDragOperationAll;
//}

- (NSDragOperation)draggingExited:(id <NSDraggingInfo>)sender {
    NSLog(@"dragging exited!!");

    // Remove Border Highlighting when dragging exited
    [[window contentView] setNeedsDisplay:YES];

    return NSDragOperationAll;
}

- (NSDragOperation)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    NSLog(@"preparing for drag operation!!");
    
    // Remove Window View Border Highlighting when dragging released
    [[window contentView] setNeedsDisplay:YES];

    return NSDragOperationAll;
}

- (NSDragOperation)performDragOperation:(id <NSDraggingInfo>)sender {
    NSLog(@"perform drag operation!!");
    
    NSString *filename = [self getFileForDrag:sender];
    NSLog(@"my filename is '%@'", filename);
    self.stlFileToGCode = filename;
    
    [gCodeMeButton setEnabled:YES];

    
    return NSDragOperationAll;
}


- (BOOL)dragIsFile:(id <NSDraggingInfo>)sender
{
    BOOL isDirectory;
    
    NSString *dragFilename = [self getFileForDrag:sender];
    
    [[NSFileManager defaultManager] fileExistsAtPath:dragFilename isDirectory:&isDirectory];
    
    //NSLog(@"I am not a directory '%@'", isDirectory);
    
    return !isDirectory;
}



- (NSString *)getFileForDrag:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pb = [sender draggingPasteboard];
    NSString *availableType = [pb availableTypeFromArray:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    NSString *dragFilename;
    NSArray *props;
    
    props = [pb propertyListForType:availableType];
    dragFilename = [props objectAtIndex:0];
    return dragFilename;	
}




// Send a notification to self that the user did update the git branch selection

- (IBAction) didUpdateGitBranchSelection:(id)sender {
    NSLog(@"I was selected!!");
    
    // Get the title of the currently selected item
    NSLog(@"I was selected and my name is %@", popUpButton.selectedItem.title);
    NSString *selectedItemName = popUpButton.selectedItem.title;
    
    // Force Git Checkout; this is what the user will expect, that we will switch branches. any modifications to skeinforge will be thrown away. later we can give another option to not throw away changes and notify user that there were changes and let them fix things...
    NSString *prefix = @"cd ~/.skeinforge; git checkout -f ";
    NSString *commandToExecute = [prefix stringByAppendingString:selectedItemName];
    NSLog(@"'%@'", commandToExecute);
    NSString *checkoutResult = [ShellTask executeShellCommandSynchronously:[prefix stringByAppendingString:selectedItemName]];
    NSLog(checkoutResult);

}    


- (IBAction) launchSkeinforge:(id)sender {
    NSLog(@"A request to launch SkeinForge was received");
    
    // Use the Skeinforge that is contained within this application package!!
    NSString *pathToSkeinforge = [[NSBundle mainBundle] pathForResource:@"skeinforge-0005" ofType:nil];
    NSLog(@"the path to skeinforge is: '%@'", pathToSkeinforge);
    NSString *skeinforgePy = @"/skeinforge.py";
    NSString *prefix = @"\"";
    NSString *suffix = prefix;
    NSLog(@"'%@'", prefix);
    NSLog(@"'%@'", suffix);
    
    
    // EXECUTE WITH QUOTES SO THAT SPACES (AND SPECIAL CHARACTERS LIKE 'µ') IN POSIX PATHS WILL BE HONORED
    NSString *commandToExecuteWithoutQuotes = [pathToSkeinforge stringByAppendingString:skeinforgePy];
    NSString *commandToExecuteWithQuotes = [[prefix stringByAppendingString:commandToExecuteWithoutQuotes] stringByAppendingString:suffix];
    NSLog(@"'%@'", commandToExecuteWithQuotes);
    [ShellTask executeShellCommandAsynchronously:commandToExecuteWithQuotes];
    NSLog(@"yep, skeinforge was launched asynchronously");
    
    
}


- (IBAction) gCodeMe:(id)sender {
    
    if (nil != self.stlFileToGCode) {
        // Use the Skeinforge that is contained within this application package!!
        NSString *pathToSkeinforge = [[NSBundle mainBundle] pathForResource:@"skeinforge-0005" ofType:nil];
        NSLog(@"the path to skeinforge is: '%@'", pathToSkeinforge);
        NSString *skeinforgePy = @"/skeinforge.py";
        NSString *prefix = @"\"";
        NSString *suffix = prefix;
        NSLog(@"'%@'", prefix);
        NSLog(@"'%@'", suffix);
        
        // EXECUTE WITH QUOTES SO THAT SPACES (AND SPECIAL CHARACTERS LIKE 'µ') IN POSIX PATHS WILL BE HONORED
        NSString *commandToExecuteWithoutQuotes = [pathToSkeinforge stringByAppendingString:skeinforgePy];
        NSString *commandToExecuteWithQuotes = [[prefix stringByAppendingString:commandToExecuteWithoutQuotes] stringByAppendingString:suffix];
        NSLog(@"'%@'", commandToExecuteWithQuotes);
        
        NSString *quotedSTLFileToGcode = [[prefix stringByAppendingString:stlFileToGCode] stringByAppendingString:suffix];
        
        NSString *completeStringToExecute = [[commandToExecuteWithQuotes stringByAppendingString:@" "] stringByAppendingString:quotedSTLFileToGcode];
        NSLog(@"'%@'", completeStringToExecute);

        // Disable gCodeMeButton and start the indicator spinning animation
        [gCodeMeButton setEnabled:NO];
        [indicator startAnimation:nil];
        
        [self processFile:[self stlFileToGCode]];
        [ShellTask executeShellCommandAsynchronously:completeStringToExecute];
        NSLog(@"yep, skeinforge was launched asynchronously");
    }
    
    
}


@end
