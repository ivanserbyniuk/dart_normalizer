import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart';
import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/value.dart';
import 'package:test/test.dart';

import 'package:dart_normalizer/dart_normalizer.dart';

void main() {

  test('key getter should return key passed to constructor', () {
    var user = new EntitySchema('users');
    expect(user.key, 'users');
  });

  test("normalizes an entity", () {
    var userSchema = new EntitySchema("user");
    var expectedJson = """
     {
    	"entities": {
    		"user": {
    			"1": {
    				"id": 1
    			},
    			"2": {
    				"id": 2
    			}
    		}
    	},
    	"result": [
    		1,
    		2
    	]
    }
        """;
    var test = [ { "id": 1 }, { "id": 2 } ];
    Map mapTest = fromJson(expectedJson);
    print(mapTest);
    expect(normalize(test, [userSchema]), fromJson(expectedJson));

  });



  test('normalizes Objects using their values', () {
      var userSchema = new EntitySchema('user');
      var expectedJson = """
      {
  "entities": {
    "user": {
      "1": {
        "id": 1
      },
      "2": {
        "id": 2
      }
    }
  },
  "result": [
    1,
    2
  ]
}
      """;
      var test = {
        "foo": { "id": 1}, "bar": { "id": 2}
      };

  expect(normalize(test, [userSchema]), fromJson(expectedJson));
});
}

toJson(Map value) {
  JsonEncoder encoder = new JsonEncoder.withIndent('');
  String prettyprint = encoder.convert(value);
  return prettyprint;
}

fromJson(value) {
  return JSON.decode(value);
}
