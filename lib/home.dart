import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_auth_project/login.dart';
import 'package:dash_widget/dash_widget.dart';
import 'package:provider/provider.dart';
import 'package:dash_widget/store/jobs_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false);
            },
          )
        ],
      ),
      body: Column(
        children: [
          const JobStoreWidgetWrapper(),
          const Text(
            'JobsStore value in example/main initial',
          ),
          Text(
            '${Provider.of<JobsStore>(context, listen: false).value}',
            style: Theme.of(context).textTheme.headline4,
          ),
          Observer(
              builder: (_) => Text(
                    '${Provider.of<JobsStore>(context, listen: false).value} dynamic Jobs store value in example/main',
                    style: const TextStyle(fontSize: 40),
                  )),
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // uid = FirebaseAuth.instance.currentUser.uid;
  }
}
