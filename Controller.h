//
//  Copyright 2009 Jordan Miller, Hive76. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Controller : NSObject {
    NSMutableArray *gitBranches;
    NSMutableString *currentBranch;
    IBOutlet NSPopUpButton *popUpButton;
    IBOutlet NSTableView *myTableView;
    BOOL firstTimeTableViewIsPopulated;
    IBOutlet NSButton *launchButton;
    IBOutlet NSButton *gCodeMeButton;
    IBOutlet NSTextField *stlFileNameDisplay;
    IBOutlet NSTextView *progressLogConsoleTextView;
    IBOutlet NSScrollView *progressLogConsoleScrollView;
    IBOutlet NSDrawer *consoleDrawer;
    IBOutlet NSButton *consoleToggleButton;
    IBOutlet NSMenuItem *consoleToggleMenuItem;
    IBOutlet NSProgressIndicator *indicator;
    IBOutlet NSWindow *window;
    IBOutlet NSArrayController *myArrayController;
    NSString *stlFileToGCode;
    NSTask *gCodeTaskInBackground;
}

@property (readwrite, retain) NSMutableArray *gitBranches;
@property (readwrite, retain) NSMutableString *currentBranch;
//@property (nonatomic, retain) IBOutlet NSPopUpButton *popUpButton;
@property (nonatomic, retain) IBOutlet NSArrayController *myArrayController;
@property (nonatomic, retain) IBOutlet NSString *stlFileToGCode;


// Send a notification to self that the user did update the git branch selection
- (IBAction) didUpdateGitBranchSelection:(id)sender;

// Launch Skeinforge
- (IBAction) launchSkeinforge:(id)sender;
- (IBAction) gCodeMe:(id)sender;


// Drag and Drop!!
- (BOOL)dragIsFile:(id <NSDraggingInfo>)sender;
- (NSString *)getFileForDrag:(id <NSDraggingInfo>)sender;

- (void)processFile;
- (void)finishedGCodeMe:(NSNotification *)aNotification;
- (void)readPipe:(NSNotification *)aNotification;

- (IBAction)consoleToggle:(id)sender;
- (IBAction)clearConsole:(id)sender;

- (void)scrollToBottom:(id)sender;

@end
