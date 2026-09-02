import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/promo_banner.dart';
import '../../../providers/admin_provider.dart';
import '../../../providers/catalog_provider.dart';
import '../../../services/imgbb_service.dart';
import '../../../widgets/app_image_view.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';

class EditBannerDialog extends StatefulWidget {
  final PromoBanner banner;

  const EditBannerDialog({super.key, required this.banner});

  @override
  State<EditBannerDialog> createState() => _EditBannerDialogState();
}

class _EditBannerDialogState extends State<EditBannerDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _badgeController;
  late TextEditingController _actionTextController;

  String? _uploadedImageUrl;
  bool _isActive = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.banner.title);
    _subtitleController = TextEditingController(text: widget.banner.subtitle);
    _badgeController = TextEditingController(text: widget.banner.badge);
    _actionTextController = TextEditingController(text: widget.banner.actionText);
    _uploadedImageUrl = widget.banner.imageUrl;
    _isActive = widget.banner.isActive;

    _titleController.addListener(() => setState(() {}));
    _subtitleController.addListener(() => setState(() {}));
    _badgeController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _badgeController.dispose();
    _actionTextController.dispose();
    super.dispose();
  }

  Future<void> _handleDirectDeviceUpload() async {
    final url = await ImgBBService.pickImageDirectFromFile(
      imageName: 'precisioncare_banner_${DateTime.now().millisecondsSinceEpoch}',
    );

    if (!mounted) return;
    setState(() {
      _isUploading = false;
      if (url != null) {
        _uploadedImageUrl = url;
      }
    });

    if (url != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Banner photo uploaded to ImgBB successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.banner.copyWith(
      title: _titleController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      badge: _badgeController.text.trim(),
      actionText: _actionTextController.text.trim(),
      imageUrl: _uploadedImageUrl,
      isActive: _isActive,
    );

    await context.read<AdminProvider>().addOrUpdateBanner(updated);
    if (mounted) {
      context.read<CatalogProvider>().loadBanners();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Banner "${updated.title}" updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.view_carousel_rounded, color: AppColors.primary, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Edit Promotional Banner',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 10),

                // Live Banner Visual Preview Box
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: _uploadedImageUrl == null
                        ? const LinearGradient(
                            colors: [Color(0xFF0E8388), Color(0xFF2E4F4F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    image: _uploadedImageUrl != null
                        ? DecorationImage(
                            image: getAppImageProvider(_uploadedImageUrl)!,
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.35), BlendMode.darken),
                          )
                        : null,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _badgeController.text.isNotEmpty ? _badgeController.text : 'OFFER',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text.isNotEmpty ? _titleController.text : 'Promotional Headline',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _subtitleController.text.isNotEmpty ? _subtitleController.text : 'Special offer details...',
                            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Banner Aspect Ratio & Size Guidance Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.aspect_ratio_rounded, size: 17, color: Color(0xFF16A34A)),
                          SizedBox(width: 8),
                          Text(
                            'Required Banner Image Ratio: 2:1 (or 16:9)',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF15803D),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        '• Best Quality: 1200 x 600 px (Exact 2:1 Ratio)\n• Standard Size: 1080 x 540 px (2:1 Ratio)\n• HD Landscape: 1280 x 720 px (16:9 Ratio)\n• Graphic Tip: Keep illustrations/photos on the RIGHT side so left headline text stays readable.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF166534), height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Direct File Upload from Device Button (ImgBB API)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryLight),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Banner Image (ImgBB API)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                            ),
                            Text(
                              _uploadedImageUrl != null ? '✅ Photo Uploaded & Linked' : 'Recommended: 1200 x 600 px (2:1 Ratio)',
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      if (_isUploading)
                        const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                      else ...[
                        ElevatedButton.icon(
                          onPressed: _handleDirectDeviceUpload,
                          icon: const Icon(Icons.file_upload_outlined, size: 14, color: Colors.white),
                          label: Text(_uploadedImageUrl != null ? 'Change Photo' : 'Upload Photo', style: const TextStyle(fontSize: 11, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                        ),
                        if (_uploadedImageUrl != null) ...[
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            tooltip: 'Remove photo (Use gradient)',
                            onPressed: () => setState(() => _uploadedImageUrl = null),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                CustomTextField(
                  controller: _titleController,
                  label: 'Banner Main Headline *',
                  hint: 'e.g. Free Home Sample Collection',
                  prefixIcon: Icons.title_rounded,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter headline' : null,
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _subtitleController,
                  label: 'Subtitle / Offer Details *',
                  hint: 'e.g. Flat 20% OFF on Full Body Master Checkup',
                  prefixIcon: Icons.subtitles_outlined,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter subtitle' : null,
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _badgeController,
                        label: 'Badge Tag',
                        hint: 'POPULAR OFFER',
                        prefixIcon: Icons.bookmark_border_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomTextField(
                        controller: _actionTextController,
                        label: 'CTA Button Text',
                        hint: 'Book Blood Test',
                        prefixIcon: Icons.touch_app_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show Banner in Patient App', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                const SizedBox(height: 16),

                CustomButton(
                  text: 'Save & Publish Banner',
                  onPressed: _handleSave,
                  icon: Icons.check_circle_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
