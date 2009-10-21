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
#import "TableView.h"
#import "gitDateToHumanReadableTransformer.h"


@implementation Controller

@synthesize gitBranches, myArrayController;
@synthesize stlFileToGCode;
@synthesize myTextFieldCell;
@synthesize currentBranch;
@synthesize myTableView;
@synthesize gCodeTaskInBackground;



- (id)init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector( readPipe: )
                                                 name:NSFileHandleReadCompletionNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(completedTask:) 
                                                 name:NSTaskDidTerminateNotification 
                                               object:nil];
    


    // Define gCodeTaskInBackground here!!
//    self.gCodeTaskInBackground = [[[NSTask alloc] init] autorelease]; 
//    [self.gCodeTaskInBackground setLaunchPath: @"/bin/sh"]; //we are launching sh, it is wha will process command for us
//    [self.gCodeTaskInBackground setStandardInput:[NSFileHandle fileHandleWithNullDevice]]; //stdin is directed to /dev/null    
//
//    //we pipe stdout and stderr into a file handle that we read to 
//    NSPipe *outputPipe = [NSPipe pipe];
//    [self.gCodeTaskInBackground setStandardOutput: outputPipe];
//    [self.gCodeTaskInBackground setStandardError: outputPipe];
//    NSFileHandle *outputFileHandle = [outputPipe fileHandleForReading];    
//    
//    
//    // We need to read in background and notify!!!!!
//    [outputFileHandle readInBackgroundAndNotify];
    
    //[self.myTextFieldCell setWantsNotificationForMarkedText:NO];
    
    //Set the self.currentBranch default value to 'basic--Raft'
    self.currentBranch = [[NSMutableString alloc] initWithString:@"basic--Raft"];

    // Register the gitDateToHumanReadableTransformer
    /*Based on Apple Demo:
     FahrenheitToCelsiusTransformer *fToCTransformer;
     
     // create an autoreleased instance of our value transformer
     fToCTransformer = [[[FahrenheitToCelsiusTransformer alloc] init]
     autorelease];
     
     // register it with the name that we refer to it with
     [NSValueTransformer setValueTransformer:fToCTransformer
     forName:@"FahrenheitToCelsiusTransformer"];
     */
    gitDateToHumanReadableTransformer *gitDateHumanReadableTransformer;
    
    // create an autoreleased instance of our value transformer
    gitDateHumanReadableTransformer = [[[gitDateToHumanReadableTransformer alloc] init] autorelease];
    
    // register it with the name that we refer to it with
    [NSValueTransformer setValueTransformer:gitDateHumanReadableTransformer
                                    forName:@"gitDateToHumanReadableTransformer"];
    
    
    
    
    return self;
}

