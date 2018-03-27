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

  //===============

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

  //=================

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

  //===================

  test('can normalize entity IDs based on their object key', () {
    //todo int string key check
    var expectedJson = """
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
        'users', idAttributeFunc: (entity, parent, key) => key);
    var inputSchema = new Values(
        { "users": user}, schemaAttributeFunc: (input, parent, key) => 'users');

    var input = { '4': { "name": 'taco'}, '56': { "name": 'burrito'}};
    expect(normalize(input, inputSchema), fromJson(expectedJson));
  });

//======================

  test('can build the entitys ID from the parent object', () {
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
        idAttributeFunc: (entity, parent,
            key) => "${parent['name']}-${key}-${entity['id']}"
    );
    var inputSchema = new ObjectSchema({"user": user});

    var input = { "name": 'tacos', "user": { "id": '4', "name": 'Jimmy'}};
    expect(normalize(input, inputSchema), fromJson(expectedJson));
  });

  //=============proccess strategy

  test('can use a custom processing strategy', () {
    var expectedJSON = """ {
        "entities":  {
    "tacos":  {
      "1":  {
        "id": 1,
        "name": "foo",
        "slug": "thing-1"
      }
     }
    },
    "result": 1
  }""";
    var processStrategy = (entity, parent, key) {
      var map = {};
      map.addAll(entity);
      map.addAll({"slug": 'thing-${entity["id"]}'});
      return map;
    };

    var mySchema = new EntitySchema('tacos', processStrategy: processStrategy);
    var input = { "id": 1, "name": 'foo'};
    expect(normalize(input, mySchema), fromJson(expectedJSON));
  });

  //======================

  test('can use information from the parent in the process strategy', () {
    var expectedJson = """ 
    {
  "entities": {
    "children": {
      "4": {
        "content": "child",
        "id": 4,
        "parentId": 1,
        "parentKey": "child"
      }
    },
    "parents": {
      "1": {
        "child": 4,
        "content": "parent",
        "id": 1
      }
    }
  },
  "result": 1
}""";
    var processStrategy = (entity, parent, key) {
      Map map = {};
      map.addAll(entity);
      map.addAll({"parentId": parent["id"], "parentKey": key});
      return map;
    };
    var childEntity = new EntitySchema(
        'children', processStrategy: processStrategy);
    var parentEntity = new EntitySchema('parents', definition: {
      "child": childEntity
    });

    var input = {
      "id": 1, "content": 'parent', "child": { "id": 4, "content": 'child'}
    };
    expect(normalize(input, parentEntity), fromJson(expectedJson));
  });


//===================== merge strategy

  test('defaults to plain merging', () {
    var expectedJson = """
      {
  "entities": {
    "tacos": {
      "1": {
        "alias": "bar",
        "id": 1,
        "name": "bar"
      }
    }
  },
  "result": [
    1,
    1
  ]
}
    """;
    var mySchema = new EntitySchema('tacos');
    var input = [
      { "id": 1, "name": 'foo'},
      { "id": 1, "name": 'bar', "alias": 'bar'}
    ];
    expect(normalize(input, [ mySchema]), fromJson(expectedJson));
  });

  //===============================

  test('can use a custom merging strategy', () {
    var expectedJson = """ 
    {
  "entities": {
    "tacos": {
      "1": {
        "alias": "bar",
        "id": 1,
        "name": "foo"
      }
    }
  },
  "result": [
    1,
    1
  ]
}""";
    var mergeStrategy = (entityA, entityB) {
      return entityB..addAll(entityA)..addAll({"name": entityA["name"]});
    };
    var mySchema = new EntitySchema('tacos', mergeStrategy: mergeStrategy);

    var input = [
      { "id": 1, "name": 'foo'},
      { "id": 1, "name": 'bar', "alias": 'bar'}
    ];
    expect(normalize(input, [ mySchema]), fromJson(expectedJson));
  });

  //===================== Denormalization

  test('denormalizes an entity', () {
    var expectedJson = """ {
      "id": 1,
      "type": "foo"
    }""";
    var mySchema = new EntitySchema('tacos');
    const entities = {
      "tacos": {
        1: { "id": 1, "type": 'foo'}
      }
    };
    expect(denormalize(1, mySchema, entities), fromJson(expectedJson));
  });

  //==========================

  test('denormalizes deep entities', () {
    var expectedJson1 = """ {
    "food": {
      "id": 1
   },
  "id": 1
  }""";

    var expectedJson2 = """  {
      "id": 2
    }""";
    var foodSchema = new EntitySchema('foods');
    var menuSchema = new EntitySchema('menus', definition: {
      "food": foodSchema
    });

    const entities = {
      "menus": {
        1: { "id": 1, "food": 1},
        2: { "id": 2}
      },
      "foods": {
        1: { "id": 1}
      }
    };

    expect(denormalize(1, menuSchema, entities), fromJson(expectedJson1));
    expect(denormalize(2, menuSchema, entities), fromJson(expectedJson2));
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
