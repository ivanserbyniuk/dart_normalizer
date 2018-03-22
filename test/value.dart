import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart';
import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/value.dart';
import 'package:test/test.dart';

import 'entity.dart';

void main() {

  test('key getter should return key passed to constructor', () {
    var user = new EntitySchema('users');
    expect(user.key, 'users');
  });

  test("normalizes an entity", () {
    var expectedJson = """
    {
  "entities": {
    "cats": {
      "1": {
        "id": 1,
        "type": "cats"
      }
    },
    "dogs": {
      "1": {
        "id": 1,
        "type": "dogs"
      }
    }
  },
  "result": {
    "fido": {
      "id": 1,
      "schema": "dogs"
    },
    "fluffy": {
      "id": 1,
      "schema": "cats"
    }
  }
}
        """;
    var inferSchemaFn = ((input, parent, key) => input["type"]);

    var cat = new EntitySchema('cats');
    var dog = new EntitySchema('dogs');
    var valuesSchema = new Values({
      "dogs": dog,
      "cats": cat
    },schemaAttribute: inferSchemaFn);


    Map<String, dynamic> test = {
      "fluffy": { "id": 1, "type": 'cats' },
      "fido": { "id": 1, "type": 'dogs' }

    };
    expect(normalize(test, valuesSchema), fromJson(expectedJson));
  });
}


