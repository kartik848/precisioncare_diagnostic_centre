import 'package:flutter/material.dart';

class TataQuickActions extends StatelessWidget {
  final VoidCallback onFullBodyTap;
  final VoidCallback onCallTap;
  final VoidCallback onWhatsAppTap;
  final VoidCallback onUploadPrescriptionTap;

  const TataQuickActions({
    super.key,
    required this.onFullBodyTap,
    required this.onCallTap,
    required this.onWhatsAppTap,
    required this.onUploadPrescriptionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 13, color: Color(0xFFD97706)),
                  SizedBox(width: 3),
                  Text(
                    'POPULAR QUICK ACTIONS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB45309),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 1. Full Body Packages
            Expanded(
              child: _buildTataActionCard(
                tag: 'UPTO 60% OFF',
                tagBg: const Color(0xFFFFEDD5),
                tagColor: const Color(0xFFC2410C),
                title: 'Full Body\nPackages',
                subtitle: '80+ Vital Tests',
                icon: Icons.health_and_safety_rounded,
                iconBg: const Color(0xFFFFE8D6),
                iconColor: const Color(0xFFEA580C),
                cardGradient: const [Color(0xFFFFF7ED), Color(0xFFFFFFFF)],
                borderColor: const Color(0xFFFED7AA),
                onTap: onFullBodyTap,
              ),
            ),
            const SizedBox(width: 10),

            // 2. Book via Call
            Expanded(
              child: _buildTataActionCard(
                tag: '24x7 HELPLINE',
                tagBg: const Color(0xFFDBEAFE),
                tagColor: const Color(0xFF1D4ED8),
                title: 'Book via\nDirect Call',
                subtitle: 'Instant Lab Desk',
                icon: Icons.phone_in_talk_rounded,
                iconBg: const Color(0xFFE0E7FF),
                iconColor: const Color(0xFF2563EB),
                cardGradient: const [Color(0xFFEFF6FF), Color(0xFFFFFFFF)],
                borderColor: const Color(0xFFBFDBFE),
                onTap: onCallTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 3. Book via WhatsApp
            Expanded(
              child: _buildTataActionCard(
                tag: 'QUICK 2-MIN',
                tagBg: const Color(0xFFDCFCE7),
                tagColor: const Color(0xFF15803D),
                title: 'Book via\nWhatsApp',
                subtitle: 'Direct Chat Slot',
                icon: Icons.chat_rounded,
                iconBg: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF059669),
                cardGradient: const [Color(0xFFF0FDF4), Color(0xFFFFFFFF)],
                borderColor: const Color(0xFFBBF7D0),
                onTap: onWhatsAppTap,
              ),
            ),
            const SizedBox(width: 10),

            // 4. Upload Prescription
            Expanded(
              child: _buildTataActionCard(
                tag: '1-TAP ORDER',
                tagBg: const Color(0xFFF3E8FF),
                tagColor: const Color(0xFF7E22CE),
                title: 'Upload\nPrescription',
                subtitle: 'Call in 15 mins',
                icon: Icons.document_scanner_rounded,
                iconBg: const Color(0xFFEDE9FE),
                iconColor: const Color(0xFF7C3AED),
                cardGradient: const [Color(0xFFFAF5FF), Color(0xFFFFFFFF)],
                borderColor: const Color(0xFFE9D5FF),
                onTap: onUploadPrescriptionTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTataActionCard({
    required String tag,
    required Color tagBg,
    required Color tagColor,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required List<Color> cardGradient,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: cardGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: tagColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF94A3B8)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
