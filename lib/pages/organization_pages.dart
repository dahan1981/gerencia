import 'package:flutter/material.dart';

import '../core/app_sections.dart';
import '../core/app_theme.dart';
import '../core/formatters.dart';
import '../core/validators.dart';
import '../models/app_models.dart';
import '../widgets/dialog_widgets.dart';
import '../widgets/form_widgets.dart';
import '../widgets/layout_widgets.dart';
import '../widgets/search_widgets.dart';
import '../widgets/status_widgets.dart';

const _initialProjectRows = [
  SimpleRow(
    title: 'Campanha Maio Lilas',
    subtitle: 'Enfrentamento da violencia contra mulheres',
    status: 'Ativo',
    detailItems: [
      DetailItem('Setor lider', 'Enfrentamento'),
      DetailItem('Setores envolvidos', 'Enfrentamento, CREAM, Recepcao'),
      DetailItem('Periodo', 'Maio/2026'),
      DetailItem('Responsavel', 'Maria Carvalho'),
      DetailItem('Equipe', 'Maria Carvalho, Juliana Santos, Roberta Faria'),
      DetailItem('Prioridade', 'Alta'),
    ],
    bodyTitle: 'Escopo do projeto',
    body:
        'Campanha mensal de mobilizacao social para orientar mulheres sobre canais de atendimento, medidas de protecao e servicos oferecidos pela Secretaria da Mulher. Inclui agenda de reunioes, materiais de divulgacao, acoes em setores publicos e registro dos indicadores de participacao.',
    note:
        'Projeto voltado a campanha publica, acoes externas e mobilizacao da rede municipal.',
  ),
  SimpleRow(
    title: 'Capacitacao da rede',
    subtitle: 'Treinamento intersetorial com CREAM e SerH',
    status: 'Planejado',
    detailItems: [
      DetailItem('Setores', 'CREAM, SerH'),
      DetailItem('Periodo', 'Junho/2026'),
      DetailItem('Responsavel', 'Ana Paula Lima'),
      DetailItem('Equipe', 'Ana Paula Lima, Juliana Santos, Maria Carvalho'),
      DetailItem('Etapa', 'Planejamento'),
    ],
    bodyTitle: 'Escopo do projeto',
    body:
        'Capacitacao interna para alinhar o atendimento, padronizar os registros, revisar fluxos de encaminhamento e preparar a equipe para uso do sistema. O projeto envolve encontros por setor, materiais de apoio e validacao dos procedimentos com a coordenacao.',
    note:
        'Treinamento para padronizar encaminhamentos, registro de atendimentos e fluxos de protecao.',
  ),
  SimpleRow(
    title: 'Atendimento itinerante',
    subtitle: 'Acoes externas nos bairros',
    status: 'Ativo',
    detailItems: [
      DetailItem('Abrangencia', 'Bairros prioritarios'),
      DetailItem('Setores envolvidos', 'Recepcao, SerH, Administrativo'),
      DetailItem('Equipe', 'Recepcao e Tecnicas'),
      DetailItem('Responsavel', 'Roberta Faria'),
      DetailItem('Indicador', 'Atendimentos realizados'),
    ],
    bodyTitle: 'Escopo do projeto',
    body:
        'Atendimento externo planejado para levar acolhimento inicial, informacoes e triagem a territorios com maior demanda. O escopo inclui cadastro de participantes, registro de encaminhamentos, agenda de visitas e relatorio final de resultados.',
    note:
        'Acao para aproximar a secretaria de mulheres com dificuldade de deslocamento.',
  ),
];

