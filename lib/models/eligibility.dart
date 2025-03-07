import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/index.dart';

//INFO: Basic Modal with getter and setter functions
class ExamEvaluateModal with ChangeNotifier {
  int _count = 10;
  var _question_answer_mark = new Map<String, int>();
  var _quesion_answer = new Map<String, String>();
  var _job_selected = new Map<String, dynamic>();
  String _company_code = "";

  String _video_file_name;
  String _video_file_path;

  // JSON is been converted to string and been moved around in state
  String _ques_journey = "";
  String _mobile = "";
  String _referred_code = "";

  int _mark_scored = 0;

  int get mark_scored => _mark_scored;

  int get count => _count;

  Map get question_answer_mark => _question_answer_mark;

  Map get question_answer => _quesion_answer;

  Map get job_selected => _job_selected;

  get ques_journey => _ques_journey;

  String get mobile => _mobile;

  String get referredCode => _referred_code;

  String get company_code => _company_code;

  String get video_file_name => _video_file_name;

  String get video_file_path => _video_file_path;

  CountdownController get countdownController => _countdownController;

  CountdownController _countdownController;

  void countdownController_select(CountdownController countdownCtr) {
    _countdownController = countdownCtr;
  }

  void video_params(fileName, filePath) {
    _video_file_name = fileName;
    _video_file_path = filePath;
  }

  void set_company_code(code) {
    _company_code = code;
  }

  void set_ques_journey(journey) {
    _ques_journey = journey;
  }

  void job_select(Map job) {
    _job_selected = job;
  }

  void set_mobile(String mobile) {
    _mobile = mobile;
  }
  void set_referred_code(String referredCode){
    _referred_code = referredCode;
  }
  // INFO: consider field {answer} , match user's 'ans' with field answer and allocate mark
  void assignMark(Map field, String ans) {
    // INFO: start evaluating answer when, question comes with answer
    if (field.containsKey('answer')) {
      String answer = field['answer'];

      String name = field['name'];

      print("answers $answer $ans");

      _quesion_answer.update(
        name,
            (value) => value,
        ifAbsent: () => ans,
      );

      if (answer.toLowerCase() == ans.toLowerCase()) {
        // Can be null and be provided from different source
        int mark = field['mark'];
        _question_answer_mark.update(
          name,
              (value) => mark,
          ifAbsent: () => mark,
        );
      }
    }
  }

  // INFO: sum marks wrt to field name
  void markScored() {
    try {
      var values = _question_answer_mark.values;
      _mark_scored = values.reduce((sum, element) => sum + element);
    } catch (e) {
      _mark_scored = 0;
      print(e);
    }

    // notifyListeners();
  }

  void increment() {
    _count++;
    notifyListeners();
  }

  String _eligiblityMessage = "default msg";
  bool _isEligible;

  void checkEligiblity(int age) {
    if (age >= 18)
      eligibleForLicense();
    else
      notEligibleForLicense();
  }

  void eligibleForLicense() {
    _eligiblityMessage = "You are eligible to apply for Driving License";
    _isEligible = true;

    //Call this whenever there is some change in any field of change notifier.
    notifyListeners();
  }

  void notEligibleForLicense() {
    _eligiblityMessage = "You are not eligible to apply for Driving License";
    _isEligible = false;

    //Call this whenever there is some change in any field of change notifier.
    notifyListeners();
  }

  //Getter for Eligiblity message
  String get eligiblityMessage => _eligiblityMessage;

  //Getter for Eligiblity flag
  bool get isEligible => _isEligible;
}
