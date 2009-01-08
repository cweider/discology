//
//  MainController.m
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

#import "MainController.h"


@implementation MainController

- (id)init
  {
  if(self = [super init])
	{
	iTunesLibrary = [[NSDictionary alloc] initWithContentsOfFile:[@"~/Music/iTunes/iTunes Music Library.xml" stringByExpandingTildeInPath]];
	}

  return self;
  }

- (void)dealloc
  {
  [iTunesLibrary release];
  [super dealloc];
  }

- (void)awakeFromNib
  {
  [albumArtwork setImageScaling:NSImageScaleProportionallyUpOrDown];
  [[refreshItemButton layer] setZPosition:1];	//make sure button is on top

  [self updatePlaylistSelection:self];
  [self updateTrackInfo:self];
  }

- (IBAction)windowWillClose:(id)sender
  {
  [NSApp terminate:self];
  }

- (IBAction)updatePlaylistSelection:(id)sender
  {
  NSMenu *playlistSelectionMenu = [[NSMenu alloc] init];

  NSArray *playlists = [iTunesLibrary objectForKey:@"Playlists"];
  for(NSUInteger playlistIndex = 0; playlistIndex < [playlists count]; playlistIndex++)
	{
	NSDictionary *playlist = [playlists objectAtIndex:playlistIndex];
	NSString *playlistName = [playlist objectForKey:@"Name"];
	NSString *playlistIconName = @"Playlist.tiff";


	//only show visible, non-empty playlists (assume visible)
	if([playlist objectForKey:@"Visible"] != nil && [[playlist objectForKey:@"Visible"] boolValue] == NO)
		continue;
	if([[playlist objectForKey:@"Playlist Items"] count] <= 0)
		continue;

	//skip over these, they're not useful
	if([playlistName isEqualToString:@"Movies"])
		continue;
	else if([playlistName isEqualToString:@"TV Shows"])
		continue;
	else if([playlistName isEqualToString:@"Party Shuffle"])
		continue;
	else if([playlistName isEqualToString:@"Genius"])
		continue;

	//set special icons if available
	if([playlistName isEqualToString: @"Music"] || [playlistName isEqualToString:@"Library"])
		playlistIconName = @"Music.tiff";
	else if([playlistName isEqualToString:@"Podcasts"])
		playlistIconName = @"Podcasts.tiff";
	else if([playlistName isEqualToString:@"Audiobooks"])
		playlistIconName = @"Audiobooks.tiff";
	else if([playlistName isEqualToString:@"Purchased"])
		playlistIconName = @"Purchased.tiff";
	else if([playlist objectForKey:@"Smart Info"] != nil)
		playlistIconName = @"SmartPlaylist.tiff";


	NSMenuItem *menuItem = [[NSMenuItem alloc] init];
	[menuItem setTitle:playlistName];
	[menuItem setImage:[NSImage imageNamed:playlistIconName]];
	[menuItem setRepresentedObject:playlist];

	[playlistSelectionMenu addItem:menuItem];
	[menuItem release];
	}

  [playlistSelector setMenu:playlistSelectionMenu];
  [playlistSelectionMenu release];
  }

- (IBAction)updateTrackInfo:(id)sender
  {
  NSArray *availableTracks = [self availableTracks];
  NSString *trackId = [[[availableTracks objectAtIndex:(random() % [availableTracks count])] objectForKey:@"Track ID"] stringValue];
  NSDictionary *trackDictionary = [[iTunesLibrary objectForKey:@"Tracks"] objectForKey:trackId];

  NSImage *artwork = [self artworkForTrack:trackId];
  if(artwork == nil)
	return [self updateTrackInfo:self];

  [albumName setStringValue:[trackDictionary objectForKey:@"Album"]];
  [artistName setStringValue:[trackDictionary objectForKey:@"Artist"]];
  [albumArtwork setImage:artwork];
  }

- (NSArray *)availableTracks
  {
  NSDictionary *playlist = [[playlistSelector selectedItem] representedObject];
  return [playlist objectForKey:@"Playlist Items"];
  }


