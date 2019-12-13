import 'dart:async';
import 'package:drcc_coffee_train/auth_check.dart';
import 'package:drcc_coffee_train/new_train.dart';
import 'package:drcc_coffee_train/upcoming_trains.dart';
import 'package:fb_auth/fb_auth.dart';
import 'package:flutter/material.dart';
import 'package:snapfeed/snapfeed.dart';
import 'plugins/desktop/desktop.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drcc_coffee_train/app_data.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setTargetPlatformForDesktop();
  runApp(DrccRailway());
}

class DrccRailway extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _DrccRailwayState createState() => _DrccRailwayState();
}

class _DrccRailwayState extends State<DrccRailway> {
  static AppData appData = AppData();
  final _app = FbApp(
    apiKey: appData.$apiKey,
    authDomain: appData.$authDomain,
    databaseURL: appData.$databaseURL,
    projectId: appData.$projectId,
    storageBucket: appData.$storageBucket,
    messagingSenderId: appData.$messagingSenderId,
    appId: appData.$appId,
    measurementId: appData.$measurementId
  );

  AuthBloc _auth;
  StreamSubscription<AuthUser> _userChanged;

  @override
  void dispose() {
    _auth.close();
    _userChanged?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _auth = AuthBloc(saveUser: _saveUser, deleteUser: _deleteUser, app: _app);
    _auth.add(CheckUser());
    final _fbAuth = FBAuth(_app);
    _userChanged = _fbAuth.onAuthChanged().listen((user) {
      _auth.add(UpdateUser(user));
    });
    super.initState();
  }

  static _deleteUser() async {}

  static _saveUser(user) async {}

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(builder: (_) => _auth),
      ],
      child: Snapfeed(
        projectId: appData.$snapfeedId,
        secret: appData.$snapfeedSecret,
        child: MaterialApp(
          title: 'DRCC Railway',
          theme: ThemeData(
            primaryColor: Color(0xff002D72),
            accentColor: Color(0xff68ACE5),
            cursorColor: Color(0xff68ACE5),
            textSelectionHandleColor: Color(0xff68ACE5),
            brightness: Brightness.dark,
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Colors.white,
                ),
              ),
            ),
            fontFamily: 'OpenSans',
          ),
          routes: <String, WidgetBuilder>{
            '/UpcomingTrains': (BuildContext context) => UpcomingTrains(),
            '/NewTrain': (BuildContext context) => NewTrain(),
          },
          home: AuthCheck(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
