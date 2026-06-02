import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/app_models.dart';

class MockDataService {
  List<DemoAccount> loginAccounts() {
    return [
      DemoAccount(
        email: 'gabriela@smm.gov.br',
        password: '********',
        profile: initialProfile(),
      ),
      const DemoAccount(
        email: 'ademir@gmail.com',
        password: 'Ademir123@',
        profile: UserProfile(
          fullName: 'Ademir',
          cpf: '000.000.000-00',
          birthDate: '01/01/1990',
          email: 'ademir@gmail.com',
          phone: '(21) 99901-0008',
          role: 'Coordenacao - Administrador',
          sector: 'Coordenacao',
          registration: 'SMM-ADM-002',
          initials: 'AD',
          avatarColor: AppColors.roseDark,
          photoPath: null,
        ),
      ),
    ];
  }

  UserProfile? authenticate(String email, String password) {
    final normalizedEmail = email.trim().toLowerCase();
    for (final account in loginAccounts()) {
      if (account.email == normalizedEmail && account.password == password) {
        return account.profile;
      }
    }
    return null;
  }

  UserProfile initialProfile() {
    return const UserProfile(
      fullName: 'Dra. Gabriela Santos',
      cpf: '123.456.789-00',
      birthDate: '14/03/1984',
      email: 'gabriela@smm.gov.br',
      phone: '(21) 99999-0000',
      role: 'Secretaria - Administrador',
      sector: 'Secretaria',
      registration: 'SMM-ADM-001',
      initials: 'DG',
      avatarColor: AppColors.roseDark,
      photoPath: null,
    );
  }

  List<AgendaEvent> initialEvents() {
    return [
      AgendaEvent(
        date: DateTime(2026, 5, 20),
        time: '08:30',
        title: 'Reuniao com CREAM',
        people: 'Juliana Santos, Dra. Gabriela',
        description: 'Alinhamento de atendimentos prioritarios.',
        color: AppColors.rose,
        tag: 'Interno',
      ),
      AgendaEvent(
        date: DateTime(2026, 5, 20),
        time: '10:00',
        title: 'Atendimento intersetorial',
        people: 'Programa SerH e Enfrentamento',
        description: 'Acompanhamento de caso com a rede.',
        color: AppColors.green,
        tag: 'Setores',
      ),
      AgendaEvent(
        date: DateTime(2026, 5, 21),
        time: '14:30',
        title: 'Oficio para Camara Municipal',
        people: 'Dra. Gabriela',
        description: 'Assinatura e envio de oficio externo.',
        color: const Color(0xFF185FA5),
        tag: 'Documento',
      ),
    ];
  }

  List<AppDocument> initialDocuments() {
    return const [
      AppDocument(
          kind: DocumentKind.ci,
          number: 'CI-2026/042',
          subject: 'Solicitacao de material administrativo',
          party: 'Administrativo',
          status: 'Pendente',
          received: false,
          sender: 'Dra. Gabriela Santos',
          recipient: 'Administrativo',
          message:
              'Solicito a verificacao e separacao dos materiais administrativos necessarios para os atendimentos desta semana, com prioridade para formularios impressos, pastas de protocolo e materiais de recepcao.'),
      AppDocument(
          kind: DocumentKind.ci,
          number: 'CI-2026/041',
          subject: 'Reuniao de alinhamento intersetorial',
          party: 'CREAM',
          status: 'Recebido',
          received: false,
          sender: 'Maria Carvalho',
          recipient: 'CREAM',
          message:
              'Encaminho convocatoria para reuniao de alinhamento intersetorial com foco nos casos prioritarios, atualizacao dos encaminhamentos e definicao de responsabilidades entre os setores envolvidos.'),
      AppDocument(
          kind: DocumentKind.ci,
          number: 'CI-2026/018',
          subject: 'Relatorio mensal de atividades',
          party: 'Controle Interno',
          status: 'Recebido',
          received: true,
          sender: 'Controle Interno',
          recipient: 'Secretaria da Mulher',
          message:
              'Solicitamos o envio do relatorio mensal consolidado contendo atendimentos realizados, acoes executadas, demandas pendentes e observacoes relevantes dos setores da pasta.'),
      AppDocument(
          kind: DocumentKind.oficio,
          number: 'OF-2026/019',
          subject: 'Resposta a Camara Municipal',
          party: 'Camara Municipal',
          status: 'Assinado',
          received: false,
          sender: 'Secretaria da Mulher',
          recipient: 'Camara Municipal de Mangaratiba',
          message:
              'Em resposta ao expediente recebido, informamos as acoes atualmente desenvolvidas pela Secretaria da Mulher, incluindo atendimento especializado, projetos de prevencao e articulacao com a rede municipal.'),
      AppDocument(
          kind: DocumentKind.oficio,
          number: 'OF-2026/014',
          subject: 'Solicitacao externa de informacoes',
          party: 'Gabinete',
          status: 'Pendente',
          received: true,
          sender: 'Gabinete do Executivo',
          recipient: 'Secretaria da Mulher',
          message:
              'Solicita-se manifestacao tecnica sobre as atividades recentes da pasta, projetos em andamento, setores envolvidos e eventuais necessidades administrativas para continuidade dos servicos.'),
    ];
  }

  List<VisitRecord> initialVisits() {
    return const [
      VisitRecord(
          name: 'Maria Jose Ferreira',
          document: '123.456.789-00',
          sector: 'CREAM',
          target: 'Juliana Santos',
          visitReason: 'Solicitar orientacao sobre atendimento no CREAM',
          status: 'Aguardando',
          time: '15:05',
          pending: true),
      VisitRecord(
          name: 'Carlos Eduardo Silva',
          document: '987.654.321-00',
          sector: 'Secretaria',
          target: 'Dra. Gabriela',
          visitReason: 'Reuniao solicitada com a Secretaria',
          status: 'Aguardando',
          time: '15:18',
          pending: true),
      VisitRecord(
          name: 'Ana Beatriz Costa',
          document: 'CPF: 111.***.***.00',
          sector: 'CREAM',
          target: 'Juliana Santos',
          visitReason: 'Acompanhamento de atendimento ja iniciado',
          status: 'Aceito',
          time: '09:12'),
      VisitRecord(
          name: 'Roberto Alves',
          document: 'RG: 12.***.***-5',
          sector: 'Administrativo',
          target: 'Paulo Ribeiro',
          visitReason: 'Entrega de documentos ao administrativo',
          status: 'Aguardando',
          time: '10:45'),
      VisitRecord(
          name: 'Sandra Melo',
          document: 'CPF: 222.***.***.11',
          sector: 'SerH',
          target: 'Ana Paula Lima',
          visitReason: 'Solicitacao de atendimento social',
          status: 'Negado',
          denialReason: 'Sem horario disponivel no setor SerH',
          time: '11:30'),
      VisitRecord(
          name: 'Pedro Nascimento',
          document: 'RG: 98.***.***-3',
          sector: 'Secretaria',
          target: 'Dra. Gabriela',
          visitReason: 'Despacho presencial com a Secretaria',
          status: 'Aceito',
          time: '14:00'),
    ];
  }
}

class DemoAccount {
  const DemoAccount({
    required this.email,
    required this.password,
    required this.profile,
  });

  final String email;
  final String password;
  final UserProfile profile;
}