const _initialResolutionRows = [
  SimpleRow(
    title: 'Lei municipal de protecao a mulher',
    subtitle: 'Legislacao relacionada a Secretaria da Mulher',
    status: 'Vigente',
    detailItems: [
      DetailItem('Esfera', 'Municipal'),
      DetailItem('Aplicacao', 'Mangaratiba'),
      DetailItem('Tipo', 'Lei'),
      DetailItem('Situacao', 'Vigente'),
    ],
    bodyTitle: 'Lei relacionada',
    body:
        'Art. 1o Fica instituida, no ambito municipal, politica permanente de protecao, acolhimento e orientacao as mulheres em situacao de vulnerabilidade, com atuacao integrada da rede de atendimento. Art. 2o A Secretaria da Mulher devera manter registros, fluxos de encaminhamento e acompanhamento das acoes executadas, observadas as regras de sigilo e protecao de dados pessoais.',
    note:
        'Referencia juridica para politicas, encaminhamentos e acoes da Secretaria da Mulher.',
  ),
  SimpleRow(
    title: 'Resolucao estadual de atendimento',
    subtitle: 'Norma de referencia para rede de acolhimento',
    status: 'Vigente',
    detailItems: [
      DetailItem('Esfera', 'Estadual'),
      DetailItem('Tipo', 'Resolucao'),
      DetailItem('Impacto', 'Rede de acolhimento'),
      DetailItem('Revisao', 'Anual'),
    ],
    bodyTitle: 'Resolucao relacionada',
    body:
        'Resolucao estabelece diretrizes minimas para atendimento humanizado, escuta qualificada, registro seguro das informacoes e articulacao entre equipamentos municipais e estaduais. Determina que os atendimentos sejam documentados de forma auditavel, com acesso restrito a profissionais autorizados.',
    note:
        'Define parametros de atendimento, acolhimento e articulacao com a rede estadual.',
  ),
  SimpleRow(
    title: 'Diretriz interna de encaminhamento',
    subtitle: 'Procedimento da pasta',
    status: 'Revisao',
    detailItems: [
      DetailItem('Esfera', 'Interna'),
      DetailItem('Tipo', 'Diretriz'),
      DetailItem('Responsavel', 'Coordenacao'),
      DetailItem('Status', 'Em revisao'),
    ],
    bodyTitle: 'Diretriz relacionada',
    body:
        'Toda demanda recebida pela Secretaria da Mulher devera ser registrada com identificacao do setor responsavel, status de acompanhamento, encaminhamentos realizados e historico de alteracoes. A inativacao de registros substituira exclusoes definitivas sempre que houver necessidade de preservacao da trilha de auditoria.',
    note:
        'Fluxo operacional para registrar, encaminhar e acompanhar demandas recebidas pela secretaria.',
  ),
];

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late final List<SimpleRow> rows = List.of(_initialProjectRows);

  Future<void> createProject() async {
    final row = await showAppDialog<SimpleRow>(
      context,
      const ModuleItemDialog(
        title: 'Novo projeto',
        titleLabel: 'Nome do projeto',
        titleHint: 'Ex.: Projeto de acolhimento',
        subtitleLabel: 'Resumo',
        subtitleHint: 'Objetivo principal',
        bodyTitle: 'Escopo do projeto',
        bodyHint: 'Descreva escopo, setores envolvidos e responsaveis',
        status: 'Planejado',
      ),
    );
    if (row == null) return;
    setState(() => rows.insert(0, row));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleListPage(
      section: AppSection.projetos,
      actionLabel: 'Novo projeto',
      onAction: createProject,
      metrics: const [
        MetricCard(label: 'Ativos', value: '8', sub: 'em andamento'),
        MetricCard(label: 'Concluidos', value: '12', sub: 'ano atual'),
        MetricCard(label: 'Pendentes', value: '2', sub: 'aguardando acao'),
      ],
      rows: rows,
    );
  }
}

class ResolutionsPage extends StatefulWidget {
  const ResolutionsPage({super.key});

  @override
  State<ResolutionsPage> createState() => _ResolutionsPageState();
}

class _ResolutionsPageState extends State<ResolutionsPage> {
  late final List<SimpleRow> rows = List.of(_initialResolutionRows);

