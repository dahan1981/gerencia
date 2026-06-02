import 'package:flutter/material.dart';

import '../core/app_sections.dart';
import '../core/app_theme.dart';
import '../models/app_models.dart';
import 'layout_widgets.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({
    super.key,
    required this.current,
    required this.profile,
    required this.closeOnSelect,
    required this.onSelected,
  });

  final AppSection current;
  final UserProfile profile;
  final bool closeOnSelect;
  final ValueChanged<AppSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  const _SidebarLabel('Principal'),
                  _NavTile(
                    section: AppSection.agenda,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                  _NavTile(
                    section: AppSection.recepcao,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                    badge: '2',
                  ),
                  _NavTile(
                    section: AppSection.clientes,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                  const _SidebarLabel('Documentos'),
                  _NavTile(
                    section: AppSection.ci,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                  _NavTile(
                    section: AppSection.oficios,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                  _NavTile(
                    section: AppSection.resolucoes,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                  const _SidebarLabel('Organizacao'),
                  _NavTile(
                    section: AppSection.projetos,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                  _NavTile(
                    section: AppSection.setores,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                  _NavTile(
                    section: AppSection.fluxograma,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                  _NavTile(
                    section: AppSection.codimm,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                  const _SidebarLabel('Sistema'),
                  _NavTile(
                    section: AppSection.usuarios,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                  _NavTile(
                    section: AppSection.perfil,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                  _NavTile(
                    section: AppSection.auditoria,
                    current: current,
                    closeOnSelect: closeOnSelect,
                    onTap: onSelected,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            InkWell(
              onTap: () {
                onSelected(AppSection.perfil);
                if (closeOnSelect) Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.role,
                      style:
                          const TextStyle(fontSize: 11, color: AppColors.gray),
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.logout, size: 14, color: AppColors.rose),
                        SizedBox(width: 4),
                        Text(
                          'Sair',
                          style: TextStyle(fontSize: 11, color: AppColors.rose),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarLabel extends StatelessWidget {
  const _SidebarLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: AppColors.gray,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.section,
    required this.current,
    required this.closeOnSelect,
    required this.onTap,
    this.badge,
  });

  final AppSection section;
  final AppSection current;
  final bool closeOnSelect;
  final ValueChanged<AppSection> onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final active = section == current;
    return InkWell(
      onTap: () {
        onTap(section);
        if (closeOnSelect) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: active ? AppColors.roseLight : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: active ? AppColors.rose : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
        child: Row(
          children: [
            Icon(
              section.icon,
              size: 18,
              color: active ? AppColors.roseDark : AppColors.grayDark,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                section.title,
                style: TextStyle(
                  fontSize: 13,
                  color: active ? AppColors.roseDark : const Color(0xFF666666),
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (badge != null) AppBadge(text: badge!),
          ],
        ),
      ),
    );
  }
}
