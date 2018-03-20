import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart';
import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/value.dart';
import 'package:test/test.dart';

import 'package:dart_normalizer/dart_normalizer.dart';

void main() {

  test('key getter should return key passed to constructor', () {
    var user = new Entity('users');
    expect(user.key, 'users');
  });

  test("normalizes an entity", () {
    var item = new Entity("item");
    var expectedJson = """
    {
  "entities": {
    "cats": {
      "1": {
        "id": 1,
        "type": "cats",
      },
    },
    "dogs": {
      "1": {
        "id": 1,
        "type": "dogs",
      },
    },
  },
  "result": {
    "fido": {
      "id": 1,
      "schema": "dogs",
    },
    "fluffy": {
      "id": 1,
      "schema": "cats",
    },
  },
}
        """;
    var cat = new Entity('cats');
    var dog = new Entity('dogs');
    var valuesSchema = new Values({
      "dogs": dog,
      "cats": cat
    }, (entity, key) => entity.type);


    Map<String, dynamic> test = {
      "fido": { "id": 1, "type": 'dogs' },
      "fluffy": { "id": 1, "type": 'cats' }
    };
    expect(normalize(test, valuesSchema), expectedJson);
  });
}

toJson(Map value) {
  JsonEncoder encoder = new JsonEncoder.withIndent('');
  String prettyprint = encoder.convert(value);
  return prettyprint;
}
