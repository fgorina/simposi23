library legacy_buttons;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

class LegacyFlatButton extends MaterialButton {
  /// Create a simple text button.
  ///
  /// The [autofocus] and [clipBehavior] arguments must not be null.

  const LegacyFlatButton({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHighlightChanged,
    MouseCursor? mouseCursor,
    ButtonTextTheme? textTheme,
    Color? textColor,
    Color? disabledTextColor,
    Color? color,
    Color? disabledColor,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    Brightness? colorBrightness,
    EdgeInsetsGeometry? padding,
    VisualDensity? visualDensity,
    ShapeBorder? shape,
    Clip clipBehavior = Clip.none,
    FocusNode? focusNode,
    bool autofocus = false,
    MaterialTapTargetSize? materialTapTargetSize,
    required Widget child,
    double? height,
    double? minWidth,
  })  : super(
        key: key,
        height: height,
        minWidth: minWidth,
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHighlightChanged: onHighlightChanged,
        mouseCursor: mouseCursor,
        textTheme: textTheme,
        textColor: textColor,
        disabledTextColor: disabledTextColor,
        color: color,
        disabledColor: disabledColor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        colorBrightness: colorBrightness,
        padding: padding,
        visualDensity: visualDensity,
        shape: shape,
        clipBehavior: clipBehavior,
        focusNode: focusNode,
        autofocus: autofocus,
        materialTapTargetSize: materialTapTargetSize,
        child: child,
      );

  /// Create a text button from a pair of widgets that serve as the button's
  /// [icon] and [label].
  ///
  /// The icon and label are arranged in a row and padded by 12 logical pixels
  /// at the start, and 16 at the end, with an 8 pixel gap in between.
  ///
  /// The [icon], [label], and [clipBehavior] arguments must not be null.

  factory LegacyFlatButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHighlightChanged,
    MouseCursor? mouseCursor,
    ButtonTextTheme? textTheme,
    Color? textColor,
    Color? disabledTextColor,
    Color? color,
    Color? disabledColor,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    Brightness? colorBrightness,
    EdgeInsetsGeometry? padding,
    ShapeBorder? shape,
    Clip clipBehavior,
    FocusNode? focusNode,
    bool autofocus,
    MaterialTapTargetSize? materialTapTargetSize,
    required Widget icon,
    required Widget label,
    double? minWidth,
    double? height,
  }) = _LegacyFlatButtonWithIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ButtonThemeData buttonTheme = ButtonTheme.of(context);
    return RawMaterialButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHighlightChanged: onHighlightChanged,
      mouseCursor: mouseCursor,
      fillColor: buttonTheme.getFillColor(this),
      textStyle: theme.textTheme.labelLarge!
          .copyWith(color: buttonTheme.getTextColor(this)),
      focusColor: buttonTheme.getFocusColor(this),
      hoverColor: buttonTheme.getHoverColor(this),
      highlightColor: buttonTheme.getHighlightColor(this),
      splashColor: buttonTheme.getSplashColor(this),
      elevation: buttonTheme.getElevation(this),
      focusElevation: buttonTheme.getFocusElevation(this),
      hoverElevation: buttonTheme.getHoverElevation(this),
      highlightElevation: buttonTheme.getHighlightElevation(this),
      disabledElevation: buttonTheme.getDisabledElevation(this),
      padding: buttonTheme.getPadding(this),
      visualDensity: visualDensity ?? theme.visualDensity,
      constraints: buttonTheme.getConstraints(this).copyWith(
        minWidth: minWidth,
        minHeight: height,
      ),
      shape: buttonTheme.getShape(this),
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      autofocus: autofocus,
      materialTapTargetSize: buttonTheme.getMaterialTapTargetSize(this),
      animationDuration: buttonTheme.getAnimationDuration(this),
      child: child,
    );
  }
}

