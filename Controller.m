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



- (id)init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector( readPipe: )
                                                 name:NSFileHandleReadCompletionNotification 
                                               object:nil];
    
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(finishedGCodeMe:) 
                                                 name:NSTaskDidTerminateNotification 
                                               object:nil];

    return self;
}


- (void)finishedGCodeMe:(NSNotification *)aNotification {
    NSLog(@"Finished GCodeMe!!!");
    [gCodeMeButton setTitle:@"Create GCode"];
    [indicator stopAnimation:nil];

}

- (void)readPipe:(NSNotification *)aNotification {
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
    
    
    // Turn off interface buttons!
    //[popUpButton setEnabled:NO];
    [gCodeMeButton setTitle:@"Create GCode"];
    [gCodeMeButton setEnabled:NO];
    [launchButton setEnabled:NO];
    [consoleToggleMenuItem setTitle:@"Show Console"];
    [consoleToggleButton setState:NSOffState];
    [stlFileNameDisplay setStringValue:@""];

    
    
    // Register for Dragtypes so that we can accept drag-and-dropped .stl files!
//    NSArray *dragTypes = [NSArray arrayWithObjects:<#(id)firstObj#>];
//    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSColorPboardType,NSFilenamesPboardType, nil]];    

    NSArray *dragTypes = [NSArray arrayWithObjects:NSFilenamesPboardType, nil];
    
    [window registerForDraggedTypes:dragTypes];
    
    
    
    // Populate pop-up with Git branches for .skeinforge directory!
    
    NSString *testDoesGitExist = [ShellTask executeShellCommandSynchronously:@"cd ~/.skeinforge; PATH=/usr/local/bin:/usr/local/git/bin:$PATH git branch"];
    NSLog(testDoesGitExist);


    NSString *whereIsGit = [ShellTask executeShellCommandSynchronously:@"which git"];
    NSLog(whereIsGit);

//    NSString *whereIsGit = [ShellTask executeShellCommandSynchronously:@"which git"];
//    NSLog(whereIsGit);


    NSString *branchesRaw = [ShellTask executeShellCommandSynchronously:@"cd ~/.skeinforge;PATH=/usr/local/bin:/usr/local/git/bin:$PATH git branch"];
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

    // Disable gCodeMeButton and start the indicator spinning animation
    [gCodeMeButton setEnabled:NO];
    [gCodeMeButton setTitle:@"Running..."];
    [indicator startAnimation:nil];
    
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



// Controller.m is set as NSTableView's delegate in Interface Builder. This allows us to call this NSTableView delegate method
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn: 
(NSTableColumn *)aTableColumn row:(int)rowIndex {
    NSLog(@"should edit table column at this row index!!!");
    return YES;
}

- (void)textDidEndEditing:(NSNotification *)aNotification {
    NSLog(@"I finished editing my text!!!");
}

- (BOOL)textShouldBeginEditing:(NSText *)textObject {
    NSLog(@"Should I begin editing!!!");
    return YES;
}




- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification {
    NSLog(@"TableView SELECTION IS CHANGING!!!");
}

- (void)tableView:(NSTableView *)tableView mouseDownInHeaderOfTableColumn:(NSTableColumn *)tableColumn {
    NSLog(@"TableView Header Clicked!!!");
}

//- (BOOL)selectionShouldChangeInTableView:(NSTableView *)aTableView {
//    NSLog(@"SELECTION SHOULD CHANGE IN TABLE VIEW!!!");   
//    //[self didUpdateGitBranchSelection:self];
//    return YES;
//}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    NSLog(@"TableView Should select row #%i!!!", rowIndex);
    NSLog(@"BUT my current selection index in myArrayController is: %i", [myArrayController selectionIndex]);
    //NSLog(@"Which Contains: %@", [myArrayController ]);
    
    // Now setting the selection index for this object!!
    [myArrayController setSelectionIndex:rowIndex];
    NSLog(@"NOW my current selection index in myArrayController is: %i", [myArrayController selectionIndex]);
    
    //Switch Git Branches!!!!
    [self didUpdateGitBranchSelection:self];
    return YES;
}





// Send a notification to self that the user did update the git branch selection

- (IBAction) didUpdateGitBranchSelection:(id)sender {
    NSLog(@"I was selected!!");
    
    NSLog(@"my current selection index in myArrayController is: %i", [myArrayController selectionIndex]);
    NSLog(@"my current selection objects in myArrayController is: %@", [myArrayController selectedObjects]);
    NSLog(@"my current selection OBJECT NAME IS: %@", [[[myArrayController selectedObjects] objectAtIndex:0] name]);
    
    
    

//    NSLog(@"therefore my selection must be %@", [[gitBranches objectAtIndex:[myArrayController selectionIndex]] name]);
//    
//    NSLog(@"but actually the row selected is: %i", [myTableView selectedRow]);
    
    //NSLog(@"therefore my selection must be %@", [[gitBranches objectAtIndex:[myArrayController selectionIndex]] name]);
    
    // Get the title of the currently selected item
//    NSLog(@"I was selected and my name is %@", popUpButton.selectedItem.title);
//    NSString *selectedItemName = popUpButton.selectedItem.title;
    
//    NSLog(@"I was selected and my name is %@", [[gitBranches objectAtIndex:[myArrayController selectionIndex]] name]);

    // NEED TO GRAB DATA FROM myArrayController, NOT from gitBranches!!!
    //NSString *selectedItemName = [[gitBranches objectAtIndex:[myArrayController selectionIndex]] name];
    NSString *selectedItemName = [[[myArrayController selectedObjects] objectAtIndex:0] name];

    // Force Git Checkout; this is what the user will expect, that we will switch branches. any modifications to skeinforge will be thrown away. later we can give another option to not throw away changes and notify user that there were changes and let them fix things...
    NSString *prefix = @"cd ~/.skeinforge;PATH=/usr/local/bin:/usr/local/git/bin:$PATH git checkout -f ";
    NSString *commandToExecute = [prefix stringByAppendingString:selectedItemName];
//    NSLog(@"'%@'", commandToExecute);
//    NSString *checkoutResult = [ShellTask executeShellCommandSynchronously:commandToExecute];
//    NSLog(checkoutResult);

    // Perform the shelltask and print it immediately to the console
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:[ShellTask executeShellCommandSynchronously:commandToExecute]];
    NSTextStorage *storage = [progressLogConsoleTextView textStorage];
    
    [storage beginEditing];
    [storage appendAttributedString:string];
    [storage endEditing];
    
    
    [string release];
    
    [self scrollToBottom:self];
    
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

        
        [self processFile];
        [ShellTask executeShellCommandAsynchronously:completeStringToExecute];
        NSLog(@"yep, skeinforge was launched asynchronously");

        
        
        
        
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