//
//  Save.h
//  Cellfense
//
//  Created by Luis Floreani on 8/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kLives @"lives"
#define kEnergy @"energy"
#define kLtaDamage @"lta"
#define kTowersLimit @"limit"
#define kTurretCost @"tcost"
#define kTurretDamage @"tdamage"
#define kTurretRange @"trange"
#define kTurretRate @"trate"
#define kTankCost @"tacost"
#define kTankDamage @"tadamage"
#define kTankRange @"tarange"
#define kTankRate @"tarate"
#define kEnemySpeed @"espeed"
#define kEnergyOnDestroy @"edestroy"
#define kSpiderSpeed @"sspeed"
#define kSpiderLife @"slife"
#define kCaterSpeed @"cspeed"
#define kCaterLife @"clife"
#define kMergeDamage @"mdamage"
#define kMergeRange @"mrange"
#define kMergeCost @"mcost"
#define kWaves @"waves"
#define kEnemiesPresentationTime @"ept"
#define kEnemiesAtStart @"eas"
#define kEnemiesNumberIncrease @"eni"
#define kEnemiesResistanceIncrease @"eri"
#define kComboTime @"combot"

@interface Save : NSObject {
@public
	int start_lives;
	int start_energy;
	int lta_damage;
	int towers_limit;
	
	int turret_cost;
	int turret_damage;
	int turret_range;
	float turret_rate;
	
	int tank_cost;
	int tank_damage;
	int tank_range;
	float tank_rate;
	
	int enemy_speed;
	int energy_on_destroy;
	
	int spider_speed;
	int spider_life;
	
	int cater_speed;
	int cater_life;
	
	float merge_damage;
	float merge_range;
	float merge_cost;
	
	int waves;
	int enemies_presentation_time;
	int enemies_at_start;
	float enemies_number_increase;
	float enemies_resistance_increase;
	
	float combo_time;
}

+ (Save *)sharedInstance;

@end
