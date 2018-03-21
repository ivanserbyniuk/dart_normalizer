import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart' as N;
import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/object.dart';
import 'package:test/test.dart';

import 'array.dart';


void main() {
  test("normalizes an object" ,(){
    var expectedJson = """
    {
  "entities": {
    "user": {
      "1": {
        "id": 1
      }
    }
  },
  "result": {
    "user": 1
  }
}
    """;

    var userSchema = new EntitySchema('user');
    var schema = new ObjectSchema({
      "user": userSchema,
    });
    var test = { "user": { "id": 1 } };
    expect(N.normalize(test, schema), fromJson(expectedJson));
  });
}