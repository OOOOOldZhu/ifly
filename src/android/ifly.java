package com.microduino.mDesigner;

import org.apache.cordova.CordovaPlugin;

import android.app.Activity;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.View;
import android.widget.Toast;

import com.iflytek.cloud.ErrorCode;
import com.iflytek.cloud.InitListener;
import com.iflytek.cloud.RecognizerListener;
import com.iflytek.cloud.RecognizerResult;
import com.iflytek.cloud.SpeechConstant;
import com.iflytek.cloud.SpeechError;
import com.iflytek.cloud.SpeechRecognizer;
import com.iflytek.cloud.SpeechUtility;
import com.iflytek.cloud.ui.RecognizerDialog;
import com.iflytek.cloud.ui.RecognizerDialogListener;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONException;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

/*
 * ：Created by z on 2018/12/05
 */

public class ifly extends CordovaPlugin {
    private SpeechRecognizer speechRecognizer;
    private Activity context;
    String TAG = "zhu";
    String respText = "";

    @Override
    protected void pluginInitialize() {
        super.pluginInitialize();
        context = cordova.getActivity();
        // 5b95e51f
        String key = context.getString(getId("app_id", "string"));
        String s = SpeechConstant.APPID + "=" + key;
        SpeechUtility.createUtility(context, s);
        if (speechRecognizer == null) {
            speechRecognizer = SpeechRecognizer.createRecognizer(cordova.getActivity(), new InitListener() {
                @Override
                public void onInit(int code) {
                    if (code != ErrorCode.SUCCESS) {
                        Log.d(TAG, "对象初始化失败，错误码" + code);
                        callbackContext.error(code);
                    } else {
                        Log.d(TAG, "对象初始化成功，状态码" + code);
                    }
                }
            });
            Log.i(TAG, "pluginInitialize2222: " + speechRecognizer);
        }
    }

    private int getId(String idName, String type) {
        return context.getResources().getIdentifier(idName, type, context.getPackageName());
    }

    CallbackContext callbackContext;

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        Log.d(TAG, "action: - - - - - -- - - - -- - - - -> " + action);

        //开始听写
        if (action.equals("startListen")) {
            Log.i(TAG, "startListen  333: " + speechRecognizer);
            initRecognizer(action, args, callbackContext);
            return true;
        }
        if (action.equals("stopListen") && speechRecognizer != null) {
            speechRecognizer.stopListening();
            return true;
        }
        return false;
    }

    private void initRecognizer(String action, CordovaArgs args, CallbackContext callbackContext) {
        Log.i(TAG, "execute 444: " + speechRecognizer);
        boolean isShowDialog;
        try {
            isShowDialog = args.getBoolean(0);
        } catch (Exception e) {
            isShowDialog = true;
        }
        String punc;
        try {
            punc = args.getBoolean(1) ? "1" : "0";
        } catch (Exception e) {
            punc = "1";
        }
        String language;
        try {
            language = args.getString(2);
        } catch (Exception e) {
            language = "zh_cn";
        }
        if (isShowDialog) {

        } else {
            // startListenWidthNotDialog(punc);
        }
        Log.i(TAG, "execute 555: " + speechRecognizer);
        if (speechRecognizer != null) {
            Log.i(TAG, "execute 666: " + speechRecognizer);
            try {
                speechRecognizer.stopListening();
                speechRecognizer.setParameter(SpeechConstant.DOMAIN, "iat");
                //zh_cn en_GB  com.sun.javafx.font  PrismFontFile.java
                // http://mscdoc.xfyun.cn/android/api/    中的SpeechRecognizer类
                if (language.equalsIgnoreCase("zh_cn")) {
                    speechRecognizer.setParameter(SpeechConstant.LANGUAGE, "zh_cn");
                    speechRecognizer.setParameter(SpeechConstant.ACCENT, "mandarin ");
                } else {
                    speechRecognizer.setParameter(SpeechConstant.LANGUAGE, "en_us");
                    speechRecognizer.setParameter(SpeechConstant.ACCENT, null);
                }
                speechRecognizer.startListening(mRecognizerListener);

            } catch (Exception e) {
                Log.i(TAG, "initRecognizer: " + e);
            }
        }
    }
    String result = "";
    private RecognizerListener mRecognizerListener = new RecognizerListener() {
        @Override
        public void onBeginOfSpeech() {
            // 此回调表示：sdk内部录音机已经准备好了，用户可以开始语音输入
            Log.d(TAG, "onBeginOfSpeech 开始说话...");
        }

        @Override
        public void onError(SpeechError error) {
            try {
                error.getHtmlDescription(true);
                Log.d(TAG, "语音识别onError() :" + error.getErrorCode() + "  " + error.getErrorDescription());
                if (error.getErrorCode() == 10118) {
                    String errStr = error.getErrorDescription();
                    callbackContext.error(errStr);
                } else {
                    String errStr = error.getErrorDescription();
                    callbackContext.error(errStr);
                }
                speechRecognizer.stopListening();
                // Tips：
                // 错误码：10118(您没有说话)，可能是录音机权限被禁，需要提示用户打开应用的录音权限。
                // 如果使用本地功能（语记）需要提示用户开启语记的录音权限。
//                btn.setImageResource(R.mipmap.voice_button_normal);
                //抬起 ，关闭动画
//                if (rippleBackground.isRippleAnimationRunning()) {
//                    rippleBackground.stopRippleAnimation();
//                }
            } catch (Exception e) {
                Log.i(TAG, "害羞小强onError()异常 : " + e);
                callbackContext.error(e.getMessage());
            }
        }

        @Override
        public void onEndOfSpeech() {
            // 此回调表示：检测到了语音的尾端点，已经进入识别过程，不再接受语音输入
            Log.d(TAG, "onEndOfSpeech() : 说话结束 ");
            //speechRecognizer.stopListening();
        }

        @Override
        public void onResult(RecognizerResult results, boolean isLast) {
            try {
                String json = results.getResultString();
                result += JsonParser.parseIatResult(json);
                if (result.equals(".") || result.equals("。") || result.equals("？") || result.equals("") || result.equals(" ") || result.equals("  ")) {
                    return;
                } else {
                    //respText += text;
                }
                if (isLast) {
                    Log.d(TAG, "onResult()最后一次 : " + results.getResultString());
                    speechRecognizer.stopListening();
                    callbackContext.success(result);
                }
            } catch (Exception e) {
                Log.i(TAG, "害羞小强返回结果的异常 : " + e);
                callbackContext.error(e.getMessage());
            }
        }

        @Override
        public void onVolumeChanged(int volume, byte[] data) {
            //dialog.updateVolumeLevel(volume);
            //showTip("当前正在说话，音量大小：" + volume);
        }

        @Override
        public void onEvent(int eventType, int arg1, int arg2, Bundle obj) {
            // 以下代码用于获取与云端的会话id，当业务出错时将会话id提供给技术支持人员，可用于查询会话日志，定位出错原因
            // 若使用本地能力，会话id为null
            //	if (SpeechEvent.EVENT_SESSION_ID == eventType) {
            //		String sid = obj.getString(SpeechEvent.KEY_EVENT_SESSION_ID);
            //		Log.d(TAG, "session id =" + sid);
            //	}
        }
    };
}
