//
//  OptionsViewController.h
//  Cellfense
//
//  Created by Luis Floreani on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OptionsViewController : UIViewController {
	id target;
	
	IBOutlet UISlider *audio;
	IBOutlet UISlider *music;
	
	IBOutlet UILabel *options;
	IBOutlet UILabel *audioVolume;
	IBOutlet UILabel *musicVolume;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil target:(id)aTarget;

@end
