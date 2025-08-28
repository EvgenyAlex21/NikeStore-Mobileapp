import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final String? hintText;
  final Widget? suffixIcon;
  final IconData? prefixIcon;
  
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, 
    TextEditingValue newValue
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    var formattedValue = '';
    
    if (digitsOnly.length <= 1) {
      formattedValue = '+7 (';
    } else if (digitsOnly.length <= 4) {
      formattedValue = '+7 (${digitsOnly.substring(1)}';
    } else if (digitsOnly.length <= 7) {
      formattedValue = '+7 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4)}';
    } else if (digitsOnly.length <= 9) {
      formattedValue = '+7 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7)}';
    } else {
      formattedValue = '+7 (${digitsOnly.substring(1, 4)}) ${digitsOnly.substring(4, 7)}-${digitsOnly.substring(7, 9)}-${digitsOnly.substring(9, digitsOnly.length > 11 ? 11 : digitsOnly.length)}';
    }
    
    return TextEditingValue(
      text: formattedValue,
      selection: TextSelection.collapsed(offset: formattedValue.length),
    );
  }
}