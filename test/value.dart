import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart' as N;
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
    var inferSchemaFunc = ((input, parent, key) => input["type"]);

    var cat = new EntitySchema('cats');
    var dog = new EntitySchema('dogs');
    var valuesSchema = new Values({
      "dogs": dog,
      "cats": cat
    }, schemaAttributeFunc: inferSchemaFunc);


    Map<String, dynamic> test = {
      "fluffy": { "id": 1, "type": 'cats'},
      "fido": { "id": 1, "type": 'dogs'}
    };
    expect(N.normalize(test, valuesSchema), fromJson(expectedJson));
  });

  //====================

  test('can use a function to determine the schema when normalizing', () {
    var exctedJson = """
    {
  "entities": {
    "cats": {
      "1": {
        "id": 1,
        "type": "cat"
      }
    },
    "dogs": {
      "1": {
        "id": 1,
        "type": "dog"
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
    },
    "jim": {
      "id": 2,
      "type": "lizard"
    }
  }
}""";
    var dog = new EntitySchema('dogs');
    var cat = new EntitySchema('cats');
    var valuesSchema = new Values({
      "dogs": dog,
      "cats": cat
    }, schemaAttributeFunc: (entity, parrent, key) => '${entity["type"]}s');

    var test = {
      "fido": { "id": 1, "type": 'dog'},
      "fluffy": { "id": 1, "type": 'cat'},
      "jim": { "id": 2, "type": 'lizard'}
    };
    expect(N.normalize(test, valuesSchema), fromJson(exctedJson));
  });

  //=====================

  test('filters out null and undefined values', () {
    var expectedJson = """
    {
  "entities": {
    "cats": {
      "1": {
        "id": 1,
        "type": "cats"
      }
    }
  },
  "result": {
    "fluffy": {
      "id": 1,
      "schema": "cats"
    }
  }
}""";
    var cat = new EntitySchema('cats');
    var dog = new EntitySchema('dogs');
    var valuesSchema = new Values({
      "dogs": dog,
      "cats": cat
    }, schemaAttributeFunc: (input, parrent, key) => input["type"]);
    var test = {
      "fido": null,
      "milo": null,
      "fluffy": { "id": 1, "type": 'cats'}
    };
    expect(N.normalize(test, valuesSchema), fromJson(expectedJson));
  });

  //================= denormalize

  test('denormalizes the values of an object with the given schema', () {
    var expectedJson = """
    {
  "fido": {
    "id": 1,
    "type": "dogs"
  },
  "fluffy": {
    "id": 1,
    "type": "cats"
  }
}""";
    var cat = new EntitySchema('cats');
    var dog = new EntitySchema('dogs');
    var valuesSchema = new Values({
      "dogs": dog,
      "cats": cat
    }, schemaAttributeFunc: (entity, parrent, key) => entity.type);

    var entities = {
      "cats": { 1: { "id": 1, "type": 'cats'}},
      "dogs": { 1: { "id": 1, "type": 'dogs'}}
    };

    expect(N.denormalize({
      "fido": { "id": 1, "schema": 'dogs'},
      "fluffy": { "id": 1, "schema": 'cats'}
    }, valuesSchema, entities), fromJson(expectedJson));
  });
}


