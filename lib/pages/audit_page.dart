import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/search_widgets.dart';

class AuditPage extends StatelessWidget {
  const AuditPage({super.key});

  Future<void> exportLogs(BuildContext context) async {
    try {
      final location = await getSaveLocation(
        suggestedName: 'auditoria_sistema_gerir.txt',
      );
      if (location == null) return;

      final content = _auditLogs
          .map((log) => '${log.$3} 20/05/26 | ${log.$1} | ${log.$2}')
          .join('\n');
      await File(location.path).writeAsString(content, flush: true);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logs exportados para ${location.path}')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel exportar os logs: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          icon: Icons.verified_user_outlined,
          title: 'Trilha de Auditoria',
          subtitle: 'Registro completo de acoes no sistema - LGPD',
          action: OutlinedButton.icon(
            onPressed: () => exportLogs(context),
            icon: const Icon(Icons.download),
            label: const Text('Exportar logs'),
          ),
        ),
        const SizedBox(height: 18),
        const LgpdBanner(
          text:
              'Acesso restrito a administradores. Logs registram finalidade, modulo e usuario para rastreabilidade e atendimento de auditoria.',
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: Column(
            children: [
              const SearchRow(hint: 'Buscar por usuario, acao ou modulo...'),
              const SizedBox(height: 12),
              for (final log in _auditLogs)
                AuditRow(
                  title: log.$1,
                  subtitle: log.$2,
                  time: log.$3,
                  icon: log.$4,
                  color: log.$5,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

final _auditLogs = [
  (
    'Login realizado',
    'Dra. Gabriela Santos - IP: 192.168.1.10 - Windows',
    '08:01',
    Icons.login,
    AppColors.green
  ),
  (
    'CI-2026/042 criada',
    'Modulo: CI - Para: Almoxarifado',
    '08:34',
    Icons.note_add_outlined,
    AppColors.rose
  ),
  (
    'Evento editado',
    'Campo: horario - Antes: 09:00 - Depois: 08:30',
    '09:15',
    Icons.edit_outlined,
    AppColors.warning
  ),
  (
    'Visitante registrado',
    'LGPD: ciencia de finalidade registrada - Notificacao enviada',
    '09:10',
    Icons.person_add_alt,
    AppColors.rose
  ),
  (
    'Visita negada',
    'Justificativa: sem agendamento previo',
    '11:31',
    Icons.close,
    const Color(0xFFA32D2D)
  ),
  (
    'Permissao alterada',
    'Usuario: Roberta Faria - Perfil: Recepcao',
    '13:40',
    Icons.admin_panel_settings_outlined,
    const Color(0xFF185FA5)
  ),
];

class AuditRow extends StatelessWidget {
  const AuditRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray),
                ),
              ],
            ),
          ),
          Text(
            '$time\n20/05/26',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 11, color: AppColors.gray),
          ),
        ],
      ),
    );
  }
}
