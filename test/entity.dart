import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart';
import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/object.dart';
import 'package:dart_normalizer/schema/value.dart';
import 'package:test/test.dart';


void main() {
  test('key getter should return key passed to constructor', () {
    var user = new EntitySchema('users');
    expect(user.key, 'users');
  });

  test("normalizes an entity", () {
    var item = new EntitySchema("item");
    var expectedJson = """
    {
        "entities": {
          "item": {
            "1": {
              "id": 1
              }
            }
          },
        "result": 1
        }
        """;
    var afterNormalizetion = normalize({ "id": 1}, item);
    expect(afterNormalizetion, fromJson(expectedJson));
  });

  test("test custome id attribute string", () {
    var expectedJson = """ 
     {
    "entities":  {
    "users":  {
      "134351":  {
        "id_str": "134351",
        "name": "Kathy"
      }
    }
  },
  "result": "134351"
}
    """;
    var item = new EntitySchema("users", idAttribute: "id_str");
    var json = normalize({ "id_str": '134351', "name": 'Kathy'}, item);
    expect(json, fromJson(expectedJson));
  });

  test('can normalize entity IDs based on their object key', () {
    //todo int string key check
    var expectedJson= """
    {
  "entities": {
    "users": {
      "4": {
        "name": "taco"
      },
      "56": {
        "name": "burrito"
      }
    }
  },
  "result": {
    "4": {
      "id": "4",
      "schema": "users"
    },
    "56": {
      "id": "56",
      "schema": "users"
    }
  }
}""";
    var user = new EntitySchema(
        'users', idAttributeFun: (entity, parent, key) => key);
    var inputSchema = new Values(
        { "users": user}, schemaAttribute: (input, parent, key) => 'users');

    var input = { 4: { "name": 'taco'}, 56: { "name": 'burrito'}};
    expect(normalize(input, inputSchema), fromJson(expectedJson));
  });


  test('can build the entity\'s ID from the parent object', () {
    var expectedJson = """ 
    {
  "entities": {
    "users": {
      "tacos-user-4": {
        "id": "4",
        "name": "Jimmy"
      }
    }
  },
  "result": {
    "name": "tacos",
    "user": "tacos-user-4"
  }
}""";
      var user = new EntitySchema('users',
        idAttributeFun: (entity, parent, key) => "${parent.name}-${key}-${entity.id}"
      );
  var inputSchema = new ObjectSchema({"user": user });

  var input = { "name": 'tacos', "user": { "id": '4', "name": 'Jimmy' } };
  expect(normalize(input, inputSchema),fromJson(expectedJson));
});
}

toJson(Map value) {
  JsonEncoder encoder = new JsonEncoder.withIndent('');
  String prettyprint = encoder.convert(value);
  return prettyprint;
}

fromJson(String source) {
  return JSON.decode(source);
}
