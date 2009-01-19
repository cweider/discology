//
//  AlbumArtView.m
//  Discology
//
//  Created by Chad Weider on 1/9/09.
//  Copyright (c) 2009, Chad Weider
//  Some rights reserved: <http://www.opensource.org/licenses/zlib-license.php>
//
//  This software is provided 'as-is', without any express or implied warranty.
//  In no event will the authors be held liable for any damages arising from the
//  use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software in a
//  product, an acknowledgment in the product documentation would be appreciated
//  but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "AlbumArtView.h"


@implementation AlbumArtView

- (id)initWithFrame:(NSRect)frame
  {
  if(self = [super initWithFrame:frame])
	{

	}
  return self;
  }

- (void)awakeFromNib
  {
  CALayer *rootLayer = [[CALayer alloc] init];
  [rootLayer setBackgroundColor:CGColorCreateGenericRGB(0.0, 0.0, 0.0, 1.0)];
  [self setLayer:rootLayer];
  [self setWantsLayer:YES];
  [rootLayer release];

  [self buildTileGridColumns:8 rows:5];

  [NSTimer scheduledTimerWithTimeInterval:(8*5)/750. target:self selector:@selector(flipATile) userInfo:nil repeats:YES];
  [self flipATile];
  }

- (void)buildTileGridColumns:(NSUInteger)columnCount rows:(NSUInteger)rowCount
  {
  NSMutableArray *tileLayers = [[NSMutableArray alloc] initWithCapacity:columnCount*rowCount];

  for(NSUInteger layerColumn = 0; layerColumn < columnCount; layerColumn++)
	{
	for(NSUInteger layerRow = 0; layerRow < rowCount; layerRow++)
		{
		CALayer *tileLayer = [self newTile];

		CGFloat size = floorf(fmin(CGRectGetWidth(NSRectToCGRect([self frame]))/columnCount,
								   CGRectGetHeight(NSRectToCGRect([self frame]))/rowCount));

		[tileLayer setFrame:CGRectMake((CGRectGetWidth(NSRectToCGRect([self frame]))-(size*columnCount))/2+size*layerColumn,
									   (CGRectGetHeight(NSRectToCGRect([self frame]))-(size*rowCount))/2+size*layerRow, size, size)];

		[tileLayers addObject:tileLayer];
		}
	}

  [[self layer] setSublayers:tileLayers];

  [tileLayers release];
  }

- (void)flipATile
  {
  NSArray *subLayers = [[self layer] sublayers];
  CALayer *tileLayer = nil;
  CALayer *newLayer = [self newTile];

  do {
	tileLayer = [subLayers objectAtIndex:(random() % [subLayers count])];
  } while([tileLayer animationForKey:@"orderingOut"] != nil || [tileLayer animationForKey:@"orderingIn"] != nil);

  [CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
	[newLayer setFrame:[tileLayer frame]];
	[[self layer] addSublayer:newLayer];
  [CATransaction commit];

  [CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithFloat:0.75] forKey:kCATransactionAnimationDuration];
	[CATransaction setValue:[NSNumber numberWithBool:NO] forKey:kCATransactionDisableActions];

	[tileLayer addAnimation:[self orderOutAnimationForLayer:tileLayer] forKey:@"orderingOut"];
	[newLayer addAnimation:[self orderInAnimationForLayer:newLayer] forKey:@"orderingIn"];
  [CATransaction commit];
  }

- (CALayer *)newTile
  {
  CALayer *tileLayer = [[CALayer alloc] init];

  CATransform3D depthTransform = CATransform3DIdentity;
  depthTransform.m34 = 1. / -(150);
  [tileLayer setTransform:depthTransform];

  [tileLayer setBackgroundColor:CGColorCreateGenericRGB((random() % 256)/255., (random() % 256)/255., (random() % 256)/255., 1.0)];
  [tileLayer setEdgeAntialiasingMask:kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge];

  return [tileLayer autorelease];
  }

- (CAAnimation *)orderOutAnimationForLayer:(CALayer *)layer
  {
  CABasicAnimation *flipAnimation = [CABasicAnimation animation];
  CATransform3D transformFrom = CATransform3DRotate([layer transform], 0*M_PI, 0, 1, 0);
  CATransform3D transformTo   = CATransform3DRotate([layer transform], 1*M_PI, 0, 1, 0);
  [flipAnimation setKeyPath:@"transform"];
  [flipAnimation setFromValue:[NSValue valueWithCATransform3D:transformFrom]];
  [flipAnimation setToValue:[NSValue valueWithCATransform3D:transformTo]];

  CABasicAnimation *orderAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
  [orderAnimation setFromValue:[NSNumber numberWithInt:999]];
  [orderAnimation setToValue:[NSNumber numberWithInt:-999]];

  CAAnimationGroup *animations = [CAAnimationGroup animation];
  [animations setAnimations:[NSArray arrayWithObjects:flipAnimation, orderAnimation, nil]];
  [animations setValue:@"orderOutAnimation" forKey:@"type"];
  [animations setValue:layer forKey:@"attachedLayer"];
  [animations setDelegate:self];

  return animations;
  }

- (CAAnimation *)orderInAnimationForLayer:(CALayer *)layer
  {
  CABasicAnimation *flipAnimation = [CABasicAnimation animation];
  CATransform3D transformFrom = CATransform3DRotate([layer transform], 1*M_PI, 0, -1, 0);
  CATransform3D transformTo   = CATransform3DRotate([layer transform], 0*M_PI, 0, -1, 0);
  [flipAnimation setKeyPath:@"transform"];
  [flipAnimation setFromValue:[NSValue valueWithCATransform3D:transformFrom]];
  [flipAnimation setToValue:[NSValue valueWithCATransform3D:transformTo]];

  CABasicAnimation *orderAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
  [orderAnimation setFromValue:[NSNumber numberWithInt:-999]];
  [orderAnimation setToValue:[NSNumber numberWithInt:999]];

  CAAnimationGroup *animations = [CAAnimationGroup animation];
  [animations setAnimations:[NSArray arrayWithObjects:flipAnimation, orderAnimation, nil]];
  [animations setValue:@"orderInAnimation" forKey:@"type"];
  [animations setValue:layer forKey:@"attachedLayer"];
  [animations setDelegate:self];

  return animations;
  }

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
  {
  if([[theAnimation valueForKey:@"type"] isEqualToString:@"orderOutAnimation"])
	{
	[CATransaction begin];
		[CATransaction setValue:[NSNumber numberWithBool:YES] forKey:kCATransactionDisableActions];
		[[theAnimation valueForKey:@"attachedLayer"] removeFromSuperlayer];
	[CATransaction commit];
	}
  }

@end
