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
@synthesize spinner;


#pragma mark Custom Methods

-(IBAction)updateTwitter:(id)sender
{
	//Dismiss Keyboard
	[tweetTextField resignFirstResponder];
	
	//Twitter Integration Code Goes Here
	[_engine sendUpdate:tweetTextField.text];
}

-(IBAction)getPosition:(id)sender
{
    CLLocation *userLoc = mapView.userLocation.location;
    CLLocationCoordinate2D userCoordinate = userLoc.coordinate;
    [mapView setCenterCoordinate: userCoordinate 
                        animated: YES];
}

-(IBAction)scanArea:(id)sender
{
    [spinner startAnimating];

    responseData = [[NSMutableData data] retain];
	tweets = [NSMutableArray array];
    
    MKCoordinateRegion region = mapView.region;
    CLLocationCoordinate2D centerCoordinate = mapView.centerCoordinate;
    
    CLLocation * newLocation = [[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude+region.span.latitudeDelta longitude:centerCoordinate.longitude+region.span.longitudeDelta] autorelease];
    CLLocation * centerLocation = [[[CLLocation alloc] initWithLatitude:centerCoordinate.latitude longitude:centerCoordinate.longitude] autorelease];
    CLLocationDistance distance = [centerLocation distanceFromLocation:newLocation]; // in meters
    distance = distance / 1000; // in km
    NSString *distString = [NSString stringWithFormat:@"%.0f", distance];
    NSString *latitude = [NSString stringWithFormat:@"%f", centerCoordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", centerCoordinate.longitude];

   //NSLog(@"%@, %@, %@", latitude, longitude, distString);
    
    NSString *urlString = [NSString stringWithFormat:@"http://search.twitter.com/search.json?geocode="];
    urlString = [urlString stringByAppendingString:latitude];
    urlString = [urlString stringByAppendingString:@"%2C"];
    urlString = [urlString stringByAppendingString:longitude];
    urlString = [urlString stringByAppendingString:@"%2C"];
    urlString = [urlString stringByAppendingString:distString];
    urlString = [urlString stringByAppendingString:@"km"];
    urlString = [urlString stringByAppendingString:@"&rpp=100"];


    NSLog(urlString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:
							 [NSURL URLWithString:urlString]];
    
    
	[[NSURLConnection alloc] initWithRequest:request delegate:self];
	
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
    
    MKCoordinateRegion startCoords;
    
    startCoords.center.latitude = 35.637209;
    startCoords.center.longitude = 139.746094;
    startCoords.span.latitudeDelta = 0.39;
    startCoords.span.longitudeDelta = 0.34;
    
    mapView.region = startCoords;
    
    //Start MGTwitter engine
    
     /**   
	if(!_engine){
		_engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
		_engine.consumerKey    = kOAuthConsumerKey;
		_engine.consumerSecret = kOAuthConsumerSecret;	
	}
	
	UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
	
	if (controller){
		[self presentModalViewController: controller animated: YES];
	}
      **/
    
    self.mapView.showsUserLocation = YES;
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect cgRect =[[UIScreen mainScreen] bounds];
    CGSize cgSize = cgRect.size;
    [spinner setCenter:CGPointMake(cgSize.width/2.0, cgSize.height/2.0)]; // I do this because I'm in landscape mode
    [self.view addSubview:spinner]; // spinner is not visible until started
    
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
    [spinner release];
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
    
    //Scroll table to top
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [listView scrollToRowAtIndexPath:indexPath
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:NO];
    
    [spinner stopAnimating];

	
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