-(void)populateGitBranchesAndSelectCurrentBranch {
    // Populate NSTableView with Git branches for .skeinforge directory!
    
    /* Output of:
     git branch
     
     * basic--Raft
     basic--noRaft
     emptyFill-Walt--Raft
     emptyFill-Walt--noRaft
     watertight--Raft
     watertight--noRaft     
     */
    
    /* Output of:
    git log --branches --no-walk --format='%d %ai'
     
     (watertight--noRaft) 2009-10-15 14:18:56 -0400
     (watertight--Raft) 2009-10-15 14:18:10 -0400
     (emptyFill-Walt--noRaft) 2009-10-15 14:17:20 -0400
     (basic--noRaft) 2009-10-15 14:16:03 -0400
     (basic--Raft) 2009-10-15 14:15:07 -0400
     (emptyFill-Walt--Raft) 2009-10-15 14:12:25 -0400     
     */
    
    
    NSString *branchesRaw = [ShellTask executeShellCommandSynchronously:@"cd ~/.skeinforge;PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git branch"];
    //NSLog(branchesRaw);
    
    
    NSString *lastModifiedRaw = [ShellTask executeShellCommandSynchronously:@"cd ~/.skeinforge;PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git log --branches --no-walk --format='%d %ai'"];
    //NSLog(lastModifiedRaw);
    
    
    NSArray *namesTemp = [branchesRaw componentsSeparatedByString:@"\n"];
    NSMutableArray *names = [NSMutableArray arrayWithArray:namesTemp];
    
    NSArray *lastModifiedTemp = [lastModifiedRaw componentsSeparatedByString:@"\n"];
    NSMutableArray *lastModifieds = [NSMutableArray arrayWithArray:lastModifiedTemp];
    
    // Step through array to get dictionary of lastModified Dates
    NSInteger lastModifiedIndex = 0;
    NSMutableDictionary *lastModifiedDictionary = [[NSMutableDictionary alloc] init];

    // We could use regex here, but regex searching is very processor intensive
    // Instead we let git do the heavy lifting, so we know the format will be exactly (BRANCH_NAME) DATE based on our git statement above:
    // git log --branches --no-walk --format='%d %ai
    
    
    for (NSString *anElement in lastModifieds) {
        
        if (0 != [anElement length]) {
            // Don't try to use substringWithRange on an empty string! you'll get an exception!!
            //NSLog(@"'%@' is element %i in this array", anElement, lastModifiedIndex);
            
            // First remove the first two characters
            // Try just removing the first two characters. These characters MUST be " (" based on git-log for git 1.6.5 intel leopard
//            NSString *openParenChopped = [anElement substringFromIndex:2];
//            NSLog(@"'%@' is element %i", openParenChopped, lastModifiedIndex);

            // First find the location of Open Parentheses
            NSRange openParenLocation = [anElement rangeOfString:@"("];
            //NSLog(@"the Range for openParenLocation is: '%i' of length '%i'", openParenLocation.location, openParenLocation.length);
            //NSUInteger openParen = openParenLocation.location;
            
            // Next find the location of closed Parentheses
            NSRange closeParenLocation = [anElement rangeOfString:@")"];
            //NSLog(@"the Range for openParenLocation is: '%i' of length '%i'", closeParenLocation.location, closeParenLocation.length);
            
            
            // Then the branch name will be the characters between these            
            NSUInteger startOfBranchName = openParenLocation.location + 1;
            NSUInteger branchNameLength = closeParenLocation.location - openParenLocation.location - 1;
            NSRange branchNameRange = NSMakeRange(startOfBranchName, branchNameLength);
            NSString *thisBranchName = [anElement substringWithRange:branchNameRange];
            //NSLog(@"branch name must therefore be '%@'", thisBranchName);
                        
            // And then the date last modified will be the characters after closed parentheses + 1 (because we have a ' ' space character in the git log format string
            // USE EXACT STRING LENGTH SO THAT WE CAN ADD MORE INFO LATER LIKE CUSTOM NAME FOR THIS BRANCH IN THE COMMIT MESSAGE THAT CAN USE SPECIAL CHARACTERS
            // This means the date must be 25 more characters starting at closeParenLocation +2
            NSRange lastModifiedDateRange = NSMakeRange((closeParenLocation.location + 2), 25);
            NSString *thisBranchModifiedDate = [anElement substringWithRange:lastModifiedDateRange];
            //NSLog(@"branch DATE must therefore be '%@'", thisBranchModifiedDate);
            
            
            
            // NOTE: here we need special code. This is because if the user has just duplicated a branch, then the git log --branches --no-walk --format='%d %ai command will produce something like this:
            //  (untitled2,, untitled, basic--Raft) 2009-10-15 14:15:07 -0400
            // Which means that thisBranchName is actually multiple different branches, each of which needs to have it's own entry in the mutabledictionary!
            // So the workaround is to test if thisBranchName contains the characters ', ' and then split on these characters into a new array, then iterate through the new array and add each to the dictionary with the IDENTICAL last Modified Date
            // Now set these variables as the key and value of a new dictionary. Then when we later set the current branch based on the "*" being an early character we will use the branch name as the key to this dictionary to pull out the lastModified date!
            
            // Note, we can do this very simply thanks to the behavior of componentsSeparatedByString:. See here:
            /*
             NSString *list = @"Norman, Stanley, Fletcher";
             NSArray *listItems = [list componentsSeparatedByString:@", "];
             produces an array { @"Norman", @"Stanley", @"Fletcher" }.
             
             If list begins with a comma and space—for example, ", Norman, Stanley, Fletcher"—the array has these contents: { @"", @"Norman", @"Stanley", @"Fletcher" }
             
             If list has no separators—for example, "Norman"—the array contains the string itself, in this case { @"Norman" }.
             */
            NSArray *allBranchesWithThisDate = [thisBranchName componentsSeparatedByString:@", "];
            
            for (NSString *aBranch in allBranchesWithThisDate) {
                //NSLog(@"aBranch is '%@' of type '%@'", aBranch, aBranch.className);
                
                [lastModifiedDictionary setObject:thisBranchModifiedDate forKey:aBranch];
            }            
            
            lastModifiedIndex++;            
        }
        
    }
    
    
    //NSLog(@"My branches with paired last Modified Dates is: '%@'", lastModifiedDictionary);
    
    
    
    // Cleanup the Array to both mark the currently selected branch and also to remove leading and lagging whitespace
    NSInteger index = 0;
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    
    for (NSString *element in names) {
        // Remove last return character! -- remove lagging whitespace == last newline
        if (index != ([names count] - 1)) {
            
            // Check whether 2nd character is *, therefore this is the current branch
            if ([[element substringToIndex:1] isEqualToString: @"*"] ) {
                [[self currentBranch] setString:[element substringFromIndex:2]];
                //NSLog(@"I am the current branch, and my name is '%@' @index '%i'", [element substringFromIndex:2], index);
            }
            
            
            // Remove first 3 characters before adding to the tempArray
            [tempArray addObject:[element substringFromIndex:2]];
            
            
        }
        index++;
    }
    
    [names setArray:tempArray];
    [tempArray release];
    
    
    
    
    
    
    //NSArray *names = [NSArray arrayWithObjects:@"Bird", @"Chair", @"Song", @"Computer", nil];
    NSMutableArray *tempGitBranches = [NSMutableArray array];
    for (NSString *name in names) {
        gitBranch *branch = [[[gitBranch alloc] init] autorelease];
        branch.name = name;
        //branch.lastModified = @"last modified on XXXXX";
        branch.lastModified = [lastModifiedDictionary objectForKey:name];
        [tempGitBranches addObject:branch];
        
        
    }
    
    // Since we use Cocoa Bindings, AS SOON AS self.gitBranches is defined, the table will be as well!
    self.gitBranches = tempGitBranches;
    
    
    // Now that the table is populated, we must immediately tell the table which row to select!
    for (gitBranch *thisBranch in self.gitBranches) {
        //NSLog(@"my branch name is:%@", whoami.name);
        
        if ([thisBranch.name isEqualToString:self.currentBranch]) {
            //NSLog(@"Yes!! the currentBranch '%@' is verified as identical to '%@'!!!", self.currentBranch, thisBranch.name);
            [myArrayController setSelectedObjects:[NSArray arrayWithObjects:thisBranch, nil]];
        }
        
    }
    
    //NSLog(@"myArrayController selection index is currently %i", [myArrayController selectionIndex]);
    
    // We also DON'T need to update the GitBranchSelection since we have just selected the current Branch!!!
    //[self didUpdateGitBranchSelection:self];

//    [self.myTableView reloadData];
//    [self.myTableView setNeedsDisplay:YES];
}



