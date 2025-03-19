import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class InternetChecker extends StatefulWidget {
  final Widget child;

  const InternetChecker({Key? key, required this.child}) : super(key: key);

  @override
  _InternetCheckerState createState() => _InternetCheckerState();
}

class _InternetCheckerState extends State<InternetChecker> {
  StreamSubscription<List<ConnectivityResult>>? _subscription; // ✅ Updated type
  bool _isConnected = true;
  late GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  @override
  void initState() {
    super.initState();
    _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

    _checkInternet();

    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {  // ✅ Handle List<ConnectivityResult>
      bool newConnectionStatus = result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi);

      if (newConnectionStatus != _isConnected) {
        setState(() {
          _isConnected = newConnectionStatus;
        });

        if (!_isConnected) {
          _showSnackbar("You have an internet issue");
        }
      }
    });
  }

  void _checkInternet() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi);
    });

    if (!_isConnected) {
      _showSnackbar("You have an internet issue");
    }
  }

  void _showSnackbar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: ScaffoldMessenger(
        key: _scaffoldMessengerKey,
        child: Stack(
          children: [
            widget.child,
            if (!_isConnected)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.all(10),
                  child: const Center(
                    child: Text(
                      "You have an internet issue",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

void checkInternetBeforeAction(BuildContext context, VoidCallback action, {bool isLoading = false}) async {
  var connectivityResult = await Connectivity().checkConnectivity();
  bool isConnected = connectivityResult.contains(ConnectivityResult.mobile) || connectivityResult.contains(ConnectivityResult.wifi);

  if (!isConnected) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You have an internet issue"),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  } else {
    action();
  }
}
