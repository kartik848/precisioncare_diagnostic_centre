import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/app_notification.dart';
import '../../../providers/admin_provider.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class SendPatientReminderDialog extends StatefulWidget {
  final String? initialUserId;
  final String? initialPatientName;

  const SendPatientReminderDialog({
    super.key,
    this.initialUserId,
    this.initialPatientName,
  });

  @override
  State<SendPatientReminderDialog> createState() => _SendPatientReminderDialogState();
}

class _SendPatientReminderDialogState extends State<SendPatientReminderDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _sendToAllUsers = true;
  late TextEditingController _patientIdController;
  final _titleController = TextEditingController(text: '🔔 Annual Preventive Health Screening Due');
  final _messageController = TextEditingController(
    text: 'Dear Patient, your annual preventive full body health checkup is due. Book your home visit slot now and get free blood sample collection.',
  );

  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _sendToAllUsers = widget.initialUserId == null;
    _patientIdController = TextEditingController(text: widget.initialUserId ?? '');
  }

  @override
  void dispose() {
    _patientIdController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _applyTemplate(String title, String message) {
    setState(() {
      _titleController.text = title;
      _messageController.text = message;
    });
  }

  Future<void> _handleSend() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    final admin = context.read<AdminProvider>();

    if (_sendToAllUsers) {
      final count = await admin.broadcastReminderToAllPatients(
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: NotificationType.nextTestDue,
      );

      if (!mounted) return;
      setState(() => _isSending = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('📢 Broadcast reminder sent to all registered patients ($count total)!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      final success = await admin.sendPatientReminder(
        userId: _patientIdController.text.trim(),
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        type: NotificationType.nextTestDue,
      );

      if (!mounted) return;
      setState(() => _isSending = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Personalized test reminder dispatched to patient!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPatients = context.watch<AdminProvider>().usersList.length;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(22),
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.campaign_rounded, color: AppColors.accent, size: 26),
                        SizedBox(width: 8),
                        Text(
                          'Push Patient Reminder & Advisory',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 10),

                // Audience Target Switcher
                const Text('Select Target Audience:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _sendToAllUsers = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _sendToAllUsers ? AppColors.accent : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _sendToAllUsers ? AppColors.accent : AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.groups_rounded, size: 18, color: _sendToAllUsers ? Colors.white : AppColors.textPrimary),
                              const SizedBox(width: 6),
                              Text(
                                'All Patients ($totalPatients)',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: _sendToAllUsers ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _sendToAllUsers = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: !_sendToAllUsers ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: !_sendToAllUsers ? AppColors.primary : AppColors.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_rounded, size: 18, color: !_sendToAllUsers ? Colors.white : AppColors.textPrimary),
                              const SizedBox(width: 6),
                              Text(
                                'Single Patient',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: !_sendToAllUsers ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                if (_sendToAllUsers)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accent),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This announcement will be pushed to ALL registered patient apps and highlighted on their Home Screens.',
                            style: TextStyle(fontSize: 11, color: Color(0xFFC2410C), fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  CustomTextField(
                    controller: _patientIdController,
                    label: 'Target Patient ID / UID *',
                    hint: 'e.g. user_1700000000000',
                    prefixIcon: Icons.person_pin_circle_outlined,
                    validator: (v) => !_sendToAllUsers && (v == null || v.trim().isEmpty) ? 'Enter Patient ID' : null,
                  ),
                ],
                const SizedBox(height: 14),

                // Quick Clinical Templates
                const Text('Quick Reminder Templates:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.favorite_rounded, size: 14, color: AppColors.primary),
                        label: const Text('Annual Checkup', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        onPressed: () => _applyTemplate(
                          '🩺 Annual Preventive Health Screening Due',
                          'Dear Patient, your annual preventive full body health checkup is due. Book your home visit slot now and get free blood sample collection.',
                        ),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Icon(Icons.water_drop_rounded, size: 14, color: AppColors.bloodTestBadge),
                        label: const Text('Diabetes HbA1c', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        onPressed: () => _applyTemplate(
                          '🩸 3-Month Diabetes & HbA1c Follow-Up Due',
                          'Quarterly HbA1c & Fasting Glucose follow-up is due. Book certified home sample collection to maintain optimal sugar monitoring.',
                        ),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Icon(Icons.monitor_heart_rounded, size: 14, color: AppColors.ecgBadge),
                        label: const Text('Cardiac & Lipid', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        onPressed: () => _applyTemplate(
                          '💓 Routine Lipid & ECG Review Due',
                          'Your 6-month Lipid Profile and 12-Lead ECG review is due as per clinical guidelines. Schedule a doorstep appointment.',
                        ),
                      ),
                      const SizedBox(width: 6),
                      ActionChip(
                        avatar: const Icon(Icons.shield_rounded, size: 14, color: AppColors.success),
                        label: const Text('Health Camp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                        onPressed: () => _applyTemplate(
                          '🎉 Free Home Sample Collection Drive',
                          'PrecisionCare is offering ZERO home visit charges on all blood tests & health packages this week. Book today!',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reminder Title
                CustomTextField(
                  controller: _titleController,
                  label: 'Reminder Alert Title *',
                  prefixIcon: Icons.title_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 12),

                // Reminder Message
                CustomTextField(
                  controller: _messageController,
                  label: 'Reminder Message Details *',
                  prefixIcon: Icons.message_outlined,
                  maxLines: 3,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter message' : null,
                ),
                const SizedBox(height: 20),

                // Send CTA
                CustomButton(
                  text: _sendToAllUsers ? '📢 Broadcast to All Patients' : 'Dispatch to Patient',
                  isLoading: _isSending,
                  onPressed: _handleSend,
                  icon: _sendToAllUsers ? Icons.campaign_rounded : Icons.send_rounded,
                  backgroundColor: AppColors.accent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