  Future<void> createResolution() async {
    final row = await showAppDialog<SimpleRow>(
      context,
      const ModuleItemDialog(
        title: 'Nova resolucao',
        titleLabel: 'Titulo',
        titleHint: 'Ex.: Portaria de atendimento',
        subtitleLabel: 'Referencia',
        subtitleHint: 'Lei, portaria ou diretriz relacionada',
        bodyTitle: 'Lei relacionada',
        bodyHint: 'Cole ou descreva o texto legal relacionado',
        status: 'Revisao',
      ),
    );
    if (row == null) return;
    setState(() => rows.insert(0, row));
  }

  @override
  Widget build(BuildContext context) {
    return ModuleListPage(
      section: AppSection.resolucoes,
      actionLabel: 'Nova resolucao',
      onAction: createResolution,
      metrics: const [
        MetricCard(label: 'Legislacoes', value: '24', sub: 'catalogadas'),
        MetricCard(label: 'Municipais', value: '13', sub: 'Mangaratiba'),
        MetricCard(label: 'Atualizadas', value: '5', sub: 'ultimos 30 dias'),
      ],
      rows: rows,
    );
  }
}

class SectorsPage extends StatelessWidget {
  const SectorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sectors = [
      (
        'Programa SerH',
        'Atendimento e acompanhamento humanizado',
        '5 servidores',
        'Ana Paula Lima, Carla Menezes, Beatriz Rocha, Luana Duarte, Marcia Alves'
      ),
      (
        'CREAM',
        'Centro de referencia especializado',
        '7 servidores',
        'Juliana Santos, Renata Paiva, Camila Torres, Bianca Lima, Fernanda Reis, Patricia Gomes, Elaine Costa'
      ),
      (
        'Enfrentamento',
        'Politicas para mulheres e meninas',
        '4 servidores',
        'Maria Carvalho, Sofia Martins, Daniela Nunes, Lais Ferreira'
      ),
      (
        'Recepcao',
        'Triagem e registro de visitantes',
        '2 servidores',
        'Roberta Faria, Vanessa Oliveira'
      ),
      (
        'Administrativo',
        'Apoio operacional e documentos',
        '3 servidores',
        'Paulo Ribeiro, Marcos Tavares, Ingrid Souza'
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          icon: Icons.apartment_outlined,
          title: 'Setores',
          subtitle: 'Estrutura interna da Secretaria da Mulher',
        ),
        const SizedBox(height: 18),
        const LgpdBanner(
          text:
              'Setores exibem equipe, responsabilidades e acesso operacional com visibilidade restrita a usuarios autorizados.',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 560
                    ? 2
                    : 1;
            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: columns == 1 ? 3.0 : 1.55,
              children: [
                for (final sector in sectors)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => openDetail(
                      context,
                      DetailDialog(
                        icon: Icons.apartment_outlined,
                        title: sector.$1,
                        subtitle: sector.$2,
                        status: 'Setor ativo',
                        statusColor: AppColors.green,
                        items: [
                          DetailItem('Equipe', sector.$3),
                          DetailItem('Pessoas', sector.$4),
                          const DetailItem('Acesso', 'Usuarios autorizados'),
                          const DetailItem('Registro', 'Auditavel'),
                        ],
                        bodyTitle: 'Funcionamento do setor',
                        body:
                            'Setor responsavel por demandas relacionadas a ${sector.$2.toLowerCase()}. As pessoas vinculadas ao setor poderao receber notificacoes, documentos, eventos de agenda e tarefas internas quando o banco de dados estiver conectado.',
                        note:
                            'Este setor podera concentrar usuarios, documentos, atendimentos e indicadores proprios quando conectado ao Supabase.',
                      ),
                    ),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.apartment_outlined,
                            color: AppColors.rose,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            sector.$1,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            sector.$2,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  sector.$3,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.gray,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.open_in_new,
                                size: 15,
                                color: AppColors.gray,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class OrgChartPage extends StatelessWidget {
  const OrgChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final people = [
      (
        'DG',
        'Dra. Gabriela Santos',
        'Secretaria',
        'Responsavel por aprovacoes e assinatura de oficios.'
      ),
      (
        'MC',
        'Maria Carvalho',
        'Coordenacao',
        'Acompanha projetos e indicadores da pasta.'
      ),
      ('AP', 'Ana Paula Lima', 'SerH', 'Atendimento e acolhimento humanizado.'),
      ('JS', 'Juliana Santos', 'CREAM', 'Referencia tecnica do setor CREAM.'),
      (
        'RF',
        'Roberta Faria',
        'Recepcao',
        'Registro de visitantes e comunicacao interna.'
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          icon: Icons.account_tree_outlined,
          title: 'Fluxograma',
          subtitle: 'Funcao de cada servidor dentro da pasta',
        ),
        const SizedBox(height: 18),
        const LgpdBanner(
          text:
              'Fluxograma usa dados funcionais para identificar responsabilidades, permissoes e trilhas de atendimento.',
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 900
                ? 3
                : constraints.maxWidth > 560
                    ? 2
                    : 1;
            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: columns == 1 ? 2.75 : 1.18,
              children: [
                for (final person in people)
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => openDetail(
                      context,
                      DetailDialog(
                        icon: Icons.badge_outlined,
                        title: person.$2,
                        subtitle: person.$4,
                        status: person.$3,
                        statusColor: AppColors.rose,
                        items: [
                          DetailItem('Iniciais', person.$1),
                          DetailItem('Cargo/Setor', person.$3),
                          const DetailItem('Permissao', 'Conforme perfil'),
                          const DetailItem('Auditoria', 'Acoes registradas'),
                        ],
                        note:
                            'A visualizacao completa do servidor ajudara a entender responsabilidades, permissoes e relacao com os fluxos internos.',
                      ),
                    ),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.roseLight,
                            foregroundColor: AppColors.roseDark,
                            child: Text(
                              person.$1,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          StatusPill(label: person.$3, color: AppColors.rose),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  person.$2,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.open_in_new,
                                size: 15,
                                color: AppColors.gray,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            person.$4,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class CodimmPage extends StatelessWidget {
  const CodimmPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          icon: Icons.groups_2_outlined,
          title: 'CODIMM',
          subtitle: 'Modulo reservado',
        ),
        SizedBox(height: 18),
        LgpdBanner(
          text:
              'Quando ativado, este modulo devera seguir os mesmos controles de finalidade, acesso restrito e rastreabilidade.',
        ),
        SizedBox(height: 14),
        SectionCard(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 42,
                  color: AppColors.gray,
                ),
                SizedBox(height: 10),
                Text(
                  'Modulo criado no menu conforme escopo.',
                  style: TextStyle(fontSize: 14, color: AppColors.grayDark),
                ),
                SizedBox(height: 4),
                Text(
                  'Nenhuma funcionalidade adicionada por enquanto.',
                  style: TextStyle(fontSize: 12, color: AppColors.gray),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ModuleItemDialog extends StatefulWidget {
  const ModuleItemDialog({
    super.key,
    required this.title,
    required this.titleLabel,
    required this.titleHint,
    required this.subtitleLabel,
    required this.subtitleHint,
    required this.bodyTitle,
    required this.bodyHint,
    required this.status,
  });

  final String title;
  final String titleLabel;
  final String titleHint;
  final String subtitleLabel;
  final String subtitleHint;
  final String bodyTitle;
  final String bodyHint;
  final String status;

  @override
  State<ModuleItemDialog> createState() => _ModuleItemDialogState();
}

class _ModuleItemDialogState extends State<ModuleItemDialog> {
  final titleController = TextEditingController();
  final subtitleController = TextEditingController();
  final bodyController = TextEditingController();
  final responsibleController =
      TextEditingController(text: 'Dra. Gabriela Santos');

  @override
  void dispose() {
    titleController.dispose();
    subtitleController.dispose();
    bodyController.dispose();
    responsibleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogScaffold(
      title: widget.title,
      actionLabel: 'Salvar',
      actionIcon: Icons.check,
      onSubmit: () {
        if (!FormValidators.hasText(titleController.text)) {
          showInlineError(context, 'Informe o titulo.');
          return;
        }
        if (!FormValidators.hasText(subtitleController.text)) {
          showInlineError(context, 'Informe o resumo.');
          return;
        }
        if (!FormValidators.hasText(bodyController.text)) {
          showInlineError(context, 'Informe o conteudo.');
          return;
        }
        Navigator.of(context).pop(
          SimpleRow(
            title: titleController.text.trim(),
            subtitle: subtitleController.text.trim(),
            status: widget.status,
            detailItems: [
              DetailItem('Criado em', appDate(todayDate())),
              DetailItem('Responsavel', responsibleController.text.trim()),
              DetailItem('Status', widget.status),
              const DetailItem('Origem', 'Cadastro manual'),
            ],
            bodyTitle: widget.bodyTitle,
            body: bodyController.text.trim(),
            note:
                'Registro criado localmente para validacao da versao teste. Depois sera persistido no Supabase.',
          ),
        );
      },
      children: [
        AppTextField(
          label: widget.titleLabel,
          hint: widget.titleHint,
          controller: titleController,
        ),
        AppTextField(
          label: widget.subtitleLabel,
          hint: widget.subtitleHint,
          controller: subtitleController,
        ),
        AppTextField(
          label: 'Responsavel',
          hint: 'Responsavel pelo registro',
          controller: responsibleController,
        ),
        const LgpdBanner(
          text:
              'Preencha apenas informacoes necessarias ao registro. Dados pessoais sensiveis devem ficar no atendimento adequado, nao no resumo publico do modulo.',
          dense: true,
        ),
        AppTextField(
          label: widget.bodyTitle,
          hint: widget.bodyHint,
          controller: bodyController,
          maxLines: 5,
        ),
      ],
    );
  }
}

class ModuleListPage extends StatelessWidget {
  const ModuleListPage({
    super.key,
    required this.section,
    required this.actionLabel,
    required this.onAction,
    required this.metrics,
    required this.rows,
  });

  final AppSection section;
  final String actionLabel;
  final VoidCallback onAction;
  final List<Widget> metrics;
  final List<SimpleRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          icon: section.icon,
          title: section.title,
          subtitle: section.subtitle,
          action: FilledButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add),
            label: Text(actionLabel),
          ),
        ),
        const SizedBox(height: 18),
        LgpdBanner(
          text: section == AppSection.projetos
              ? 'Projetos devem registrar somente dados necessarios ao acompanhamento das acoes, equipe responsavel e escopo operacional.'
              : 'Resolucoes registram referencias legais e diretrizes com acesso administrativo controlado.',
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final metric in metrics) SizedBox(width: 180, child: metric),
          ],
        ),
        const SizedBox(height: 14),
        SectionCard(
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 640;
                  final search = SearchRow(
                    hint: 'Buscar em ${section.title.toLowerCase()}...',
                  );
                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        search,
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: ClickHint(),
                        ),
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: search),
                      const SizedBox(width: 12),
                      const ClickHint(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              for (final row in rows) row,
            ],
          ),
        ),
      ],
    );
  }
}

class SimpleRow extends StatelessWidget {
  const SimpleRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    this.detailItems = const [],
    this.note,
    this.bodyTitle,
    this.body,
  });

  final String title;
  final String subtitle;
  final String status;
  final List<DetailItem> detailItems;
  final String? note;
  final String? bodyTitle;
  final String? body;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => openDetail(
        context,
        DetailDialog(
          icon: Icons.info_outline,
          title: title,
          subtitle: subtitle,
          status: status,
          statusColor: statusColor(status),
          items: detailItems.isEmpty
              ? const [
                  DetailItem('Status', 'Disponivel'),
                  DetailItem('Registro', 'Auditavel'),
                  DetailItem('Acesso', 'Usuarios autorizados'),
                ]
              : [
                  ...detailItems,
                  const DetailItem('Acesso', 'Usuarios autorizados'),
                ],
          note: note,
          bodyTitle: bodyTitle,
          body: body,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
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
            StatusPill(label: status, color: statusColor(status)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.gray),
          ],
        ),
      ),
    );
  }
}
