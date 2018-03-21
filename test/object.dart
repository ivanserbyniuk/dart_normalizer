import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart';
import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/object.dart';
import 'package:test/test.dart';

import 'package:dart_normalizer/dart_normalizer.dart';

void main() {
  test("normalizes an object" ,(){
    var expectedJson = """
    {
  "entities": {
    "user": {
      "1": {
        "id": 1,
      },
    },
  },
  "result": {
    "user": 1,
  },
}
    """;

    var userSchema = new Entity('user');
    var schema = new ObjectSchema({
      "user": userSchema,
    });
    var test = { "user": { "id": 1 } };
    expect(normalize(test, schema), expectedJson);
  });
}