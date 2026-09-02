import 'package:flutter/material.dart';

class DoctorSpecialistsSection extends StatelessWidget {
  final Function(String category) onSpecialtyTap;

  const DoctorSpecialistsSection({super.key, required this.onSpecialtyTap});

  static final List<Map<String, dynamic>> _doctors = [
    {
      'title': 'Clinical Pathologist',
      'specialty': 'Blood & Lab Tests',
      'badge': 'NABL ACCREDITED',
      'icon': Icons.biotech_rounded,
      'color': const Color(0xFF0284C7),
      'avatarEmoji': '👨‍⚕️',
      'category': 'Blood Tests',
      'bgGradient': [const Color(0xFFE0F2FE), const Color(0xFFF8FAFC)],
      'borderColor': const Color(0xFFBAE6FD),
    },
    {
      'title': 'Senior Cardiologist',
      'specialty': 'ECG, TMT & Heart',
      'badge': 'INSTANT REPORT',
      'icon': Icons.monitor_heart_rounded,
      'color': const Color(0xFFDC2626),
      'avatarEmoji': '🫀',
      'category': 'ECG',
      'bgGradient': [const Color(0xFFFEE2E2), const Color(0xFFF8FAFC)],
      'borderColor': const Color(0xFFFECACA),
    },
    {
      'title': 'Consultant Physio',
      'specialty': 'Ortho & Rehab Therapy',
      'badge': '1-ON-1 SESSIONS',
      'icon': Icons.accessibility_new_rounded,
      'color': const Color(0xFFD97706),
      'avatarEmoji': '🦴',
      'category': 'Physiotherapy',
      'bgGradient': [const Color(0xFFFEF3C7), const Color(0xFFF8FAFC)],
      'borderColor': const Color(0xFFFDE68A),
    },
    {
      'title': 'Chest Pulmonologist',
      'specialty': 'Digital X-Ray & PFT',
      'badge': 'LUNG CAPACITY',
      'icon': Icons.air_rounded,
      'color': const Color(0xFF7C3AED),
      'avatarEmoji': '🫁',
      'category': 'Digital X-Ray',
      'bgGradient': [const Color(0xFFEDE9FE), const Color(0xFFF8FAFC)],
      'borderColor': const Color(0xFFDDD6FE),
    },
    {
      'title': 'Diabetes Specialist',
      'specialty': 'HbA1c & Blood Sugar',
      'badge': 'FASTING / PP',
      'icon': Icons.bloodtype_rounded,
      'color': const Color(0xFFEA580C),
      'avatarEmoji': '🩸',
      'category': 'Blood Tests',
      'bgGradient': [const Color(0xFFFFEDD5), const Color(0xFFF8FAFC)],
      'borderColor': const Color(0xFFFED7AA),
    },
    {
      'title': 'General Physician',
      'specialty': 'Full Body Prevention',
      'badge': '80+ PARAMETERS',
      'icon': Icons.health_and_safety_rounded,
      'color': const Color(0xFF0D9488),
      'avatarEmoji': '🩺',
      'category': 'Full Body Checkups',
      'bgGradient': [const Color(0xFFCCFBF1), const Color(0xFFF8FAFC)],
      'borderColor': const Color(0xFF99F6E4),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consult Specialists & Lab Doctors',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Verified MD Pathologists & Radiologists supervising tests',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _doctors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final doc = _doctors[index];
              return InkWell(
                onTap: () => onSpecialtyTap(doc['category'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: doc['bgGradient'] as List<Color>,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: doc['borderColor'] as Color, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 3D Cartoon Emoji / Icon Circle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (doc['color'] as Color).withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                doc['avatarEmoji'] as String,
                                style: const TextStyle(fontSize: 22),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: (doc['color'] as Color).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              doc['icon'] as IconData,
                              size: 15,
                              color: doc['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['title'] as String,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            doc['specialty'] as String,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(
                          color: (doc['color'] as Color).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            doc['badge'] as String,
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: doc['color'] as Color,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
