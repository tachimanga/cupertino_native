import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';

import '../channel/params.dart';
import '../style/sf_symbol.dart';
import '../style/button_style.dart';

/// Action types for alert dialog buttons.
enum CNAlertActionStyle {
  /// Default style for standard actions.
  defaultAction,

  /// Cancel style for dismissing actions.
  cancel,

  /// Destructive style for dangerous actions.
  destructive,

  /// Primary style for emphasized actions (bold).
  primary,

  /// Secondary style for less important actions.
  secondary,

  /// Success style for positive confirmations.
  success,

  /// Warning style for caution actions.
  warning,

  /// Info style for informational actions.
  info,

  /// Disabled style for non-interactive actions.
  disabled,
}

/// A single action in an alert dialog.
class CNAlertAction {
  /// Creates an alert action.
  const CNAlertAction({
    required this.title,
    required this.onPressed,
    this.style = CNAlertActionStyle.defaultAction,
    this.enabled = true,
  });

  /// The text displayed in the action button.
  final String title;

  /// Called when the action is pressed.
  final VoidCallback onPressed;

  /// The visual style of the action.
  final CNAlertActionStyle style;

  /// Whether the action can be pressed.
  final bool enabled;
}

/// A Cupertino-native alert dialog with bordered prominent styling.
///
/// On iOS/macOS this uses native UIAlertController/NSAlert with bordered prominent styling.
/// Falls back to CupertinoAlertDialog on other platforms.
class CNAlertDialog extends StatefulWidget {
  /// Creates an alert dialog.
  const CNAlertDialog({
    super.key,
    required this.title,
    this.message,
    required this.actions,
    this.icon,
    this.oneTimeCode,
  });

  /// The title of the alert dialog.
  final String title;

  /// Optional message text for additional context.
  final String? message;

  /// List of actions for the alert.
  final List<CNAlertAction> actions;

  /// Optional icon to display in the alert.
  final CNSymbol? icon;

  /// Optional 6-digit one-time code to display.
  final String? oneTimeCode;

  /// Shows the alert dialog as a modal.
  static Future<void> show({
    required BuildContext context,
    required String title,
    String? message,
    required List<CNAlertAction> actions,
    CNSymbol? icon,
    String? oneTimeCode,
  }) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) => CNAlertDialog(
        title: title,
        message: message,
        actions: actions,
        icon: icon,
        oneTimeCode: oneTimeCode,
      ),
    );
  }

  @override
  State<CNAlertDialog> createState() => _CNAlertDialogState();
}

class _CNAlertDialogState extends State<CNAlertDialog> {
  MethodChannel? _channel;
  bool? _lastIsDark;
  int? _lastTint;

  bool get _isDark => CupertinoTheme.of(context).brightness == Brightness.dark;
  Color? get _effectiveTint => CupertinoTheme.of(context).primaryColor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncBrightnessIfNeeded();
  }

  @override
  void dispose() {
    _channel?.setMethodCallHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we're on a supported platform
    if (!(defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS)) {
      // Fallback to CupertinoAlertDialog on unsupported platforms
      return CupertinoAlertDialog(
        title: Text(widget.title),
        content: widget.message != null ? Text(widget.message!) : null,
        actions: widget.actions.map((action) {
          return CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop();
              action.onPressed();
            },
            isDefaultAction: action.style == CNAlertActionStyle.defaultAction,
            isDestructiveAction: action.style == CNAlertActionStyle.destructive,
            child: Text(action.title),
          );
        }).toList(),
      );
    }

    // Use native implementation
    const viewType = 'CupertinoNativeAlertDialog';

    final creationParams = <String, dynamic>{
      'title': widget.title,
      if (widget.message != null) 'message': widget.message,
      'actionTitles': widget.actions.map((a) => a.title).toList(),
      'actionStyles': widget.actions.map((a) => a.style.name).toList(),
      'actionEnabled': widget.actions.map((a) => a.enabled).toList(),
      if (widget.icon != null) 'iconName': widget.icon!.name,
      if (widget.icon?.size != null) 'iconSize': widget.icon!.size,
      if (widget.icon?.color != null)
        'iconColor': resolveColorToArgb(widget.icon!.color, context),
      if (widget.oneTimeCode != null) 'oneTimeCode': widget.oneTimeCode,
      'alertStyle': CNButtonStyle.borderedProminent.name,
      'isDark': _isDark,
      'style': encodeStyle(context, tint: _effectiveTint),
      if (widget.icon?.mode != null)
        'iconRenderingMode': widget.icon!.mode!.name,
      if (widget.icon?.paletteColors != null)
        'iconPaletteColors': widget.icon!.paletteColors!
            .map((c) => resolveColorToArgb(c, context))
            .toList(),
      if (widget.icon?.gradient != null)
        'iconGradientEnabled': widget.icon!.gradient,
    };

    final platformView = defaultTargetPlatform == TargetPlatform.iOS
        ? UiKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          )
        : AppKitView(
            viewType: viewType,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onCreated,
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<TapGestureRecognizer>(() => TapGestureRecognizer()),
            },
          );

    // Alert dialogs are modal and should fill the screen
    return Container(
      color: Colors.black26, // Semi-transparent overlay
      child: Center(
        child: SizedBox(
          width: 270, // Standard iOS alert width
          height: 200, // Approximate height, will be adjusted by native
          child: platformView,
        ),
      ),
    );
  }

  void _onCreated(int id) {
    final ch = MethodChannel('CupertinoNativeAlertDialog_$id');
    _channel = ch;
    ch.setMethodCallHandler(_onMethodCall);
    _lastTint = resolveColorToArgb(_effectiveTint, context);
    _lastIsDark = _isDark;
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'actionPressed') {
      final args = call.arguments as Map?;
      final idx = (args?['index'] as num?)?.toInt();

      if (idx != null && idx >= 0 && idx < widget.actions.length) {
        // Dismiss the dialog first
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Then call the action
        widget.actions[idx].onPressed();
      }
    }
    return null;
  }

  Future<void> _syncBrightnessIfNeeded() async {
    final ch = _channel;
    if (ch == null) return;

    final isDark = _isDark;
    final tint = resolveColorToArgb(_effectiveTint, context);

    if (_lastIsDark != isDark) {
      await ch.invokeMethod('setBrightness', {'isDark': isDark});
      _lastIsDark = isDark;
    }

    if (_lastTint != tint && tint != null) {
      await ch.invokeMethod('setStyle', {'tint': tint});
      _lastTint = tint;
    }
  }
}
