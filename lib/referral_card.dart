import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

class ReferralCard extends StatefulWidget {
  ReferralCard({Key key}) : super(key: key);

  @override
  _ReferralCardState createState() => _ReferralCardState();
}

class _ReferralCardState extends State<ReferralCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: 500,
      alignment: Alignment.center,
      child: Center(
        child: Card(
          shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.white70, width: 1),
          borderRadius: BorderRadius.circular(0),
          ),
          color: Colors.grey[300],
          clipBehavior: Clip.antiAlias,
          child: Center(
            child: Container(
              height: 160,
              width: 460,
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black, width: 1),
                  borderRadius: BorderRadius.circular(0),
                  ),
                child: Column(
                  children: [
                    Column(
                      children: [
                        ListTile(
                          title: Text(
                            "Refer and Earn 1k",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            "We'll give you ₹1,000 for every candidate that signs up via your referral link and gets a job through Dashhire.",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }
}