//
//  Config.h
//  Cellfense
//
//  Created by Luis Floreani on 8/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Config : UIViewController {
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIButton *playButton;
	
	IBOutlet UISlider *livesSlider;
	IBOutlet UILabel *livesLabel;
	
	IBOutlet UISlider *energySlider;
	IBOutlet UILabel *energyLabel;
	
	IBOutlet UISlider *ltaSlider;
	IBOutlet UILabel *ltaLabel;
	
	IBOutlet UISlider *towersLimitSlider;
	IBOutlet UILabel *towersLimitLabel;
	
	IBOutlet UISlider *turretCostSlider;
	IBOutlet UILabel *turretCostLabel;
	
	IBOutlet UISlider *turretDamageSlider;
	IBOutlet UILabel *turretDamageLabel;
	
	IBOutlet UISlider *turretRangeSlider;
	IBOutlet UILabel *turretRangeLabel;
	
	IBOutlet UISlider *turretRateSlider;
	IBOutlet UILabel *turretRateLabel;
	
	IBOutlet UISlider *tankCostSlider;
	IBOutlet UILabel *tankCostLabel;
	
	IBOutlet UISlider *tankDamageSlider;
	IBOutlet UILabel *tankDamageLabel;
	
	IBOutlet UISlider *tankRangeSlider;
	IBOutlet UILabel *tankRangeLabel;
	
	IBOutlet UISlider *tankRateSlider;
	IBOutlet UILabel *tankRateLabel;
	
	IBOutlet UISlider *enemySpeedSlider;
	IBOutlet UILabel *enemySpeedLabel;
	
	IBOutlet UISlider *energyOnDestroySlider;
	IBOutlet UILabel *energyOnDestroyLabel;
	
	IBOutlet UISlider *spiderSpeedSlider;
	IBOutlet UILabel *spiderSpeedLabel;
	
	IBOutlet UISlider *spiderLifeSlider;
	IBOutlet UILabel *spiderLifeLabel;
	
	IBOutlet UISlider *caterSpeedSlider;
	IBOutlet UILabel *caterSpeedLabel;
	
	IBOutlet UISlider *caterLifeSlider;
	IBOutlet UILabel *caterLifeLabel;
	
	IBOutlet UISlider *mergeDamageSlider;
	IBOutlet UILabel *mergeDamageLabel;
	
	IBOutlet UISlider *mergeRangeSlider;
	IBOutlet UILabel *mergeRangeLabel;
	
	IBOutlet UISlider *mergeCostSlider;
	IBOutlet UILabel *mergeCostLabel;
	
	IBOutlet UISlider *wavesSlider;
	IBOutlet UILabel *wavesLabel;
	
	IBOutlet UISlider *enemiesAtStartSlider;
	IBOutlet UILabel *enemiesAtStartLabel;
	
	IBOutlet UISlider *enemiesNumberIncreaseSlider;
	IBOutlet UILabel *enemiesNumberIncreaseLabel;
	
	IBOutlet UISlider *enemiesResistIncreaseSlider;
	IBOutlet UILabel *enemiesResistIncreaseLabel;
	
	IBOutlet UISlider *enemiesPresentationTimeSlider;
	IBOutlet UILabel *enemiesPresentationTimeLabel;
	
	IBOutlet UISlider *comboRecogTimeSlider;
	IBOutlet UILabel *comboRecogTimeLabel;	
}

@end
