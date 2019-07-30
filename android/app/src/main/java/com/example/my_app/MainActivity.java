package com.example.my_app;

import android.content.SharedPreferences;
import android.os.Bundle;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "samples.flutter.dev/theme";
    public static final String PREFS_NAME = "MyPrefsFile";

    String changeTheme(String theme) {
        SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString("theme", theme);
        editor.commit();
        return theme;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        GeneratedPluginRegistrant.registerWith(this);

        new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
                new MethodCallHandler() {
                    @Override
                    public void onMethodCall(MethodCall call, Result result) {
                        // Note: this method is invoked on the main thread.
                        if (call.method.equals("_getTheme")) {
                            SharedPreferences settings = getSharedPreferences(PREFS_NAME, 0);
                            String theme = settings.getString("theme", "black");
                            result.success(theme);
                        } else if (call.method.equals("_setTheme")) {
                            String theme = changeTheme(call.arguments());
                            result.success(theme);
                        }
                        {
                            result.notImplemented();
                        }
                    }
                });
    }


}