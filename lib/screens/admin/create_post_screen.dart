import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/post_provider.dart';
import '../../services/storage_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/common/app_snackbar.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'upcoming';
  DateTime? _eventDate;
  File? _imageFile;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2040),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryDark,
            surface: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _eventDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await StorageService().uploadPostImage(_imageFile!);
      }
      if (!mounted) return;
      await context.read<PostProvider>().createPost(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty
            ? null
            : _descCtrl.text.trim(),
        date: _eventDate,
        imageUrl: imageUrl,
        type: _type,
      );
      if (!mounted) return;
      AppSnackbar.show(
        context: context,
        type: AppSnackbarType.success,
        title: 'Success',
        message: 'Post created successfully.',
      );
      _titleCtrl.clear();
      _descCtrl.clear();
      setState(() {
        _type = 'upcoming';
        _eventDate = null;
        _imageFile = null;
      });
    } catch (e) {
      if (mounted) {
        AppSnackbar.show(
          context: context,
          type: AppSnackbarType.error,
          title: 'Create Post Failed',
          message: e.toString().replaceAll('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading,
      message: 'Publishing post...',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Create Post',
              style: AppText.titleMd.copyWith(color: AppColors.textOnDark)),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Type toggle
              Row(
                children: [
                  Expanded(
                    child: _TypeButton(
                      label: '🗓 Upcoming',
                      selected: _type == 'upcoming',
                      onTap: () => setState(() => _type = 'upcoming'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TypeButton(
                      label: '🏆 Recent',
                      selected: _type == 'recent',
                      onTap: () => setState(() => _type = 'recent'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha:0.3),
                        style: BorderStyle.solid),
                    image: _imageFile != null
                        ? DecorationImage(
                            image: FileImage(_imageFile!),
                            fit: BoxFit.cover)
                        : null,
                  ),
                  child: _imageFile == null
                      ?  Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined,
                                color: AppColors.textOnDark30, size: 48),
                            SizedBox(height: 8),
                            Text('Tap to add image',
                                style: AppText.s.copyWith(color: AppColors.textHint)),
                          ],
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(_imageFile!,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _imageFile = null),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.textPrimary.withValues(alpha: 0.54),
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: const Icon(Icons.close,
                                      color: AppColors.textOnDark, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Title
              TextFormField(
                controller: _titleCtrl,
                style: AppText.body.copyWith(color: AppColors.textOnDark),
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon:
                      Icon(Icons.title, color: AppColors.textHint),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Title is required' : null,
              ),
              const SizedBox(height: 14),
              // Description
              TextFormField(
                controller: _descCtrl,
                style: AppText.body.copyWith(color: AppColors.textOnDark),
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  alignLabelWithHint: true,
                  prefixIcon:
                      Icon(Icons.description_outlined, color: AppColors.textHint),
                ),
              ),
              const SizedBox(height: 14),
              // Date
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.fieldDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.textHint, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        _eventDate == null
                            ? 'Pick event date (optional)'
                            : DateFormat('MMMM d, yyyy').format(_eventDate!),
                        style: TextStyle(
                          color: _eventDate == null
                              ? AppColors.textHint
                              : AppColors.textOnDark,
                        ),
                      ),
                      if (_eventDate != null) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: () => setState(() => _eventDate = null),
                          child: const Icon(Icons.close,
                              color: AppColors.textHint, size: 18),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.publish),
                label: const Text('Publish Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeButton(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha:0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.borderLighter,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppText.m.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}


