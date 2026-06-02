import 'package:flutter/material.dart';

import '../core/app_data.dart';
import '../core/app_theme.dart';
import '../models/app_models.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/search_widgets.dart';
import '../widgets/status_widgets.dart';

class UsersPage extends StatelessWidget {
  const UsersPage({
    super.key,
    required this.visits,
    required this.documents,
  });

  final List<VisitRecord> visits;
  final List<AppDocument> documents;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          icon: Icons.manage_accounts_outlined,
          title: 'Usuarios',
          subtitle: 'Cadastros, datas de entrada e historico de movimentacoes',
        ),
        const SizedBox(height: 18),
        const LgpdBanner(
          text:
              'Dados de usuarios ficam limitados a identificacao funcional, contato institucional, permissoes e trilha de atividades.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 180,
              child: MetricCard(
                label: 'Cadastrados',
                value: '${appUsers.length}',
                sub: 'usuarios ativos',
              ),
            ),
            SizedBox(
              width: 180,
              child: MetricCard(
                label: 'Setores',
                value: '${appSectorNames.length}',
                sub: 'com acesso',
              ),
            ),
            SizedBox(
              width: 180,
              child: MetricCard(
                label: 'Registros',
                value: '${visits.length + documents.length}',
                sub: 'visitas e pedidos',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SearchRow(hint: 'Buscar por nome, setor ou matricula...'),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 720;
                  return Column(
                    children: [
                      for (final user in appUsers) ...[
                        UserRegistryRow(
                          user: user,
                          compact: compact,
                          visits: visitsForUser(user),
                          requests: requestsForUser(user),
                        ),
                        const Divider(height: 1),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<VisitRecord> visitsForUser(AppUser user) {
    return visits
        .where((visit) =>
            visit.target == user.name ||
            visit.sector == user.sector ||
            visit.name == user.name)
        .toList();
  }

  List<AppDocument> requestsForUser(AppUser user) {
    return documents.where((document) {
      return document.sender == user.name ||
          listTextContainsPerson(document.recipient, user.name) ||
          listTextContainsSector(document.party, user.sector);
    }).toList();
  }
}

class UserRegistryRow extends StatelessWidget {
  const UserRegistryRow({
    super.key,
    required this.user,
    required this.compact,
    required this.visits,
    required this.requests,
  });

  final AppUser user;
  final bool compact;
  final List<VisitRecord> visits;
  final List<AppDocument> requests;

  @override
  Widget build(BuildContext context) {
    final totalHistory = visits.length + requests.length;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.roseLight,
              foregroundColor: AppColors.roseDark,
              child: Text(
                initials(user.name),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${user.role} - ${user.sector}',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (compact) ...[
          const SizedBox(height: 10),
          _UserMeta(user: user),
        ],
      ],
    );

    return InkWell(
      key: ValueKey('user-row-${user.registration}'),
      onTap: () => openUserDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  content,
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusPill(
                        label: '$totalHistory historico',
                        color: AppColors.rose,
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: AppColors.gray,
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 3, child: content),
                  Expanded(flex: 4, child: _UserMeta(user: user)),
                  StatusPill(
                    label: '$totalHistory historico',
                    color: AppColors.rose,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.gray,
                  ),
                ],
              ),
      ),
    );
  }

  String initials(String name) {
    final parts = name
        .replaceAll('Dra.', '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '--';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void openUserDetail(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => UserHistoryDialog(
        user: user,
        visits: visits,
        requests: requests,
      ),
    );
  }
}

class _UserMeta extends StatelessWidget {
  const _UserMeta({required this.user});
  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        _MetaText(label: 'Matricula', value: user.registration),
        _MetaText(label: 'Cadastro', value: user.createdAt),
        _MetaText(label: 'E-mail', value: user.email),
      ],
    );
  }
}

class _MetaText extends StatelessWidget {
  const _MetaText({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$label: ',
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.gray,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: AppColors.grayDark,
            ),
          ),
        ],
      ),
    );
  }
}

class UserHistoryDialog extends StatelessWidget {
  const UserHistoryDialog({
    super.key,
    required this.user,
    required this.visits,
    required this.requests,
  });

  final AppUser user;
  final List<VisitRecord> visits;
  final List<AppDocument> requests;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.manage_accounts_outlined,
                    color: AppColors.rose,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${user.role} - ${user.sector}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _InfoBox(label: 'Data de cadastro', value: user.createdAt),
                  _InfoBox(label: 'Matricula', value: user.registration),
                  _InfoBox(label: 'Telefone', value: user.phone),
                  _InfoBox(label: 'E-mail', value: user.email),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HistorySection(
                        title: 'Visitas relacionadas',
                        emptyText: 'Nenhuma visita relacionada a este usuario.',
                        children: [
                          for (final visit in visits)
                            _HistoryItem(
                              icon: Icons.door_front_door_outlined,
                              title: visit.name,
                              subtitle:
                                  '${visit.document} - ${visit.sector} - ${visit.target} - ${visit.visitReason}',
                              status: '${visit.status} - ${visit.time}',
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _HistorySection(
                        title: 'Pedidos e documentos',
                        emptyText:
                            'Nenhum pedido ou documento relacionado a este usuario.',
                        children: [
                          for (final request in requests)
                            _HistoryItem(
                              icon: request.kind == DocumentKind.ci
                                  ? Icons.forward_to_inbox_outlined
                                  : Icons.description_outlined,
                              title: request.number,
                              subtitle: '${request.subject} - ${request.party}',
                              status: request.status,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check),
                  label: const Text('Entendi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.gray,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grayDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.title,
    required this.emptyText,
    required this.children,
  });

  final String title;
  final String emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (children.isEmpty)
            Text(
              emptyText,
              style: const TextStyle(fontSize: 12, color: AppColors.gray),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.rose, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.gray),
                ),
              ],
            ),
          ),
          StatusPill(label: status, color: statusColor(status)),
        ],
      ),
    );
  }
}
