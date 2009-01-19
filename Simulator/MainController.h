//
//  MainController.h
//  Discology
//
//  Created by Chad Weider on 1/8/09.
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

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

#import "AlbumArtView.h"


@interface MainController : NSObject
  {
  NSDictionary *iTunesLibrary;

  IBOutlet AlbumArtView *albumArtView;

  IBOutlet NSPopUpButton *playlistSelector;
  IBOutlet NSButton *refreshItemButton;

  IBOutlet NSTextField *albumName;
  IBOutlet NSTextField *artistName;
  IBOutlet NSImageView *albumArtwork;
  }

- (IBAction)updatePlaylistSelection:(id)sender;
- (IBAction)updateTrackInfo:(id)sender;

- (NSArray *)availableTracks;
- (NSDictionary *)anyTrack;
- (NSImage *)anyArtwork;

- (NSImage *)artworkForTrack:(NSString *)trackId;
- (NSImage *)fetchArtworkFromFile:(NSURL *)url;
- (NSImage *)fetchArtworkFromAlbumArtworkFolder:(NSString *)persistentId;

@end
