import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart';
import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/value.dart';
import 'package:test/test.dart';

import 'entity.dart';

void main() {



  test("normalizes the values of an object with the given schema", () {
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


  test('can use a function to determine the schema when normalizing', (){
var  dog = new EntitySchema('dogs');
  const valuesSchema = new schema.Values({
    dogs: dog,
    cats: cat
  }, (entity, key) => `${entity.type}s`);

  expect(normalize({
    fido: { id: 1, type: 'dog' },
    fluffy: { id: 1, type: 'cat' },
    jim: { id: 2, type: 'lizard' }
  }, valuesSchema)).toMatchSnapshot();
});
}


