import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart' as N;
import 'package:dart_normalizer/schema/array.dart';
import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/value.dart';
import 'package:test/test.dart';


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
    var test = [ { "id": 1}, { "id": 2}];
    Map mapTest = fromJson(expectedJson);
    print(mapTest);
    expect(N.normalize(test, [userSchema]), fromJson(expectedJson));
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

    expect(N.normalize(test, [userSchema]), fromJson(expectedJson));
  });


  test('normalizes a single entity', () {
    var expectedJson = """
    {
  "entities": {
    "cats": {
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
} """;
    var cats = new EntitySchema('cats');
    var listSchema = new ArraySchema(cats);
    var test = [{"id":1}, {"id":2}];
    expect(N.normalize(test, listSchema), fromJson(expectedJson));
  });


  test('normalizes multiple entities', (){//todo check order
      var inferSchemaFn = ((input, parent, key) => input["type"]);
  var catSchema = new EntitySchema('cats');
  var peopleSchema = new EntitySchema('person');
  var listSchema = new ArraySchema({
  "cats": catSchema,
  "people": peopleSchema
  },schemaAttribute:inferSchemaFn);

      var expectedJson = """ {
  "entities": {
    "cats": {
      "123": {
        "id": "123",
        "type": "cats"
      },
      "456": {
        "id": "456",
        "type": "cats"
      }
    },
    "person": {
      "123": {
        "id": "123",
        "type": "people"
      }
    }
  },
  "result": [
    {
      "id": "123",
      "schema": "cats"
    },
    {
      "id": "123",
      "schema": "people"
    },
    {
      "id": "789",
      "name": "fido"
    },
    {
      "id": "456",
      "schema": "cats"
    }
  ]
} """;
  var test =
  [{ "type": 'cats', "id": '123' },
  { "type": 'people', "id": '123' },
  { "id:" :'789', "name": 'fido' },
  { "type": 'cats', "id": '456' }];
 //print(N.normalize(test, listSchema));
  expect(N.normalize(test, listSchema), fromJson(expectedJson));

});}


toJson(Map value) {
  JsonEncoder encoder = new JsonEncoder.withIndent('');
  String prettyprint = encoder.convert(value);
  return prettyprint;
}

fromJson(value) {
  return JSON.decode(value);
}
