import 'package:flutter/material.dart';

enum AppSection {
  agenda('Agenda', 'Calendario e eventos', Icons.calendar_today_outlined),
  recepcao('Recepcao', 'Entrada e visitantes', Icons.door_front_door_outlined),
  clientes('Clientes', 'Pessoas cadastradas', Icons.people_alt_outlined),
  ci('CI', 'Comunicacao Interna', Icons.forward_to_inbox_outlined),
  oficios('Oficios', 'Documentos externos', Icons.description_outlined),
  projetos('Projetos', 'Acompanhamento', Icons.business_center_outlined),
  resolucoes('Resolucoes', 'Legislacao e normas', Icons.balance_outlined),
  setores('Setores', 'Estrutura interna', Icons.apartment_outlined),
  fluxograma('Fluxograma', 'Papeis da equipe', Icons.account_tree_outlined),
  codimm('CODIMM', 'Modulo reservado', Icons.groups_2_outlined),
  usuarios(
      'Usuarios', 'Cadastros e historicos', Icons.manage_accounts_outlined),
  perfil('Perfil', 'Dados do usuario', Icons.person_outline),
  auditoria('Auditoria', 'Logs e LGPD', Icons.verified_user_outlined);

  const AppSection(this.title, this.subtitle, this.icon);
  final String title;
  final String subtitle;
  final IconData icon;
}
