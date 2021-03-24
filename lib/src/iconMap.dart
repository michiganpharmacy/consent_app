//
// iconMap.dart
//
// 2020.11.23.ET 
//

import 'package:flutter/material.dart';

class IconMap{

  static Map<String,IconData> _iconMap = {
    'default':Icons.waves,
    'Introduction':Icons.waves,
    'Time Commitment':Icons.timer,
    'Time':Icons.timer,
    'Data Gathering':Icons.tune,
    'Data':Icons.tune,
    'Purpose':Icons.timeline,
    'Participation':Icons.group_add,
    'Privacy':Icons.verified_user,
    'Disclaimer & Limitation of Liability':Icons.assignment,
    'Disclaimer':Icons.assignment,
    'Release of Protected Health Information':Icons.local_hospital,
    'Contacting Us':Icons.contact_page,
    'Contacts':Icons.contact_page,
    'Authorization':Icons.history_edu,
  };

  //
  // lookup
  //
  static IconData? lookup(label) {
    if (_iconMap.containsKey(label)) {
      return _iconMap[label];
    } else {
      return _iconMap['default'];
    }
  }
}

