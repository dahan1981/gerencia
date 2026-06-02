import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.profile,
    required this.radius,
    required this.fontSize,
  });

  final UserProfile profile;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final path = profile.photoPath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: profile.avatarColor,
        backgroundImage: FileImage(File(path)),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: profile.avatarColor,
      child: Text(
        profile.initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AvatarEditResult {
  const AvatarEditResult({
    required this.initials,
    required this.avatarColor,
    required this.photoPath,
  });

  final String initials;
  final Color avatarColor;
  final String? photoPath;
}

class AvatarEditDialog extends StatefulWidget {
  const AvatarEditDialog({
    super.key,
    required this.initials,
    required this.avatarColor,
    required this.photoPath,
    required this.colors,
  });

  final String initials;
  final Color avatarColor;
  final String? photoPath;
  final List<Color> colors;

  @override
  State<AvatarEditDialog> createState() => _AvatarEditDialogState();
}

class _AvatarEditDialogState extends State<AvatarEditDialog> {
  late final TextEditingController initialsController;
  late String initials;
  late Color avatarColor;
  String? photoPath;

  @override
  void initState() {
    super.initState();
    initials = widget.initials;
    avatarColor = widget.avatarColor;
    photoPath = widget.photoPath;
    initialsController = TextEditingController(text: initials);
  }

  @override
  void dispose() {
    initialsController.dispose();
    super.dispose();
  }

  Future<void> pickPhoto() async {
    try {
      const imageGroup = XTypeGroup(
        label: 'Imagens',
        extensions: ['jpg', 'jpeg', 'png', 'webp'],
        mimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
      );
      final image = await openFile(acceptedTypeGroups: [imageGroup]);
      if (image == null) return;

      final appDir = await getApplicationSupportDirectory();
      final profileDir =
          Directory('${appDir.path}${Platform.pathSeparator}profile');
      if (!profileDir.existsSync()) {
        profileDir.createSync(recursive: true);
      }

      final extension = image.name.contains('.')
          ? image.name.substring(image.name.lastIndexOf('.'))
          : '.jpg';
      final targetPath =
          '${profileDir.path}${Platform.pathSeparator}funcionario_foto$extension';
      final imageBytes = await image.readAsBytes();
      await File(targetPath).writeAsBytes(imageBytes, flush: true);

      if (!mounted) return;
      setState(() => photoPath = targetPath);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto carregada no perfil.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel escolher a foto: $error')),
      );
    }
  }

  UserProfile previewProfile() {
    return UserProfile(
      fullName: '',
      cpf: '',
      birthDate: '',
      email: '',
      phone: '',
      role: '',
      sector: '',
      registration: '',
      initials: initials.isEmpty ? widget.initials : initials,
      avatarColor: avatarColor,
      photoPath: photoPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar foto do perfil'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UserAvatar(profile: previewProfile(), radius: 46, fontSize: 24),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: pickPhoto,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Escolher foto'),
              ),
              if (photoPath != null && photoPath!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  photoPath!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.gray),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => photoPath = null),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Remover foto'),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                maxLength: 3,
                decoration: const InputDecoration(labelText: 'Iniciais'),
                controller: initialsController,
                onChanged: (value) {
                  final normalized = value.trim().toUpperCase();
                  final limit = normalized.length > 3 ? 3 : normalized.length;
                  setState(() => initials = normalized.substring(0, limit));
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final color in widget.colors)
                    InkWell(
                      borderRadius: BorderRadius.circular(24),
                      onTap: () => setState(() => avatarColor = color),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: color,
                        child: avatarColor == color
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.of(context).pop(
            AvatarEditResult(
              initials: initials,
              avatarColor: avatarColor,
              photoPath: photoPath,
            ),
          ),
          icon: const Icon(Icons.check),
          label: const Text('Aplicar'),
        ),
      ],
    );
  }
}