- (IBAction)addGitBranch:(id)sender {
    NSString *prefix = @"cd ~/.skeinforge;PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git checkout -f -b ";
    NSString *commandToExecute = [prefix stringByAppendingString:@"untitled"];
    
    // Perform the shelltask and print it immediately to the console
    [self executeStringCommandSynchronouslyAndLogToConsole:commandToExecute isAShellTask:YES];
    
    [self populateGitBranchesAndSelectCurrentBranch];

    //NSLog(@"addedGitBranch!");
    
}

- (IBAction)delGitBranch:(id)sender {
    
    // To delete it's a bit more complicated because we CANNOT delete the branch that we have currently checked out; So we should figure out which branch we have currently selected and store that name temporarily, then select the branch below it (or the branch above it if it is the last branch), then delete the branch above it and reload the gitbranches
    [self.currentBranch setString:[[[myArrayController selectedObjects] objectAtIndex:0] name]];
    //NSLog(@"the branch to delete is: %@", self.currentBranch);
    NSUInteger currentSelectionIndexToDelete = self.myArrayController.selectionIndex;
    NSUInteger nextSelectionIndex = 0;
    //NSLog(@"the branchIndex to delete is: %i", currentSelectionIndexToDelete);
    NSString *branchToDelete = [[[myArrayController selectedObjects] objectAtIndex:0] name];

    // Select the next or previous row as possible given how many objects are in the myArrayController
    // NOTE: cannot use selectNext: and selectPrevious: because:
    // "Beginning with Mac OS X v10.4 the result of this method is deferred until the next iteration of the runloop so that the error presentation mechanism can provide feedback as a sheet."
    
    if (self.myArrayController.canSelectNext) {
        // set the array controller selection to the next one
        //[self.myArrayController selectNext:self];
        nextSelectionIndex = currentSelectionIndexToDelete + 1;
        
    } else if (self.myArrayController.canSelectPrevious) {
        // set the array controller selection to the previous one
        //[self.myArrayController selectPrevious:self];
        nextSelectionIndex = currentSelectionIndexToDelete - 1;
    }
    
//    // Make Sure we actually change branches!!
    [myArrayController setSelectionIndex:nextSelectionIndex];
    [self didUpdateGitBranchSelection:self];

    //[self.myTableView reloadData];
    //NSLog(@"currentIndexToDelete %i, nextSelectionIndex %i", currentSelectionIndexToDelete, nextSelectionIndex);
    
//    NSLog(@"branchToDelete is %@, while the newly selected branch is now %@", branchToDelete, [[[myArrayController selectedObjects] objectAtIndex:0] name]);

    NSString *prefix = @"cd ~/.skeinforge;PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git branch -D ";
    NSString *commandToExecute = [prefix stringByAppendingString:branchToDelete];
//    
    // Perform the shelltask and print it immediately to the console
    [self executeStringCommandSynchronouslyAndLogToConsole:commandToExecute isAShellTask:YES];

    
    //NSLog(@"%@ was deleted", branchToDelete);
    // Make sure table view reloads appropriately!!
    [self populateGitBranchesAndSelectCurrentBranch];

    //[self.gitBranches removeAllObjects];
    
    
}


