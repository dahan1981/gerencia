import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../core/app_data.dart';
import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../core/validators.dart';
import '../models/app_models.dart';
import '../widgets/dialog_widgets.dart';
import '../widgets/form_widgets.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/status_widgets.dart';

class ReceptionPage extends StatelessWidget {
  const ReceptionPage({
    super.key,
    required this.visits,
    required this.onAddVisit,
    required this.onVisitStatus,
  });

  final List<VisitRecord> visits;
  final ValueChanged<VisitRecord> onAddVisit;
  final void Function(VisitRecord visit, String status, [String? denialReason])
      onVisitStatus;

  Future<void> createVisit(BuildContext context) async {
    final visit =
        await showAppDialog<VisitRecord>(context, const VisitorDialog());
    if (visit == null) return;
    onAddVisit(visit);
  }

  @override
  Widget build(BuildContext context) {
    final pendingVisits = visits.where((visit) => visit.pending).toList();
    final todayVisits = visits.where((visit) => !visit.pending).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          icon: Icons.door_front_door_outlined,
          title: 'Recepcao',
          subtitle: 'Registro de entrada e notificacoes',
          action: FilledButton.icon(
            onPressed: () => createVisit(context),
            icon: const Icon(Icons.person_add_alt),
            label: const Text('Registrar visitante'),
          ),
        ),
        const SizedBox(height: 18),
        const LgpdBanner(
          text:
              'Dados pessoais dos visitantes protegidos pela LGPD. Finalidade: controle de acesso.',
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notificacoes de visita pendentes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.roseDark,
                ),
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: pendingVisits.isEmpty
                    ? const EmptyState(
                        icon: Icons.notifications_none_outlined,
                        title: 'Nenhuma visita pendente',
                        subtitle:
                            'Novas solicitacoes aparecerao aqui para aceite ou negativa.',
                        compact: true,
                      )
                    : Column(
                        key: ValueKey(pendingVisits.length),
                        children: [
                          for (var i = 0; i < pendingVisits.length; i++) ...[
                            VisitRequest(
                              visit: pendingVisits[i],
                              onAccept: () =>
                                  onVisitStatus(pendingVisits[i], 'Aceito'),
                              onDeny: () async {
                                final reason = await showAppDialog<String>(
                                  context,
                                  const DenyVisitDialog(),
                                );
                                if (reason != null && reason.isNotEmpty) {
                                  onVisitStatus(
                                      pendingVisits[i], 'Negado', reason);
                                }
                              },
                            ),
                            if (i != pendingVisits.length - 1) const Divider(),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Historico de visitas',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${todayVisits.length} entradas',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  if (todayVisits.isEmpty) {
                    return const EmptyState(
                      icon: Icons.history_outlined,
                      title: 'Nenhuma visita no historico',
                      subtitle:
                          'As entradas aceitas ou negadas aparecerao aqui.',
                      compact: true,
                    );
                  }
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final visit in todayVisits)
                        SizedBox(
                          width: constraints.maxWidth > 760
                              ? (constraints.maxWidth - 12) / 2
                              : double.infinity,
                          child: VisitorCard(
                            name: visit.name,
                            sector: visit.sector,
                            person: visit.target,
                            doc: visit.document,
                            status: '${visit.status} - ${visit.time}',
                            color: statusColor(visit.status),
                            photoPath: visit.photoPath,
                            denialReason: visit.denialReason,
                            visitReason: visit.visitReason,
                            legalBasis: visit.legalBasis,
                            dataPurpose: visit.dataPurpose,
                            lgpdAcknowledged: visit.lgpdAcknowledged,
                          ),
                        ),
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
}

class VisitRequest extends StatelessWidget {
  const VisitRequest({
    super.key,
    required this.visit,
    required this.onAccept,
    required this.onDeny,
  });

  final VisitRecord visit;
  final VoidCallback onAccept;
  final VoidCallback onDeny;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 620;
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              visit.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              'Doc: ${visit.document} - Setor: ${visit.sector} - Para: ${visit.target}',
              style: const TextStyle(fontSize: 11, color: AppColors.gray),
            ),
          ],
        );
        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
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
        );
        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [details, const SizedBox(height: 10), actions],
          );
        }
        return Row(children: [Expanded(child: details), actions]);
      },
    );
  }
}

