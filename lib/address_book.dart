import 'dart:async';

import 'package:flutter/services.dart';

import 'package:equatable/equatable.dart';

class AddressBook {
  static const MethodChannel _channel =
      const MethodChannel('com.gsshop.mobile.flutter.address_book');

  static Future<dynamic?> openAddressBook() async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod('openAddressBook');
    return result;
  }
}