- (void)completedTask:(NSNotification *)aNotification {
//    NSLog(@"'%@' ", aNotification.name);
//    
//    NSLog(@"the termination reason is %i", [gCodeTaskInBackground terminationStatus]);
    
    
    
    
    
    [gCodeMeButton setTitle:@"Create GCode"];

    //Reenable the gCodeMe button since we still have an .stl file selected...
    // On launch, a task is run for some reason, so we need to check if there is an .stl file loaded. If so, then keep gcodeMeButton enabled!
    if ([self.stlFileToGCode isNotEqualTo:nil]) {
        [gCodeMeButton setEnabled:YES];        
    }
    
    [launchButton setEnabled:YES];
    [gitCommitButton setEnabled:YES];
    [addGitBranchButton setEnabled:YES];
    [delGitBranchButton setEnabled:YES];
    [myTableView setEnabled:YES];
    [indicator stopAnimation:nil];
    
}

- (void)readPipe:(NSNotification *)aNotification {
    // See http://macosx.com/forums/software-programming-web-scripting/4522-better-way-read-nstask.html
    //NSLog(@"We are reading live output from standard output as it is being written, because we are being notified each time it's being written!!!");
    
    NSData *data;
    NSString *text;
    
//    if( [notification object] != _fileHandle )
//        return;
    
    //NSLog(@"the userinfo NSDictionary is \n %@", [aNotification userInfo]);
    
    data = [[aNotification userInfo] 
            objectForKey:NSFileHandleNotificationDataItem];
    text = [[NSString alloc] initWithData:data 
                                 encoding:NSASCIIStringEncoding];
    
    // Do something with your text
    // ...
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text];
    NSTextStorage *storage = [progressLogConsoleTextView textStorage];
    
    [storage beginEditing];
    [storage appendAttributedString:string];
    [storage endEditing];
    
    
    [string release];
    [self scrollToBottom:self];

    //NSLog(text);
    
    [text release];
    
    //NSLog(@"the data are '%@'", data);
    // If the task is still running, then keep reading!!
    if ([data length] != 0) {
        [[aNotification object] readInBackgroundAndNotify];
    }
//    if ([data length] == 0) {
//        NSLog(@"MY DATA ARE NIL!!!!!!!");
//    }    
}



