# Delphi Windows Toast (Only Firemonkey)
Windows Toast like Android Toast


# Usage

Place TWindowsToastDialog on form;

On your form, anywhere in your source, call the MakeText procedure;

exemple:

```pascal
WindowsToastDialog1.MakeText("Testing Windows Toast");
```
# ----

You can change the duration, text color and background color;

MakeText(Text; Duration; BackgroundColor; TextColor);

exemple:

```pascal
WindowsToastDialog1.MakeText('Toast on Windows Application', ToastDurationLengthShort, $FF009688, $FFFFFFFF);
```
