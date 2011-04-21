//
//  Tweet_RadarAppDelegate.h
//  Tweet Radar
//
//  Created by Erik Ortman on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TweetRadarViewController;


@interface Tweet_RadarAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    TweetRadarViewController *viewController;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TweetRadarViewController *viewController;

@end