- (void)awakeFromNib {
    
    // Check if git is installed!
    
    
    // See if .skeinforge Directory exists
    NSString *skeinforgeConfigDirectory = [@"~/.skeinforge" stringByExpandingTildeInPath];
    //NSLog(skeinforgeConfigDirectory);
    NSString *skeinforgeMasterTemplatesDirectory = [[NSBundle mainBundle] pathForResource:@".skeinforge" ofType:nil];
    //NSLog(@"The .skeinforge master template folder is located at: '%@'", skeinforgeMasterTemplatesDirectory);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL fileExists = [fileManager fileExistsAtPath:skeinforgeConfigDirectory];
    if (!fileExists) {
        //NSLog(@".skeinforge directory DOES NOT exist!");
        // If .skeinforge doesn't exist, then copy it from the current application resources        
        
        if ([fileManager copyItemAtPath:skeinforgeMasterTemplatesDirectory toPath:skeinforgeConfigDirectory error:nil]) {
            NSLog(@"Skeinforge Directory copy SUCCESS");
        } else {
            NSLog(@"Skeinforge Directory copy FAILURE");            
        }
    } else {
        //NSLog(@".skeinforge directory exists!");
        
        
        // If the .git directory doesn't already exist... if it already exists, DON'T OVERWRITE IT. People will be pissed!
        NSString *gitConfigDirectory = [skeinforgeConfigDirectory stringByAppendingString:@"/.git"];
        //NSLog(gitConfigDirectory);
        
        BOOL gitExists = [fileManager fileExistsAtPath:gitConfigDirectory];
        if (!gitExists) {
            // If .skeinforge directory already exists, and the .git DOES NOT exist, then we should just initiate a brand new .git repo and DO NOT TRY TO COPY OR INTERLEAVE GIT BRANCHES with that of the current user
            NSString *prefix = @"cd ~/.skeinforge;PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git init; PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git add .; PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git commit -a -m 'hello'; PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git branch -M ";
            NSString *commandToExecute = [prefix stringByAppendingString:NSUserName()];
            //NSLog(commandToExecute);
            
            // Perform the shelltask and print it immediately to the console
            [self executeStringCommandSynchronouslyAndLogToConsole:commandToExecute isAShellTask:YES];
            
            

        } else {
            //NSLog(@"%@'s .git directory exists, so don't mess with it", NSUserName());
            // So we do nothing
        }
    }
    
    
    // Now we definitely have a .skeinforge directory with a .git repo inside of it
    
    // So setup all of our table variables
    [self populateGitBranchesAndSelectCurrentBranch];
    
    NSString *logMessage = [NSString stringWithFormat:@"'%@' is the current branch\n", self.currentBranch];
    
    [self executeStringCommandSynchronouslyAndLogToConsole:logMessage isAShellTask:NO];
    
    
    //*******************
    // Control for Interface Elements setup
    //*******************
    
    // Turn off interface buttons!
    //[popUpButton setEnabled:NO];
    [gCodeMeButton setTitle:@"Create GCode"];
    [gCodeMeButton setEnabled:NO];
    [launchButton setEnabled:YES];
    [consoleToggleMenuItem setTitle:@"Show Console"];
    [consoleToggleButton setState:NSOffState];
    [stlFileNameDisplay setStringValue:@""];
    
    
    
    // Register for Dragtypes so that we can accept drag-and-dropped .stl files!
    //    NSArray *dragTypes = [NSArray arrayWithObjects:<#(id)firstObj#>];
    //    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSColorPboardType,NSFilenamesPboardType, nil]];    
    
    NSArray *dragTypes = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
    
    [window registerForDraggedTypes:dragTypes];
    
    [self setupBundleNameInMenuBar];
        
}

- (void) executeStringCommandSynchronouslyAndLogToConsole:(NSString *)commandToExecute isAShellTask:(BOOL)isAShellTask {
        // Perform the shelltask and print it immediately to the console
    
    
    NSAttributedString *string = [NSAttributedString alloc];
    
    if (isAShellTask) {
        // Execute the command and get the output
        [string initWithString:[ShellTask executeShellCommandSynchronously:commandToExecute]];
    } else {
        [string initWithString:commandToExecute];
    }
        
    NSTextStorage *storage = [progressLogConsoleTextView textStorage];

    [storage beginEditing];
    [storage appendAttributedString:string];
    [storage endEditing];
    
    [string release];
    
    [self scrollToBottom:self];
}


- (void)setupBundleNameInMenuBar {
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    if (appName == nil) appName = [[NSProcessInfo processInfo] processName];
    
    NSMenu *menuBar = [NSApp mainMenu];
    for (NSMenuItem *menuItem in [menuBar itemArray])
        [self replaceTitlePlaceholderInMenuItem: menuItem withString: appName];
}

