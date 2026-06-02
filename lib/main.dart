import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'core/app_sections.dart';
import 'core/app_theme.dart';
import 'core/formatters.dart';
import 'models/app_models.dart';
import 'pages/agenda_page.dart';
import 'pages/audit_page.dart';
import 'pages/clients_page.dart';
import 'pages/documents_page.dart';
import 'pages/organization_pages.dart';
import 'pages/profile_page.dart';
import 'pages/reception_page.dart';
import 'pages/users_page.dart';
import 'services/mock_data_service.dart';
import 'widgets/avatar_widgets.dart';
import 'widgets/layout_widgets.dart';
import 'widgets/navigation_widgets.dart';

void main() {
  runApp(const SistemaGerirApp());
}

class SistemaGerirApp extends StatelessWidget {
  const SistemaGerirApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Gerir',
      theme: AppTheme.light(),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController(text: 'gabriela@smm.gov.br');
  final passwordController = TextEditingController(text: '********');
  bool obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 820;
              final brandPanel = _LoginBrandPanel(compact: compact);
              final loginCard = Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entrar no sistema',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      const Text(
                        'Acesso restrito a usuarios autorizados.',
                        style: TextStyle(color: AppColors.gray),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail institucional',
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip:
                                obscure ? 'Mostrar senha' : 'Ocultar senha',
                            onPressed: () => setState(() => obscure = !obscure),
                            icon: Icon(obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      LgpdBanner(
                        text:
                            'Login registrado na trilha de auditoria. Dados tratados conforme LGPD.',
                        dense: true,
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              CupertinoPageRoute(
                                  builder: (_) => const HomeShell()),
                            );
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Acessar'),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              return Padding(
                padding: const EdgeInsets.all(20),
                child: compact
                    ? SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            brandPanel,
                            const SizedBox(height: 20),
                            loginCard,
                          ],
                        ),
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 6, child: brandPanel),
                          const SizedBox(width: 20),
                          Expanded(flex: 4, child: loginCard),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LoginBrandPanel extends StatelessWidget {
  const _LoginBrandPanel({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 22 : 32),
      decoration: BoxDecoration(
        color: AppColors.roseDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.female, color: Colors.white),
          ),
          const SizedBox(height: 24),
          const Text(
            'SMM - Secretaria da Mulher',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Prefeitura de Mangaratiba - RJ',
            style:
                TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 14),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _LoginChip('Agenda'),
              _LoginChip('Documentos'),
              _LoginChip('Recepcao'),
              _LoginChip('Auditoria'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoginChip extends StatelessWidget {
  const _LoginChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final MockDataService mockData = MockDataService();
  AppSection section = AppSection.agenda;
  late UserProfile profile = mockData.initialProfile();
  late final List<AgendaEvent> events = List.of(mockData.initialEvents());
  late final List<AppDocument> documents = List.of(mockData.initialDocuments());
  late final List<VisitRecord> visits = List.of(mockData.initialVisits());

  void setSection(AppSection value) {
    setState(() => section = value);
    if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
      Navigator.of(context).pop();
    }
  }

  void addEvent(AgendaEvent event) => setState(() => events.add(event));

  void updateEvent(AgendaEvent current, AgendaEvent updated) {
    final index = events.indexWhere((event) => identical(event, current));
    if (index == -1) return;
    setState(() => events[index] = updated);
  }

  void deleteEvent(AgendaEvent event) {
    setState(() => events.removeWhere((item) => identical(item, event)));
  }

  void addDocument(AppDocument document) =>
      setState(() => documents.insert(0, document));

  void addVisit(VisitRecord visit) => setState(() => visits.insert(0, visit));

  void updateVisit(VisitRecord visit, String status, [String? denialReason]) {
    final index = visits.indexOf(visit);
    if (index == -1) return;
    setState(() {
      visits[index] = visit.copyWith(
          status: status,
          time: currentTime(),
          denialReason: denialReason,
          pending: false);
    });
  }

  void updateProfile(UserProfile updatedProfile) {
    setState(() => profile = updatedProfile);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 760;
        return Scaffold(
          appBar: AppBar(
            leading: compact
                ? Builder(
                    builder: (context) => IconButton(
                      tooltip: 'Menu',
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                : null,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.female, size: 19),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SMM - Secretaria da Mulher',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('Prefeitura de Mangaratiba - RJ',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xB3FFFFFF))),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Notificacoes',
                onPressed: () => setState(() => section = AppSection.auditoria),
                icon: Badge.count(
                    count: 3, child: const Icon(Icons.notifications_none)),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Tooltip(
                  message: 'Perfil',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => section = AppSection.perfil),
                    child: UserAvatar(
                      profile: profile,
                      radius: 15,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
          drawer: compact
              ? Drawer(
                  child: AppSidebar(
                      current: section,
                      profile: profile,
                      closeOnSelect: true,
                      onSelected: setSection))
              : null,
          body: Row(
            children: [
              if (!compact)
                SizedBox(
                  width: 220,
                  child: AppSidebar(
                    current: section,
                    profile: profile,
                    closeOnSelect: false,
                    onSelected: setSection,
                  ),
                ),
              Expanded(
                child: AppPage(
                  section: section,
                  events: events,
                  documents: documents,
                  visits: visits,
                  profile: profile,
                  onAddEvent: addEvent,
                  onUpdateEvent: updateEvent,
                  onDeleteEvent: deleteEvent,
                  onAddDocument: addDocument,
                  onAddVisit: addVisit,
                  onVisitStatus: updateVisit,
                  onProfileSave: updateProfile,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.section,
    required this.events,
    required this.documents,
    required this.visits,
    required this.profile,
    required this.onAddEvent,
    required this.onUpdateEvent,
    required this.onDeleteEvent,
    required this.onAddDocument,
    required this.onAddVisit,
    required this.onVisitStatus,
    required this.onProfileSave,
  });

  final AppSection section;
  final List<AgendaEvent> events;
  final List<AppDocument> documents;
  final List<VisitRecord> visits;
  final UserProfile profile;
  final ValueChanged<AgendaEvent> onAddEvent;
  final void Function(AgendaEvent current, AgendaEvent updated) onUpdateEvent;
  final ValueChanged<AgendaEvent> onDeleteEvent;
  final ValueChanged<AppDocument> onAddDocument;
  final ValueChanged<VisitRecord> onAddVisit;
  final void Function(VisitRecord visit, String status, [String? denialReason])
      onVisitStatus;
  final ValueChanged<UserProfile> onProfileSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0.025, 0),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey(section),
                    child: switch (section) {
                      AppSection.agenda => AgendaPage(
                          events: events,
                          onAddEvent: onAddEvent,
                          onUpdateEvent: onUpdateEvent,
                          onDeleteEvent: onDeleteEvent,
                        ),
                      AppSection.recepcao => ReceptionPage(
                          visits: visits,
                          onAddVisit: onAddVisit,
                          onVisitStatus: onVisitStatus),
                      AppSection.clientes => ClientsPage(
                          visits: visits,
                          onVisitStatus: onVisitStatus,
                        ),
                      AppSection.ci => DocumentsPage(
                          kind: DocumentKind.ci,
                          profile: profile,
                          documents: documents,
                          onAddDocument: onAddDocument),
                      AppSection.oficios => DocumentsPage(
                          kind: DocumentKind.oficio,
                          profile: profile,
                          documents: documents,
                          onAddDocument: onAddDocument),
                      AppSection.projetos => const ProjectsPage(),
                      AppSection.resolucoes => const ResolutionsPage(),
                      AppSection.setores => const SectorsPage(),
                      AppSection.fluxograma => const OrgChartPage(),
                      AppSection.codimm => const CodimmPage(),
                      AppSection.usuarios => UsersPage(
                          visits: visits,
                          documents: documents,
                        ),
                      AppSection.perfil => ProfilePage(
                          profile: profile,
                          onSave: onProfileSave,
                        ),
                      AppSection.auditoria => const AuditPage(),
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const AppDeveloperFooter(),
      ],
    );
  }
}
