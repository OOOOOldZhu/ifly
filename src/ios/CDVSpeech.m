//
//  CDVSpeech.m
//  ZJxunfeiDemo-OC
//
//  Created by Edc.zhang on 2017/2/13.
//  Copyright © 2017年 Edc.zhang. All rights reserved.
//


#import "CDVSpeech.h"
#import "ISRDataHelper.h"
#define STR_EVENT @"event"
#define STR_CODE @"code"
#define STR_MESSAGE @"message"
#define STR_VOLUME @"volume"
#define STR_RESULTS @"results"
#define STR_PROGRESS @"progress"
// always replace the appid and the SDK with what you get from voicecloud.cn
#define SPEECH_APP_ID @"59a90381"


@interface CDVSpeech()
- (void) fireEvent:(NSString*)event;
@end

#import "CDVSpeech.h"

@implementation CDVSpeech
- (void)init:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;

    self.appId = SPEECH_APP_ID;

    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",self.appId];
    [IFlySpeechUtility createUtility:initString];

    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                  messageAsBool: YES];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

#pragma mark - 语音录入
- (void)startListen:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: startListen");
    NSDictionary* options = [command.arguments objectAtIndex:0];
    //                                                 withDefault:[NSNull null]];
    //是否有UI弹窗
//    BOOL isShowDialog = [command.arguments objectAtIndex:1];
    NSString *isShowDialog = [NSString stringWithFormat:@"%@",[command.arguments objectAtIndex:0]];
    NSString *isShowPunc = [NSString stringWithFormat:@"%@",[command.arguments objectAtIndex:1]];
    if ([isShowDialog isEqualToString:@"0"]) {
        if (!self.recognizer){
            self.recognizer = [IFlySpeechRecognizer sharedInstance];
            self.recognizer.delegate = self;
            [self.recognizer setParameter:@"iat" forKey:@"domain"];
            [self.recognizer setParameter:[command.arguments objectAtIndex:2] forKey:@"language"];
            [self.recognizer setParameter:@"16000" forKey:@"sample_rate"];
            [self.recognizer setParameter:@"700" forKey:@"vad_eos"];
            [self.recognizer setParameter:@"0" forKey:@"plain_result"];
            [self.recognizer setParameter:@"asr.pcm" forKey:@"asr_audio_path"];
            //是否显示标点
            if ([isShowPunc isEqualToString:@"0"]) {
                [self.recognizer setParameter:@"0" forKey:@"asr_ptt"];
            }
            NSLog(@"Speech :: createRecognizer");
        }
        if ((NSNull *)options != [NSNull null]) {
            NSArray *keys = [options allKeys];
            for (NSString *key in keys) {
                NSString *value = [options objectForKey:key];
                [self.recognizer setParameter:value forKey:key];
            }
        }

        //判断当前是否正在听 若正在识别则先停止 再开始听
        if ([self.recognizer isListening]) {
            [self.recognizer stopListening];
        }
            [self.recognizer stopListening];

    }else{
        //初始化语音识别控件
        self.callbackId = command.callbackId;
        UIWindow *keyWindow =  [UIApplication sharedApplication].keyWindow;
        self.iflyRecognizerView = [[IFlyRecognizerView alloc] initWithCenter:keyWindow.center];
        self.iflyRecognizerView.delegate = self;
        [self.iflyRecognizerView setParameter: @"iat" forKey: [IFlySpeechConstant IFLY_DOMAIN]];
        [self.iflyRecognizerView setParameter:[command.arguments objectAtIndex:2] forKey:@"language"];
        //asr_audio_path保存录音文件名，如不再需要，设置value为nil表示取消，默认目录是documents
        [self.iflyRecognizerView setParameter:@"asrview.pcm " forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
        if ([isShowPunc isEqualToString:@"0"]) {
            [self.iflyRecognizerView setParameter:@"0" forKey:@"asr_ptt"];
        }
        [self.iflyRecognizerView start];
    }
}

- (void)stopListen:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: stopListen");
    [self.recognizer stopListening];
}

- (void)cancelListening:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: cancelListening");
    [self.recognizer cancel];
    [self.iflyRecognizerView cancel];
}