- (void)replaceTitlePlaceholderInMenuItem:(NSMenuItem *)root withString:(NSString *)appName {
    root.title = [root.title stringByReplacingOccurrencesOfString: @"NewApplication"
                  withString: appName];
    
    NSArray *submenuItems = [root.submenu itemArray];
    for (NSMenuItem *menuItem in submenuItems)
        [self replaceTitlePlaceholderInMenuItem: menuItem withString: appName];
}



- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
//    NSLog(@"tableView:aTableView called!!!");
//    
//    NSLog(@"TableView Should select row #%i!!!", rowIndex);
//    NSLog(@"BUT my current selection index in myArrayController is: %i", [myArrayController selectionIndex]);
    //NSLog(@"Which Contains: %@", [myArrayController ]);
    
    // Now setting the selection index for this object!!
    [myArrayController setSelectionIndex:rowIndex];
    //NSLog(@"NOW my current selection index in myArrayController is: %i", [myArrayController selectionIndex]);
    
    //Switch Git Branches!!!!
    [self didUpdateGitBranchSelection:self];
    return YES;
    
}









- (void)consoleToggle:(id)sender {
    //NSLog(@"Console toggled");
    if ([consoleDrawer state] == NSDrawerOpenState) {
        // About to close...
        [consoleToggleMenuItem setTitle:@"Show Console"];
        [consoleToggleButton setState:NSOffState];
        
    } else {
        // About to open...
        [consoleToggleMenuItem setTitle:@"Hide Console"];
        [consoleToggleButton setState:NSOnState];        
    }
    
    // Perform the toggle
    [consoleDrawer toggle:self];
}

- (void)clearConsole:(id)sender {
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:@""];
    NSTextStorage *storage = [progressLogConsoleTextView textStorage];
    
    [storage beginEditing];
    [storage setAttributedString:string];
    [storage endEditing];
    
    
    [string release];
    
    [self scrollToBottom:self];
    
}



- (void)processFile {
    [popUpButton setEnabled:NO];
    [launchButton setEnabled:NO];
    [launchButton setEnabled:NO];
    [gitCommitButton setEnabled:NO];
    [addGitBranchButton setEnabled:NO];
    [delGitBranchButton setEnabled:NO];
    [myTableView setEnabled:NO];

    // Disable gCodeMeButton and start the indicator spinning animation
    [gCodeMeButton setEnabled:NO];
    [gCodeMeButton setTitle:@"Running..."];
    [indicator startAnimation:nil];
    
    //[openFile setEnabled:NO];
}






// Drag and drop .stl files!
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    //NSLog(@"dragging entered and started!!");
    
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
    //NSLog(@"dragging exited!!");

    // Remove Border Highlighting when dragging exited
    [[window contentView] setNeedsDisplay:YES];

    return NSDragOperationAll;
}

- (NSDragOperation)prepareForDragOperation:(id <NSDraggingInfo>)sender {
    //NSLog(@"preparing for drag operation!!");
    
    // Remove Window View Border Highlighting when dragging released
    [[window contentView] setNeedsDisplay:YES];

    return NSDragOperationAll;
}

- (NSDragOperation)performDragOperation:(id <NSDraggingInfo>)sender {
    //NSLog(@"perform drag operation!!");
    
    NSString *filename = [self getFileForDrag:sender];
    //NSLog(@"my filename is '%@'", filename);
    self.stlFileToGCode = filename;
    
    [stlFileNameDisplay setStringValue:[self stlFileToGCode]];
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
//    NSLog(@"I was selected!!");    
//    NSLog(@"my current selection index in myArrayController is: %i", [myArrayController selectionIndex]);
//    NSLog(@"my current selection objects in myArrayController is: %@", [myArrayController selectedObjects]);
//    NSLog(@"my current selection OBJECT NAME IS: %@", [[[myArrayController selectedObjects] objectAtIndex:0] name]);
    
    [self.currentBranch setString:[[[myArrayController selectedObjects] objectAtIndex:0] name]];
    

    
    NSString *selectedItemName = [[[myArrayController selectedObjects] objectAtIndex:0] name];


    // Force Git Checkout; this is what the user will expect, that we will switch branches. any modifications to skeinforge will be thrown away. later we can give another option to not throw away changes and notify user that there were changes and let them fix things...
    NSString *prefix = @"cd ~/.skeinforge;PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git checkout -f ";
    NSString *commandToExecute = [prefix stringByAppendingString:selectedItemName];
//    NSLog(@"'%@'", commandToExecute);
//    NSString *checkoutResult = [ShellTask executeShellCommandSynchronously:commandToExecute];
//    NSLog(checkoutResult);

    [self executeStringCommandSynchronouslyAndLogToConsole:commandToExecute isAShellTask:YES];
    
}    

