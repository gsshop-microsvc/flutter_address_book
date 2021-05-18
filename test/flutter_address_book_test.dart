import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/address_book.dart';

void main() {
  const MethodChannel channel = MethodChannel('package_manager');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {});

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('openAddressBook', () async {
    await AddressBook.openAddressBook();
  });
}
