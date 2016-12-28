//
//  ViewController.h
//  voicestopwatch
//
//  Created by Edward Winget on 7/19/16.
//  Copyright © 2016 junesiphone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenEars/OEEventsObserver.h>

@interface ViewController : UIViewController <OEEventsObserverDelegate, UITableViewDelegate, UITableViewDataSource>{
    
    int msInt;
    int secInt;
    int minInt;
    
    IBOutlet UILabel *minuteLabel;
    IBOutlet UILabel *secondLabel;
    IBOutlet UILabel *milliLabel;
    
    IBOutlet UITableView *historyTable;
    
    NSString *minuteString;
    NSString *secondString;
    NSString *milliString;
    
    NSString *historyString;
    
    NSTimer *stopWatchtimer;
}

@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;

@end