// Edited the settings in Skeinforge, so now we need to commit the changes
// git add .; git commit -a -m "DateTimeStamp"
- (IBAction) didUpdateGitBranchSettings:(id)sender {
    NSString *commandToExecute = @"cd ~/.skeinforge;PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git add .;PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git commit -a -m Now";
    [self executeStringCommandSynchronouslyAndLogToConsole:commandToExecute isAShellTask:YES];

    
    // Update lastModified dates!!!
    [self populateGitBranchesAndSelectCurrentBranch];


    //NSLog(branchesRaw);

    
    
    //NSLog(@"Controller didUpdateGitBranchSettings to commit them!!");
    
}


// We renamed the branch name, so now we need to actually rename the branch name on disk
// Note that changes may be present, BUT DO NOT DO A COMMIT! The user will not expect a rename will also commit any changes present. This is EXPLICITLY and EXCLUSIVELY what the "Save Changes" button is for!
// git branch -M "NewBranchName"
- (IBAction)didRenameGitBranch:(NSString *)newBranchName {
    //NSLog(@"Controller didRenameGitBranch");
    
    // Note that changes may be present, BUT DO NOT DO A COMMIT! The user will not expect a rename will also commit any changes present. This is EXPLICITLY and EXCLUSIVELY what the "Save Changes" button is for!
    // First we commit the current branch in case there are any changes
    //[self didUpdateGitBranchSettings:self];

    NSString *prefix = @"cd ~/.skeinforge;PATH=/usr/local/bin:/usr/local/git/bin:/opt/local/bin:/sw/bin:$PATH git branch -M ";
    NSString *commandToExecute = [prefix stringByAppendingString:newBranchName];
    
    
    //NSLog(@"The New Branch Name will be %@", newBranchName);
    //NSLog(@"The Command to Execute will be '%@'", commandToExecute);
    
    // Perform the shelltask and print it immediately to the console
    [self executeStringCommandSynchronouslyAndLogToConsole:commandToExecute isAShellTask:YES];
    
    [self populateGitBranchesAndSelectCurrentBranch];
    
    
    // Don't log the new branch name here, because git does not produce output for renamed branch. Rather, just leave it blank on success
//    NSString *logMessage = [NSString stringWithFormat:@"Renamed branch to '%@'", newBranchName];
//    [self executeStringCommandSynchronouslyAndLogToConsole:logMessage isAShellTask:NO];
    
    //NSLog(@"renamed git branch!!");
}



- (void)scrollToBottom:(id)sender {
    // Scroll to the bottom!!!
    // get the current scroll position of the document view
    //NSPoint currentScrollPosition=[[progressLogConsoleScrollView contentView] bounds].origin;
    
    NSPoint newScrollOrigin;
    
    // assume that the scrollview is an existing variable
    if ([[progressLogConsoleScrollView documentView] isFlipped]) {
    //    newScrollOrigin=NSMakePoint(0.0,NSMaxY([[progressLogConsoleScrollView documentView] frame]) - NSHeight([[progressLogConsoleScrollView contentView] bounds]));
        newScrollOrigin=NSMakePoint(0.0,NSMaxY([[progressLogConsoleScrollView documentView] frame]));
    } else {
        newScrollOrigin=NSMakePoint(0.0,0.0);
    }
    
    [[progressLogConsoleScrollView documentView] scrollPoint:newScrollOrigin];
    
}



