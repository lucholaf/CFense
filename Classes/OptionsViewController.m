//
//  OptionsViewController.m
//  Cellfense
//
//  Created by Luis Floreani on 3/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OptionsViewController.h"
#import "AudioEngine.h"

@implementation OptionsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil target:(id)aTarget {
	target = aTarget;
	
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		UIImage *image = [UIImage imageNamed:@"back_button.png"];
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
		backButton.frame = CGRectMake(0, 16, 40, 40);
		[backButton setBackgroundImage:image forState:UIControlStateNormal];
		[self.view addSubview:backButton];
		
		options.text = NSLocalizedString(@"Options", @"");
		musicVolume.text = NSLocalizedString(@"MusicVolume", @"");
		audioVolume.text = NSLocalizedString(@"SoundVolume", @"");		
    }
    return self;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


- (void)viewWillAppear:(BOOL)animated {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	music.value = [[settings objectForKey:@"cfmusic"] floatValue];
	audio.value = [[settings objectForKey:@"cfaudio"] floatValue];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
- (void)backButtonClick {
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	[settings setObject:[NSString stringWithFormat:@"%f", music.value] forKey:@"cfmusic"];
	[settings setObject:[NSString stringWithFormat:@"%f", audio.value] forKey:@"cfaudio"];
	[settings synchronize];
	
	[AudioEngine updateVolumes];

	[self.view removeFromSuperview];	
	[target performSelector:@selector(showMenu)];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
