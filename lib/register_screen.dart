import 'package:fb_auth/fb_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({Key key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _createAccount = false;
  bool _hidePassword = true;
  final _formKey = GlobalKey<FormState>();
  String _email, _password, _name;

  EdgeInsetsGeometry _formPadding;

  @override
  Widget build(BuildContext context) {
    // ignore: close_sinks
    final _auth = BlocProvider.of<AuthBloc>(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).canvasColor,
          centerTitle: true,
          title: _createAccount == false ? Text('Login to DRCC Railway') : Text('Sign up for DRCC Railway'),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 650) {
              _formPadding = EdgeInsets.only(left: 375, right: 375);
            } else {
              _formPadding = EdgeInsets.only(left: 16, right: 16);
            }
            return Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: _formPadding,
                    child: Column(
                      children: <Widget>[
                        Visibility(
                          visible: _createAccount,
                          child: ListTile(
                            title: TextFormField(
                              decoration: InputDecoration(prefixIcon: Icon(Icons.person), labelText: 'Name',),
                              onSaved: (val) => _name = val,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        ListTile(
                          title: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            textCapitalization: TextCapitalization.none,
                            decoration: InputDecoration(prefixIcon: Icon(Icons.email), labelText: 'Email'),
                            validator: (val) => val.isEmpty ? 'Email Required' : null,
                            onSaved: (val) => _email = val,
                          ),
                        ),
                        SizedBox(height: 8),
                        ListTile(
                          title: TextFormField(
                            obscureText: _hidePassword,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.security),
                              labelText: 'Password',
                              suffixIcon: IconButton(
                                icon: Icon(MdiIcons.eye),
                                onPressed: () {
                                  if (_hidePassword == true) {
                                    setState(() {
                                      _hidePassword = false;
                                    });
                                  } else {
                                    setState(() {
                                      _hidePassword = true;
                                    });
                                  }
                                },
                                tooltip: 'View Password',
                              ),
                            ),
                            validator: (val) =>
                            val.isEmpty ? 'Password Required' : null,
                            onSaved: (val) => _password = val,
                          ),
                        ),
                        SizedBox(height: 16),
                        if (_createAccount) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                color: Theme.of(context).primaryColor,
                                child: Text('Sign Up'),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    _auth.add(CreateAccount(_email, _password, displayName: _name));
                                    Navigator.pushNamedAndRemoveUntil(context, '/UpcomingTrains', (Route<dynamic> route) => false);
                                  }
                                },
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                color: Theme.of(context).primaryColor,
                                child: Text('Login'),
                                onPressed: () {
                                  if (_formKey.currentState.validate()) {
                                    _formKey.currentState.save();
                                    _auth.add(LoginEvent(_email, _password));
                                    Navigator.pushNamedAndRemoveUntil(context, '/UpcomingTrains', (Route<dynamic> route) => false);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FlatButton(
                              child: Text(_createAccount
                                  ? 'Already have an account?'
                                  : 'Create a new account?'),
                              onPressed: () {
                                if (mounted)
                                  setState(() {
                                    _createAccount = !_createAccount;
                                  });
                              },
                            ),
                          ],
                        ),
                        if (state is AuthLoadingState) ...[CircularProgressIndicator()],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}