class VisitorCard extends StatelessWidget {
  const VisitorCard({
    super.key,
    required this.name,
    required this.sector,
    required this.person,
    required this.doc,
    required this.status,
    required this.color,
    this.photoPath,
    this.denialReason,
    required this.visitReason,
    required this.legalBasis,
    required this.dataPurpose,
    required this.lgpdAcknowledged,
  });

  final String name;
  final String sector;
  final String person;
  final String doc;
  final String status;
  final Color color;
  final String? photoPath;
  final String? denialReason;
  final String visitReason;
  final String legalBasis;
  final String dataPurpose;
  final bool lgpdAcknowledged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final avatar = Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.grayLight,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: photoPath != null &&
                  photoPath!.isNotEmpty &&
                  File(photoPath!).existsSync()
              ? Image.file(File(photoPath!), fit: BoxFit.cover)
              : const Icon(
                  Icons.person_outline,
                  color: AppColors.gray,
                  size: 30,
                ),
        );
        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Setor: $sector - $person',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.gray),
            ),
            Text(
              doc,
              style: const TextStyle(fontSize: 11, color: AppColors.gray),
            ),
            Text(
              'Motivo da visita: $visitReason',
              maxLines: compact ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.grayDark),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                StatusPill(label: status, color: color),
              ],
            ),
            if (denialReason != null && denialReason!.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                'Motivo: $denialReason',
                maxLines: compact ? 3 : 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFFA32D2D)),
              ),
            ],
          ],
        );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: compact
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [avatar, const SizedBox(height: 10), details],
                )
              : Row(
                  children: [
                    avatar,
                    const SizedBox(width: 12),
                    Expanded(child: details),
                  ],
                ),
        );
      },
    );
  }
}

class VisitorDialog extends StatefulWidget {
  const VisitorDialog({super.key});

  @override
  State<VisitorDialog> createState() => _VisitorDialogState();
}

class _VisitorDialogState extends State<VisitorDialog> {
  final name = TextEditingController(text: 'Novo visitante');
  final document = TextEditingController(text: '000.000.000-00');
  final type = TextEditingController(text: 'CPF');
  final visitReason = TextEditingController(text: 'Atendimento presencial');
  String selectedSector = 'CREAM';
  late String selectedTarget = usersForSector(selectedSector).first;
  String? photoPath;
  bool lgpdAcknowledged = false;