/// The type of LegacyFlatButtons created with [LegacyFlatButton.icon].
///
/// This class only exists to give LegacyFlatButtons created with [LegacyFlatButton.icon]
/// a distinct class for the sake of [ButtonTheme]. It can not be instantiated.
class _LegacyFlatButtonWithIcon extends LegacyFlatButton
    {
  _LegacyFlatButtonWithIcon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHighlightChanged,
    MouseCursor? mouseCursor,
    ButtonTextTheme? textTheme,
    Color? textColor,
    Color? disabledTextColor,
    Color? color,
    Color? disabledColor,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    Brightness? colorBrightness,
    EdgeInsetsGeometry? padding,
    ShapeBorder? shape,
    Clip clipBehavior = Clip.none,
    FocusNode? focusNode,
    bool autofocus = false,
    MaterialTapTargetSize? materialTapTargetSize,
    required Widget icon,
    required Widget label,
    double? minWidth,
    double? height,
  })  : super(
        key: key,
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHighlightChanged: onHighlightChanged,
        mouseCursor: mouseCursor,
        textTheme: textTheme,
        textColor: textColor,
        disabledTextColor: disabledTextColor,
        color: color,
        disabledColor: disabledColor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        colorBrightness: colorBrightness,
        padding: padding,
        shape: shape,
        clipBehavior: clipBehavior,
        focusNode: focusNode,
        autofocus: autofocus,
        materialTapTargetSize: materialTapTargetSize,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            icon,
            const SizedBox(width: 8.0),
            label,
          ],
        ),
        minWidth: minWidth,
        height: height,
      );
}

//
//

////
///
/////
///
///
///

// The total time to make the button's fill color opaque and change
// its elevation. Only applies when highlightElevation > 0.0.
const Duration _kPressDuration = Duration(milliseconds: 150);

// Half of _kPressDuration: just the time to change the button's
// elevation. Only applies when highlightElevation > 0.0.
const Duration _kElevationDuration = Duration(milliseconds: 75);

/// Similar to a [FlatButton] with a thin grey rounded rectangle border.
///

class LegacyOutlineButton extends MaterialButton {
  /// Create an outline button.
  ///
  /// The [highlightElevation] argument must be null or a positive value
  /// and the [autofocus] and [clipBehavior] arguments must not be null.

  const LegacyOutlineButton({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    MouseCursor? mouseCursor,
    ButtonTextTheme? textTheme,
    Color? textColor,
    Color? disabledTextColor,
    Color? color,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    double? highlightElevation,
    this.borderSide,
    this.disabledBorderColor,
    this.highlightedBorderColor,
    EdgeInsetsGeometry? padding,
    VisualDensity? visualDensity,
    ShapeBorder? shape,
    Clip clipBehavior = Clip.none,
    FocusNode? focusNode,
    bool autofocus = false,
    MaterialTapTargetSize? materialTapTargetSize,
    Widget? child,
  })  : assert(highlightElevation == null || highlightElevation >= 0.0),
        super(
        key: key,
        onPressed: onPressed,
        onLongPress: onLongPress,
        mouseCursor: mouseCursor,
        textTheme: textTheme,
        textColor: textColor,
        disabledTextColor: disabledTextColor,
        color: color,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        highlightElevation: highlightElevation,
        padding: padding,
        visualDensity: visualDensity,
        shape: shape,
        clipBehavior: clipBehavior,
        focusNode: focusNode,
        materialTapTargetSize: materialTapTargetSize,
        autofocus: autofocus,
        child: child,
      );

  /// Create an outline button from a pair of widgets that serve as the button's
  /// [icon] and [label].
  ///
  /// The icon and label are arranged in a row and padded by 12 logical pixels
  /// at the start, and 16 at the end, with an 8 pixel gap in between.
  ///
  /// The [highlightElevation] argument must be null or a positive value. The
  /// [icon], [label], [autofocus], and [clipBehavior] arguments must not be null.

