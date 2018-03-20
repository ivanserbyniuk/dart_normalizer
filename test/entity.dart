import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart';
import 'package:dart_normalizer/schema/entity.dart';
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
          "item": {
            "1": {
              "id": 1
              }
            }
          },
        "result": 1
        }
        """;
    var afterNormalizetion = normalize({ "id": 1 }, item);
    expect(afterNormalizetion, fromJson(expectedJson));
  });




  test("test custome id attribute", (){
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
    var item = new Entity("users",idAttribute: "id_str");
    var json = normalize({ "id_str": '134351', "name": 'Kathy' },item);
    print(json);
    expect(json, fromJson(expectedJson));
      });

/*
 test('can normalize entity IDs based on their object key', () {
   var expectedJson = """ {
  "entities": {
    "users": {
      "4": {
        "name": "taco",
      },
      "56": {
        "name": "burrito",
      },
    },
  },
  "result": {
    "4": {
      "id": "4",
      "schema": "users",
    },
    "56": {
      "id": "56",
      "schema": "users",
    },
  },
}""";
      var  user = new Entity('users',{ idAttributeFunc: (entity, parent, key) => key });
  var inputSchema = new schema.Values({ users: user }, () => 'users');
  var sourceJson = {
    4: { "name": 'taco' },
    56: { "name": 'burrito' } };
     expect(normalize( sourceJson, inputSchema)).toMatchSnapshot();
});
*/



}

toJson(Map value) {
  JsonEncoder encoder = new JsonEncoder.withIndent('');
  String prettyprint = encoder.convert(value);
  return prettyprint;
}

fromJson(String source) {
  return JSON.decode(source);
}
