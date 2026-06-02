import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sistema_gerir/core/formatters.dart';
import 'package:sistema_gerir/main.dart';

Future<void> login(
  WidgetTester tester, {
  Size size = const Size(1200, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const SistemaGerirApp());
  await tester.tap(find.text('Acessar'));
  await tester.pumpAndSettle();
}

Future<void> openDesktopPage(WidgetTester tester, String label) async {
  await tester.tap(find.text(label).first);
  await tester.pumpAndSettle();
}

Future<void> enterDialogText(
  WidgetTester tester,
  int index,
  String value,
) async {
  final field = find
      .descendant(of: find.byType(Dialog), matching: find.byType(TextField))
      .at(index);
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.tap(field, warnIfMissed: false);
  await tester.enterText(field, value);
  await tester.pumpAndSettle();
}

Future<void> tapAfterScroll(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder, warnIfMissed: false);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SistemaGerirApp());

    expect(find.text('Entrar no sistema'), findsOneWidget);
    expect(find.text('SMM - Secretaria da Mulher'), findsOneWidget);
  });

  testWidgets('opens agenda after login', (WidgetTester tester) async {
    await login(tester);

    expect(find.text('Agenda'), findsWidgets);
    expect(find.text('Eventos de ${appDate(todayDate())}'), findsOneWidget);
  });

  testWidgets('rejects invalid login', (WidgetTester tester) async {
    await tester.pumpWidget(const SistemaGerirApp());

    await tester.enterText(find.byType(TextField).at(1), 'senha-incorreta');
    tester.testTextInput.hide();
    await tapAfterScroll(tester, find.widgetWithText(FilledButton, 'Acessar'));

    expect(find.text('E-mail ou senha invalidos.'), findsOneWidget);
    expect(find.text('Entrar no sistema'), findsOneWidget);
  });

  testWidgets('opens Ademir administrator profile',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SistemaGerirApp());

    await tester.enterText(find.byType(TextField).at(0), 'ademir@gmail.com');
    await tester.enterText(find.byType(TextField).at(1), 'Ademir123@');
    tester.testTextInput.hide();
    await tapAfterScroll(tester, find.widgetWithText(FilledButton, 'Acessar'));

    expect(find.text('Ademir'), findsWidgets);
    expect(find.text('Coordenacao - Administrador'), findsWidgets);
    expect(find.text('Agenda'), findsWidgets);
  });

  testWidgets('opens user profile after login', (WidgetTester tester) async {
    await login(tester);

    await tester.tap(find.text('Perfil').first);
    await tester.pumpAndSettle();

    expect(find.text('Informacoes pessoais e acesso'), findsOneWidget);
    expect(find.text('NOME COMPLETO'), findsOneWidget);
    expect(find.text('CPF'), findsOneWidget);
    expect(find.text('DATA DE NASCIMENTO'), findsOneWidget);

    await tester.tap(find.text('Editar foto'));
    await tester.pumpAndSettle();

    expect(find.text('Editar foto do perfil'), findsOneWidget);
    expect(find.text('Escolher foto'), findsOneWidget);
  });

  testWidgets('desktop navigation opens all main pages',
      (WidgetTester tester) async {
    await login(tester);

    for (final label in [
      'Recepcao',
      'Clientes',
      'CI',
      'Oficios',
      'Projetos',
      'Resolucoes',
      'Setores',
      'Fluxograma',
      'CODIMM',
      'Usuarios',
      'Perfil',
      'Auditoria',
    ]) {
      await tester.tap(find.text(label).first);
      await tester.pumpAndSettle();
      expect(find.text(label), findsWidgets);
      expect(tester.takeException(), isNull, reason: label);
    }
  });

  testWidgets('mobile navigation opens core pages without layout errors',
      (WidgetTester tester) async {
    await login(tester, size: const Size(390, 844));

    final pages = {
      'Agenda': 'Agenda',
      'Recepcao': 'Recepcao',
      'Clientes': 'Clientes',
      'CI': 'CI - Comunicacao Interna',
      'Oficios': 'Oficios',
      'Usuarios': 'Usuarios',
      'Perfil': 'Perfil',
    };

    for (final entry in pages.entries) {
      final label = entry.key;
      await tester.tap(find.byIcon(Icons.menu), warnIfMissed: false);
      await tester.pumpAndSettle();
      final drawer = find.byType(Drawer);
      var drawerItem = find.descendant(of: drawer, matching: find.text(label));
      if (drawerItem.evaluate().isEmpty) {
        await tester.drag(
            find.descendant(of: drawer, matching: find.byType(ListView)),
            const Offset(0, -220));
        await tester.pumpAndSettle();
        drawerItem = find.descendant(of: drawer, matching: find.text(label));
      }
      await tester.tap(drawerItem.first);
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsWidgets);
      expect(tester.takeException(), isNull, reason: label);
    }
  });

  testWidgets('agenda creates edits and deletes an event',
      (WidgetTester tester) async {
    await login(tester);

    await tester.tap(find.text('Novo evento'));
    await tester.pumpAndSettle();
    await enterDialogText(tester, 0, 'Reuniao de teste');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Reuniao de teste'), findsOneWidget);
    expect(find.textContaining('Participantes notificados'), findsOneWidget);

    await tester.tap(find.text('Reuniao de teste'));
    await tester.pumpAndSettle();
    expect(find.text('Editar evento'), findsOneWidget);
    await enterDialogText(tester, 0, 'Reuniao atualizada');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Reuniao atualizada'), findsOneWidget);

    await tester.tap(find.byTooltip('Excluir evento').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(find.text('Reuniao atualizada'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reception denies a visit and shows the reason',
      (WidgetTester tester) async {
    await login(tester);
    await openDesktopPage(tester, 'Recepcao');

    await tester.tap(find.text('Registrar visitante'));
    await tester.pumpAndSettle();
    await enterDialogText(tester, 0, 'Visitante Teste');
    await tapAfterScroll(tester, find.byType(CheckboxListTile));
    await tapAfterScroll(tester, find.text('Registrar e notificar'));

    expect(find.text('Visitante Teste'), findsOneWidget);

    await tapAfterScroll(tester, find.text('Negar').last);
    await enterDialogText(tester, 0, 'Sem agendamento');
    await tapAfterScroll(tester, find.text('Registrar negativa'));

    expect(find.textContaining('Motivo: Sem agendamento'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clients tab shows registered visitors and history',
      (WidgetTester tester) async {
    await login(tester);
    await openDesktopPage(tester, 'Recepcao');

    await tester.tap(find.text('Registrar visitante'));
    await tester.pumpAndSettle();
    await enterDialogText(tester, 0, 'Cliente Teste');
    await tapAfterScroll(tester, find.byType(CheckboxListTile));
    await tapAfterScroll(tester, find.text('Registrar e notificar'));

    await openDesktopPage(tester, 'Clientes');

    expect(find.text('Cliente Teste'), findsOneWidget);
    expect(find.textContaining('visita(s)'), findsWidgets);

    await tester.tap(find
        .byKey(const ValueKey('client-row-Cliente Teste-CPF: 000.000.000-00')));
    await tester.pumpAndSettle();

    expect(find.text('Historico do cliente'), findsOneWidget);
    expect(find.text('TOTAL DE VISITAS'), findsOneWidget);
    expect(find.textContaining('Motivo da visita:'), findsOneWidget);
    expect(find.textContaining('Foi falar com'), findsOneWidget);
    expect(find.text('Aceitar'), findsOneWidget);

    await tapAfterScroll(tester, find.text('Aceitar'));

    expect(find.text('Aceito'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clients history denies pending visit with reason',
      (WidgetTester tester) async {
    await login(tester);
    await openDesktopPage(tester, 'Clientes');

    await tester.tap(find.byKey(
        const ValueKey('client-row-Carlos Eduardo Silva-987.654.321-00')));
    await tester.pumpAndSettle();

    expect(find.text('Historico do cliente'), findsOneWidget);
    expect(find.text('Negar'), findsOneWidget);

    await tapAfterScroll(tester, find.text('Negar'));
    await enterDialogText(tester, 0, 'Sem disponibilidade no setor');
    await tapAfterScroll(tester, find.text('Registrar negativa'));

    expect(
      find.textContaining('Motivo: Sem disponibilidade no setor'),
      findsOneWidget,
    );
    expect(find.textContaining('Motivo da visita:'), findsOneWidget);
    expect(find.textContaining('Foi falar com'), findsOneWidget);
    expect(find.text('Negado'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates CI and opens its message detail',
      (WidgetTester tester) async {
    await login(tester);
    await openDesktopPage(tester, 'CI');

    await tester.tap(find.text('Nova CI'));
    await tester.pumpAndSettle();
    await enterDialogText(tester, 1, 'CI automatizada');
    await enterDialogText(tester, 2, 'Assunto da CI');
    await enterDialogText(tester, 3, 'Mensagem completa da CI.');
    await tester.tap(find.text('Enviar CI'));
    await tester.pumpAndSettle();

    expect(find.text('Assunto da CI'), findsOneWidget);

    await tester.tap(find.text('Assunto da CI'));
    await tester.pumpAndSettle();

    expect(find.text('MENSAGEM DA CI'), findsOneWidget);
    expect(find.text('Mensagem completa da CI.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens users registry and user history detail',
      (WidgetTester tester) async {
    await login(tester);
    await openDesktopPage(tester, 'Usuarios');

    expect(
        find.text('Cadastros, datas de entrada e historico de movimentacoes'),
        findsOneWidget);
    expect(find.text('Dra. Gabriela Santos'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey('user-row-SMM-001')));
    await tester.pumpAndSettle();

    expect(find.text('DATA DE CADASTRO'), findsOneWidget);
    expect(find.text('SMM-001'), findsOneWidget);
    expect(find.text('02/01/2026'), findsOneWidget);
    expect(find.text('Visitas relacionadas'), findsOneWidget);
    expect(find.text('Pedidos e documentos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates oficio with Gabriela signature',
      (WidgetTester tester) async {
    await login(tester);
    await openDesktopPage(tester, 'Oficios');

    await tester.tap(find.text('Novo oficio'));
    await tester.pumpAndSettle();
    await enterDialogText(tester, 1, 'Camara Municipal');
    await enterDialogText(tester, 2, 'Assunto do oficio');
    await enterDialogText(tester, 3, 'Texto completo do oficio.');
    await tester.tap(find.text('Emitir e assinar'));
    await tester.pumpAndSettle();

    expect(find.text('Assunto do oficio'), findsOneWidget);

    await tester.tap(find.text('Assunto do oficio'));
    await tester.pumpAndSettle();

    expect(find.text('MENSAGEM DO OFICIO'), findsOneWidget);
    expect(find.text('Texto completo do oficio.'), findsOneWidget);
    expect(find.text('Assinado digitalmente'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates project and opens its scope detail',
      (WidgetTester tester) async {
    await login(tester);
    await openDesktopPage(tester, 'Projetos');

    await tester.tap(find.text('Novo projeto'));
    await tester.pumpAndSettle();
    await enterDialogText(tester, 0, 'Projeto teste');
    await enterDialogText(tester, 1, 'Resumo do projeto');
    await enterDialogText(tester, 3, 'Escopo completo do projeto.');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Projeto teste'), findsOneWidget);

    await tester.tap(find.text('Projeto teste'));
    await tester.pumpAndSettle();

    expect(find.text('ESCOPO DO PROJETO'), findsOneWidget);
    expect(find.text('Escopo completo do projeto.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('creates resolution and opens related law detail',
      (WidgetTester tester) async {
    await login(tester);
    await openDesktopPage(tester, 'Resolucoes');

    await tester.tap(find.text('Nova resolucao'));
    await tester.pumpAndSettle();
    await enterDialogText(tester, 0, 'Resolucao teste');
    await enterDialogText(tester, 1, 'Referencia legal');
    await enterDialogText(tester, 3, 'Texto legal relacionado.');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Resolucao teste'), findsOneWidget);

    await tester.tap(find.text('Resolucao teste'));
    await tester.pumpAndSettle();

    expect(find.text('LEI RELACIONADA'), findsOneWidget);
    expect(find.text('Texto legal relacionado.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile agenda creates event without layout errors',
      (WidgetTester tester) async {
    await login(tester, size: const Size(390, 844));

    await tester.tap(find.text('Novo evento'));
    await tester.pumpAndSettle();
    await enterDialogText(tester, 0, 'Evento mobile');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Evento mobile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile reception registers and denies visit',
      (WidgetTester tester) async {
    await login(tester, size: const Size(390, 844));

    await tester.tap(find.byIcon(Icons.menu), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: find.byType(Drawer), matching: find.text('Recepcao')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Registrar visitante'));
    await tester.pumpAndSettle();
    await enterDialogText(tester, 0, 'Visitante Mobile');
    await tapAfterScroll(tester, find.byType(CheckboxListTile));
    await tapAfterScroll(tester, find.text('Registrar e notificar'));

    await tapAfterScroll(tester, find.text('Negar').last);
    await enterDialogText(tester, 0, 'Sem horario disponivel');
    await tapAfterScroll(tester, find.text('Registrar negativa'));

    expect(find.text('Motivo: Sem horario disponivel'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