  factory LegacyOutlineButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    MouseCursor? mouseCursor,
    ButtonTextTheme? textTheme,
    Color? textColor,
    Color? disabledTextColor,
    Color? color,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    double? highlightElevation,
    Color? highlightedBorderColor,
    Color? disabledBorderColor,
    BorderSide? borderSide,
    EdgeInsetsGeometry? padding,
    VisualDensity? visualDensity,
    ShapeBorder? shape,
    Clip clipBehavior,
    FocusNode? focusNode,
    bool autofocus,
    MaterialTapTargetSize? materialTapTargetSize,
    required Widget icon,
    required Widget label,
  }) = _LegacyOutlineButtonWithIcon;

  /// The outline border's color when the button is [enabled] and pressed.
  ///
  /// By default the border's color does not change when the button
  /// is pressed.
  ///
  /// This field is ignored if [BorderSide.color] is a [MaterialStateProperty<Color>].
  final Color? highlightedBorderColor;

  /// The outline border's color when the button is not [enabled].
  ///
  /// By default the outline border's color does not change when the
  /// button is disabled.
  ///
  /// This field is ignored if [BorderSide.color] is a [MaterialStateProperty<Color>].
  final Color? disabledBorderColor;

  /// Defines the color of the border when the button is enabled but not
  /// pressed, and the border outline's width and style in general.
  ///
  /// If the border side's [BorderSide.style] is [BorderStyle.none], then
  /// an outline is not drawn.
  ///
  /// If null the default border's style is [BorderStyle.solid], its
  /// [BorderSide.width] is 1.0, and its color is a light shade of grey.
  ///
  /// If [BorderSide.color] is a [MaterialStateProperty<Color>], [WidgetStateProperty.resolve]
  /// is used in all states and both [highlightedBorderColor] and [disabledBorderColor]
  /// are ignored.
  final BorderSide? borderSide;

  @override
  Widget build(BuildContext context) {
    final ButtonThemeData buttonTheme = ButtonTheme.of(context);
    return _LegacyOutlineButton(
      autofocus: autofocus,
      onPressed: onPressed,
      onLongPress: onLongPress,
      mouseCursor: mouseCursor,
      brightness: buttonTheme.getBrightness(this),
      textTheme: textTheme,
      textColor: buttonTheme.getTextColor(this),
      disabledTextColor: buttonTheme.getDisabledTextColor(this),
      color: color,
      focusColor: buttonTheme.getFocusColor(this),
      hoverColor: buttonTheme.getHoverColor(this),
      highlightColor: buttonTheme.getHighlightColor(this),
      splashColor: buttonTheme.getSplashColor(this),
      highlightElevation: buttonTheme.getHighlightElevation(this),
      borderSide: borderSide,
      disabledBorderColor: disabledBorderColor,
      highlightedBorderColor:
      highlightedBorderColor ?? buttonTheme.colorScheme!.primary,
      padding: buttonTheme.getPadding(this),
      visualDensity: visualDensity,
      shape: buttonTheme.getShape(this),
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      materialTapTargetSize: materialTapTargetSize,
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<BorderSide>('borderSide', borderSide,
        defaultValue: null));
    properties.add(ColorProperty('disabledBorderColor', disabledBorderColor,
        defaultValue: null));
    properties.add(ColorProperty(
        'highlightedBorderColor', highlightedBorderColor,
        defaultValue: null));
  }
}

