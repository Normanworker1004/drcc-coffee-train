import 'package:drcc_coffee_train/train_card.dart';
import 'package:fb_auth/data/blocs/auth/auth_state.dart';
import 'package:fb_auth/fb_auth.dart';
import 'package:fb_firestore/classes/index.dart';
import 'package:fb_firestore/fb_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class UpcomingTrains extends StatefulWidget {
  @override
  _UpcomingTrainsState createState() => _UpcomingTrainsState();
}

class _UpcomingTrainsState extends State<UpcomingTrains> {
  bool isMobileLayout;

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final _auth = BlocProvider.of<AuthBloc>(context);
    final size = MediaQuery.of(context).size;
    if (size.width > 420) {
      isMobileLayout = false;
    } else {
      isMobileLayout = true;
    }
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(MdiIcons.accountCircleOutline),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Account'),
                content: ListTile(
                  title: Text(AuthBloc.currentUser(context).displayName),
                  subtitle: Text(AuthBloc.currentUser(context).email),
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Log Out',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    onPressed: () {
                      _auth.add(LogoutEvent(AuthBloc.currentUser(context)));
                      Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
                    },
                  ),
                  FlatButton(
                    child: Text(
                      'Dismiss',
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
          title: Text('Upcoming Trains'),
          actions: <Widget>[
            isMobileLayout == false ? FlatButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/NewTrain'),
              icon: Icon(MdiIcons.trainVariant),
              label: Text('New Train'),
            ) : Container(),
          ],
        ),
        body: FutureBuilder<List<FbDocumentSnapshot>>(
          future: FbFirestore.getDocs('Trains'),
          builder: (context, snapshot) {
            print(snapshot);
            if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError && snapshot.connectionState == ConnectionState.done) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            } else {
              final trains = snapshot.data;
              if (size.width > 400) {
                return DesktopWebLayout(trains: trains);
              } else {
                return MobileLayout(trains: trains);
              }
            }
          },
        ),
        floatingActionButton: isMobileLayout == true ? FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).pushNamed('/NewTrain'),
          label: Text(
            'New Train',
            style: TextStyle(color: Colors.white),
          ),
          icon: Icon(
            MdiIcons.trainVariant,
            color: Colors.white,
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ) : Container(),
      ),
    );
  }
}

class MobileLayout extends StatefulWidget {
  final List<FbDocumentSnapshot> trains;

  MobileLayout({
    this.trains,
  });

  @override
  _MobileLayoutState createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  var _passengerCount;

  void getPassengerCount(String trainId) async {
    final passengerList = await FbFirestore.getDocs('Trains/$trainId/Passengers');
    setState(() {
      _passengerCount = passengerList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trains.length > 0) {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: widget.trains.length,
        itemBuilder: (context, index) {
          final train = widget.trains[index];
          final trainId = train.documentId;
          getPassengerCount(trainId);
          return TrainCard(
            trainId: trainId,
            submittedBy: train.data['SubmittedBy'],
            destination: train.data['Destination'],
            departureTime: train.data['DepartureTime'],
            passengerCount: _passengerCount,
            isRecurring: train.data['Recurring'],
          );
        },
      );
    } else {
      return Center(
        child: Text('No Upcoming Trains'),
      );
    }
  }
}

class DesktopWebLayout extends StatefulWidget {
  final List<FbDocumentSnapshot> trains;

  const DesktopWebLayout({
    Key key,
    this.trains,
  }) : super(key: key);

  @override
  _DesktopWebLayoutState createState() => _DesktopWebLayoutState();
}

class _DesktopWebLayoutState extends State<DesktopWebLayout> {
  var _passengerCount;

  void getPassengerCount(String trainId) async {
    final passengerList = await FbFirestore.getDocs('Trains/$trainId/Passengers');
    setState(() {
      _passengerCount = passengerList.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    double _aspectRatio;
    int _crossAxisCount;
    final double _screenWidth = MediaQuery.of(context).size.width;
    if (_screenWidth > 400 && _screenWidth < 475) {
      _crossAxisCount = 1;
      _aspectRatio = 2.7;
    } else if (_screenWidth > 475 && _screenWidth <= 600) {
      _crossAxisCount = 1;
      _aspectRatio = 3.2;
    } else if (_screenWidth > 600 && _screenWidth <= 710) {
      _crossAxisCount = 1;
      _aspectRatio = 4;
    } else if (_screenWidth > 710 && _screenWidth <= 800) {
      _crossAxisCount = 1;
      _aspectRatio = 5;
    } else if (_screenWidth > 800 && _screenWidth <= 900) {
      _crossAxisCount = 1;
      _aspectRatio = 5.5;
    } else if (_screenWidth > 900 && _screenWidth <= 1100) {
      _crossAxisCount = 2;
      _aspectRatio = 3;
    } else if (_screenWidth > 1100 && _screenWidth <= 1200) {
      _crossAxisCount = 2;
      _aspectRatio = 3.5;
    } else if (_screenWidth > 1200 && _screenWidth <= 1350) {
      _crossAxisCount = 2;
      _aspectRatio = 4;
    } else if (_screenWidth > 1350 && _screenWidth <= 1919) {
      _crossAxisCount = 3;
      _aspectRatio = 3;
    } else if (_screenWidth >= 1920) {
      _crossAxisCount = 3;
      _aspectRatio = 4;
    }

    if (widget.trains.length > 0) {
      return GridView.builder(
        padding: EdgeInsets.all(16),
        itemCount: widget.trains.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _crossAxisCount,
          childAspectRatio: _aspectRatio,
        ),
        itemBuilder: (context, index) {
          final train = widget.trains[index];
          final trainId = train.documentId;
          getPassengerCount(trainId);
          return TrainCard(
            trainId: trainId,
            submittedBy: train.data['SubmittedBy'],
            destination: train.data['Destination'],
            departureTime: train.data['DepartureTime'],
            passengerCount: _passengerCount,
            isRecurring: train.data['Recurring'],
          );
        },
      );
    } else {
      return Center(
        child: Text('No Upcoming Trains'),
      );
    }
  }
}

