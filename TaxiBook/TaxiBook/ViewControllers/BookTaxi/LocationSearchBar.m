//
//  LocationSearchBar.m
//  TaxiBook
//
//  Created by Yik Wai Ng Jason on 9/1/14.
//  Copyright (c) 2014 taxibook. All rights reserved.
//

#import "LocationSearchBar.h"

@implementation LocationSearchBar


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self myInitialize];
    }
    return self;
}

-(void)awakeFromNib

{
    [super awakeFromNib];
    [self myInitialize];
}

-(void)myInitialize
{
    
  
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	UIImage *searchBarBkg = [UIImage imageNamed:@"location.png"];
	
	CGContextTranslateCTM(ctx, 0, searchBarBkg.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	CGContextDrawTiledImage(ctx, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height), searchBarBkg.CGImage);

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