#pragma mark - 语音朗读
- (void)startSpeaking:(CDVInvokedUrlCommand*)command
{
    NSString* text = [command.arguments objectAtIndex:0];
    NSDictionary* options = [command.arguments objectAtIndex:1];
    //                                                 withDefault:[NSNull null]];
    NSLog(@"Speech :: startSpeaking - %@", text);
    //   [self.commandDelegate runInBackground:^{
    if (!self.synthesizer){
        self.synthesizer = [IFlySpeechSynthesizer sharedInstance];
        self.synthesizer.delegate = self;

        [self.synthesizer setParameter:@"50" forKey:[IFlySpeechConstant SPEED]];//合成的语速,取值范围 0~100
        [self.synthesizer setParameter:@"80" forKey:[IFlySpeechConstant VOLUME]];//合成的音量;取值范围 0~100
        [self.synthesizer setParameter:@"vixr" forKey:[IFlySpeechConstant VOICE_NAME]];//发音人,默认为”xiaoyan”

        [self.synthesizer setParameter:@"8000" forKey: [IFlySpeechConstant SAMPLE_RATE]];//音频采样率,目前支持的采样率有 16000 和 8000;
        [self.synthesizer setParameter:@"tts.pcm" forKey: [IFlySpeechConstant TTS_AUDIO_PATH]];

        NSLog(@"Speech :: createSynthesizer");
    }
    if ((NSNull *)options != [NSNull null]) {
        NSArray *keys = [options allKeys];
        for (NSString *key in keys) {
            NSString *value = [options objectForKey:key];
            [self.synthesizer setParameter:value forKey:key];
        }
    }

    if ([self.synthesizer isSpeaking]) {
        [self.synthesizer stopSpeaking];
    }
    [self.synthesizer startSpeaking:text];
    //   }];
}

#pragma mark - 暂停语音朗读
- (void)pauseSpeaking:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: pauseSpeaking");
    [self.synthesizer pauseSpeaking];
}

#pragma mark - 继续语音朗读
- (void)resumeSpeaking:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: resumeSpeaking");
    [self.synthesizer resumeSpeaking];
}

#pragma mark - 停止语音朗读
- (void)stopSpeaking:(CDVInvokedUrlCommand*)command
{
    NSLog(@"Speech :: stopSpeaking");
    [self.synthesizer stopSpeaking];
}


#pragma mark IFlyRecognizerViewDelegate

/*! 有UI
 * IFlyRecognizerViewDelegate 回调返回识别结果
 *
 *  @param resultArray 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，sc为识别结果的置信度
 *  @param isLast      -[out] 是否最后一个结果
 */
NSMutableString *allResult = nil;
- (void)onResult:(NSArray *)resultArray isLast:(BOOL)isLast{
    if(allResult == nil){
        allResult = [[NSMutableString alloc] init];
    }
    NSMutableString * resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = [resultArray objectAtIndex:0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSString *result = [ISRDataHelper stringFromJson:resultString];
    [allResult appendString:result];
    if (isLast){
        allResult = [allResult stringByReplacingOccurrencesOfString:@" " withString:@""];  //去掉空格
        allResult = [allResult stringByReplacingOccurrencesOfString:@"," withString:@""];  //去掉逗号
        allResult = [allResult stringByReplacingOccurrencesOfString:@"，" withString:@""];  //去掉逗号
        allResult = [allResult stringByReplacingOccurrencesOfString:@"." withString:@""];  //去掉句号
        allResult = [allResult stringByReplacingOccurrencesOfString:@"。" withString:@""];  //去掉句号
        NSLog(@"最后的结果    %@", result);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                                      messageAsString:allResult];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        allResult = nil;
    }
    NSLog(@"_result=%@",result);
}


//- (void)onResult:(NSArray *)resultArray isLast:(BOOL) isLast{
//        NSLog(@"Speech :: onResults - %@", resultArray);
//        if (self.callbackId) {
//            NSMutableString *text = [[NSMutableString alloc] init];
//            NSDictionary *dic = [resultArray objectAtIndex:0];
//            for (NSString *key in dic) {
//
//                NSLog(@"Recognize Result: %@",key);
//
//                //取出json字符串中的汉字
////                NSData *jsonData = [key dataUsingEncoding:NSUTF8StringEncoding];
////                NSError *err;
////                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
////
//
//
//                [text appendFormat:@"%@",key];
//            }
//          ///  NSLog(@"Recognize Result: %@",text);
//
////            NSString * resultFromJson =  [ISRDataHelper stringFromJson:text];
////            NSLog(@"---------%@",resultFromJson);
//
//            NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"SpeechResults",STR_EVENT,text,STR_RESULTS, nil];
//            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
//            [result setKeepCallbackAsBool:YES];
//            [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
//        }
//}

