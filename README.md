 # Sistema Gerir

Aplicativo Flutter nativo para Windows, Android e iOS da SMM Secretaria da Mulher de Mangaratiba.

## Escopo inicial

- Login e usuarios.
- Agenda como tela inicial.
- Comunicacao Interna com enviados e recebidos.
- Oficios com enviados e recebidos.
- Projetos, Resolucoes, CODIMM, Fluxograma, Setores e Recepcao.
- Trilha de auditoria e sinalizacao LGPD.
- Estrutura preparada para trocar os dados locais por Supabase posteriormente.

## Rodar

O Flutter SDK fica em `C:\Users\dahan\dev\flutter` e o `bin` foi adicionado ao PATH do usuario. Feche e abra o terminal antes de usar `flutter` diretamente.

Em um terminal novo:

```powershell
flutter pub get
flutter run -d windows
```

Para Android/iOS, use os emuladores/dispositivos configurados pelo Flutter:

```powershell
flutter devices
flutter run -d <device-id>
```