  @override
  void dispose() {
    name.dispose();
    document.dispose();
    type.dispose();
    visitReason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogScaffold(
      title: 'Registrar visitante',
      actionLabel: 'Registrar e notificar',
      actionIcon: Icons.send,
      onSubmit: () {
        if (!FormValidators.hasText(name.text)) {
          showInlineError(context, 'Informe o nome do visitante.');
          return;
        }
        if (!FormValidators.hasText(document.text)) {
          showInlineError(context, 'Informe o documento do visitante.');
          return;
        }
        if (type.text.trim().toUpperCase() == 'CPF' &&
            !FormValidators.isCpfLike(document.text)) {
          showInlineError(context, 'Informe um CPF valido com 11 digitos.');
          return;
        }
        if (!FormValidators.hasText(selectedSector)) {
          showInlineError(context, 'Informe o setor desejado.');
          return;
        }
        if (!FormValidators.hasText(selectedTarget)) {
          showInlineError(context, 'Informe a pessoa a encontrar.');
          return;
        }
        if (!FormValidators.hasText(visitReason.text)) {
          showInlineError(context, 'Informe o motivo da visita.');
          return;
        }
        if (!lgpdAcknowledged) {
          showInlineError(
            context,
            'Confirme a ciencia da finalidade e tratamento dos dados.',
          );
          return;
        }
        Navigator.of(context).pop(
          VisitRecord(
            name: name.text.trim(),
            document: '${type.text.trim()}: ${document.text.trim()}',
            sector: selectedSector,
            target: selectedTarget,
            status: 'Aguardando',
            time: currentTime(),
            photoPath: photoPath,
            visitReason: visitReason.text.trim(),
            lgpdAcknowledged: lgpdAcknowledged,
            legalBasis: 'Execucao de politica publica',
            dataPurpose: 'Controle de acesso e atendimento presencial',
            pending: true,
          ),
        );
      },
      children: [
        const LgpdBanner(
          text:
              'Dados coletados com base legal LGPD. Finalidade: controle de acesso.',
          dense: true,
        ),
        AppTextField(
          label: 'Nome completo',
          hint: 'Nome do visitante',
          controller: name,
        ),
        AppFormGrid(
          children: [
            AppTextField(
              label: 'Documento',
              hint: '000.000.000-00',
              controller: document,
            ),
            AppTextField(
              label: 'Tipo',
              hint: 'CPF, RG ou CNH',
              controller: type,
            ),
          ],
        ),
        PhotoCaptureBox(
          photoPath: photoPath,
          onPhotoSelected: (value) => setState(() => photoPath = value),
        ),
        AppFormGrid(
          children: [
            AppDropdownField(
              label: 'Setor desejado',
              value: selectedSector,
              options: appSectorNames,
              onChanged: (value) {
                if (value == null) return;
                final users = usersForSector(value);
                setState(() {
                  selectedSector = value;
                  selectedTarget = users.isEmpty ? '' : users.first;
                });
              },
            ),
            AppDropdownField(
              label: 'Pessoa a encontrar',
              value: selectedTarget,
              options: usersForSector(selectedSector),
              onChanged: (value) {
                if (value == null) return;
                setState(() => selectedTarget = value);
              },
            ),
          ],
        ),
        AppTextField(
          label: 'Motivo da visita',
          hint: 'Ex.: Entrega de documento, atendimento, reuniao',
          controller: visitReason,
          maxLines: 2,
        ),
        CheckboxListTile(
          value: lgpdAcknowledged,
          onChanged: (value) =>
              setState(() => lgpdAcknowledged = value ?? false),
          dense: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'O visitante foi informado sobre a finalidade do cadastro, controle de acesso, atendimento presencial e registro de historico conforme LGPD.',
            style: TextStyle(fontSize: 12, color: AppColors.grayDark),
          ),
        ),
      ],
    );
  }
}

class DenyVisitDialog extends StatefulWidget {
  const DenyVisitDialog({super.key});

  @override
  State<DenyVisitDialog> createState() => _DenyVisitDialogState();
}

class _DenyVisitDialogState extends State<DenyVisitDialog> {
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
        final value = reason.text.trim();
        if (value.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Informe o motivo da negativa.')),
          );
          return;
        }
        Navigator.of(context).pop(value);
      },
      children: [
        AppTextField(
          label: 'Justificativa obrigatoria',
          hint: 'Informe o motivo da negativa',
          maxLines: 3,
          controller: reason,
        ),
      ],
    );
  }
}

class PhotoCaptureBox extends StatelessWidget {
  const PhotoCaptureBox({
    super.key,
    required this.photoPath,
    required this.onPhotoSelected,
  });

  final String? photoPath;
  final ValueChanged<String?> onPhotoSelected;

  Future<void> pickPhoto(BuildContext context) async {
    try {
      const imageGroup = XTypeGroup(
        label: 'Imagens',
        extensions: ['jpg', 'jpeg', 'png', 'webp'],
        mimeTypes: ['image/jpeg', 'image/png', 'image/webp'],
      );
      final image = await openFile(acceptedTypeGroups: [imageGroup]);
      if (image == null) return;
      onPhotoSelected(image.path);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel carregar a foto: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null &&
        photoPath!.isNotEmpty &&
        File(photoPath!).existsSync();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.gray,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => pickPhoto(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: AppColors.grayLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: hasPhoto
                      ? Image.file(File(photoPath!), fit: BoxFit.cover)
                      : const Icon(Icons.camera_alt_outlined,
                          size: 28, color: AppColors.gray),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasPhoto
                        ? 'Foto carregada. Clique para trocar.'
                        : 'Clique para carregar foto do visitante',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray),
                  ),
                ),
                if (hasPhoto)
                  IconButton(
                    tooltip: 'Remover foto',
                    onPressed: () => onPhotoSelected(null),
                    icon: const Icon(Icons.close, size: 18),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
