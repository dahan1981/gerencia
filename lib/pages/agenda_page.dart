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

class AgendaPage extends StatefulWidget {
  const AgendaPage({
    super.key,
    required this.events,
    required this.onAddEvent,
    required this.onUpdateEvent,
    required this.onDeleteEvent,
  });

  final List<AgendaEvent> events;
  final ValueChanged<AgendaEvent> onAddEvent;
  final void Function(AgendaEvent current, AgendaEvent updated) onUpdateEvent;
  final ValueChanged<AgendaEvent> onDeleteEvent;

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  late DateTime visibleMonth;
  late DateTime selectedDay;
  String selectedSectorFilter = allSectorsLabel;
  String selectedUserFilter = allAccountsLabel;

  @override
  void initState() {
    super.initState();
    selectedDay = todayDate();
    visibleMonth = DateTime(selectedDay.year, selectedDay.month);
  }

  void shiftMonth(int delta) {
    setState(() {
      visibleMonth = DateTime(visibleMonth.year, visibleMonth.month + delta);
      selectedDay = DateTime(visibleMonth.year, visibleMonth.month, 1);
    });
  }

  Future<void> createEvent() async {
    final event = await showAppDialog<AgendaEvent>(
      context,
      EventDialog(initialDate: selectedDay),
    );
    if (event == null) return;
    widget.onAddEvent(event);
    notifyEventParticipants(event);
    setState(() {
      visibleMonth = DateTime(event.date.year, event.date.month);
      selectedDay = event.date;
    });
  }

  Future<void> editEvent(AgendaEvent current) async {
    final updated = await showAppDialog<AgendaEvent>(
      context,
      EventDialog(initialDate: current.date, event: current),
    );
    if (updated == null) return;
    widget.onUpdateEvent(current, updated);
    notifyEventParticipants(updated);
    setState(() {
      visibleMonth = DateTime(updated.date.year, updated.date.month);
      selectedDay = updated.date;
    });
  }

  Future<void> deleteEvent(AgendaEvent event) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir evento'),
        content: Text('Deseja excluir "${event.title}" da agenda?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    widget.onDeleteEvent(event);
    setState(() {});
  }

  bool eventMatchesFilters(AgendaEvent event) {
    final participants =
        event.people.split(',').map((value) => value.trim()).toList();
    if (selectedUserFilter != allAccountsLabel &&
        !participants.contains(selectedUserFilter) &&
        event.people != allAccountsLabel) {
      return false;
    }
    if (selectedSectorFilter != allSectorsLabel &&
        event.people != allAccountsLabel) {
      final hasSectorParticipant = participants.any(
          (participant) => userSector(participant) == selectedSectorFilter);
      if (!hasSectorParticipant) return false;
    }
    return true;
  }

