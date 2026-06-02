import 'package:flutter/material.dart';

import '../core/app_data.dart';
import '../core/app_theme.dart';
import '../core/validators.dart';
import '../models/app_models.dart';
import '../widgets/avatar_widgets.dart';
import '../widgets/dialog_widgets.dart';
import '../widgets/form_widgets.dart';
import '../widgets/layout_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.profile, required this.onSave});

  final UserProfile profile;
  final ValueChanged<UserProfile> onSave;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final TextEditingController fullName;
  late final TextEditingController cpf;
  late final TextEditingController birthDate;
  late final TextEditingController email;
  late final TextEditingController phone;
  late final TextEditingController role;
  late final TextEditingController registration;
  late String sector;
  late String initials;
  late Color avatarColor;
  String? photoPath;

  static const avatarColors = [
    AppColors.roseDark,
    AppColors.rose,
    AppColors.greenDark,
    Color(0xFF185FA5),
    Color(0xFF6A4C93),
  ];

  @override
  void initState() {
    super.initState();
    fullName = TextEditingController(text: widget.profile.fullName);
    cpf = TextEditingController(text: widget.profile.cpf);
    birthDate = TextEditingController(text: widget.profile.birthDate);
    email = TextEditingController(text: widget.profile.email);
    phone = TextEditingController(text: widget.profile.phone);
    role = TextEditingController(text: widget.profile.role);
    registration = TextEditingController(text: widget.profile.registration);
    sector = widget.profile.sector;
    initials = widget.profile.initials;
    avatarColor = widget.profile.avatarColor;
    photoPath = widget.profile.photoPath;
  }

  @override
  void dispose() {
    fullName.dispose();
    cpf.dispose();
    birthDate.dispose();
    email.dispose();
    phone.dispose();
    role.dispose();
    registration.dispose();
    super.dispose();
  }

  UserProfile currentProfile() {
    return widget.profile.copyWith(
      email: email.text.trim(),
      phone: phone.text.trim(),
      role: role.text.trim(),
      sector: sector,
      registration: registration.text.trim(),
      initials: initials.trim().isEmpty ? widget.profile.initials : initials,
      avatarColor: avatarColor,
      photoPath: photoPath,
    );
  }

  void saveProfile() {
    if (!FormValidators.isEmail(email.text)) {
      showInlineError(context, 'Informe um e-mail institucional valido.');
      return;
    }
    if (!FormValidators.isPhone(phone.text)) {
      showInlineError(context, 'Informe um telefone valido.');
      return;
    }
    if (!FormValidators.hasText(role.text)) {
      showInlineError(context, 'Informe o cargo ou funcao.');
      return;
    }
    if (!FormValidators.hasText(registration.text)) {
      showInlineError(context, 'Informe a matricula.');
      return;
    }
    widget.onSave(currentProfile());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado.')),
    );
  }

  Future<void> editAvatar() async {
    final result = await showDialog<AvatarEditResult>(
      context: context,
      builder: (context) => AvatarEditDialog(
        initials: initials,
        avatarColor: avatarColor,
        photoPath: photoPath,
        colors: avatarColors,
      ),
    );

    if (result == null) return;
    setState(() {
      initials = result.initials.isEmpty ? initials : result.initials;
      avatarColor = result.avatarColor;
      photoPath = result.photoPath;
    });
    widget.onSave(currentProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          icon: Icons.person_outline,
          title: 'Perfil',
          subtitle: 'Informacoes pessoais e acesso',
          action: FilledButton.icon(
            onPressed: saveProfile,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar alteracoes'),
          ),
        ),
        const SizedBox(height: 18),
        const LgpdBanner(
          text:
              'Seu perfil usa dados pessoais para autenticacao, contato institucional, permissao de acesso e auditoria do sistema.',
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 760;
              final profileHeader = Column(
                children: [
                  UserAvatar(
                    profile: widget.profile.copyWith(
                      initials: initials,
                      avatarColor: avatarColor,
                      photoPath: photoPath,
                    ),
                    radius: 54,
                    fontSize: 28,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: editAvatar,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Editar foto'),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Nome completo, CPF e data de nascimento ficam bloqueados por seguranca.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppColors.gray),
                  ),
                ],
              );

              final form = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppFormGrid(
                    children: [
                      AppTextField(
                        label: 'Nome completo',
                        hint: widget.profile.fullName,
                        controller: fullName,
                        enabled: false,
                      ),
                      AppTextField(
                        label: 'CPF',
                        hint: widget.profile.cpf,
                        controller: cpf,
                        enabled: false,
                      ),
                    ],
                  ),
                  AppFormGrid(
                    children: [
                      AppTextField(
                        label: 'Data de nascimento',
                        hint: widget.profile.birthDate,
                        controller: birthDate,
                        enabled: false,
                      ),
                      AppDropdownField(
                        label: 'Setor',
                        value: sector,
                        options: appSectorNames,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() => sector = value);
                        },
                      ),
                    ],
                  ),
                  AppFormGrid(
                    children: [
                      AppTextField(
                        label: 'E-mail institucional',
                        hint: 'usuario@smm.gov.br',
                        controller: email,
                      ),
                      AppTextField(
                        label: 'Telefone',
                        hint: '(21) 99999-0000',
                        controller: phone,
                      ),
                    ],
                  ),
                  AppFormGrid(
                    children: [
                      AppTextField(
                        label: 'Cargo/Funcao',
                        hint: 'Cargo do usuario',
                        controller: role,
                      ),
                      AppTextField(
                        label: 'Matricula',
                        hint: 'Identificacao funcional',
                        controller: registration,
                      ),
                    ],
                  ),
                  const LgpdBanner(
                    text:
                        'Nome completo, CPF e data de nascimento exigem processo administrativo para alteracao. Esses campos ficam bloqueados para reduzir risco de alteracao indevida.',
                    dense: true,
                  ),
                ],
              );

              if (compact) {
                return Column(
                  children: [
                    profileHeader,
                    const SizedBox(height: 22),
                    form,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 230, child: profileHeader),
                  const SizedBox(width: 24),
                  Expanded(child: form),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
