import 'package:clinic/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool showCursor;
  final bool autocorrect;
  final bool enableSuggestions;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final Color? fillColor;
  final Color? focusedBorderColor;
  final Color? enabledBorderColor;
  final Color? cursorColor;
  final Color? textColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final bool autovalidate;
  final String? Function(String?)? validator;
  final bool showCounter;
  final String? counterText;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextAlign textAlign;
  final TextDirection? textDirection;
  final bool expands;
  final bool isDense;
  final bool showClearButton;
  final String? clearButtonTooltip;
  final String? obscuringCharacter;
  final BoxShadow? boxShadow;
  final bool toggleObscureText;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.showCursor = true,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.onTap,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.fillColor,
    this.focusedBorderColor,
    this.enabledBorderColor,
    this.cursorColor,
    this.textColor,
    this.borderRadius = 12,
    this.contentPadding,
    this.autovalidate = false,
    this.validator,
    this.showCounter = false,
    this.counterText,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.expands = false,
    this.isDense = false,
    this.showClearButton = false,
    this.clearButtonTooltip,
    this.obscuringCharacter,
    this.boxShadow,
    this.toggleObscureText = false,
  })  : assert(initialValue == null || controller == null, 
          'Cannot provide both an initialValue and a controller'),
        assert(maxLines == null || maxLines > 0, 
          'maxLines must be null or greater than 0'),
        assert(minLines == null || minLines > 0, 
          'minLines must be null or greater than 0'),
        assert(maxLength == null || maxLength > 0, 
          'maxLength must be null or greater than 0'),
        assert(
          (maxLines == null) || (minLines == null) || (maxLines >= minLines),
          'maxLines cannot be smaller than minLines',
        ),
        assert(
          !expands || (maxLines == null && minLines == null),
          'minLines and maxLines must be null when expands is true',
        );

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;
  bool _hasFocus = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _hasText = _controller.text.isNotEmpty;
    
    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.controller != null && widget.controller != _controller) {
      _controller.removeListener(_handleTextChange);
      _controller = widget.controller!;
      _controller.addListener(_handleTextChange);
      _hasText = _controller.text.isNotEmpty;
    }
    
    if (widget.focusNode != null && widget.focusNode != _focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode = widget.focusNode!;
      _focusNode.addListener(_handleFocusChange);
    }

    if (widget.initialValue != null && 
        widget.controller == null && 
        widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_handleTextChange);
    }
    
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _clearText() {
    _controller.clear();
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  InputDecoration _buildInputDecoration() {
    // Rang va stil sozlamalari
    final Color fillColor = widget.fillColor ?? Colors.white;
    final Color enabledBorderColor = widget.enabledBorderColor ?? ColorConstants.borderColor;
    final Color focusedBorderColor = widget.focusedBorderColor ?? ColorConstants.primaryColor;
    
    return InputDecoration(
      // Matn va label
      labelText: widget.label,
      hintText: widget.hint,
      helperText: widget.helperText,
      errorText: widget.errorText,
      counterText: widget.showCounter ? null : '',
      
      // Stillar
      labelStyle: widget.labelStyle ?? TextStyle(
        color: _hasFocus ? focusedBorderColor : ColorConstants.secondaryTextColor,
        fontSize: 14,
      ),
      hintStyle: widget.hintStyle ?? TextStyle(
        color: ColorConstants.hintColor,
        fontSize: 14,
      ),
      errorStyle: widget.errorStyle ?? const TextStyle(
        color: ColorConstants.errorColor,
        fontSize: 12,
      ),
      
      // To'ldirish va kontur
      filled: true,
      fillColor: widget.enabled ? fillColor : ColorConstants.disabledColor.withValues(alpha: 0.1),
      isDense: widget.isDense,
      contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(
        horizontal: 16, 
        vertical: (widget.maxLines ?? 1) > 1 ? 16 : 14,
      ),
      
      // Chegaralar
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: enabledBorderColor,
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: enabledBorderColor,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: focusedBorderColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: const BorderSide(
          color: ColorConstants.errorColor,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: const BorderSide(
          color: ColorConstants.errorColor,
          width: 1.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        borderSide: BorderSide(
          color: enabledBorderColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      
      // Prefix/Suffix elementlari
      prefixIcon: widget.prefixIcon,
      prefix: widget.prefix,
      suffixIcon: _buildSuffixIcon(),
      suffix: widget.suffix,
    );
  }

  Widget? _buildSuffixIcon() {
    // Oldin custom suffix ko'rsatilganmi?
    if (widget.suffixIcon != null) {
      return widget.onSuffixTap != null
          ? GestureDetector(
              onTap: widget.onSuffixTap,
              child: widget.suffixIcon,
            )
          : widget.suffixIcon;
    }
    
    // Ko'rish/Yashirish buttoni
    if (widget.toggleObscureText && widget.obscureText) {
      return GestureDetector(
        onTap: _toggleObscureText,
        child: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: _hasFocus ? focusedBorderColor : ColorConstants.secondaryTextColor,
          size: 20,
        ),
      );
    }
    
    // Tozalash buttoni
    if (widget.showClearButton && _hasText && widget.enabled && !widget.readOnly) {
      return GestureDetector(
        onTap: _clearText,
        child: Tooltip(
          message: widget.clearButtonTooltip ?? 'Tozalash',
          child: const Icon(
            Icons.clear,
            color: ColorConstants.secondaryTextColor,
            size: 18,
          ),
        ),
      );
    }
    
    return null;
  }

  Color get focusedBorderColor => 
      widget.focusedBorderColor ?? ColorConstants.primaryColor;

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    
    Widget textField = TextFormField(
      // Asosiy kontroller va holat
      controller: _controller,
      focusNode: _focusNode,
      
      // Validator va form
      autovalidateMode: widget.autovalidate 
          ? AutovalidateMode.onUserInteraction 
          : AutovalidateMode.disabled,
      validator: widget.validator,
      
      // Matn sozlamalari
      style: widget.style ?? TextStyle(
        color: widget.enabled ? widget.textColor ?? ColorConstants.textColor : ColorConstants.secondaryTextColor,
        fontSize: 16,
      ),
      textAlign: widget.textAlign,
      textDirection: widget.textDirection,
      textCapitalization: widget.textCapitalization,
      
      // Klaviatura sozlamalari
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      
      // Ko'rinish va funksionallik
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: _obscureText,
      obscuringCharacter: widget.obscuringCharacter ?? '•',
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      autofocus: widget.autofocus,
      expands: widget.expands,
      showCursor: widget.showCursor,
      cursorColor: widget.cursorColor ?? ColorConstants.primaryColor,
      
      // Tekst formatteri
      inputFormatters: widget.inputFormatters,
      
      // Smart features
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      
      // Kallabeklar
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      
      // Dekoratsiya
      decoration: _buildInputDecoration(),
    );
    
    // Soya qo'shish kerak bo'lsa
    if (widget.boxShadow != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [widget.boxShadow!],
        ),
        child: textField,
      );
    }
    
    return textField;
  }
}