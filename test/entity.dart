import 'package:dart_normalizer/entity.dart';
import 'package:test/test.dart';

import 'package:dart_normalizer/dart_normalizer.dart';

void main() {
  test('adds one to input values', () {
    final calculator = new Calculator();
    expect(calculator.addOne(2), 3);
    expect(calculator.addOne(-7), -6);
    expect(calculator.addOne(0), 1);
    expect(() => calculator.addOne(null), throwsNoSuchMethodError);
  });


  test('key getter should return key passed to constructor', () {
    var user = new EntitySchema('users');
    expect(user.key, 'users');
  });

  test("normalizes an entity", () {
    var item = new EntitySchema("iten");
    expect("", """
         {
        "entities": {
        "item": {
        "1": {
        "id": 1,
        },
        },
        },
        "result": 1,
        }
        )
        """);
  }
  );
}
