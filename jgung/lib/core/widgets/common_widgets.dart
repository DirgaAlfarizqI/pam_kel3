import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Card standar TaniJagung dengan sudut membulat dan garis halus
class TaniCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;
  final Color? color;
  final Border? border;

  const TaniCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.onTap,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.permukaan,
        borderRadius: BorderRadius.circular(16),
        border: border ?? Border.all(color: AppColors.garis),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Tombol utama TaniJagung dengan gaya hijau tua atau kuning jagung
class TaniButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isSecondary;
  final bool isFullWidth;
  final Color? customColor;
  final Color? customTextColor;

  const TaniButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isSecondary = false,
    this.isFullWidth = true,
    this.customColor,
    this.customTextColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = customColor ??
        (isSecondary ? AppColors.kuningJagung : AppColors.hijauTua);
    final Color fgColor = customTextColor ??
        (isSecondary ? AppColors.teksUtama : Colors.white);

    final Widget btnContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: fgColor),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: fgColor,
          ),
        ),
      ],
    );

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: btnContent,
      ),
    );
  }
}

/// Badge indikator status (Aktif, Selesai, Untung, Rugi, Belum Lengkap)
class TaniBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;

  const TaniBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.hijauPudar;
    Color fg = AppColors.hijauTua;

    final upper = label.toUpperCase();
    if (upper == 'UNTUNG' || upper == 'SELESAI') {
      bg = const Color(0xFFE8F5E9);
      fg = AppColors.untung;
    } else if (upper == 'RUGI') {
      bg = const Color(0xFFFFEBEE);
      fg = AppColors.rugi;
    } else if (upper == 'BELUM LENGKAP' || upper == 'BELUM PANEN') {
      bg = const Color(0xFFFFF3E0);
      fg = AppColors.peringatan;
    } else if (upper == 'AKTIF') {
      bg = const Color(0xFFE0F2FE);
      fg = const Color(0xFF0369A1);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor ?? fg,
        ),
      ),
    );
  }
}

/// Spanduk pemberitahuan mode demo yang transparan
class DemoBanner extends StatelessWidget {
  final bool isDemo;
  const DemoBanner({super.key, required this.isDemo});

  @override
  Widget build(BuildContext context) {
    if (!isDemo) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.kuningPudar,
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.peringatan),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Mode Demo: Menampilkan contoh data usaha tani jagung yang terpisah dari akun produksi.',
              style: TextStyle(fontSize: 12, color: Colors.orange.shade900),
            ),
          ),
        ],
      ),
    );
  }
}
