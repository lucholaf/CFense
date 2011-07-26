//
//  Config.m
//  Cellfense
//
//  Created by Luis Floreani on 8/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Config.h"
#import "cocos2d.h"
#import "GameScene.h"
#import "Save.h"

@implementation Config

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)livesChanged {
	livesLabel.text = [NSString stringWithFormat:@"%d", (int)livesSlider.value];
}

- (void)energyChanged {
	energyLabel.text = [NSString stringWithFormat:@"%d", (int)energySlider.value];
}

- (void)ltaChanged {
	ltaLabel.text = [NSString stringWithFormat:@"%d", (int)ltaSlider.value];
}

- (void)towersLimitChange {
	towersLimitLabel.text = [NSString stringWithFormat:@"%d", (int)towersLimitSlider.value];
}

- (void)turretCostChange {
	turretCostLabel.text = [NSString stringWithFormat:@"%d", (int)turretCostSlider.value];
}

- (void)turretDamageChange {
	turretDamageLabel.text = [NSString stringWithFormat:@"%d", (int)turretDamageSlider.value];
}

- (void)turretRangeChange {
	turretRangeLabel.text = [NSString stringWithFormat:@"%d", (int)turretRangeSlider.value];
}

- (void)turretRateChange {
	turretRateLabel.text = [NSString stringWithFormat:@"%f", (float)turretRateSlider.value];
}

- (void)tankCostChange {
	tankCostLabel.text = [NSString stringWithFormat:@"%d", (int)tankCostSlider.value];
}

- (void)tankDamageChange {
	tankDamageLabel.text = [NSString stringWithFormat:@"%d", (int)tankDamageSlider.value];
}

- (void)tankRangeChange {
	tankRangeLabel.text = [NSString stringWithFormat:@"%d", (int)tankRangeSlider.value];
}

- (void)tankRateChange {
	tankRateLabel.text = [NSString stringWithFormat:@"%f", (float)tankRateSlider.value];
}

- (void)enemySpeedChange {
	enemySpeedLabel.text = [NSString stringWithFormat:@"%d", (int)enemySpeedSlider.value];
}

- (void)energyOnDestroyChange {
	energyOnDestroyLabel.text = [NSString stringWithFormat:@"%d", (int)energyOnDestroySlider.value];
}

- (void)spiderSpeedChange {
	spiderSpeedLabel.text = [NSString stringWithFormat:@"%d", (int)spiderSpeedSlider.value];
}

- (void)spiderLifeChange {
	spiderLifeLabel.text = [NSString stringWithFormat:@"%d", (int)spiderLifeSlider.value];
}

- (void)caterSpeedChange {
	caterSpeedLabel.text = [NSString stringWithFormat:@"%d", (int)caterSpeedSlider.value];
}

- (void)caterLifeChange {
	caterLifeLabel.text = [NSString stringWithFormat:@"%d", (int)caterLifeSlider.value];
}

- (void)mergeDamageChange {
	mergeDamageLabel.text = [NSString stringWithFormat:@"%f", (float)mergeDamageSlider.value];
}

- (void)mergeRangeChange {
	mergeRangeLabel.text = [NSString stringWithFormat:@"%f", (float)mergeRangeSlider.value];
}

- (void)mergeCostChange {
	mergeCostLabel.text = [NSString stringWithFormat:@"%f", (float)mergeCostSlider.value];
}

- (void)wavesChange {
	wavesLabel.text = [NSString stringWithFormat:@"%d", (int)wavesSlider.value];
}

- (void)enemyPresentationTimeChange {
	enemiesPresentationTimeLabel.text = [NSString stringWithFormat:@"%d", (int)enemiesPresentationTimeSlider.value];
}

- (void)enemiesAtStartChange {
	enemiesAtStartLabel.text = [NSString stringWithFormat:@"%d", (int)enemiesAtStartSlider.value];
}

