import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,

      decoration: BoxDecoration(
        color: const Color(0xFF111827),

        borderRadius: BorderRadius.circular(20),

        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),

      child: TextField(
        style: const TextStyle(
          color: Colors.white,
        ),

        decoration: InputDecoration(
          border: InputBorder.none,

          hintText: "Search movies, videos, channels...",

          hintStyle: TextStyle(
            color: Colors.grey.shade500,
          ),

          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
          ),

          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
          ),
        ),
      ),
    );
  }
}