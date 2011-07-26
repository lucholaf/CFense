//
//  AudioEngine.m
//  Tap Hotel
//
//  Created by Luis Floreani on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AudioEngine.h"
#import "SimpleAudioEngine.h"
#import "Constants.h"

@implementation AudioEngine

+ (void)preload {
#ifdef CF_AUDIO
	SimpleAudioEngine *sae = [SimpleAudioEngine sharedEngine];
	if (sae != nil) {
		[sae preloadEffect:@"chain_gun.wav"];
		[sae preloadEffect:@"canon.wav"];
		[sae preloadEffect:@"fireball.wav"];
		[sae preloadBackgroundMusic:@"prepare1.mp3"];
		[sae preloadBackgroundMusic:@"attack1.mp3"];
		if (sae.willPlayBackgroundMusic) {
			sae.backgroundMusicVolume = 0.7f;
		}
	}
#endif		
}

+ (void)playPrepareMusic {
#ifdef CF_AUDIO
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:[NSString stringWithFormat:@"prepare%d.mp3", 1 + (rand() % 2)]];
#endif	
}

+ (void)updateVolumes {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	
	[SimpleAudioEngine sharedEngine].effectsVolume = [[settings objectForKey:@"cfaudio"] floatValue];
	[SimpleAudioEngine sharedEngine].backgroundMusicVolume = [[settings objectForKey:@"cfmusic"] floatValue];
}

+ (void)playAttackMusic {
#ifdef CF_AUDIO
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[SimpleAudioEngine sharedEngine] playBackgroundMusic:[NSString stringWithFormat:@"attack%d.mp3", 1 + (rand() % 6)]];
#endif
}

+ (void)playSound:(NSString *)sound {
#ifdef CF_AUDIO
	[[SimpleAudioEngine sharedEngine] playEffect:sound];	
#endif
}

+ (void)stopMusic {
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];	
}

@end
