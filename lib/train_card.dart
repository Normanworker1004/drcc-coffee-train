import 'package:badges/badges.dart';
import 'package:fb_auth/data/blocs/auth/auth_bloc.dart';
import 'package:fb_firestore/classes/index.dart';
import 'package:fb_firestore/fb_firestore.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class TrainCard extends StatefulWidget {
  final String trainId;
  final String submittedBy;
  final String destination;
  final String departureTime;
  final int passengerCount;
  final bool isRecurring;

  const TrainCard({
    Key key,
    this.departureTime,
    this.passengerCount,
    this.isRecurring,
    this.trainId,
    this.submittedBy,
    this.destination,
  }) : super(key: key);

  @override
  _TrainCardState createState() => _TrainCardState();
}

class _TrainCardState extends State<TrainCard> {
  @override
  Widget build(BuildContext context) {
    String name = AuthBloc.currentUser(context).displayName;
    int passengerCount = widget.passengerCount;

    void joinTrain() {
      setState(() {
        FbFirestore.editDoc('Trains/${widget.trainId}/Passengers/$name', {});
      });
      print('joined train');
    }

    void leaveTrain() {
      setState(() {
        FbFirestore.deleteDoc('Trains/${widget.trainId}/Passengers/$name');
      });
      print('left train');
    }

    void viewPassengers() async {
      final _passengerList = await FbFirestore.getDocs('Trains/${widget.trainId}/Passengers');
      showDialog(
        context: context,
        builder: (_) => SimpleDialog(
          title: Text('Passengers'),
          contentPadding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 16),
          children: <Widget>[
            for (FbDocumentSnapshot snap in _passengerList) Text(snap.documentId),
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

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xff0072CE),
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        height: 125,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                MediaQuery.of(context).size.width > 475
                    ? FlatButton.icon(
                        icon: Icon(MdiIcons.accountMinus),
                        label: Text('Leave Train'),
                        onPressed: leaveTrain,
                      )
                    : Material(
                      color: Color(0xff0072CE),
                      child: IconButton(
                          icon: Icon(MdiIcons.accountMinus),
                          onPressed: leaveTrain,
                          tooltip: 'Leave Train',
                        ),
                    ),
                MediaQuery.of(context).size.width > 475
                    ? FlatButton.icon(
                        onPressed: viewPassengers,
                        icon: Icon(Icons.people),
                        label: Text(
                          '$passengerCount passengers',
                        ),
                      )
                    : Badge(
                      badgeColor: Theme.of(context).primaryColor,
                      position: BadgePosition.topRight(),
                      badgeContent: Text('${widget.passengerCount}'),
                      animationDuration: Duration(milliseconds: 500),
                      animationType: BadgeAnimationType.slide,
                      child: Material(
                        color: Color(0xff0072CE),
                        child: IconButton(
                          icon: Icon(Icons.people),
                          onPressed: viewPassengers,
                        ),
                      ),
                    ),
                MediaQuery.of(context).size.width > 475
                    ? FlatButton.icon(
                        icon: Icon(MdiIcons.accountPlus),
                        label: Text('Join Train'),
                        onPressed: joinTrain,
                      )
                    : Material(
                      color: Color(0xff0072CE),
                      child: IconButton(
                          icon: Icon(MdiIcons.accountPlus),
                          onPressed: joinTrain,
                          tooltip: 'Join Train',
                        ),
                    ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