- (void)enemiesNumberIncreaseChange {
	enemiesNumberIncreaseLabel.text = [NSString stringWithFormat:@"%f", (float)enemiesNumberIncreaseSlider.value];
}

- (void)enemiesResistanceIncreaseChange {
	enemiesResistIncreaseLabel.text = [NSString stringWithFormat:@"%f", (float)enemiesResistIncreaseSlider.value];
}

- (void)comboRecogTimeChange {
	comboRecogTimeLabel.text = [NSString stringWithFormat:@"%f", (float)comboRecogTimeSlider.value];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {	
	scrollView.contentSize = CGSizeMake(320, 1050);
	
	[playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
	[livesSlider addTarget:self action:@selector(livesChanged) forControlEvents:UIControlEventValueChanged];
	[energySlider addTarget:self action:@selector(energyChanged) forControlEvents:UIControlEventValueChanged];
	[ltaSlider addTarget:self action:@selector(ltaChanged) forControlEvents:UIControlEventValueChanged];
	[towersLimitSlider addTarget:self action:@selector(towersLimitChange) forControlEvents:UIControlEventValueChanged];
	[turretCostSlider addTarget:self action:@selector(turretCostChange) forControlEvents:UIControlEventValueChanged];
	[turretDamageSlider addTarget:self action:@selector(turretDamageChange) forControlEvents:UIControlEventValueChanged];
	[turretRangeSlider addTarget:self action:@selector(turretRangeChange) forControlEvents:UIControlEventValueChanged];
	[turretRateSlider addTarget:self action:@selector(turretRateChange) forControlEvents:UIControlEventValueChanged];
	[tankCostSlider addTarget:self action:@selector(tankCostChange) forControlEvents:UIControlEventValueChanged];
	[tankDamageSlider addTarget:self action:@selector(tankDamageChange) forControlEvents:UIControlEventValueChanged];
	[tankRangeSlider addTarget:self action:@selector(tankRangeChange) forControlEvents:UIControlEventValueChanged];
	[tankRateSlider addTarget:self action:@selector(tankRateChange) forControlEvents:UIControlEventValueChanged];
	[enemySpeedSlider addTarget:self action:@selector(enemySpeedChange) forControlEvents:UIControlEventValueChanged];
	[energyOnDestroySlider addTarget:self action:@selector(energyOnDestroyChange) forControlEvents:UIControlEventValueChanged];
	[spiderLifeSlider addTarget:self action:@selector(spiderLifeChange) forControlEvents:UIControlEventValueChanged];
	[spiderSpeedSlider addTarget:self action:@selector(spiderSpeedChange) forControlEvents:UIControlEventValueChanged];
	[caterLifeSlider addTarget:self action:@selector(caterLifeChange) forControlEvents:UIControlEventValueChanged];
	[caterSpeedSlider addTarget:self action:@selector(caterSpeedChange) forControlEvents:UIControlEventValueChanged];
	[mergeDamageSlider addTarget:self action:@selector(mergeDamageChange) forControlEvents:UIControlEventValueChanged];
	[mergeRangeSlider addTarget:self action:@selector(mergeRangeChange) forControlEvents:UIControlEventValueChanged];
	[mergeCostSlider addTarget:self action:@selector(mergeCostChange) forControlEvents:UIControlEventValueChanged];
	[wavesSlider addTarget:self action:@selector(wavesChange) forControlEvents:UIControlEventValueChanged];
	[enemiesPresentationTimeSlider addTarget:self action:@selector(enemyPresentationTimeChange) forControlEvents:UIControlEventValueChanged];
	[enemiesAtStartSlider addTarget:self action:@selector(enemiesAtStartChange) forControlEvents:UIControlEventValueChanged];
	[enemiesNumberIncreaseSlider addTarget:self action:@selector(enemiesNumberIncreaseChange) forControlEvents:UIControlEventValueChanged];
	[enemiesResistIncreaseSlider addTarget:self action:@selector(enemiesResistanceIncreaseChange) forControlEvents:UIControlEventValueChanged];
	[comboRecogTimeSlider addTarget:self action:@selector(comboRecogTimeChange) forControlEvents:UIControlEventValueChanged];
	
	livesSlider.value = [Save sharedInstance]->start_lives;
	[self livesChanged];
	energySlider.value = [Save sharedInstance]->start_energy;
	[self energyChanged];
	ltaSlider.value = [Save sharedInstance]->lta_damage;
	[self ltaChanged];
	towersLimitSlider.value = [Save sharedInstance]->towers_limit;
	[self towersLimitChange];
	turretCostSlider.value = [Save sharedInstance]->turret_cost;
	[self turretCostChange];
	turretDamageSlider.value = [Save sharedInstance]->turret_damage;
	[self turretDamageChange];
	turretRangeSlider.value = [Save sharedInstance]->turret_range;
	[self turretRangeChange];
	turretRateSlider.value = [Save sharedInstance]->turret_rate;
	[self turretRateChange];
	tankCostSlider.value = [Save sharedInstance]->tank_cost;
	[self tankCostChange];
	tankDamageSlider.value = [Save sharedInstance]->tank_damage;
	[self tankDamageChange];
	tankRangeSlider.value = [Save sharedInstance]->tank_range;
	[self tankRangeChange];
	tankRateSlider.value = [Save sharedInstance]->tank_rate;
	[self tankRateChange];
	enemySpeedSlider.value = [Save sharedInstance]->enemy_speed;
	[self enemySpeedChange];
	energyOnDestroySlider.value = [Save sharedInstance]->energy_on_destroy;
	[self energyOnDestroyChange];
	spiderLifeSlider.value = [Save sharedInstance]->spider_life;
	[self spiderLifeChange];
	spiderSpeedSlider.value = [Save sharedInstance]->spider_speed;
	[self spiderSpeedChange];
	caterLifeSlider.value = [Save sharedInstance]->cater_life;
	[self caterLifeChange];
	caterSpeedSlider.value = [Save sharedInstance]->cater_speed;
	[self caterSpeedChange];
	mergeDamageSlider.value = [Save sharedInstance]->merge_damage;
	[self mergeDamageChange];
	mergeRangeSlider.value = [Save sharedInstance]->merge_range;
	[self mergeRangeChange];
	mergeCostSlider.value = [Save sharedInstance]->merge_cost;
	[self mergeCostChange];
	wavesSlider.value = [Save sharedInstance]->waves;
	[self wavesChange];
	enemiesPresentationTimeSlider.value = [Save sharedInstance]->enemies_presentation_time;
	[self enemyPresentationTimeChange];
	enemiesAtStartSlider.value = [Save sharedInstance]->enemies_at_start;
	[self enemiesAtStartChange];
	enemiesNumberIncreaseSlider.value = [Save sharedInstance]->enemies_number_increase;
	[self enemiesNumberIncreaseChange];
	enemiesResistIncreaseSlider.value = [Save sharedInstance]->enemies_resistance_increase;
	[self enemiesResistanceIncreaseChange];
	comboRecogTimeSlider.value = [Save sharedInstance]->combo_time;
	[self comboRecogTimeChange];
	
    [super viewDidLoad];
}

- (IBAction)play {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setObject:[NSNumber numberWithInt:(int)livesSlider.value] forKey:kLives];
	[Save sharedInstance]->start_lives = (int)livesSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)energySlider.value] forKey:kEnergy];
	[Save sharedInstance]->start_energy = (int)energySlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)ltaSlider.value] forKey:kLtaDamage];
	[Save sharedInstance]->lta_damage = (int)ltaSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)towersLimitSlider.value] forKey:kTowersLimit];
	[Save sharedInstance]->towers_limit = (int)towersLimitSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)turretCostSlider.value] forKey:kTurretCost];
	[Save sharedInstance]->turret_cost = (int)turretCostSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)turretDamageSlider.value] forKey:kTurretDamage];
	[Save sharedInstance]->turret_damage = (int)turretDamageSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)turretRangeSlider.value] forKey:kTurretRange];
	[Save sharedInstance]->turret_range = (int)turretRangeSlider.value;
	[settings setObject:[NSNumber numberWithFloat:(float)turretRateSlider.value] forKey:kTurretRate];
	[Save sharedInstance]->turret_rate = (float)turretRateSlider.value;
	[settings setObject:[NSNumber numberWithFloat:(float)tankCostSlider.value] forKey:kTankCost];
	[Save sharedInstance]->tank_cost = (int)tankCostSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)tankDamageSlider.value] forKey:kTankDamage];
	[Save sharedInstance]->tank_damage = (int)tankDamageSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)tankRangeSlider.value] forKey:kTankRange];
	[Save sharedInstance]->tank_range = (int)tankRangeSlider.value;
	[settings setObject:[NSNumber numberWithFloat:(float)tankRateSlider.value] forKey:kTankRate];
	[Save sharedInstance]->tank_rate = (float)tankRateSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)enemySpeedSlider.value] forKey:kEnemySpeed];
	[Save sharedInstance]->enemy_speed = (int)enemySpeedSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)energyOnDestroySlider.value] forKey:kEnergyOnDestroy];
	[Save sharedInstance]->energy_on_destroy = (int)energyOnDestroySlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)spiderLifeSlider.value] forKey:kSpiderLife];
	[Save sharedInstance]->spider_life = spiderLifeSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)spiderSpeedSlider.value] forKey:kSpiderSpeed];
	[Save sharedInstance]->spider_speed = (int)spiderSpeedSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)caterLifeSlider.value] forKey:kCaterLife];
	[Save sharedInstance]->cater_life = (int)caterLifeSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)caterSpeedSlider.value] forKey:kCaterSpeed];
	[Save sharedInstance]->cater_speed = (int)caterSpeedSlider.value;
	[settings setObject:[NSNumber numberWithFloat:(float)mergeDamageSlider.value] forKey:kMergeDamage];
	[Save sharedInstance]->merge_damage = (float)mergeDamageSlider.value;
	[settings setObject:[NSNumber numberWithFloat:(float)mergeRangeSlider.value] forKey:kMergeRange];
	[Save sharedInstance]->merge_range = (float)mergeRangeSlider.value;
	[settings setObject:[NSNumber numberWithFloat:(float)mergeCostSlider.value] forKey:kMergeCost];
	[Save sharedInstance]->merge_cost = (float)mergeCostSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)wavesSlider.value] forKey:kWaves];
	[Save sharedInstance]->waves = (int)wavesSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)enemiesPresentationTimeSlider.value] forKey:kEnemiesPresentationTime];
	[Save sharedInstance]->enemies_presentation_time = (int)enemiesPresentationTimeSlider.value;
	[settings setObject:[NSNumber numberWithInt:(int)enemiesAtStartSlider.value] forKey:kEnemiesAtStart];
	[Save sharedInstance]->enemies_at_start = (int)enemiesAtStartSlider.value;
	[settings setObject:[NSNumber numberWithFloat:(float)enemiesNumberIncreaseSlider.value] forKey:kEnemiesNumberIncrease];
	[Save sharedInstance]->enemies_number_increase = (float)enemiesNumberIncreaseSlider.value;
	[settings setObject:[NSNumber numberWithFloat:(float)enemiesResistIncreaseSlider.value] forKey:kEnemiesResistanceIncrease];
	[Save sharedInstance]->enemies_resistance_increase = (float)enemiesResistIncreaseSlider.value;
	[settings setObject:[NSNumber numberWithFloat:(float)comboRecogTimeSlider.value] forKey:kComboTime];
	[Save sharedInstance]->combo_time = (float)comboRecogTimeSlider.value;

	[settings synchronize];
	
	[self.view removeFromSuperview];
	
	[[CCDirector sharedDirector] resume];
}

- (void)dealloc {
    [super dealloc];
}


@end
