import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CallNumberBadge extends StatelessWidget {
  final String locationCode;

  const CallNumberBadge({super.key, required this.locationCode});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.026, // Rotasi sekitar -1.5 derajat dalam radian
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bgPaper,
          // Catatan: Flutter butuh package tambahan (dotted_border) untuk garis putus-putus murni,
          // tapi kita bisa pakai solid border tipis dulu untuk kerangkanya.
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          locationCode,
          style: GoogleFonts.ibmPlexMono(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
