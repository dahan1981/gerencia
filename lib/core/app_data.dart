import '../models/app_models.dart';

const appUsers = [
  AppUser(
    name: 'Dra. Gabriela Santos',
    sector: 'Secretaria',
    role: 'Secretaria - Administrador',
    email: 'gabriela@smm.gov.br',
    phone: '(21) 99901-0001',
    registration: 'SMM-001',
    createdAt: '02/01/2026',
  ),
  AppUser(
    name: 'Maria Carvalho',
    sector: 'Secretaria',
    role: 'Coordenacao de projetos',
    email: 'maria.carvalho@smm.gov.br',
    phone: '(21) 99901-0002',
    registration: 'SMM-002',
    createdAt: '05/01/2026',
  ),
  AppUser(
    name: 'Ana Paula Lima',
    sector: 'SerH',
    role: 'Atendimento',
    email: 'ana.lima@smm.gov.br',
    phone: '(21) 99901-0003',
    registration: 'SMM-003',
    createdAt: '07/01/2026',
  ),
  AppUser(
    name: 'Juliana Santos',
    sector: 'CREAM',
    role: 'Tecnica CREAM',
    email: 'juliana.santos@smm.gov.br',
    phone: '(21) 99901-0004',
    registration: 'SMM-004',
    createdAt: '10/01/2026',
  ),
  AppUser(
    name: 'Roberta Faria',
    sector: 'Recepcao',
    role: 'Recepcao',
    email: 'roberta.faria@smm.gov.br',
    phone: '(21) 99901-0005',
    registration: 'SMM-005',
    createdAt: '12/01/2026',
  ),
  AppUser(
    name: 'Paulo Ribeiro',
    sector: 'Administrativo',
    role: 'Administrativo',
    email: 'paulo.ribeiro@smm.gov.br',
    phone: '(21) 99901-0006',
    registration: 'SMM-006',
    createdAt: '15/01/2026',
  ),
  AppUser(
    name: 'Controle Interno',
    sector: 'Controle Interno',
    role: 'Auditoria interna',
    email: 'controle.interno@smm.gov.br',
    phone: '(21) 99901-0007',
    registration: 'SMM-007',
    createdAt: '18/01/2026',
  ),
  AppUser(
    name: 'Ademir',
    sector: 'Coordenacao',
    role: 'Coordenacao - Administrador',
    email: 'ademir@gmail.com',
    phone: '(21) 99901-0008',
    registration: 'SMM-ADM-002',
    createdAt: '02/06/2026',
  ),
];

final appUserNames = appUsers.map((user) => user.name).toList();

const allAccountsLabel = 'Todos os usuarios';

const appSectorNames = [
  'Secretaria',
  'CREAM',
  'SerH',
  'Recepcao',
  'Administrativo',
  'Controle Interno',
  'Coordenacao',
  'CODIMM',
];

const allSectorsLabel = 'Todos os setores';

List<String> usersForSector(String sector) {
  if (sector == allSectorsLabel) return appUserNames;
  return appUsers
      .where((user) => user.sector == sector)
      .map((user) => user.name)
      .toList();
}

String userSector(String name) {
  return appUsers
      .firstWhere((user) => user.name == name,
          orElse: () => const AppUser(
                name: '',
                sector: '',
                role: '',
                email: '',
                phone: '',
                registration: '',
                createdAt: '',
              ))
      .sector;
}

bool listTextContainsPerson(String text, String person) {
  return text == allAccountsLabel ||
      text.split(',').map((value) => value.trim()).contains(person);
}

bool listTextContainsSector(String text, String sector) {
  return text == allSectorsLabel ||
      text.split(',').map((value) => value.trim()).contains(sector);
}