// The type of LegacyOutlineButtons created with LegacyOutlineButton.icon.
//
// This class only exists to give LegacyOutlineButtons created with LegacyOutlineButton.icon
// a distinct class for the sake of ButtonTheme. It can not be instantiated.
class _LegacyOutlineButtonWithIcon extends LegacyOutlineButton
     {
  _LegacyOutlineButtonWithIcon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    MouseCursor? mouseCursor,
    ButtonTextTheme? textTheme,
    Color? textColor,
    Color? disabledTextColor,
    Color? color,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    double? highlightElevation,
    Color? highlightedBorderColor,
    Color? disabledBorderColor,
    BorderSide? borderSide,
    EdgeInsetsGeometry? padding,
    VisualDensity? visualDensity,
    ShapeBorder? shape,
    Clip clipBehavior = Clip.none,
    FocusNode? focusNode,
    bool autofocus = false,
    MaterialTapTargetSize? materialTapTargetSize,
    required Widget icon,
    required Widget label,
  })  : assert(highlightElevation == null || highlightElevation >= 0.0),
        super(
        key: key,
        onPressed: onPressed,
        onLongPress: onLongPress,
        mouseCursor: mouseCursor,
        textTheme: textTheme,
        textColor: textColor,
        disabledTextColor: disabledTextColor,
        color: color,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        highlightElevation: highlightElevation,
        disabledBorderColor: disabledBorderColor,
        highlightedBorderColor: highlightedBorderColor,
        borderSide: borderSide,
        padding: padding,
        visualDensity: visualDensity,
        shape: shape,
        clipBehavior: clipBehavior,
        focusNode: focusNode,
        autofocus: autofocus,
        materialTapTargetSize: materialTapTargetSize,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            icon,
            const SizedBox(width: 8.0),
            label,
          ],
        ),
      );
}

class _LegacyOutlineButton extends StatefulWidget {
  const _LegacyOutlineButton({
    Key? key,
    required this.onPressed,
    this.onLongPress,
    this.mouseCursor,
    required this.brightness,
    this.textTheme,
    required this.textColor,
    required this.disabledTextColor,
    this.color,
    required this.focusColor,
    required this.hoverColor,
    required this.highlightColor,
    required this.splashColor,
    required this.highlightElevation,
    this.borderSide,
    this.disabledBorderColor,
    required this.highlightedBorderColor,
    required this.padding,
    this.visualDensity,
    required this.shape,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.child,
    this.materialTapTargetSize,
  })  : assert(highlightElevation >= 0.0),
        super(key: key);

  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final MouseCursor? mouseCursor;
  final Brightness brightness;
  final ButtonTextTheme? textTheme;
  final Color textColor;
  final Color disabledTextColor;
  final Color? color;
  final Color splashColor;
  final Color focusColor;
  final Color hoverColor;
  final Color highlightColor;
  final double highlightElevation;
  final BorderSide? borderSide;
  final Color? disabledBorderColor;
  final Color highlightedBorderColor;
  final EdgeInsetsGeometry padding;
  final VisualDensity? visualDensity;
  final ShapeBorder shape;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final bool autofocus;
  final Widget? child;
  final MaterialTapTargetSize? materialTapTargetSize;

  bool get enabled => onPressed != null || onLongPress != null;

  @override
  _LegacyOutlineButtonState createState() => _LegacyOutlineButtonState();
}

