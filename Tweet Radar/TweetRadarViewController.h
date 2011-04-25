//
//  TweetRadarViewController.h
//  Tweet Radar
//
//  Created by Erik Ortman on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"
#import <MapKit/MapKit.h>


@class SA_OAuthTwitterEngine;

@interface TweetRadarViewController : UIViewController <UITextFieldDelegate, SA_OAuthTwitterControllerDelegate, UITableViewDelegate, MKMapViewDelegate>
{ 
	IBOutlet UITextField *tweetTextField;
	
	SA_OAuthTwitterEngine				*_engine;
	NSMutableData *responseData;
	NSMutableArray *tweets;
    NSArray *listtweets;
    UITableView *listView;
    IBOutlet MKMapView *mapView;

}

@property(nonatomic, retain) IBOutlet UITextField *tweetTextField;
@property (nonatomic, retain) NSMutableArray *tweets;
@property(nonatomic,retain) IBOutlet UITableView *listView;
@property (nonatomic, retain) NSArray *listtweets;
@property (nonatomic, retain) MKMapView *mapView;



-(IBAction)updateTwitter:(id)sender; 
-(IBAction)changeView:(id)sender; 


@end


