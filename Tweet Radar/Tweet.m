
#import "Tweet.h"


@implementation Tweet
@synthesize profile_image_url, userName, tweet;


-(id)init:(NSString *) text user:(NSString *)user url:(NSString *)url {
	if (self = [super init]) {
		self.tweet = text;
		self.userName = user;
		self.profile_image_url = url;
	}
	return self;
}

-(id)init {
	return [super init];
}



@end
