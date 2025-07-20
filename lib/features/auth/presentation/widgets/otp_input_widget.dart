// lib/features/auth/presentation/widgets/otp_input_widget.dart
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/ui/widgets/controls/russian_text_selection_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputWidget extends StatefulWidget {
  final Function(String) onCompleted;
  final Function(String)? onChanged;
  final bool isLoading;
  final int length;

  const OtpInputWidget({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.isLoading = false,
    this.length = 6,
  });

  @override
  State<OtpInputWidget> createState() => OtpInputWidgetState();
}

class OtpInputWidgetState extends State<OtpInputWidget>
    with TickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  String _currentOtp = '';

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );

    // Birinchi input'ga focus berish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_focusNodes.isNotEmpty) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && value.length == 1) {
      // Keyingi input'ga o'tish
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Oxirgi input - focus'ni olib tashlash
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      // Oldingi input'ga qaytish
      _focusNodes[index - 1].requestFocus();
    }

    _updateOtpString();
  }

  void _updateOtpString() {
    _currentOtp = _controllers.map((controller) => controller.text).join();

    // Callback'larni chaqirish
    if (widget.onChanged != null) {
      widget.onChanged!(_currentOtp);
    }

    if (_currentOtp.length == widget.length) {
      // Animation
      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Completed callback
      widget.onCompleted(_currentOtp);
    }
  }

  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
          _controllers[index - 1].clear();
        }
      }
    }
  }

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _currentOtp = '';
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              widget.length,
              (index) => _buildOtpBox(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOtpBox(int index) {
    final isActive = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 55,
      decoration: BoxDecoration(
        color: widget.isLoading
            ? Colors.grey.shade100
            : (isActive
                ? ColorConstants.primaryColor.withOpacity(0.1)
                : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isLoading
              ? Colors.grey.shade300
              : (hasValue
                  ? ColorConstants.primaryColor
                  : (isActive
                      ? ColorConstants.primaryColor
                      : ColorConstants.borderColor)),
          width: isActive || hasValue ? 2 : 1,
        ),
        boxShadow: [
          if (isActive || hasValue)
            BoxShadow(
              color: ColorConstants.primaryColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Focus(
        onKeyEvent: (node, event) {
          _onKeyEvent(event, index);
          return KeyEventResult.ignored;
        },
        child: TextFormField(
          contextMenuBuilder: RussianContextMenu.build,
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: !widget.isLoading,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: widget.isLoading
                ? Colors.grey.shade400
                : ColorConstants.textColor,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(1),
          ],
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.transparent)),
            counterText: '',
          ),
          onChanged: (value) => _onChanged(value, index),
          onTap: () {
            // Agar bo'sh bo'lsa cursor oxiriga qo'yish
            if (_controllers[index].text.isEmpty) {
              _controllers[index].selection = TextSelection.fromPosition(
                const TextPosition(offset: 0),
              );
            }
          },
        ),
      ),
    );
  }
}
