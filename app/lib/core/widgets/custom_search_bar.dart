import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const CustomSearchBar({
    super.key,
    required this.hintText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            spreadRadius: 0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: TextField(
          key: const ValueKey('search_text_field'),
          controller: controller,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 16,
            color: Color(0x80000000),
          ),
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'Raleway',
              fontSize: 16,
              color: Color(0x80000000),
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.only(left: 20),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIconConstraints: const BoxConstraints(
              maxHeight: 22,
              minHeight: 22,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Image.asset(
                'assets/images/commun/search_icon.png',
                width: 22,
                height: 22,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.search,
                  color: Color(0xFF033B63),
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}