- (IBAction) launchSkeinforge:(id)sender {
    //NSLog(@"A request to launch SkeinForge was received");
    
    // Use the Skeinforge that is contained within this application package!!
    NSString *pathToSkeinforge = [[NSBundle mainBundle] pathForResource:@"skeinforge-0005" ofType:nil];
    //NSLog(@"the path to skeinforge is: '%@'", pathToSkeinforge);
    NSString *skeinforgePy = @"/skeinforge.py";
    NSString *prefix = @"\"";
    NSString *suffix = prefix;
    //NSLog(@"'%@'", prefix);
    //NSLog(@"'%@'", suffix);
    
    
    // EXECUTE WITH QUOTES SO THAT SPACES (AND SPECIAL CHARACTERS LIKE 'µ') IN POSIX PATHS WILL BE HONORED
    NSString *commandToExecuteWithoutQuotes = [pathToSkeinforge stringByAppendingString:skeinforgePy];
    NSString *commandToExecuteWithQuotes = [[prefix stringByAppendingString:commandToExecuteWithoutQuotes] stringByAppendingString:suffix];
    //NSLog(@"'%@'", commandToExecuteWithQuotes);
    [ShellTask executeShellCommandAsynchronously:commandToExecuteWithQuotes];
    //NSLog(@"yep, skeinforge was launched asynchronously");
    
    
}

- (IBAction) haltGCoding:(id)sender {
    //self.gCodeTaskInBackground.terminate;    
}

- (IBAction) gCodeMe:(id)sender {
    
    if (nil != self.stlFileToGCode) {
        // Use the Skeinforge that is contained within this application package!!
        NSString *pathToSkeinforge = [[NSBundle mainBundle] pathForResource:@"skeinforge-0005" ofType:nil];
        //NSLog(@"the path to skeinforge is: '%@'", pathToSkeinforge);
        NSString *skeinforgePy = @"/skeinforge.py";
        NSString *prefix = @"\"";
        NSString *suffix = prefix;
        //NSLog(@"'%@'", prefix);
        //NSLog(@"'%@'", suffix);
        
        // EXECUTE WITH QUOTES SO THAT SPACES (AND SPECIAL CHARACTERS LIKE 'µ') IN POSIX PATHS WILL BE HONORED
        NSString *commandToExecuteWithoutQuotes = [pathToSkeinforge stringByAppendingString:skeinforgePy];
        NSString *commandToExecuteWithQuotes = [[prefix stringByAppendingString:commandToExecuteWithoutQuotes] stringByAppendingString:suffix];
        //NSLog(@"'%@'", commandToExecuteWithQuotes);
        
        NSString *quotedSTLFileToGcode = [[prefix stringByAppendingString:stlFileToGCode] stringByAppendingString:suffix];
        
        NSString *completeStringToExecute = [[commandToExecuteWithQuotes stringByAppendingString:@" "] stringByAppendingString:quotedSTLFileToGcode];
        //NSLog(@"'%@'", completeStringToExecute);

        // Update UI that we're working
        [self processFile];
        // Launch the shellTask in the background
        // We have to have the task be completely defined here because we need to keep track of the NSTask so that we can terminate the task if we want to!!
        
        
        [ShellTask executeShellCommandAsynchronously:completeStringToExecute];
        
        
//        NSArray	*args = [NSArray arrayWithObjects:	@"-c", //-c tells sh to execute commands from the next argument
//                         completeStringToExecute, //sh will read and execute the commands in this string.
//                         nil];
//        [self.gCodeTaskInBackground setArguments: args];
        
        
//        [self.gCodeTaskInBackground launch];
        
        
        
                //NSLog(@"yep, skeinforge was launched asynchronously");

        
        

        
        //[self.gCodeTaskInBackground launch];
        
        
        
        
        //Launch "ls -l -a -t" in the current directory, and then read the result into an NSString:
        
//        NSTask *task;
//        task = [[NSTask alloc] init];
////        [task setLaunchPath: @"/bin/ls"];
//        [task setLaunchPath: commandToExecuteWithoutQuotes];
//
//        NSArray *arguments;
////        arguments = [NSArray arrayWithObjects: @"-l", @"-a", @"-t", nil];
//        arguments = [NSArray arrayWithObjects: stlFileToGCode, nil];
//        [task setArguments: arguments];
//        
//        NSPipe *pipe;
//        pipe = [NSPipe pipe];
//        [task setStandardOutput: pipe];
//        
//        NSFileHandle *file;
//        file = [pipe fileHandleForReading];
//        
//        [task launch];
//        
//        NSData *data;
//        data = [file readDataToEndOfFile];
//        
//        NSString *string;
//        string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
//        NSLog (@"got\n%@", string);
    

    }
    
    
}


@end