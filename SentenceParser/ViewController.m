//
//  ViewController.m
//  SentenceParser
//
//  Created by 刘文昌 on 2019/8/4.
//  Copyright © 2019 刘文昌. All rights reserved.
//

#import "ViewController.h"
#import "SentenceParser.h"
#import "ASRResultParser.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    [self._cmbSentences addItemsWithObjectValues:@[@"D d",
                                             @"^aw^-^aw^-str^aw^",
                                             @"Timmy and his father are in the study.\\t",
                                             @"{^sn^-^sn^-^sn^ail#snail}",
                                             @"Yes, it is. My building has {20th#twentieth} floors.",
                                             @"Aircraft: a machine (such as an airplane) that flies through the air.",
                                             @"It's also only {120#hundred twenty$a hundred and twenty$the hundred and twenty     } centimeters in height, which is even shorter than us!",
                                             @"^Without^ bees, ^it^ ^would^ ^be^ much harder to grow fruit.\\n没有蜜蜂，种植水果将会比现在困难得多。",
                                             @"A {A # a} B {B # b $ bb $ bbb} C {C # c $ cc} D."]];
    
    [self._cmbSentences selectItemAtIndex:0];
//    self._lblResult.stringValue = self._cmbSentences.stringValue;

    NSString *sentTest = @"{\"tokenId\":\"5d4c01315f0a0ca5b9000002\",\"refText\":\"Let me introduce myself.\",\"audioUrl\":\"records.17kouyu.com\\/5d4c012fc14f76c8dc025e79\",\"dtLastResponse\":\"2019-08-08 19:02:14:851\",\"result\":{\"fluency\":0,\"words\":[{\"scores\":{\"prominence\":0,\"overall\":0,\"pronunciation\":0},\"span\":{\"end\":44,\"start\":35},\"word\":\"Let\",\"charType\":0,\"phonics\":[{\"overall\":0,\"phoneme\":[\"l\"],\"spell\":\"L\"},{\"overall\":0,\"phoneme\":[\"ɛ\"],\"spell\":\"e\"},{\"overall\":0,\"phoneme\":[\"t\"],\"spell\":\"t\"}]},{\"scores\":{\"prominence\":0,\"overall\":1,\"pronunciation\":1},\"span\":{\"end\":192,\"start\":176},\"word\":\"me\",\"charType\":0,\"phonics\":[{\"overall\":13,\"phoneme\":[\"m\"],\"spell\":\"m\"},{\"overall\":0,\"phoneme\":[\"i\"],\"spell\":\"e\"}]},{\"scores\":{\"prominence\":0,\"overall\":0,\"pronunciation\":0},\"span\":{\"end\":240,\"start\":192},\"word\":\"introduce\",\"charType\":0,\"phonics\":[{\"overall\":0,\"phoneme\":[\"ɪ\"],\"spell\":\"i\"},{\"overall\":0,\"phoneme\":[\"n\"],\"spell\":\"n\"},{\"overall\":0,\"phoneme\":[\"t\"],\"spell\":\"t\"},{\"overall\":32,\"phoneme\":[\"r\"],\"spell\":\"r\"},{\"overall\":6,\"phoneme\":[\"ə\"],\"spell\":\"o\"},{\"overall\":0,\"phoneme\":[\"d\"],\"spell\":\"d\"},{\"overall\":0,\"phoneme\":[\"u\"],\"spell\":\"u\"},{\"overall\":0,\"phoneme\":[\"s\"],\"spell\":\"ce\"}]},{\"scores\":{\"prominence\":0,\"overall\":0,\"pronunciation\":0},\"span\":{\"end\":258,\"start\":240},\"word\":\"myself.\",\"charType\":0,\"phonics\":[{\"overall\":0,\"phoneme\":[\"m\"],\"spell\":\"m\"},{\"overall\":0,\"phoneme\":[\"aɪ\"],\"spell\":\"y\"},{\"overall\":0,\"phoneme\":[\"s\"],\"spell\":\"s\"},{\"overall\":0,\"phoneme\":[\"ɛ\"],\"spell\":\"e\"},{\"overall\":0,\"phoneme\":[\"l\"],\"spell\":\"l\"},{\"overall\":0,\"phoneme\":[\"f\"],\"spell\":\"f\"}]}],\"duration\":\"5.606\",\"kernel_version\":\"3.6.3\",\"rear_tone\":\"rise\",\"speed\":107,\"integrity\":0,\"pronunciation\":0,\"overall\":0,\"resource_version\":\"1.7.9\",\"rhythm\":0},\"eof\":1,\"applicationId\":\"15512466730000a1\",\"recordId\":\"5d4c012fc14f76c8dc025e79\"}";
    NSString *choiceTest = @"{\"tokenId\":\"5d4c01705f0a0ca5b9000003\",\"refText\":\"It's also only hundred twenty centimeters in height, which is even shorter than us!|It's also only a hundred and twenty centimeters in height, which is even shorter than us!|It's also only the hundred and twenty centimeters in height, which is even shorter than us!\",\"audioUrl\":\"records.17kouyu.com\\/5d4c01709b08124e28024f71\",\"dtLastResponse\":\"2019-08-08 19:03:21:488\",\"result\":{\"words\":[{\"confidence\":65,\"word\":\"It's\"},{\"confidence\":19,\"word\":\"also\"},{\"confidence\":2,\"word\":\"only\"},{\"confidence\":64,\"word\":\"a\"},{\"confidence\":14,\"word\":\"hundred\"},{\"confidence\":0,\"word\":\"and\"}],\"confidence\":22,\"kernel_version\":\"3.6.3\",\"recognition\":\"It's also only a hundred and\",\"resource_version\":\"1.7.9\"},\"eof\":1,\"applicationId\":\"15512466730000a1\",\"recordId\":\"5d4c01709b08124e28024f71\"}";
    NSString* vqdTest = @"{\"refText\":\"hello\", \"overall\":80}";
    
    ASRResultParser* parser = [[ASRResultParser alloc] init];
    NSString *result = [parser parse:2 result:sentTest];
    NSLog(@"result:%@", result);
    
    result = [parser parse:2 result:choiceTest];
    NSLog(@"result:%@", result);
    
    result = [parser parse:3 result:vqdTest];
    NSLog(@"result:%@", result);
}

- (IBAction)onComboBoxChanged:(id)sender {
    NSInteger index = [self._cmbSentences indexOfSelectedItem];
    
    NSString *sentence = [self._cmbSentences itemObjectValueAtIndex:index];
    sentence = [SentenceParser parse:sentence];
    self._lblResult.stringValue = sentence;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
