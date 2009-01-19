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
  }

- (void)buildTileGridColumns:(NSUInteger)columnCount rows:(NSUInteger)rowCount
  {
  NSMutableArray *tileLayers = [[NSMutableArray alloc] initWithCapacity:columnCount*rowCount];

  for(NSUInteger layerColumn = 0; layerColumn < columnCount; layerColumn++)
	{
	for(NSUInteger layerRow = 0; layerRow < rowCount; layerRow++)
		{
		CALayer *tileLayer = [[CALayer alloc] init];

		CGFloat size = floorf(fmin(CGRectGetWidth(NSRectToCGRect([self frame]))/columnCount,
								   CGRectGetHeight(NSRectToCGRect([self frame]))/rowCount));

		[tileLayer setEdgeAntialiasingMask:kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge];
		[tileLayer setBackgroundColor:CGColorCreateGenericRGB((random() % 256)/255., (random() % 256)/255., (random() % 256)/255., 1.0)];
		[tileLayer setFrame:CGRectMake((CGRectGetWidth(NSRectToCGRect([self frame]))-(size*columnCount))/2+size*layerColumn,
									   (CGRectGetHeight(NSRectToCGRect([self frame]))-(size*rowCount))/2+size*layerRow, size, size)];

		[tileLayers addObject:tileLayer];
		[tileLayer release];
		}
	}

  [[self layer] setSublayers:tileLayers];

  [tileLayers release];
  }

@end