  void notifyEventParticipants(AgendaEvent event) {
    final target =
        event.people == allAccountsLabel ? 'todos os usuarios' : event.people;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Participantes notificados: $target')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents =
        widget.events.where(eventMatchesFilters).toList(growable: false);
    final selectedEvents = filteredEvents
        .where((event) =>
            event.date.year == selectedDay.year &&
            event.date.month == selectedDay.month &&
            event.date.day == selectedDay.day)
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final monthTitle =
        '${monthNames[visibleMonth.month - 1]} ${visibleMonth.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PageHeading(
          icon: Icons.calendar_today_outlined,
          title: 'Agenda',
          subtitle: monthTitle,
          action: FilledButton.icon(
            onPressed: createEvent,
            icon: const Icon(Icons.add),
            label: const Text('Novo evento'),
          ),
        ),
        const SizedBox(height: 18),
        const LgpdBanner(
          text:
              'Agenda usa dados de participantes somente para organizacao institucional, notificacao do evento e historico operacional.',
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: AppFormGrid(
            children: [
              AppDropdownField(
                label: 'Filtrar por setor',
                value: selectedSectorFilter,
                options: [allSectorsLabel, ...appSectorNames],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    selectedSectorFilter = value;
                    selectedUserFilter = allAccountsLabel;
                  });
                },
              ),
              AppDropdownField(
                label: 'Filtrar por usuario',
                value: selectedUserFilter,
                options: [
                  allAccountsLabel,
                  ...usersForSector(selectedSectorFilter),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedUserFilter = value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 800;
            return Flex(
              direction: compact ? Axis.vertical : Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: compact ? double.infinity : 390,
                  child: MiniCalendar(
                    visibleMonth: visibleMonth,
                    selectedDay: selectedDay,
                    events: filteredEvents,
                    onPrevious: () => shiftMonth(-1),
                    onNext: () => shiftMonth(1),
                    onSelected: (day) => setState(() => selectedDay = day),
                  ),
                ),
                SizedBox(width: compact ? 0 : 16, height: compact ? 16 : 0),
                if (compact)
                  EventList(
                    date: selectedDay,
                    events: selectedEvents,
                    onEdit: editEvent,
                    onDelete: deleteEvent,
                  )
                else
                  Expanded(
                    child: EventList(
                      date: selectedDay,
                      events: selectedEvents,
                      onEdit: editEvent,
                      onDelete: deleteEvent,
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

class MiniCalendar extends StatelessWidget {
  const MiniCalendar({
    super.key,
    required this.visibleMonth,
    required this.selectedDay,
    required this.events,
    required this.onPrevious,
    required this.onNext,
    required this.onSelected,
  });

  final DateTime visibleMonth;
  final DateTime selectedDay;
  final List<AgendaEvent> events;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final monthTitle =
        '${monthNames[visibleMonth.month - 1]} ${visibleMonth.year}';
    final daysInMonth =
        DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final firstWeekday =
        DateTime(visibleMonth.year, visibleMonth.month, 1).weekday % 7;
    final eventDays = events
        .where((event) =>
            event.date.year == visibleMonth.year &&
            event.date.month == visibleMonth.month)
        .map((event) => event.date.day)
        .toSet();

    return SectionCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    monthTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: GridView.count(
              key: ValueKey(monthTitle),
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [
                for (final label in ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'])
                  _CalendarLabel(label),
                for (var i = 0; i < firstWeekday; i++) const SizedBox.shrink(),
                for (var day = 1; day <= daysInMonth; day++)
                  _CalendarDay(
                    day: day,
                    selected: selectedDay.year == visibleMonth.year &&
                        selectedDay.month == visibleMonth.month &&
                        selectedDay.day == day,
                    hasEvent: eventDays.contains(day),
                    onTap: () => onSelected(
                      DateTime(visibleMonth.year, visibleMonth.month, day),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarLabel extends StatelessWidget {
  const _CalendarLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.gray,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.selected,
    required this.hasEvent,
    required this.onTap,
  });

  final int day;
  final bool selected;
  final bool hasEvent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: selected ? AppColors.rose : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasEvent && !selected
                ? AppColors.rose.withValues(alpha: 0.25)
                : Colors.transparent,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontSize: 14,
                color: selected ? Colors.white : AppColors.grayDark,
                fontWeight: hasEvent ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            if (hasEvent)
              Positioned(
                bottom: 7,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : AppColors.rose,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class EventList extends StatelessWidget {
  const EventList({
    super.key,
    required this.date,
    required this.events,
    required this.onEdit,
    required this.onDelete,
  });

  final DateTime date;
  final List<AgendaEvent> events;
  final ValueChanged<AgendaEvent> onEdit;
  final ValueChanged<AgendaEvent> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          child: Row(
            children: [
              const Icon(Icons.today_outlined, color: AppColors.rose),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Eventos de ${appDate(date)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              AppBadge(text: '${events.length}'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: events.isEmpty
              ? const SectionCard(
                  key: ValueKey('empty-events'),
                  child: EmptyState(
                    icon: Icons.event_available_outlined,
                    title: 'Nenhum evento nesse dia',
                    subtitle: 'Use Novo evento para criar um compromisso.',
                  ),
                )
              : Column(
                  key: ValueKey(
                    '${date.year}-${date.month}-${date.day}-${events.length}',
                  ),
                  children: [
                    for (final event in events) ...[
                      SectionCard(
                        padding: EdgeInsets.zero,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => onEdit(event),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final compact = constraints.maxWidth < 430;
                              final eventBody = Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 48,
                                    child: Text(
                                      event.time,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.gray,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 3,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: event.color,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          event.title,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          event.people,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.gray,
                                          ),
                                        ),
                                        if (event.description.isNotEmpty) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            event.description,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppColors.grayDark,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 7),
                                        StatusPill(
                                          label: event.tag,
                                          color: event.color,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                              final actions = Wrap(
                                spacing: 2,
                                runSpacing: 2,
                                alignment: compact
                                    ? WrapAlignment.end
                                    : WrapAlignment.start,
                                children: [
                                  IconButton(
                                    tooltip: 'Editar evento',
                                    onPressed: () => onEdit(event),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Excluir evento',
                                    onPressed: () => onDelete(event),
                                    icon: const Icon(Icons.delete_outline),
                                    color: const Color(0xFFA32D2D),
                                  ),
                                ],
                              );

                              return Padding(
                                padding: const EdgeInsets.all(16),
                                child: compact
                                    ? Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          eventBody,
                                          const SizedBox(height: 8),
                                          actions,
                                        ],
                                      )
                                    : Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(child: eventBody),
                                          const SizedBox(width: 8),
                                          actions,
                                        ],
                                      ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class EventDialog extends StatefulWidget {
  const EventDialog({super.key, required this.initialDate, this.event});

  final DateTime initialDate;
  final AgendaEvent? event;

  @override
  State<EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<EventDialog> {
  late final TextEditingController title;
  late final TextEditingController date;
  final time = TextEditingController(text: '09:00');
  final description = TextEditingController();
  List<String> selectedPeople = const ['Dra. Gabriela Santos'];

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    title = TextEditingController(text: event?.title ?? 'Novo compromisso');
    date =
        TextEditingController(text: appDate(event?.date ?? widget.initialDate));
    time.text = event?.time ?? '09:00';
    description.text = event?.description ?? '';
    final initialPeople = event?.people;
    if (initialPeople == allAccountsLabel) {
      selectedPeople = const [allAccountsLabel];
    } else if (initialPeople != null) {
      final values = initialPeople
          .split(',')
          .map((value) => value.trim())
          .map((value) =>
              value == 'Dra. Gabriela' ? 'Dra. Gabriela Santos' : value)
          .where(appUserNames.contains)
          .toList();
      if (values.isNotEmpty) {
        selectedPeople = values;
      }
    }
  }

  @override
  void dispose() {
    title.dispose();
    date.dispose();
    time.dispose();
    description.dispose();
    super.dispose();
  }

  DateTime parseDate() {
    final parts = date.text.split('/');
    if (parts.length != 3) return widget.initialDate;
    return DateTime(
      int.tryParse(parts[2]) ?? widget.initialDate.year,
      int.tryParse(parts[1]) ?? widget.initialDate.month,
      int.tryParse(parts[0]) ?? widget.initialDate.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppDialogScaffold(
      title: widget.event == null ? 'Novo evento na agenda' : 'Editar evento',
      actionLabel: 'Salvar',
      actionIcon: Icons.check,
      onSubmit: () {
        if (!FormValidators.hasText(title.text)) {
          showInlineError(context, 'Informe o titulo do evento.');
          return;
        }
        if (!FormValidators.isBrazilianDate(date.text)) {
          showInlineError(
              context, 'Informe uma data valida no formato DD/MM/AAAA.');
          return;
        }
        if (!FormValidators.isTime(time.text)) {
          showInlineError(
              context, 'Informe um horario valido no formato HH:MM.');
          return;
        }
        Navigator.of(context).pop(
          AgendaEvent(
            date: parseDate(),
            time: time.text.trim(),
            title: title.text.trim(),
            people: selectedPeople.join(', '),
            description: description.text.trim(),
            color: widget.event?.color ?? AppColors.rose,
            tag: widget.event?.tag ?? 'Interno',
            legalBasis:
                widget.event?.legalBasis ?? 'Execucao de politica publica',
            dataPurpose: widget.event?.dataPurpose ??
                'Organizacao de agenda institucional',
            accessLevel: widget.event?.accessLevel ??
                'Participantes e usuarios autorizados',
          ),
        );
      },
      children: [
        AppTextField(
          label: 'Titulo',
          hint: 'Ex.: Reuniao com CREAM',
          controller: title,
        ),
        AppFormGrid(
          children: [
            AppTextField(label: 'Data', hint: '20/05/2026', controller: date),
            AppTextField(label: 'Horario', hint: '09:00', controller: time),
          ],
        ),
        AppMultiSelectField(
          label: 'Participantes',
          options: [allAccountsLabel, ...appUserNames],
          selected: selectedPeople,
          allOption: allAccountsLabel,
          onChanged: (values) => setState(() => selectedPeople = values),
        ),
        const LgpdBanner(
          text:
              'Os participantes serao usados para notificar o evento e limitar a visualizacao por usuario ou setor.',
          dense: true,
        ),
        AppTextField(
          label: 'Descricao',
          hint: 'Pauta da reuniao',
          maxLines: 3,
          controller: description,
        ),
      ],
    );
  }
}
