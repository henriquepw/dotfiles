user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// RFP forces prefers-color-scheme: light on every site. Use FPP with every
// RFP target instead, minus the color scheme spoofing
user_pref("privacy.resistFingerprinting", false);
user_pref("privacy.fingerprintingProtection", true);
user_pref("privacy.fingerprintingProtection.overrides", "+AllTargets,-CSSPrefersColorScheme");
