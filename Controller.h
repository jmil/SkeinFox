//
//  Copyright 2009 Jordan Miller, Hive76. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class TableView;

@interface Controller : NSObject {
    NSString *gitVersion;
    NSMutableArray *gitBranches;
    NSMutableString *currentBranch;
    IBOutlet NSWindow *thisWindow;
    IBOutlet NSPopUpButton *popUpButton;
    IBOutlet TableView *myTableView;
    IBOutlet NSTextFieldCell *myTextFieldCell;
    IBOutlet NSButton *addGitBranchButton;
    IBOutlet NSButton *delGitBranchButton;
    IBOutlet NSButton *gitCommitButton;
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
    IBOutlet NSButton *haltButton;
    NSTask *gCodeTaskInBackground;
}

@property (nonatomic, retain) NSString *gitVersion;
@property (nonatomic, retain) IBOutlet NSWindow *thisWindow;
@property (readwrite, retain) NSMutableArray *gitBranches;
@property (readwrite, retain) NSMutableString *currentBranch;
//@property (nonatomic, retain) IBOutlet NSPopUpButton *popUpButton;
@property (nonatomic, retain) IBOutlet NSArrayController *myArrayController;
@property (nonatomic, retain) IBOutlet TableView *myTableView;
@property (nonatomic, retain) IBOutlet NSTextFieldCell *myTextFieldCell;
@property (nonatomic, retain) IBOutlet NSString *stlFileToGCode;
@property (nonatomic, retain) NSTask *gCodeTaskInBackground;

// Git version checking
- (void) notifyUserImproperGitVersion:(NSString *)gitVersionDotNumberRaw gitVersionRequiredArray:(NSArray *)gitVersionRequired;


// Send a notification to self that the user did update the git branch selection
- (IBAction) didUpdateGitBranchSelection:(id)sender;
- (IBAction) didUpdateGitBranchSettings:(id)sender;
//- (IBAction)doubleClickTableViewRow:(id)sender;

// Launch Skeinforge
- (IBAction) launchSkeinforge:(id)sender;
- (IBAction) gCodeMe:(id)sender;
- (IBAction) haltGCoding:(id)sender;

- (IBAction)addGitBranch:(id)sender;
- (IBAction)delGitBranch:(id)sender;
    
- (void)setupBundleNameInMenuBar;
- (void)replaceTitlePlaceholderInMenuItem:(NSMenuItem *)root withString:(NSString *)appName;
- (void) executeStringCommandSynchronouslyAndLogToConsole:(NSString *)commandToExecute isAShellTask:(BOOL)isAShellTask;

// Drag and Drop!!
- (BOOL)dragIsFile:(id <NSDraggingInfo>)sender;
- (NSString *)getFileForDrag:(id <NSDraggingInfo>)sender;

- (void)processFile;
- (void)setConcatenatedWindowTitle;
- (void)completedTask:(NSNotification *)aNotification;
- (void)readPipe:(NSNotification *)aNotification;
- (IBAction)didRenameGitBranch:(NSString *)newBranchName;

- (IBAction)consoleToggle:(id)sender;
- (IBAction)clearConsole:(id)sender;

- (void)scrollToBottom:(id)sender;

@end
