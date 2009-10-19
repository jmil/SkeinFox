//
//  TableView.h
//  SkeinFox
//
//  Created by Jordan on 10/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Controller;

@interface TableView : NSTableView {
    IBOutlet Controller *myController;
    
    
}

@property (nonatomic, retain) IBOutlet Controller *myController;

@end
