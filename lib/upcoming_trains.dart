import 'package:drcc_coffee_train/train_card.dart';
import 'package:fb_auth/data/blocs/auth/auth_state.dart';
import 'package:fb_auth/fb_auth.dart';
import 'package:fb_firestore/classes/index.dart';
import 'package:fb_firestore/fb_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rounded_modal/rounded_modal.dart';
import 'package:snapfeed/snapfeed.dart';
import 'package:flutter/foundation.dart';

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
    if (size.width >= 500) {
      isMobileLayout = false;
    } else {
      isMobileLayout = true;
    }
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(MdiIcons.accountCircleOutline),
            onPressed: () => isMobileLayout == true ? showRoundedModalBottomSheet(
              color: Theme.of(context).canvasColor,
              context: context,
              builder: (context) => Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: Icon(MdiIcons.accountCircleOutline),
                    title: Text(AuthBloc.currentUser(context).displayName),
                    subtitle: Text(AuthBloc.currentUser(context).email),
                  ),
                  ListTile(
                    title: Text('Give Feedback'),
                    onTap: () {
                      Navigator.pop(context);
                      Snapfeed.of(context).startFeedback();
                    },
                  ),
                  ListTile(
                    title: Text('Log out'),
                    onTap: () {
                      _auth.add(LogoutEvent(AuthBloc.currentUser(context)));
                      Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
                    },
                  ),
                ],
              ),
            ) : showDialog(
              context: context,
              builder: (_) => SimpleDialog(
                title: Text('Account'),
                children: <Widget>[
                  ListTile(
                    title: Text(AuthBloc.currentUser(context).displayName),
                    subtitle: Text(AuthBloc.currentUser(context).email),
                  ),
                  ListTile(
                    title: Text('Give Feedback'),
                    onTap: () {
                      Navigator.pop(context);
                      Snapfeed.of(context).startFeedback();
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
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
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth >= 1000) {
                    return DesktopWebLayout(trains: trains,);
                  } else {
                    return MobileLayout(trains: trains,);
                  }
                },
              );
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

  @override
  Widget build(BuildContext context) {
    if (widget.trains.length > 0) {
      return ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: widget.trains.length,
        itemBuilder: (context, index) {
          DateTime _loadTime = DateTime.now();
          final train = widget.trains[index];
          final trainId = train.documentId;

          /// Begin filtering: if the train's departure time is before
          /// the user's load time, delete that train. Otherwise show that train.
          DateTime _departureTime = DateTime.parse(train.data['FullDepartureTime']);
          if (_departureTime.isBefore(_loadTime)) {
            FbFirestore.deleteDoc('Trains/$trainId');
            if (widget.trains.length > 0) {
              return Container();
            } else {
              return Center(
                child: Text('No Upcoming Trains'),
              );
            }
          } else {
            String _submittedBy = train.data['SubmittedBy'];
            FbFirestore.editDoc('Trains/${trainId}/Passengers/$_submittedBy', {});
            return TrainCard(
              trainId: trainId,
              userName: AuthBloc.currentUser(context).displayName,
              submittedBy: _submittedBy,
              destination: train.data['Destination'],
              departureTime: train.data['DepartureTime'],
              isRecurring: train.data['Recurring'],
            );
          }
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

  @override
  Widget build(BuildContext context) {
    if (widget.trains.length > 0) {
      return LayoutBuilder(
        builder: (context, constraints) {
          double _childAspectRatio;
          if (constraints.maxWidth < 1065) {
            _childAspectRatio = 4.0;
          } else if (constraints.maxWidth >= 1065 && constraints.maxWidth < 1220) {
            _childAspectRatio = 4.2;
          } else if (constraints.maxWidth >= 1220 && constraints.maxWidth < 1300) {
            _childAspectRatio = 4.5;
          } else if (constraints.maxWidth >= 1300 && constraints.maxWidth < 1400) {
            _childAspectRatio = 4.8;
          } else if (constraints.maxWidth >= 1400 && constraints.maxWidth < 1621) {
            _childAspectRatio = 5.0;
          } else if (constraints.maxWidth >= 1980 && constraints.maxWidth < 2431) {
            _childAspectRatio = 5.2;
          } else {
            _childAspectRatio = 4.0;
          }
          return CustomScrollView(
            slivers: <Widget>[
              SliverGrid(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 800.0,
                  mainAxisSpacing: 10.0,
                  crossAxisSpacing: 10.0,
                  childAspectRatio: _childAspectRatio,
                ),
                delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
                    DateTime _loadTime = DateTime.now();
                    final train = widget.trains[index];
                    final trainId = train.documentId;

                    /// Begin filtering: if the train's departure time is before
                    /// the user's load time, delete that train. Otherwise show that train.
                    DateTime _departureTime = DateTime.parse(train.data['FullDepartureTime']);
                    if (_departureTime.isBefore(_loadTime)) {
                      FbFirestore.deleteDoc('Trains/$trainId');
                      if (widget.trains.length > 0) {
                        return Container();
                      } else {
                        return Center(
                          child: Text('No Upcoming Trains'),
                        );
                      }
                    } else {
                      String _submittedBy = train.data['SubmittedBy'];
                      FbFirestore.editDoc('Trains/${trainId}/Passengers/$_submittedBy', {});
                      return TrainCard(
                        trainId: trainId,
                        userName: AuthBloc.currentUser(context).displayName,
                        submittedBy: _submittedBy,
                        destination: train.data['Destination'],
                        departureTime: train.data['DepartureTime'],
                        isRecurring: train.data['Recurring'],
                      );
                    }
                  },
                  childCount: widget.trains.length,
                ),
              ),
            ],
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

