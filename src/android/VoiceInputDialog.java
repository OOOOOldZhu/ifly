package com.microduino.mDesigner;

/**
 * Created by z on 2017/9/14.
 */

import android.app.Dialog;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;

import com.microduino.mDesigner.R;

public class VoiceInputDialog {
    private Dialog dialog;
    private ImageView v1, v2, v3, v4, v5, v6;
    private Button cancelButton;
    private Context context;

    public VoiceInputDialog(Context context) {
        this.context = context;
        dialog = new Dialog(context, R.style.VoiceDialog);
        LayoutInflater inflater = LayoutInflater.from(context);
        View view = inflater.inflate(R.layout.layout_dialog_voiceinput, null);
        dialog.setContentView(view);
        dialog.setCanceledOnTouchOutside(false);
        v1 = (ImageView) view.findViewById(R.id.v1);
        v2 = (ImageView) view.findViewById(R.id.v2);
        v3 = (ImageView) view.findViewById(R.id.v3);
        v4 = (ImageView) view.findViewById(R.id.v4);
        v5 = (ImageView) view.findViewById(R.id.v5);
        v6 = (ImageView) view.findViewById(R.id.v6);
        cancelButton = (Button) view.findViewById(R.id.cacel);
        cancelButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                listener.onCancelButtonClick();
                //dialog.dismiss();
            }
        });
    }
    public void showDialog() {
        dialog.show();
    }

    public void dismissDialog() {
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
            //dialog = null;
        }
    }

    public void updateVolumeLevel(int volume) {  // 0- 30

        if (dialog != null && dialog.isShowing()) {
            if (volume == 30) volume = volume - 1;
            if (volume == 0) volume = volume + 1;

            if (0 <= volume && volume <= 3) {
                setNumVisible(1);
            } else if (3 < volume && volume <= 7) {
                setNumVisible(2);
            } else if (7 < volume && volume <= 13) {
                setNumVisible(3);
            } else if (13 < volume && volume <= 18) {
                setNumVisible(4);
            } else if (18 < volume && volume <= 25) {
                setNumVisible(5);
            } else if (25 < volume && volume <= 30) {
                setNumVisible(6);
            }
        }
    }

    private void setNumVisible(int num) {
        switch (num) {
            case 1:
                v1.setVisibility(View.VISIBLE);
                v2.setVisibility(View.INVISIBLE);
                v3.setVisibility(View.INVISIBLE);
                v4.setVisibility(View.INVISIBLE);
                v5.setVisibility(View.INVISIBLE);
                v6.setVisibility(View.INVISIBLE);
                break;
            case 2:
                v1.setVisibility(View.VISIBLE);
                v2.setVisibility(View.VISIBLE);
                v3.setVisibility(View.INVISIBLE);
                v4.setVisibility(View.INVISIBLE);
                v5.setVisibility(View.INVISIBLE);
                v6.setVisibility(View.INVISIBLE);
                break;
            case 3:
                v1.setVisibility(View.VISIBLE);
                v2.setVisibility(View.VISIBLE);
                v3.setVisibility(View.VISIBLE);
                v4.setVisibility(View.INVISIBLE);
                v5.setVisibility(View.INVISIBLE);
                v6.setVisibility(View.INVISIBLE);
                break;
            case 4:
                v1.setVisibility(View.VISIBLE);
                v2.setVisibility(View.VISIBLE);
                v3.setVisibility(View.VISIBLE);
                v4.setVisibility(View.VISIBLE);
                v5.setVisibility(View.INVISIBLE);
                v6.setVisibility(View.INVISIBLE);
                break;
            case 5:
                v1.setVisibility(View.VISIBLE);
                v2.setVisibility(View.VISIBLE);
                v3.setVisibility(View.VISIBLE);
                v4.setVisibility(View.VISIBLE);
                v5.setVisibility(View.VISIBLE);
                v6.setVisibility(View.INVISIBLE);
                break;
            case 6:
                v1.setVisibility(View.VISIBLE);
                v2.setVisibility(View.VISIBLE);
                v3.setVisibility(View.VISIBLE);
                v4.setVisibility(View.VISIBLE);
                v5.setVisibility(View.VISIBLE);
                v6.setVisibility(View.VISIBLE);
                break;
            default:
                v1.setVisibility(View.VISIBLE);
                v2.setVisibility(View.INVISIBLE);
                v3.setVisibility(View.INVISIBLE);
                v4.setVisibility(View.INVISIBLE);
                v5.setVisibility(View.INVISIBLE);
                v6.setVisibility(View.INVISIBLE);
                break;
        }

    }
    private VoiceInputDialogListener listener ;
    public void setCancelButtonClickListener(VoiceInputDialogListener listener){
        this.listener=listener;
    }
    public interface VoiceInputDialogListener{
        void onCancelButtonClick();
    }
}
