import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fb_auth/data/blocs/auth/auth_bloc.dart';
import 'package:fb_auth/data/blocs/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:groovin_widgets/outline_dropdown_button.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:fb_firestore/fb_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewTrain extends StatefulWidget {
  NewTrain({Key key}) : super(key: key);

  @override
  _NewTrainState createState() => _NewTrainState();
}

class _NewTrainState extends State<NewTrain> {
  final timeFormat = DateFormat("hh:mm a");
  TimeOfDay departureTime;
  String selection;
  bool isRecurring = false;
  String destination;

  bool isMobileLayout;

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();  //"6:00 AM"
    return format.format(dt);
  }

  String typeOfPlaceSuggestion;

  @override
  Widget build(BuildContext context) {
    EdgeInsetsGeometry _formPadding;

    final _size = MediaQuery.of(context).size;
    if (_size.width > 420) {
      isMobileLayout = false;
    } else {
      isMobileLayout = true;
    }

    if (_size.width >= 650 && _size.width < 1000) {
      _formPadding = EdgeInsets.only(top: 24, left: 75, right: 75, bottom: 24);
    } else if (_size.width >= 1000 && _size.width < 1920) {
      _formPadding = EdgeInsets.only(top: 24, left: 175, right: 175, bottom: 24);
    } else if (_size.width >= 1920) {
      _formPadding = EdgeInsets.only(top: 24, left: 375, right: 375, bottom: 24);
    } else {
      _formPadding = EdgeInsets.all(24);
    }

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text('New Train'),
          centerTitle: true,
          actions: [
            isMobileLayout == false ? FlatButton.icon(
              onPressed: () {
                try {
                  if (departureTime != null && destination.isNotEmpty) {
                    final formattedDepartureTime = formatTimeOfDay(departureTime);
                    FbFirestore.addDoc('Trains', {
                      'SubmittedBy': AuthBloc.currentUser(context).displayName,
                      'Destination': destination,
                      'DepartureTime': formattedDepartureTime,
                      'Recurring': isRecurring,
                    });
                    Navigator.pop(context);
                  }
                } catch (e) {
                  print(e);
                }
              },
              icon: Icon(MdiIcons.contentSave),
              label: Text('Save'),
            ) : Container(),
          ]
        ),
        body: SingleChildScrollView(
          padding: _formPadding,
          child: Column(
            children: <Widget>[
              OutlineDropdownButton(
                items: [
                  DropdownMenuItem(
                    child: Text('Brody Cafe'),
                    value: 'Brody Cafe',
                  ),
                  DropdownMenuItem(
                    child: Text("Eddie's"),
                    value: 'Eddies',
                  ),
                  DropdownMenuItem(
                    child: Text('Honeygrow'),
                    value: 'Honeygrow',
                  ),
                  DropdownMenuItem(
                    child: Text('Home Slyce'),
                    value: 'Home Slyce',
                  ),
                  DropdownMenuItem(
                    child: Text('Insomnia Cookies'),
                    value: 'Insomnia Cookies',
                  ),
                ],
                value: destination,
                hint: Row(
                  children: <Widget>[
                    SizedBox(width: 4),
                    Icon(Icons.location_city),
                    SizedBox(width: 16),
                    Text('Destination'),
                  ],
                ),
                onChanged: (selection) {
                  setState(() {
                    destination = selection;
                  });
                },
              ),
              SizedBox(height: 24),
              DateTimeField(
                format: timeFormat,
                onShowPicker: (context, currentValue) async {
                  departureTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                  );
                  print(departureTime);
                  return DateTimeField.convert(departureTime);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(MdiIcons.clock),
                  labelText: 'Departure Time',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Colors.white,
                      ),
                      left: BorderSide(
                        color: Colors.white,
                      ),
                      top: BorderSide(
                        color: Colors.white,
                      ),
                      bottom: BorderSide(
                        color: Colors.white,
                      ),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                child: CheckboxListTile(
                  title: Text('Recurring?'),
                  activeColor: Theme.of(context).accentColor,
                  secondary: Icon(MdiIcons.calendarRepeat),
                  value: isRecurring,
                  onChanged: (sel) {
                    setState(
                          () {
                        isRecurring = sel;
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: isMobileLayout == true ? FloatingActionButton.extended(
          onPressed: () {
            try {
              if (departureTime != null && destination.isNotEmpty) {
                final formattedDepartureTime = formatTimeOfDay(departureTime);
                FbFirestore.addDoc('Trains', {
                  'SubmittedBy': AuthBloc.currentUser(context).displayName,
                  'Destination': destination,
                  'DepartureTime': formattedDepartureTime,
                  'Recurring': isRecurring,
                });
                Navigator.pop(context);
              }
            } catch (e) {
              print(e);
            }
          },
          label: Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          icon: Icon(
            MdiIcons.contentSave,
            color: Colors.white,
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ) : Container(),
      ),
    );
  }
}