- (NSImage *)artworkForTrack:(NSString *)trackId
  {
  NSDictionary *trackDictionary = [[iTunesLibrary objectForKey:@"Tracks"] objectForKey:trackId];

  NSImage *artwork = nil;

  artwork = [self fetchArtworkFromAlbumArtworkFolder:[trackDictionary objectForKey:@"Persistent ID"]];

  if(artwork == nil)
	  artwork = [self fetchArtworkFromFile:[NSURL URLWithString:[trackDictionary objectForKey:@"Location"]]];

  return artwork;
  }

- (NSImage *)fetchArtworkFromFile:(NSURL *)url
  {
  QTMovie *track = [[QTMovie alloc] initWithURL:url];

  QTMetaDataRef metaDataContainer = NULL;
  QTMetaDataItem metadataItem = kQTMetaDataItemUninitialized;
  OSType key = kQTMetaDataCommonKeyArtwork;

  QTCopyMovieMetaData([track quickTimeMovie], &metaDataContainer);

  if(!metaDataContainer)
	return nil;

  QTMetaDataGetNextItem(metaDataContainer,
						kQTMetaDataStorageFormatiTunes,
						metadataItem,
						kQTMetaDataKeyFormatCommon,
						(const UInt8 *)&key,
						sizeof(key),
						&metadataItem);
  if(metadataItem == kQTMetaDataItemUninitialized)
	{
	QTMetaDataRelease(metaDataContainer);
	return nil;
	}

  ByteCount artworkSize;
  QTMetaDataGetItemValue(metaDataContainer,
						 metadataItem,
						 NULL,
						 0,
						 &artworkSize);
  if(artworkSize == 0)
	{
	QTMetaDataRelease(metaDataContainer);
	return nil;
	}

  NSMutableData *artworkData = [[NSMutableData alloc] initWithLength:artworkSize];
  QTMetaDataGetItemValue(metaDataContainer,
						 metadataItem,
						 [artworkData mutableBytes],
						 artworkSize,
						 &artworkSize);

  QTMetaDataRelease(metaDataContainer);
  [track release];

  NSImage *artwork = [[NSImage alloc] initWithData:artworkData];
  [artworkData release];

  return [artwork autorelease];
  }

- (NSImage *)fetchArtworkFromAlbumArtworkFolder:(NSString *)persistentId
  {
  NSString *baseArworkPath = [@"~/Music/iTunes/Album Artwork/Download/" stringByExpandingTildeInPath];
  NSString *libraryPersistantId = [iTunesLibrary objectForKey:@"Library Persistent ID"];

  NSString *hexDigitPath = @"";
  for(unsigned digitsAppended = 0; digitsAppended < 3; digitsAppended++)
	{
	unsigned digit;
	[[NSScanner scannerWithString:[persistentId substringWithRange:NSMakeRange([persistentId length]-(digitsAppended+1), 1)]] scanHexInt:&digit];
	hexDigitPath = [hexDigitPath stringByAppendingFormat:@"/%02d/", digit];
	}

  NSString *artworkPath = [NSString stringWithFormat:@"%@/%@/%@/%@-%@.itc", baseArworkPath, libraryPersistantId, hexDigitPath, libraryPersistantId, persistentId];
  if([[NSFileManager defaultManager] fileExistsAtPath:artworkPath] == NO)
	return nil;


  NSData *iTunesArtworkData = [[NSData alloc] initWithContentsOfFile:artworkPath];

  UInt32 dataSectionLength = 0;
  [iTunesArtworkData getBytes:&dataSectionLength range:NSMakeRange(284, 4)];	//bytes 285-288
  dataSectionLength = EndianU32_BtoN(dataSectionLength);

  UInt32 dataHeaderSize = 0;
  [iTunesArtworkData getBytes:&dataHeaderSize range:NSMakeRange(292, 4)];		//bytes 293-296
  dataHeaderSize = EndianU32_BtoN(dataHeaderSize);

  NSData *artworkData = [iTunesArtworkData subdataWithRange:NSMakeRange(284+dataHeaderSize, dataSectionLength-dataHeaderSize)];
  NSImage *artwork = [[NSImage alloc] initWithData:artworkData];

  [iTunesArtworkData release];

  return [artwork autorelease];
  }

@end
