import 'dart:io';

import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/validators.dart';
import '../models/app_models.dart';
import '../widgets/dialog_widgets.dart';
import '../widgets/form_widgets.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/search_widgets.dart';
import '../widgets/status_widgets.dart';

class ClientsPage extends StatelessWidget {
  const ClientsPage({
    super.key,
    required this.visits,
    required this.onVisitStatus,
  });

  final List<VisitRecord> visits;
  final void Function(VisitRecord visit, String status, [String? denialReason])
      onVisitStatus;

  @override
  Widget build(BuildContext context) {
    final clients = groupedClients();
    final totalVisits = clients.fold<int>(
      0,
      (total, client) => total + client.visits.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          icon: Icons.people_alt_outlined,
          title: 'Clientes',
          subtitle: 'Pessoas cadastradas pela recepcao e historico de visitas',
        ),
        const SizedBox(height: 18),
        const LgpdBanner(
          text:
              'Historico de clientes usa dados coletados na recepcao para controle de acesso, atendimento presencial e rastreabilidade.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 180,
              child: MetricCard(
                label: 'Clientes',
                value: '${clients.length}',
                sub: 'pessoas cadastradas',
              ),
            ),
            SizedBox(
              width: 180,
              child: MetricCard(
                label: 'Visitas',
                value: '$totalVisits',
                sub: 'historico total',
              ),
            ),
            SizedBox(
              width: 180,
              child: MetricCard(
                label: 'Pendentes',
                value: '${visits.where((visit) => visit.pending).length}',
                sub: 'aguardando retorno',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SearchRow(
                  hint: 'Buscar por cliente, documento ou setor...'),
              const SizedBox(height: 12),
              if (clients.isEmpty)
                const EmptyState(
                  icon: Icons.people_alt_outlined,
                  title: 'Nenhum cliente cadastrado',
                  subtitle:
                      'Registros feitos pela recepcao aparecerao aqui automaticamente.',
                  compact: true,
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final compact = constraints.maxWidth < 720;
                    return Column(
                      children: [
                        for (final client in clients) ...[
                          ClientRow(
                            client: client,
                            compact: compact,
                            onVisitStatus: onVisitStatus,
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

  List<ClientRecord> groupedClients() {
    final grouped = <String, List<VisitRecord>>{};
    for (final visit in visits) {
      final key = '${visit.name.trim().toLowerCase()}|${visit.document.trim()}';
      grouped.putIfAbsent(key, () => []).add(visit);
    }

    final clients = grouped.values.map((records) {
      records.sort((a, b) => b.time.compareTo(a.time));
      return ClientRecord(records.first, List.unmodifiable(records));
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return clients;
  }
}

class ClientRecord {
  const ClientRecord(this.latestVisit, this.visits);

  final VisitRecord latestVisit;
  final List<VisitRecord> visits;

  String get name => latestVisit.name;
  String get document => latestVisit.document;
  String get sector => latestVisit.sector;
  String get target => latestVisit.target;
  String get status => latestVisit.status;
  String get time => latestVisit.time;
  String? get photoPath => latestVisit.photoPath;
}

class ClientRow extends StatelessWidget {
  const ClientRow({
    super.key,
    required this.client,
    required this.compact,
    required this.onVisitStatus,
  });

  final ClientRecord client;
  final bool compact;
  final void Function(VisitRecord visit, String status, [String? denialReason])
      onVisitStatus;

  @override
  Widget build(BuildContext context) {
    final avatar = ClientAvatar(path: client.photoPath, name: client.name);
    final identity = Row(
      children: [
        avatar,
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              Text(
                client.document,
                style: const TextStyle(fontSize: 12, color: AppColors.gray),
              ),
            ],
          ),
        ),
      ],
    );

    final meta = Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        _MetaText(label: 'Ultimo setor', value: client.sector),
        _MetaText(label: 'Para', value: client.target),
        _MetaText(label: 'Ultima visita', value: client.time),
      ],
    );

    return InkWell(
      key: ValueKey('client-row-${client.name}-${client.document}'),
      onTap: () => openClientDetail(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: compact
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  identity,
                  const SizedBox(height: 10),
                  meta,
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusPill(
                        label: '${client.visits.length} visita(s)',
                        color: AppColors.rose,
                      ),
                      StatusPill(
                        label: client.status,
                        color: statusColor(client.status),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(flex: 3, child: identity),
                  Expanded(flex: 4, child: meta),
                  StatusPill(
                    label: '${client.visits.length} visita(s)',
                    color: AppColors.rose,
                  ),
                  const SizedBox(width: 8),
                  StatusPill(
                    label: client.status,
                    color: statusColor(client.status),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.gray),
                ],
              ),
      ),
    );
  }

  void openClientDetail(BuildContext context) {
    openClientHistory(context, client, onVisitStatus);
  }
}

void openClientHistory(
  BuildContext context,
  ClientRecord client,
  void Function(VisitRecord visit, String status, [String? denialReason])
      onVisitStatus,
) {
  showDialog<void>(
    context: context,
    builder: (context) => ClientHistoryDialog(
      client: client,
      onVisitStatus: onVisitStatus,
    ),
  );
}

class ClientAvatar extends StatelessWidget {
  const ClientAvatar({super.key, required this.path, required this.name});

  final String? path;
  final String name;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        path != null && path!.isNotEmpty && File(path!).existsSync();
    return Container(
      width: 42,
      height: 42,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.roseLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: hasPhoto
          ? Image.file(File(path!), fit: BoxFit.cover)
          : Center(
              child: Text(
                initials(name),
                style: const TextStyle(
                  color: AppColors.roseDark,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
    );
  }

  String initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '--';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

class ClientHistoryDialog extends StatefulWidget {
  const ClientHistoryDialog({
    super.key,
    required this.client,
    required this.onVisitStatus,
  });

  final ClientRecord client;
  final void Function(VisitRecord visit, String status, [String? denialReason])
      onVisitStatus;

  @override
  State<ClientHistoryDialog> createState() => _ClientHistoryDialogState();
}

class _ClientHistoryDialogState extends State<ClientHistoryDialog> {
  late List<VisitRecord> visits;

  @override
  void initState() {
    super.initState();
    visits = List.of(widget.client.visits);
  }

  VisitRecord get latestVisit => visits.first;

  void acceptVisit(VisitRecord visit) {
    widget.onVisitStatus(visit, 'Aceito');
    replaceVisit(visit, visit.copyWith(status: 'Aceito', pending: false));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Visita de ${visit.name} aceita.')),
    );
  }

  Future<void> denyVisit(VisitRecord visit) async {
    final reason = await showAppDialog<String>(
      context,
      const _ClientDenyDialog(),
    );
    if (reason == null || reason.isEmpty) return;
    widget.onVisitStatus(visit, 'Negado', reason);
    replaceVisit(
      visit,
      visit.copyWith(status: 'Negado', pending: false, denialReason: reason),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Visita de ${visit.name} negada.')),
    );
  }

  void replaceVisit(VisitRecord current, VisitRecord updated) {
    setState(() {
      final index = visits.indexOf(current);
      if (index == -1) return;
      visits[index] = updated;
      visits.sort((a, b) => b.time.compareTo(a.time));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClientAvatar(
                    path: widget.client.photoPath,
                    name: widget.client.name,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.client.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          widget.client.document,
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
                  _InfoBox(
                      label: 'Total de visitas', value: '${visits.length}'),
                  _InfoBox(label: 'Ultimo setor', value: latestVisit.sector),
                  _InfoBox(label: 'Ultimo status', value: latestVisit.status),
                  _InfoBox(label: 'Ultimo horario', value: latestVisit.time),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 360),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Historico do cliente',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final visit in visits)
                          _VisitHistoryItem(
                            visit: visit,
                            onAccept:
                                visit.pending ? () => acceptVisit(visit) : null,
                            onDeny:
                                visit.pending ? () => denyVisit(visit) : null,
                          ),
                      ],
                    ),
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

class _VisitHistoryItem extends StatelessWidget {
  const _VisitHistoryItem({
    required this.visit,
    this.onAccept,
    this.onDeny,
  });

  final VisitRecord visit;
  final VoidCallback? onAccept;
  final VoidCallback? onDeny;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: visit.pending ? onAccept : null,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: visit.pending ? AppColors.roseLight : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: visit.pending
                  ? AppColors.rose.withValues(alpha: 0.35)
                  : AppColors.border,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 560;
              final details = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.door_front_door_outlined,
                      color: AppColors.rose, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${visit.sector} - ${visit.target}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${visit.document} - ${visit.time}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.gray),
                        ),
                        Text(
                          'Foi falar com ${visit.target}, setor ${visit.sector}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.grayDark),
                        ),
                        Text(
                          'Motivo da visita: ${visit.visitReason}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.grayDark),
                        ),
                        if (visit.denialReason != null &&
                            visit.denialReason!.isNotEmpty)
                          Text(
                            'Motivo: ${visit.denialReason}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFA32D2D),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
              final statusAndActions = Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: compact ? WrapAlignment.start : WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusPill(
                      label: visit.status, color: statusColor(visit.status)),
                  if (visit.pending) ...[
                    FilledButton.icon(
                      onPressed: onAccept,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Aceitar'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onDeny,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Negar'),
                    ),
                  ],
                ],
              );
              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    details,
                    const SizedBox(height: 10),
                    statusAndActions,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: details),
                  const SizedBox(width: 12),
                  statusAndActions,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ClientDenyDialog extends StatefulWidget {
  const _ClientDenyDialog();

  @override
  State<_ClientDenyDialog> createState() => _ClientDenyDialogState();
}

class _ClientDenyDialogState extends State<_ClientDenyDialog> {
  final reason = TextEditingController();

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogScaffold(
      title: 'Negar visita',
      actionLabel: 'Registrar negativa',
      actionIcon: Icons.close,
      onSubmit: () {
        if (!FormValidators.hasText(reason.text)) {
          showInlineError(context, 'Informe o motivo da negativa.');
          return;
        }
        Navigator.of(context).pop(reason.text.trim());
      },
      children: [
        AppTextField(
          label: 'Justificativa obrigatoria',
          hint: 'Informe o motivo para o historico',
          controller: reason,
          maxLines: 3,
        ),
      ],
    );
  }
}
