

#import <Foundation/Foundation.h>


@interface Tweet : NSObject {
	NSString *profile_image_url;
	NSString *userName;
	NSString *tweet;
}

@property (nonatomic, retain) NSString *profile_image_url;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *tweet;

-(id)init:(NSString *) tweet user:(NSString *)user url:(NSString *)url;

@end
