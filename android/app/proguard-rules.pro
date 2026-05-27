-keep class com.analisismotoresoex.motoresoex.MainActivity { public <init>(); }
-keep class com.analisismotoresoex.motoresoex.OexEngineProvider { public <init>(); }

-assumenosideeffects class android.view.Window {
    public void setStatusBarColor(int);
    public void setNavigationBarColor(int);
    public void setNavigationBarDividerColor(int);
}
