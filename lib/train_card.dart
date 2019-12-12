import 'package:badges/badges.dart';
import 'package:fb_firestore/classes/index.dart';
import 'package:fb_firestore/fb_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// This widget represents a user-created 'train'
class TrainCard extends StatefulWidget {
  final String trainId;
  final String userName;
  final String submittedBy;
  final String destination;
  final String departureTime;
  final bool isRecurring;

  const TrainCard({
    Key key,
    this.departureTime,
    this.isRecurring,
    this.trainId,
    this.submittedBy,
    this.destination,
    this.userName,
  }) : super(key: key);

  @override
  _TrainCardState createState() => _TrainCardState();
}

/// This class represents the state of a 'train'
class _TrainCardState extends State<TrainCard> {
  String name;
  int passengerCount;
  var trainId;

  @override
  void initState() {
    getNameAndTrainId();
    getPassengerCount();
    super.initState();
  }

  void getNameAndTrainId () {
    name = widget.userName;
    trainId = widget.trainId;
  }

  /// Get the current user's name as well as the passenger count for this 'train'.
  /// This is called when the widget is built
  void getPassengerCount() async {
    try {
      final passengerList = await FbFirestore.getDocs('Trains/$trainId/Passengers');
      if (passengerList.length != null) {
        setState(() {
          passengerCount = passengerList.length;
        });
      } else {
        setState(() {
          passengerCount = 0;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  /// Adds the current user's name to the passenger list for this 'train'
  void joinTrain() {
    setState(() {
      FbFirestore.editDoc('Trains/${widget.trainId}/Passengers/$name', {});
      getPassengerCount();
    });
    print('joined train');
  }

  /// Removes the current user's name from the passenger list for this 'train'
  void leaveTrain() {
    setState(() {
      FbFirestore.deleteDoc('Trains/${widget.trainId}/Passengers/$name');
      getPassengerCount();
    });
    print('left train');
  }

  /// Allows the current user to view the passenger list for this 'train'
  void viewPassengers() async {
    final _pl = await FbFirestore.getDocs('Trains/${widget.trainId}/Passengers');
    var _passengerList;
    try {
      setState(() {
        _passengerList = _pl;
      });
    } catch (e) {
      print(e);
    }
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Passengers'),
        contentPadding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
        children: <Widget>[
          if (_passengerList != null)
            for (FbDocumentSnapshot snap in _passengerList) Text(snap.documentId),
          if (_passengerList == null || _passengerList.length == 0)
            Row(
              children: <Widget>[
                Text('No Passengers'),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FlatButton(
                child: Text('Dismiss', style: TextStyle(color: Theme.of(context).accentColor),),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),
      color: Color(0xff0072CE),
      child: Column(
        children: <Widget>[
          ListTile(
            leading: Icon(
              MdiIcons.train,
            ),
            title: Text(
              '${widget.departureTime} to ${widget.destination}',
            ),
            trailing: Opacity(
              opacity: widget.isRecurring == true ? 1 : 0,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 6,
                  ),
                  Icon(
                    Icons.repeat,
                  ),
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 475) {
                //todo: extract to widget called LargeLayoutButtonRow
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    FlatButton.icon(
                      icon: Icon(MdiIcons.accountMinus),
                      label: Text('Leave Train'),
                      onPressed: leaveTrain,
                    ),
                    FlatButton.icon(
                      onPressed: viewPassengers,
                      icon: Icon(Icons.people),
                      label: Text(
                        '$passengerCount passengers',
                      ),
                    ),
                    FlatButton.icon(
                      icon: Icon(MdiIcons.accountPlus),
                      label: Text('Join Train'),
                      onPressed: joinTrain,
                    )
                  ],
                );
              } else {
                //todo: extract to widget called SmallLayoutButtonRow
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(MdiIcons.accountMinus),
                      onPressed: leaveTrain,
                      tooltip: 'Leave Train',
                    ),
                    Badge(
                      badgeColor: Theme.of(context).primaryColor,
                      position: BadgePosition.topRight(),
                      badgeContent: Text('$passengerCount'),
                      animationDuration: Duration(milliseconds: 500),
                      animationType: BadgeAnimationType.slide,
                      child: IconButton(
                        icon: Icon(Icons.people),
                        onPressed: viewPassengers,
                      ),
                    ),
                    IconButton(
                      icon: Icon(MdiIcons.accountPlus),
                      onPressed: joinTrain,
                      tooltip: 'Join Train',
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