//
///*! 无UI
// *  IFlySpeechRecognizerDelegate 识别结果回调
// *    在识别过程中可能会多次回调此函数，你最好不要在此回调函数中进行界面的更改等操作，只需要将回调的结果保存起来。
// *  使用results的示例如下：
// *  <pre><code>
// *  - (void) onResults:(NSArray *) results{
// *     NSMutableString *result = [[NSMutableString alloc] init];
// *     NSDictionary *dic = [results objectAtIndex:0];
// *     for (NSString *key in dic){
// *        [result appendFormat:@"%@",key];//合并结果
// *     }
// *   }
// *  </code></pre>
// *
// *  @param results  -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，sc为识别结果的置信度。
// *  @param isLast   -[out] 是否最后一个结果
// */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast{
    NSLog(@"Speech :: onResults - %@", results);
    if (self.callbackId) {
        NSMutableString *text = [[NSMutableString alloc] init];
        NSDictionary *dic = [results objectAtIndex:0];
        for (NSString *key in dic) {
            [text appendFormat:@"%@",key];
        }
        NSLog(@"Recognize Result: %@",text);

        //        NSString * resultFromJson =  [ISRDataHelper stringFromJson:text];
        //
        //        NSLog(@"---------%@",resultFromJson);

        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"SpeechResults",STR_EVENT,text,STR_RESULTS, nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

/*!
 *  IFlySpeechRecognizerDelegate 音量变化回调
 *    在录音过程中，回调音频的音量。
 *
 *  @param volume -[out] 音量，范围从0-30
 */

- (void) onVolumeChanged:(int)volume
{
    NSLog(@"Speech :: onVolumeChanged - %d", volume);
    if (self.callbackId) {
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"VolumeChanged",STR_EVENT,[NSNumber numberWithInt:volume],STR_VOLUME, nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}


    /*!
     *  识别结束回调
     *
     *  @param error 识别结束错误码
     */
    - (void)onError: (IFlySpeechError *) error{
            NSLog(@"Speech :: onError - %d", error.errorCode);
//            if (self.callbackId) {
//                NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"11SpeechError",STR_EVENT,[NSNumber numberWithInt:error.errorCode],STR_CODE,error.errorDesc,STR_MESSAGE, nil];
//                CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
//                [result setKeepCallbackAsBool:YES];
//                [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
//            }
    }


#pragma mark IFlySpeechSynthesizerDelegate
- (void) onCompleted:(IFlySpeechError*)error
{
    NSLog(@"Speech :: onCompleted - %d", error.errorCode);
    if (self.callbackId) {
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"SpeakCompleted",STR_EVENT,[NSNumber numberWithInt:error.errorCode],STR_CODE,error.errorDesc,STR_MESSAGE, nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void) onSpeakBegin
{
    NSLog(@"Speech :: onSpeakBegin");
    [self fireEvent:@"SpeakBegin"];
}

- (void) onBufferProgress:(int)progress message:(NSString *)msg
{
    NSLog(@"Speech :: onBufferProgress - %d", progress);
    if (self.callbackId) {
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"BufferProgress",STR_EVENT,[NSNumber numberWithInt:progress],STR_PROGRESS,msg,STR_MESSAGE, nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void) onSpeakProgress:(int)progress
{
    NSLog(@"Speech :: onSpeakProgress - %d", progress);
    if (self.callbackId) {
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:@"SpeakProgress",STR_EVENT,[NSNumber numberWithInt:progress],STR_PROGRESS, nil];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

- (void) onSpeakPaused
{
    NSLog(@"Speech :: onSpeakPaused");
    [self fireEvent:@"SpeakPaused"];
}

- (void) onSpeakResumed
{
    NSLog(@"Speech :: onSpeakResumed");
    [self fireEvent:@"SpeakResumed"];
}

- (void) onSpeakCancel
{
    NSLog(@"Speech :: onSpeakCancel");
    [self fireEvent:@"SpeakCancel"];
}

- (void) fireEvent:(NSString*)event
{
    if (self.callbackId) {
        NSDictionary* info = [NSDictionary dictionaryWithObject:event forKey:STR_EVENT];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:info];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
}

-(void)parseJsonStr:(NSString*)jsonStr{
//
//        StringBuffer ret = new StringBuffer();
//        try {
//            JSONTokener tokener = new JSONTokener(json);
//            JSONObject joResult = new JSONObject(tokener);
//
//            JSONArray words = joResult.getJSONArray("ws");
//            for (int i = 0; i < words.length(); i++) {
//                // 转写结果词，默认使用第一个结果
//                JSONArray items = words.getJSONObject(i).getJSONArray("cw");
//                JSONObject obj = items.getJSONObject(0);
//                ret.append(obj.getString("w"));
//                //                如果需要多候选结果，解析数组其他字段
//                //                for(int j = 0; j < items.length(); j++)
//                //                {
//                //                    JSONObject obj = items.getJSONObject(j);
//                //                    ret.append(obj.getString("w"));
//                //                }
//            }
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//        return ret.toString();
//
//    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
//    NSError *err;
//    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
//    [dic getObjects:@"ws"]
}




@end
