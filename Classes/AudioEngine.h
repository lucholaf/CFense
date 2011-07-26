//
//  AudioEngine.h
//  Tap Hotel
//
//  Created by Luis Floreani on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AudioEngine : NSObject {

}

+ (void)preload;
+ (void)playPrepareMusic;
+ (void)playAttackMusic;
+ (void)stopMusic;
+ (void)playSound:(NSString *)sound;
+ (void)updateVolumes;

@end
