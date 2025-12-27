import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CustomTextformfield extends StatelessWidget {
  String? labelText;
  String? hintText;
  Widget? suffixIcon;
  Widget? prefixIcon;
  bool? obscureText;
  int? maxLines;
  bool? readOnly;
  Function()? onTap;
  TextInputType? keyboardType;
  TextEditingController? controller;
  String? Function(String?)? validator;
  CustomTextformfield({
    super.key,
    this.labelText,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.obscureText,
    this.maxLines,
    this.keyboardType,
    this.controller,
    this.validator,
    this.readOnly,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText!,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 5),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType ?? TextInputType.text,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validator,
            readOnly: readOnly ?? false,
            onTap: onTap,
            maxLines: maxLines ?? 1,
            obscureText: obscureText ?? false,
            decoration: InputDecoration(
              // labelText:labelText ,
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              alignLabelWithHint: true,
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5)
              ),
            ),
          ),
        ],
      ),
    );
  }
}
