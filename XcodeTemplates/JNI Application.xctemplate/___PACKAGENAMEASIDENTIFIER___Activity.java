package ___VARIABLE_bundleIdentifierPrefix:bundleIdentifier___.___PACKAGENAMEASIDENTIFIER___;

import android.app.Activity;
import android.os.Bundle;
import com.apportable.RuntimeService;

public class ___PACKAGENAMEASIDENTIFIER___Activity extends Activity {
    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        new RuntimeService(this).loadLibraries();
        run();
    }
    public native void run();
}