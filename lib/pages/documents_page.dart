import 'package:flutter/material.dart';

import '../core/app_data.dart';
import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../core/validators.dart';
import '../models/app_models.dart';
import '../widgets/dialog_widgets.dart';
import '../widgets/document_widgets.dart';
import '../widgets/form_widgets.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/search_widgets.dart';
import '../widgets/status_widgets.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({
    super.key,
    required this.kind,
    required this.profile,
    required this.documents,
    required this.onAddDocument,
  });

  final DocumentKind kind;
  final UserProfile profile;
  final List<AppDocument> documents;
  final ValueChanged<AppDocument> onAddDocument;

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  int tab = 0;
  String selectedParticipant = allAccountsLabel;

  Future<void> createDocument() async {
    final document = await showAppDialog<AppDocument>(
      context,
      DocumentDialog(
        kind: widget.kind,
        profile: widget.profile,
        nextNumber: nextDocumentNumber(widget.kind),
      ),
    );
    if (document == null) return;
    widget.onAddDocument(document);
  }

  String nextDocumentNumber(DocumentKind kind) {
    final prefix = kind == DocumentKind.ci ? 'CI' : 'OF';
    final count =
        widget.documents.where((document) => document.kind == kind).length + 1;
    return '$prefix-2026/${twoDigits(40 + count)}';
  }

  @override
  Widget build(BuildContext context) {
    final isCi = widget.kind == DocumentKind.ci;
    final title = isCi ? 'CI - Comunicacao Interna' : 'Oficios';
    final subtitle = isCi
        ? 'Documentos internos enviados e recebidos'
        : 'Documentos externos enviados e recebidos';
    final icon =
        isCi ? Icons.forward_to_inbox_outlined : Icons.description_outlined;
    final visibleDocuments = widget.documents
        .where((document) =>
            document.kind == widget.kind && document.received == (tab == 1))
        .where((document) {
      if (!isCi || selectedParticipant == allAccountsLabel) return true;
      final participantSector = userSector(selectedParticipant);
      return document.sender == selectedParticipant ||
          listTextContainsPerson(document.recipient, selectedParticipant) ||
          (participantSector.isNotEmpty &&
              listTextContainsSector(document.party, participantSector));
    }).toList();
    final participantCiDocuments = widget.documents
        .where((document) => document.kind == DocumentKind.ci)
        .where((document) {
      if (selectedParticipant == allAccountsLabel) return true;
      final participantSector = userSector(selectedParticipant);
      return document.sender == selectedParticipant ||
          listTextContainsPerson(document.recipient, selectedParticipant) ||
          (participantSector.isNotEmpty &&
              listTextContainsSector(document.party, participantSector));
    }).toList();
    final participantSent = participantCiDocuments
        .where((document) => document.sender == selectedParticipant)
        .length;
    final participantReceived = selectedParticipant == allAccountsLabel
        ? participantCiDocuments.length
        : participantCiDocuments.length - participantSent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          icon: icon,
          title: title,
          subtitle: subtitle,
          action: FilledButton.icon(
            onPressed: createDocument,
            icon: const Icon(Icons.add),
            label: Text(isCi ? 'Nova CI' : 'Novo oficio'),
          ),
        ),
        const SizedBox(height: 18),
        if (!isCi)
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: LgpdBanner(
              text:
                  'Oficios enviados exigem assinatura digital da Dra. Gabriela. Entradas podem ser assinadas por usuarios autorizados.',
            ),
          ),
        if (isCi)
          const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: LgpdBanner(
              text:
                  'CIs exibem remetente, destinatarios e mensagem apenas para usuarios e setores envolvidos no fluxo.',
            ),
          ),
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              icon: Icon(Icons.call_made),
              label: Text('Enviados'),
            ),
            ButtonSegment(
              value: 1,
              icon: Icon(Icons.call_received),
              label: Text('Recebidos'),
            ),
          ],
          selected: {tab},
          onSelectionChanged: (value) => setState(() => tab = value.first),
        ),
        if (isCi) ...[
          const SizedBox(height: 14),
          SectionCard(
            child: AppFormGrid(
              children: [
                AppDropdownField(
                  label: 'Historico por participante',
                  value: selectedParticipant,
                  options: [allAccountsLabel, ...appUserNames],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => selectedParticipant = value);
                  },
                ),
                MetricCard(
                  label: 'CIs enviadas',
                  value: selectedParticipant == allAccountsLabel
                      ? '-'
                      : '$participantSent',
                  sub: selectedParticipant == allAccountsLabel
                      ? 'escolha um usuario'
                      : 'por participante',
                ),
                MetricCard(
                  label: 'CIs recebidas',
                  value: selectedParticipant == allAccountsLabel
                      ? '-'
                      : '$participantReceived',
                  sub: selectedParticipant == allAccountsLabel
                      ? 'escolha um usuario'
                      : 'para usuario/setor',
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: 180,
              child: MetricCard(
                label: tab == 0 ? 'Enviados' : 'Recebidos',
                value:
                    '${widget.documents.where((document) => document.kind == widget.kind && document.received == (tab == 1)).length}',
                sub: 'em 2026',
              ),
            ),
            SizedBox(
              width: 180,
              child: MetricCard(
                label: 'Pendentes',
                value:
                    '${widget.documents.where((document) => document.kind == widget.kind && document.status == 'Pendente').length}',
                sub: 'exigem acao',
              ),
            ),
            SizedBox(
              width: 180,
              child: MetricCard(
                label: 'Assinados',
                value:
                    '${widget.documents.where((document) => document.kind == widget.kind && document.status == 'Assinado').length}',
                sub: 'validacao digital',
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
                hint: 'Buscar por numero, assunto ou destinatario...',
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: DocumentTable(
                  key: ValueKey(
                    '${widget.kind}-$tab-${widget.documents.length}-$selectedParticipant',
                  ),
                  documents: visibleDocuments,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DocumentTable extends StatelessWidget {
  const DocumentTable({super.key, required this.documents});
  final List<AppDocument> documents;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Nenhum documento encontrado',
        subtitle: 'Crie um novo registro ou ajuste os filtros.',
        compact: true,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 680) {
          return Column(
            children: [
              for (final document in documents) ...[
                DocumentMobileCard(document: document),
                const SizedBox(height: 10),
              ],
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle: const TextStyle(
              fontSize: 11,
              color: AppColors.gray,
              fontWeight: FontWeight.w700,
            ),
            dataTextStyle:
                const TextStyle(fontSize: 13, color: AppColors.grayDark),
            columns: const [
              DataColumn(label: Text('Numero')),
              DataColumn(label: Text('Assunto')),
              DataColumn(label: Text('Destino/Origem')),
              DataColumn(label: Text('Status')),
            ],
            rows: [
              for (final document in documents)
                DataRow(
                  onSelectChanged: (_) => openDocumentDetail(context, document),
                  cells: [
                    DataCell(
                      Text(document.number),
                      onTap: () => openDocumentDetail(context, document),
                    ),
                    DataCell(
                      Text(document.subject),
                      onTap: () => openDocumentDetail(context, document),
                    ),
                    DataCell(
                      Text(document.party),
                      onTap: () => openDocumentDetail(context, document),
                    ),
                    DataCell(
                      StatusPill(
                        label: document.status,
                        color: statusColor(document.status),
                      ),
                      onTap: () => openDocumentDetail(context, document),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

class DocumentMobileCard extends StatelessWidget {
  const DocumentMobileCard({super.key, required this.document});
  final AppDocument document;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => openDocumentDetail(context, document),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    document.number,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                StatusPill(
                  label: document.status,
                  color: statusColor(document.status),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              document.subject,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.grayDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              document.party,
              style: const TextStyle(fontSize: 12, color: AppColors.gray),
            ),
          ],
        ),
      ),
    );
  }
}

void openDocumentDetail(BuildContext context, AppDocument document) {
  openDetail(
    context,
    DetailDialog(
      icon: document.kind == DocumentKind.ci
          ? Icons.forward_to_inbox_outlined
          : Icons.description_outlined,
      title: document.number,
      subtitle: document.subject,
      status: document.status,
      statusColor: statusColor(document.status),
      items: [
        DetailItem(
          'Tipo',
          document.kind == DocumentKind.ci ? 'Comunicacao Interna' : 'Oficio',
        ),
        DetailItem('Numero', document.number),
        DetailItem('Enviado por', document.sender),
        DetailItem('Destinatario', document.recipient),
        DetailItem(document.received ? 'Origem' : 'Destino', document.party),
        DetailItem('Fluxo', document.received ? 'Recebido' : 'Enviado'),
        DetailItem('Acesso', document.accessLevel),
        if (document.kind == DocumentKind.oficio) ...[
          DetailItem('Assinatura', document.signatureStatus ?? 'Assinado'),
          DetailItem('Assinante', document.signedBy ?? document.assignedSigner),
        ],
        const DetailItem('Ano', '2026'),
        const DetailItem('Responsavel', 'Dra. Gabriela Santos'),
      ],
      note: document.kind == DocumentKind.oficio
          ? (document.status != 'Assinado'
              ? 'Este oficio aguarda assinatura digital da Dra. Gabriela Santos para conclusao.'
              : 'Oficio assinado digitalmente por ${document.signedBy ?? document.assignedSigner}.')
          : 'A estrutura do documento permanece fixa; apenas os campos editaveis sao alterados.',
      bodyTitle: document.kind == DocumentKind.ci
          ? 'Mensagem da CI'
          : 'Mensagem do oficio',
      body: document.message,
    ),
  );
}

class DocumentDialog extends StatefulWidget {
  const DocumentDialog({
    super.key,
    required this.kind,
    required this.profile,
    required this.nextNumber,
  });

  final DocumentKind kind;
  final UserProfile profile;
  final String nextNumber;

  @override
  State<DocumentDialog> createState() => _DocumentDialogState();
}

class _DocumentDialogState extends State<DocumentDialog> {
  final titleController = TextEditingController();
  final subjectController = TextEditingController();
  final partyController = TextEditingController();
  final bodyController = TextEditingController();
  late final TextEditingController dateController;
  List<String> selectedRecipients = const [allAccountsLabel];
  List<String> selectedSectors = const [allSectorsLabel];

  @override
  void initState() {
    super.initState();
    dateController = TextEditingController(text: appDate(todayDate()));
  }

  @override
  void dispose() {
    titleController.dispose();
    subjectController.dispose();
    partyController.dispose();
    bodyController.dispose();
    dateController.dispose();
    super.dispose();
  }

  String selectedText(List<String> values) => values.join(', ');

  @override
  Widget build(BuildContext context) {
    final isCi = widget.kind == DocumentKind.ci;
    final issuedByGabriela = widget.profile.fullName == 'Dra. Gabriela Santos';
    return AppDialogScaffold(
      title: isCi ? 'Nova Comunicacao Interna' : 'Novo Oficio',
      actionLabel: isCi ? 'Enviar CI' : 'Emitir e assinar',
      actionIcon: isCi ? Icons.send : Icons.draw_outlined,
      onSubmit: () {
        if (!FormValidators.isBrazilianDate(dateController.text)) {
          showInlineError(
              context, 'Informe uma data valida no formato DD/MM/AAAA.');
          return;
        }
        if (isCi && !FormValidators.hasText(titleController.text)) {
          showInlineError(context, 'Informe o titulo da CI.');
          return;
        }
        if (!isCi && !FormValidators.hasText(partyController.text)) {
          showInlineError(context, 'Informe o destinatario do oficio.');
          return;
        }
        if (!FormValidators.hasText(subjectController.text)) {
          showInlineError(context, 'Informe o assunto.');
          return;
        }
        if (!FormValidators.hasText(bodyController.text)) {
          showInlineError(context, 'Informe o texto do documento.');
          return;
        }
        Navigator.of(context).pop(
          AppDocument(
            kind: widget.kind,
            number: widget.nextNumber,
            subject: subjectController.text.trim().isEmpty
                ? titleController.text.trim()
                : subjectController.text.trim(),
            party: isCi
                ? selectedText(selectedSectors)
                : (partyController.text.trim().isEmpty
                    ? 'Destinatario externo'
                    : partyController.text.trim()),
            status: isCi
                ? 'Recebido'
                : (issuedByGabriela ? 'Assinado' : 'Pendente'),
            received: false,
            sender: widget.profile.fullName,
            recipient: isCi
                ? selectedText(selectedRecipients)
                : (partyController.text.trim().isEmpty
                    ? 'Destinatario externo'
                    : partyController.text.trim()),
            message: bodyController.text.trim(),
            assignedSigner: 'Dra. Gabriela Santos',
            signedBy: isCi
                ? null
                : (issuedByGabriela ? 'Dra. Gabriela Santos' : null),
            signatureStatus: isCi
                ? null
                : (issuedByGabriela
                    ? 'Assinado digitalmente'
                    : 'Aguardando assinatura'),
            legalBasis: 'Execucao de politica publica',
            dataPurpose: isCi
                ? 'Comunicacao interna, encaminhamento e acompanhamento de demanda'
                : 'Comunicacao oficial externa e registro administrativo',
            accessLevel: isCi
                ? 'Remetente, destinatarios e setores selecionados'
                : 'Usuarios autorizados e assinatura da Secretaria',
            retentionPolicy: 'Retencao conforme regra administrativa',
          ),
        );
      },
      children: [
        AppFormGrid(
          children: [
            DocumentNumber(text: widget.nextNumber),
            AppTextField(
              label: 'Data',
              hint: appDate(todayDate()),
              controller: dateController,
            ),
          ],
        ),
        AppTextField(
          label: isCi ? 'Titulo' : 'Destinatario externo',
          hint: isCi
              ? 'Titulo da comunicacao'
              : 'Ex.: Camara Municipal de Mangaratiba',
          controller: isCi ? titleController : partyController,
        ),
        AppTextField(
          label: 'Assunto',
          hint: 'Assunto resumido',
          controller: subjectController,
        ),
        if (isCi)
          AppMultiSelectField(
            label: 'Para',
            options: [allAccountsLabel, ...appUserNames],
            selected: selectedRecipients,
            allOption: allAccountsLabel,
            onChanged: (values) => setState(() => selectedRecipients = values),
          ),
        if (isCi)
          AppMultiSelectField(
            label: 'Setores',
            options: const [allSectorsLabel, ...appSectorNames],
            selected: selectedSectors,
            allOption: allSectorsLabel,
            onChanged: (values) => setState(() => selectedSectors = values),
          ),
        LgpdBanner(
          text: isCi
              ? 'Preencha somente os dados necessarios para a comunicacao interna. O acesso ficara vinculado aos destinatarios e setores escolhidos.'
              : 'Preencha somente dados necessarios ao oficio. O registro fica pendente quando precisar da assinatura da Dra. Gabriela.',
          dense: true,
        ),
        AppTextField(
          label: 'Texto',
          hint: 'Conteudo do documento',
          maxLines: 4,
          controller: bodyController,
        ),
        if (!isCi)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.roseLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.rose.withOpacity(0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ASSINATURA DA DRA. GABRIELA',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.roseDark,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  issuedByGabriela
                      ? 'Este oficio sera emitido como assinado digitalmente por Dra. Gabriela Santos.'
                      : 'Este oficio sera salvo como pendente e aguardara assinatura digital da Dra. Gabriela Santos.',
                  style:
                      const TextStyle(fontSize: 12, color: AppColors.roseDark),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        issuedByGabriela
                            ? Icons.draw_outlined
                            : Icons.pending_actions_outlined,
                        size: 18,
                        color: AppColors.rose,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          issuedByGabriela
                              ? 'Assinatura aplicada no envio.'
                              : 'Espaco reservado para assinatura.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.grayDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