class _LegacyOutlineButtonState extends State<_LegacyOutlineButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fillAnimation;
  late Animation<double> _elevationAnimation;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    // When highlightElevation > 0.0, the Material widget animates its
    // shape (which includes the outline border) and elevation over
    // _kElevationDuration. When pressed, the button makes its fill
    // color opaque white first, and then sets its
    // highlightElevation. We can't change the elevation while the
    // button's fill is translucent, because the shadow fills the
    // interior of the button.

    _controller = AnimationController(
      duration: _kPressDuration,
      vsync: this,
    );
    _fillAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.0,
        0.5,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _elevationAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 0.5),
      reverseCurve: const Interval(1.0, 1.0),
    );
  }

  @override
  void didUpdateWidget(_LegacyOutlineButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_pressed && !widget.enabled) {
      _pressed = false;
      _controller.reverse();
    }
  }

  void _handleHighlightChanged(bool value) {
    if (_pressed == value) return;
    setState(() {
      _pressed = value;
      if (value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getFillColor() {
    if (widget.highlightElevation == 0.0) {
      return Colors.transparent;
    }
    final Color color = widget.color ?? Theme.of(context).canvasColor;
    final Tween<Color?> colorTween = ColorTween(
      begin: color.withAlpha(0x00),
      end: color.withAlpha(0xFF),
    );
    return colorTween.evaluate(_fillAnimation)!;
  }

  Color? get _outlineColor {
    // If outline color is a `MaterialStateProperty`, it will be used in all
    // states, otherwise we determine the outline color in the current state.
    if (widget.borderSide?.color is WidgetStateProperty<Color?>) {
      return widget.borderSide!.color;
    }
    if (!widget.enabled) return widget.disabledBorderColor;
    if (_pressed) return widget.highlightedBorderColor;
    return widget.borderSide?.color;
  }

  BorderSide _getOutline() {
    if (widget.borderSide?.style == BorderStyle.none) return widget.borderSide!;

    final Color themeColor =
    Theme.of(context).colorScheme.onSurface.withOpacity(0.12);

    return BorderSide(
      color: _outlineColor ?? themeColor,
      width: widget.borderSide?.width ?? 1.0,
    );
  }

  double _getHighlightElevation() {
    if (widget.highlightElevation == 0.0) {
      return 0.0;
    }
    return Tween<double>(
      begin: 0.0,
      end: widget.highlightElevation,
    ).evaluate(_elevationAnimation);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return LegacyRaisedButton(
          autofocus: widget.autofocus,
          textColor: widget.textColor,
          disabledTextColor: widget.disabledTextColor,
          color: _getFillColor(),
          splashColor: widget.splashColor,
          focusColor: widget.focusColor,
          hoverColor: widget.hoverColor,
          highlightColor: widget.highlightColor,
          disabledColor: Colors.transparent,
          onPressed: widget.onPressed,
          onLongPress: widget.onLongPress,
          mouseCursor: widget.mouseCursor,
          elevation: 0.0,
          disabledElevation: 0.0,
          focusElevation: 0.0,
          hoverElevation: 0.0,
          highlightElevation: _getHighlightElevation(),
          onHighlightChanged: _handleHighlightChanged,
          padding: widget.padding,
          visualDensity: widget.visualDensity ?? theme.visualDensity,
          shape: _OutlineBorder(
            shape: widget.shape,
            side: _getOutline(),
          ),
          clipBehavior: widget.clipBehavior,
          focusNode: widget.focusNode,
          animationDuration: _kElevationDuration,
          materialTapTargetSize: widget.materialTapTargetSize,
          child: widget.child,
        );
      },
    );
  }
}

// Render the button's outline border using using the LegacyOutlineButton's
// border parameters and the button or buttonTheme's shape.
class _OutlineBorder extends ShapeBorder
    implements WidgetStateProperty<ShapeBorder> {
  const _OutlineBorder({
    required this.shape,
    required this.side,
  });

  final ShapeBorder shape;
  final BorderSide side;

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.all(side.width);
  }

  @override
  ShapeBorder scale(double t) {
    return _OutlineBorder(
      shape: shape.scale(t),
      side: side.scale(t),
    );
  }

  @override
  ShapeBorder? lerpFrom(ShapeBorder? a, double t) {
    if (a is _OutlineBorder) {
      return _OutlineBorder(
        side: BorderSide.lerp(a.side, side, t),
        shape: ShapeBorder.lerp(a.shape, shape, t)!,
      );
    }
    return super.lerpFrom(a, t);
  }

  @override
  ShapeBorder? lerpTo(ShapeBorder? b, double t) {
    if (b is _OutlineBorder) {
      return _OutlineBorder(
        side: BorderSide.lerp(side, b.side, t),
        shape: ShapeBorder.lerp(shape, b.shape, t)!,
      );
    }
    return super.lerpTo(b, t);
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return shape.getInnerPath(rect.deflate(side.width),
        textDirection: textDirection);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return shape.getOuterPath(rect, textDirection: textDirection);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    switch (side.style) {
      case BorderStyle.none:
        break;
      case BorderStyle.solid:
        canvas.drawPath(shape.getOuterPath(rect, textDirection: textDirection),
            side.toPaint());
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is _OutlineBorder &&
        other.side == side &&
        other.shape == shape;
  }

  @override
  int get hashCode => Object.hash(side, shape);

  @override
  ShapeBorder resolve(Set<WidgetState> states) {
    return _OutlineBorder(
      shape: shape,
      side: side.copyWith(
          color: WidgetStateProperty.resolveAs<Color>(side.color, states)),
    );
  }
}

/// A Material Design "raised button" which is deprecated.

class LegacyRaisedButton extends MaterialButton {
  /// Create a filled button.
  ///
  /// The [autofocus] and [clipBehavior] arguments must not be null.
  /// Additionally,  [elevation], [hoverElevation], [focusElevation],
  /// [highlightElevation], and [disabledElevation] must be non-negative, if
  /// specified.

  const LegacyRaisedButton({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHighlightChanged,
    MouseCursor? mouseCursor,
    ButtonTextTheme? textTheme,
    Color? textColor,
    Color? disabledTextColor,
    Color? color,
    Color? disabledColor,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    Brightness? colorBrightness,
    double? elevation,
    double? focusElevation,
    double? hoverElevation,
    double? highlightElevation,
    double? disabledElevation,
    EdgeInsetsGeometry? padding,
    VisualDensity? visualDensity,
    ShapeBorder? shape,
    Clip clipBehavior = Clip.none,
    FocusNode? focusNode,
    bool autofocus = false,
    MaterialTapTargetSize? materialTapTargetSize,
    Duration? animationDuration,
    Widget? child,
  })  : assert(elevation == null || elevation >= 0.0),
        assert(focusElevation == null || focusElevation >= 0.0),
        assert(hoverElevation == null || hoverElevation >= 0.0),
        assert(highlightElevation == null || highlightElevation >= 0.0),
        assert(disabledElevation == null || disabledElevation >= 0.0),
        super(
        key: key,
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHighlightChanged: onHighlightChanged,
        mouseCursor: mouseCursor,
        textTheme: textTheme,
        textColor: textColor,
        disabledTextColor: disabledTextColor,
        color: color,
        disabledColor: disabledColor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        colorBrightness: colorBrightness,
        elevation: elevation,
        focusElevation: focusElevation,
        hoverElevation: hoverElevation,
        highlightElevation: highlightElevation,
        disabledElevation: disabledElevation,
        padding: padding,
        visualDensity: visualDensity,
        shape: shape,
        clipBehavior: clipBehavior,
        focusNode: focusNode,
        autofocus: autofocus,
        materialTapTargetSize: materialTapTargetSize,
        animationDuration: animationDuration,
        child: child,
      );

  /// Create a filled button from a pair of widgets that serve as the button's
  /// [icon] and [label].
  ///
  /// The icon and label are arranged in a row and padded by 12 logical pixels
  /// at the start, and 16 at the end, with an 8 pixel gap in between.
  ///
  /// The [elevation], [highlightElevation], [disabledElevation], [icon],
  /// [label], and [clipBehavior] arguments must not be null.

  factory LegacyRaisedButton.icon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHighlightChanged,
    MouseCursor? mouseCursor,
    ButtonTextTheme? textTheme,
    Color? textColor,
    Color? disabledTextColor,
    Color? color,
    Color? disabledColor,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    Brightness? colorBrightness,
    double? elevation,
    double? highlightElevation,
    double? disabledElevation,
    ShapeBorder? shape,
    Clip clipBehavior,
    FocusNode? focusNode,
    bool autofocus,
    EdgeInsetsGeometry? padding,
    MaterialTapTargetSize? materialTapTargetSize,
    Duration? animationDuration,
    required Widget icon,
    required Widget label,
  }) = _LegacyRaisedButtonWithIcon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ButtonThemeData buttonTheme = ButtonTheme.of(context);
    return RawMaterialButton(
      onPressed: onPressed,
      onLongPress: onLongPress,
      onHighlightChanged: onHighlightChanged,
      mouseCursor: mouseCursor,
      clipBehavior: clipBehavior,
      fillColor: buttonTheme.getFillColor(this),
      textStyle: theme.textTheme.labelLarge!
          .copyWith(color: buttonTheme.getTextColor(this)),
      focusColor: buttonTheme.getFocusColor(this),
      hoverColor: buttonTheme.getHoverColor(this),
      highlightColor: buttonTheme.getHighlightColor(this),
      splashColor: buttonTheme.getSplashColor(this),
      elevation: buttonTheme.getElevation(this),
      focusElevation: buttonTheme.getFocusElevation(this),
      hoverElevation: buttonTheme.getHoverElevation(this),
      highlightElevation: buttonTheme.getHighlightElevation(this),
      disabledElevation: buttonTheme.getDisabledElevation(this),
      padding: buttonTheme.getPadding(this),
      visualDensity: visualDensity ?? theme.visualDensity,
      constraints: buttonTheme.getConstraints(this),
      shape: buttonTheme.getShape(this),
      focusNode: focusNode,
      autofocus: autofocus,
      animationDuration: buttonTheme.getAnimationDuration(this),
      materialTapTargetSize: buttonTheme.getMaterialTapTargetSize(this),
      child: child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<double>('elevation', elevation,
        defaultValue: null));
    properties.add(DiagnosticsProperty<double>('focusElevation', focusElevation,
        defaultValue: null));
    properties.add(DiagnosticsProperty<double>('hoverElevation', hoverElevation,
        defaultValue: null));
    properties.add(DiagnosticsProperty<double>(
        'highlightElevation', highlightElevation,
        defaultValue: null));
    properties.add(DiagnosticsProperty<double>(
        'disabledElevation', disabledElevation,
        defaultValue: null));
  }
}

