import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MovieShimmer extends StatelessWidget {
  const MovieShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,

      child: ListView.builder(
        scrollDirection: Axis.horizontal,

        itemCount: 6,

        itemBuilder: (context, index) {
          return Container(
            width: 170,

            margin: const EdgeInsets.only(right: 18),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // IMAGE SHIMMER
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade900,

                  highlightColor: Colors.grey.shade800,

                  child: Container(
                    height: 230,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // TITLE
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade900,

                  highlightColor: Colors.grey.shade800,

                  child: Container(
                    height: 18,
                    width: 140,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // OVERVIEW
                Shimmer.fromColors(
                  baseColor: Colors.grey.shade900,

                  highlightColor: Colors.grey.shade800,

                  child: Container(
                    height: 14,
                    width: 160,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Shimmer.fromColors(
                  baseColor: Colors.grey.shade900,

                  highlightColor: Colors.grey.shade800,

                  child: Container(
                    height: 14,
                    width: 100,

                    decoration: BoxDecoration(
                      color: Colors.white,

                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
