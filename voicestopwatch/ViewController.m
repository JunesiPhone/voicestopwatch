//
//  ViewController.m
//  voicestopwatch
//
//  Created by Edward Winget on 7/19/16.
//  Copyright © 2016 junesiphone. All rights reserved.
//

#import "ViewController.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEPocketsphinxController.h>
#import <OpenEars/OEAcousticModel.h>
#import <Slt/Slt.h>
#import <OpenEars/OEFliteController.h>

@interface ViewController ()

@property (nonatomic, strong)NSMutableArray *tableViewData;
@property (strong, nonatomic) OEFliteController *fliteController;
@property (strong, nonatomic) Slt *slt;

@end

@implementation ViewController

int lap;
NSString *lapTxt;
NSString *voiceString;

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *myIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:myIdentifier];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:myIdentifier];
    }
    
    NSString *stringFromArray = [self.tableViewData objectAtIndex:indexPath.row];
    NSLog(@"%@",stringFromArray);
    UILabel *label = (UILabel *) [cell viewWithTag:1];
    label.text = stringFromArray;
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tableViewData.count;
}



-(void)voiceSetup {
    self.openEarsEventsObserver = [[OEEventsObserver alloc] init];
    [self.openEarsEventsObserver setDelegate:self];
    
    OELanguageModelGenerator *lmGenerator = [[OELanguageModelGenerator alloc] init];
    
    NSArray *words = [NSArray arrayWithObjects:@"START TIMER", @"STOP TIMER", @"LAP COMPLETE", @"RESET TIMER", nil];
    NSString *name = @"NameIWantForMyLanguageModelFiles";
    NSError *err = [lmGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    NSString *lmPath = nil;
    NSString *dicPath = nil;
    
    if(err == nil) {
        
        lmPath = [lmGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
        dicPath = [lmGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"NameIWantForMyLanguageModelFiles"];
        
    } else {
        NSLog(@"Error: %@",[err localizedDescription]);
    }
    
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath:lmPath dictionaryAtPath:dicPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
    
    self.fliteController = [[OEFliteController alloc] init];
    self.fliteController.duration_stretch = 1.0; //changes the speed of the voice. It is on a scale of 0.0-2.0 where 1.0 is the default.
    self.fliteController.target_mean = 1.3; //changes the pitch of the voice. It is on a scale of 0.0-2.0 where 1.0 is the default.
    self.fliteController.target_stddev = 1.0; // changes convolution of the voice. It is on a scale of 0.0-2.0 where 1.0 is the default.
    self.slt = [[Slt alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self voiceSetup];
    
    self.tableViewData = [[NSMutableArray alloc]init];
    historyTable.separatorInset = UIEdgeInsetsZero;
    lapTxt = [NSString stringWithFormat:@"Lap:"];
    
    minInt = 0;
    secInt = 0;
    msInt = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) startTimer{
    stopWatchtimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(stopWatchMethod) userInfo:nil repeats:YES];
    
    voiceString = [NSString stringWithFormat:@"Timer Started"];
    [self.fliteController say:voiceString withVoice:self.slt];
}

-(void) stopTimer{
    [stopWatchtimer invalidate];
    voiceString = [NSString stringWithFormat:@"Timer Stopped"];
    [self.fliteController say:voiceString withVoice:self.slt];
}

-(void) splitLap{
    lap = lap + 1;
    
    minInt = 0;
    secInt = 0;
    msInt = 0;
    
    milliLabel.text = @"00";
    secondLabel.text  = @"00";
    milliLabel.text = @"00";
    
    historyString = [NSString stringWithFormat:@"%@ %i - %@:%@:%@",lapTxt,lap,minuteString, secondString, milliString];
    voiceString = [NSString stringWithFormat:@"%@ seconds and %@ milliseconds on %@ %i", secondString, milliString, lapTxt, lap];
    
    [self.fliteController say:voiceString withVoice:self.slt];
    
    [self.tableViewData addObject:historyString];
    [historyTable reloadData];
    
    
}

-(void) stopWatchMethod{
    msInt = msInt + 1;
    
    if(msInt == 100){
        msInt = 0;
        secInt = secInt + 1;
    
        if(secInt == 60){
            secInt = 0;
            minInt = minInt + 1;
        }
    }
    
    if(msInt < 10){
        milliString = [NSString stringWithFormat:@"0%i", msInt];
    }else{
        milliString = [NSString stringWithFormat:@"%i", msInt];
    }
    
    if(secInt < 10){
        secondString = [NSString stringWithFormat:@"0%i", secInt];
    }else{
        secondString = [NSString stringWithFormat:@"%i", secInt];
    }
    
    if(minInt < 10){
        minuteString = [NSString stringWithFormat:@"0%i", minInt];
    }else{
        minuteString = [NSString stringWithFormat:@"%i", minInt];
    }
    
    milliLabel.text = milliString;
    secondLabel.text = secondString;
    minuteLabel.text = minuteString;
}

-(void) resetTimer{
    [stopWatchtimer invalidate];
    minInt = 0;
    secInt = 0;
    msInt = 0;
    
    milliLabel.text = @"00";
    secondLabel.text  = @"00";
    milliLabel.text = @"00";
    lap = 0;
    
    [self.tableViewData removeAllObjects];
    [historyTable reloadData];
    
    voiceString = [NSString stringWithFormat:@"Timer Reset"];
    [self.fliteController say:voiceString withVoice:self.slt];
}

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID {
    NSLog(@"The received hypothesis is %@ with a score of %@ and an ID of %@", hypothesis, recognitionScore, utteranceID);
    
    if([hypothesis isEqualToString:@"START TIMER"]){
        if([recognitionScore intValue] < -19000){
            [self startTimer];
        }
    }
    
    if([hypothesis isEqualToString:@"LAP COMPLETE"]){
        if([recognitionScore intValue] < -15000 && secInt > 1){
            [self splitLap];
        }
    }
    
    if([hypothesis isEqualToString:@"STOP TIMER"]){
        if([recognitionScore intValue] < -19000){
            [self stopTimer];
        }
    }
    
    if([hypothesis isEqualToString:@"RESET TIMER"]){
        if([recognitionScore intValue] < -19000){
            [self resetTimer];
        }
    }
    
}

- (void) pocketsphinxDidStartListening {
//    NSLog(@"Pocketsphinx is now listening.");
}

- (void) pocketsphinxDidDetectSpeech {
//    NSLog(@"Pocketsphinx has detected speech.");
}

- (void) pocketsphinxDidDetectFinishedSpeech {
//    NSLog(@"Pocketsphinx has detected a period of silence, concluding an utterance.");
}

- (void) pocketsphinxDidStopListening {
    //NSLog(@"Pocketsphinx has stopped listening.");
}

- (void) pocketsphinxDidSuspendRecognition {
    //NSLog(@"Pocketsphinx has suspended recognition.");
}

- (void) pocketsphinxDidResumeRecognition {
    //NSLog(@"Pocketsphinx has resumed recognition.");
}

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString {
    NSLog(@"Pocketsphinx is now using the following language model: \n%@ and the following dictionary: %@",newLanguageModelPathAsString,newDictionaryPathAsString);
}

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening setup wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure {
    NSLog(@"Listening teardown wasn't successful and returned the failure reason: %@", reasonForFailure);
}

- (void) testRecognitionCompleted {
    NSLog(@"A test file that was submitted for recognition is now complete.");
}

@end
