import 'package:calendar_events/PROVIDER/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calendar_events/utils.dart';
import 'package:calendar_events/MODEL/event.dart';

class EventEditingPage extends StatefulWidget {
  final Event? event;

  const EventEditingPage({
    Key? key,
    this.event,
  }) : super(key: key);

  @override
  _EventEditingPageState createState() => _EventEditingPageState();
}

class _EventEditingPageState extends State<EventEditingPage> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  late DateTime fromDate;
  late DateTime toDate;
  bool isAllDay = false;

  @override
  void initState() {
    super.initState();

    if (widget.event == null) {
      fromDate = DateTime.now();
      toDate = DateTime.now().add(Duration(hours: 2));
    } else {
      final event = widget.event!;
      titleController.text = event.title;
      descriptionController.text = event.description;
      fromDate = event.from;
      toDate = event.to;
      isAllDay = event.isAllDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(),
        actions: buildEditingActions(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTitle(),
              SizedBox(height: 16),
              buildDateTimePickers(),
              SizedBox(height: 16),
              buildAllDayEventCheckbox(),
              SizedBox(height: 16),
              buildDescription(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTitle() => TextFormField(
        controller: titleController,
        decoration: InputDecoration(
          labelText: 'ADD Title',
          border: OutlineInputBorder(),
        ),
        validator: (title) =>
            title != null && title.isEmpty ? 'Title cannot be empty' : null,
      );

  Widget buildDateTimePickers() => Column(
        children: [
          buildFrom(),
          buildTo(),
        ],
      );

  Widget buildFrom() => buildHeader(
        header: 'FROM',
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: buildDropDownField(
                text: Utils.toDate(fromDate),
                onClicked: () => pickFromDateTime(pickDate: true),
              ),
            ),
            Expanded(
              child: buildDropDownField(
                text: Utils.toTime(fromDate),
                onClicked: () => pickFromDateTime(pickDate: false),
              ),
            ),
          ],
        ),
      );

  Widget buildTo() => buildHeader(
        header: 'TO',
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: buildDropDownField(
                text: Utils.toDate(toDate),
                onClicked: () =>
                    pickToDateTime(pickDate: true), 
              ),
            ),
            Expanded(
              child: buildDropDownField(
                text: Utils.toTime(toDate),
                onClicked: () =>
                    pickToDateTime(pickDate: false), 
              ),
            ),
          ],
        ),
      );

  Widget buildHeader({required String header, required Widget child}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            header,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          child,
        ],
      );

  Widget buildDropDownField({
    required String text,
    required VoidCallback onClicked,
  }) =>
      ListTile(
        title: Text(text),
        trailing: Icon(Icons.arrow_drop_down),
        onTap: onClicked,
      );

  Widget buildAllDayEventCheckbox() => CheckboxListTile(
        controlAffinity: ListTileControlAffinity.leading,
        title: Text('All Day Event'),
        value: isAllDay,
        onChanged: (value) => setState(() => isAllDay = value ?? false),
      );

  Widget buildDescription() => TextFormField(
        controller: descriptionController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: 'Description',
          border: OutlineInputBorder(),
        ),
        validator: (desc) =>
            desc != null && desc.isEmpty ? 'Description cannot be empty' : null,
      );

  Future pickFromDateTime({required bool pickDate}) async {
    final date = await pickDateTime(fromDate, pickDate: pickDate);
    if (date == null) return;

    if (date.isAfter(toDate)) {
      toDate = DateTime(
        date.year,
        date.month,
        date.day,
        toDate.hour,
        toDate.minute,
      );
    }

    setState(() => fromDate = date);
  }

  Future pickToDateTime({required bool pickDate}) async {
    final date = await pickDateTime(toDate, pickDate: pickDate);
    if (date == null) return;

    setState(() => toDate = date);
  }

  Future<DateTime?> pickDateTime(DateTime initialDate,
      {required bool pickDate}) async {
    if (pickDate) {
      final date = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101),
      );
      if (date == null) return null;

      final time =
          Duration(hours: initialDate.hour, minutes: initialDate.minute);
      return date.add(time);
    } else {
      final timeOfDay = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      if (timeOfDay == null) return null;

      final date = DateTime(
        initialDate.year,
        initialDate.month,
        initialDate.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
      return date;
    }
  }

  List<Widget> buildEditingActions() => [
        ElevatedButton.icon(
          icon: Icon(Icons.done),
          label: Text('SAVE'),
          onPressed: saveForm,
        ),
      ];

  Future saveForm() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) return;

    final event = Event(
      title: titleController.text,
      description: descriptionController.text, 
      from: fromDate,
      to: toDate,
      isAllDay: isAllDay,
    );

    final isEditing = widget.event != null;
    final provider = Provider.of<EventProvider>(context, listen: false);

    if (isEditing) {
      provider.editEvent(event, widget.event!);
      Navigator.of(context).pop();
    } else {
      provider.addEvent(event);
      Navigator.of(context).pop();
    }
  }
}
