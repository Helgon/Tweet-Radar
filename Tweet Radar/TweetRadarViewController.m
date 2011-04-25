//
//  TweetRadarViewController.m
//  Tweet Radar
//
//  Created by Erik Ortman on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TweetRadarViewController.h"
#import "SA_OAuthTwitterEngine.h"
#import "JSON.h"  



/* Define the constants below with the Twitter 
 Key and Secret for your application. Create
 Twitter OAuth credentials by registering your
 application as an OAuth Client here: http://twitter.com/apps/new
 */

#define kOAuthConsumerKey				@"pOmMi1XAaJLB5NoMnX37g"	    //REPLACE With Twitter App OAuth Key  
#define kOAuthConsumerSecret			@"JZvHHaRzMQmbYiShhMKiMU5ndGllzbl3uLN64qzio"		//REPLACE With Twitter App OAuth Secret

@implementation TweetRadarViewController

@synthesize tweetTextField; 
@synthesize tweets;
@synthesize listView;
@synthesize listtweets;
@synthesize mapView;


#pragma mark Custom Methods

-(IBAction)updateTwitter:(id)sender
{
	//Dismiss Keyboard
	[tweetTextField resignFirstResponder];
	
	//Twitter Integration Code Goes Here
	[_engine sendUpdate:tweetTextField.text];
}

-(IBAction)changeView:(id)sender
{
    [UIView beginAnimations:@"changePerspective" context:nil];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationDelegate:self];
	if(listView.frame.size.height == 159)
    {
		listView.frame = CGRectMake(listView.frame.origin.x, 30, listView.frame.size.width, 430);
        
        mapView.frame = CGRectMake(mapView.frame.origin.x, mapView.frame.origin.y, mapView.frame.size.width, 30);
        //listView.frame = CGRectMake(listView.frame.origin.x, listView.frame.origin.y, listView.frame.size.width, 0);
    }
	else {
		listView.frame = CGRectMake(listView.frame.origin.x, 301, listView.frame.size.width, 159);
        
        mapView.frame = CGRectMake(mapView.frame.origin.x, mapView.frame.origin.y, mapView.frame.size.width, 302);
        //listView.frame = CGRectMake(listView.frame.origin.x, listView.frame.origin.y, listView.frame.size.width, 0);
	}
    
	[UIView commitAnimations];
}

#pragma mark ViewController Lifecycle

- (void)viewDidAppear: (BOOL)animated {
    
    responseData = [[NSMutableData data] retain];
	tweets = [NSMutableArray array];
        
	if(!_engine){
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_engine.consumerKey    = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;	
	}
	
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
	
	if (controller){
		[self presentModalViewController: controller animated: YES];
	}
    
    NSURLRequest *request = [NSURLRequest requestWithURL:
							 [NSURL URLWithString:@"http://search.twitter.com/search.json?geocode=37.781157%2C-122.398720%2C4km"]];
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void)viewDidUnload {	
	[tweetTextField release];
	tweetTextField = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[_engine release];
	[tweetTextField release];
    [listView release];
    [listtweets release];
    [super dealloc];
}

//=============================================================================================================================
#pragma mark NSURLConnection delegate methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[connection release];
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
	[responseData release];
	
	NSDictionary *results = [responseString JSONValue];
	
	NSArray *allTweets = [results objectForKey:@"results"];
	
	[self setListtweets:allTweets];
    //NSLog(@"%@",allTweets);
    //[self addSubview:listView];
    //[window makeKeyAndVisible];
    NSLog(@"%@", allTweets);
    [listView reloadData];
	
}

//=============================================================================================================================
#pragma mark SA_OAuthTwitterEngineDelegate
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {
	NSUserDefaults			*defaults = [NSUserDefaults standardUserDefaults];
	
	[defaults setObject: data forKey: @"authData"];
	[defaults synchronize];
}

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}

//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}


//=============================================================================================================================

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [listtweets count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
	NSDictionary *aTweet = [listtweets objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = [aTweet objectForKey:@"text"];
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.font = [UIFont systemFontOfSize:12];
	cell.textLabel.minimumFontSize = 10;
	cell.textLabel.numberOfLines = 4;
	cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
	
	cell.detailTextLabel.text = [aTweet objectForKey:@"from_user"];
	
	NSURL *url = [NSURL URLWithString:[aTweet objectForKey:@"profile_image_url"]];
	NSData *data = [NSData dataWithContentsOfURL:url];
	cell.imageView.image = [UIImage imageWithData:data];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}



@end

