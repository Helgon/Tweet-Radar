//
//  TweetRadarViewController.h
//  Tweet Radar
//
//  Created by Erik Ortman on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"

@class SA_OAuthTwitterEngine;

@interface TweetRadarViewController : UIViewController <UITextFieldDelegate, SA_OAuthTwitterControllerDelegate>
{ 
	IBOutlet UITextField *tweetTextField;
	
	SA_OAuthTwitterEngine				*_engine;	
}

@property(nonatomic, retain) IBOutlet UITextField *tweetTextField;

-(IBAction)updateTwitter:(id)sender; 

@end


