//
//  AboutViewController.h
//  Cellfense
//
//  Created by Luis Floreani on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AboutViewController : UIViewController {
	id target;
	
	IBOutlet UILabel *quitarts;
	IBOutlet UILabel *pizzapixel;
	IBOutlet UILabel *takingoff;
	
	IBOutlet UILabel *version;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil target:(id)aTarget;

@end