/// The type of LegacyRaisedButtons created with [LegacyRaisedButton.icon].
///
/// This class only exists to give LegacyRaisedButtons created with [LegacyRaisedButton.icon]
/// a distinct class for the sake of [ButtonTheme]. It can not be instantiated.
class _LegacyRaisedButtonWithIcon extends LegacyRaisedButton
    {
  _LegacyRaisedButtonWithIcon({
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHighlightChanged,
    MouseCursor? mouseCursor,
    ButtonTextTheme? textTheme,
    Color? textColor,
    Color? disabledTextColor,
    Color? color,
    Color? disabledColor,
    Color? focusColor,
    Color? hoverColor,
    Color? highlightColor,
    Color? splashColor,
    Brightness? colorBrightness,
    double? elevation,
    double? highlightElevation,
    double? disabledElevation,
    ShapeBorder? shape,
    Clip clipBehavior = Clip.none,
    FocusNode? focusNode,
    bool autofocus = false,
    EdgeInsetsGeometry? padding,
    MaterialTapTargetSize? materialTapTargetSize,
    Duration? animationDuration,
    required Widget icon,
    required Widget label,
  })  : assert(elevation == null || elevation >= 0.0),
        assert(highlightElevation == null || highlightElevation >= 0.0),
        assert(disabledElevation == null || disabledElevation >= 0.0),
        super(
        key: key,
        onPressed: onPressed,
        onLongPress: onLongPress,
        onHighlightChanged: onHighlightChanged,
        mouseCursor: mouseCursor,
        textTheme: textTheme,
        textColor: textColor,
        disabledTextColor: disabledTextColor,
        color: color,
        disabledColor: disabledColor,
        focusColor: focusColor,
        hoverColor: hoverColor,
        highlightColor: highlightColor,
        splashColor: splashColor,
        colorBrightness: colorBrightness,
        elevation: elevation,
        highlightElevation: highlightElevation,
        disabledElevation: disabledElevation,
        shape: shape,
        clipBehavior: clipBehavior,
        focusNode: focusNode,
        autofocus: autofocus,
        padding: padding,
        materialTapTargetSize: materialTapTargetSize,
        animationDuration: animationDuration,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            icon,
            const SizedBox(width: 8.0),
            label,
          ],
        ),
      );
}
