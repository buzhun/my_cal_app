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

    private String _theme= "black";

    void changeTheme(String theme) {
        _theme = theme;
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

                            result.success(_theme);

                        } else if (call.method.equals("_setTheme")) {
                            changeTheme(call.arguments());
                            result.success(_theme);
                        }
                        {
                            result.notImplemented();
                        }
                    }
                });
    }


}