import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart' as N;
import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/union.dart';
import 'package:test/test.dart';

import 'array.dart';

void main() {
// Normalization

  test('normalizes an object using string schemaAttribute', () {
    var expectedJson1 = """{
   "entities": {
    "users": {
      "1": {
        "id": 1,
        "type": "users"
      }
    }
  },
  "result": {
    "id": 1,
    "schema": "users"
  }
}""";

    var expectedJson2 = """{
   "entities": {
    "groups": {
      "2": {
        "id": 2,
        "type": "groups"
      }
    }
  },
  "result": {
    "id": 2,
    "schema": "groups"
  }
}""";
    var user = new EntitySchema('users');
    var group = new EntitySchema('groups');
    var union = new UnionSchema({
      "users": user,
      "groups": group
    }, schemaAttribute: 'type');

    var userTest = N.normalize({ "id": 1, "type": 'users'}, union);
    var groupsTest = N.normalize({ "id": 2, "type": 'groups'}, union);
    expect(userTest, fromJson(expectedJson1));
    expect(groupsTest, fromJson(expectedJson2));
  });

  //======================

  test(
      'normalizes an array of multiple entities using a function to infer the schemaAttribute', () {
    var expectedJson1 = """
  {
  "entities": {
    "users": {
      "1": {
        "id": 1,
        "username": "Janey"
      }
    }
  },
  "result": {
    "id": 1,
    "schema": "users"
  }
}
  """;

    var expectedJson2 = """
  {
  "entities": {
    "groups": {
      "2": {
        "groupname": "People",
        "id": 2
      }
    }
  },
  "result": {
    "id": 2,
    "schema": "groups"
  }
}
  """;
    var expectedJson3 = """
  {
  "entities": {},
  "result": {
    "id": 3,
    "notdefined": "yep"
  }
}
  """;

    var user = new EntitySchema('users');
    var group = new EntitySchema('groups');
    var union = new UnionSchema({
      "users": user,
      "groups": group
    },schemaAttributeFunc: (input, parrent, key) =>
    input.containsKey("username") ? 'users' : input.containsKey("groupname")
        ? 'groups'
        : null);

    expect(N.normalize({ "id": 1, "username": 'Janey'}, union),
        fromJson(expectedJson1));
    expect(N.normalize({ "id": 2, "groupname": 'People'}, union),
        fromJson(expectedJson2));
    expect(N.normalize({ "id": 3, "notdefined": 'yep'}, union),
        fromJson(expectedJson3));
  });


  //=================== Denormalization

  var user = new EntitySchema('users');
  var group = new EntitySchema('groups');
  var entities = {
    "users": {
      1: { "id": 1, "username": 'Janey', "type": 'users'}
    },
    "groups": {
      2: { "id": 2, "groupname": 'People', "type": 'groups'}
    }
  };

  //===================

  test('denormalizes an object using string schemaAttribute', () {
    var expectedJson1 = """ {
    "id": 1,
    "type": "users",
    "username": "Janey"
    }
    """;


    var expectedJson2 = """ {
    "groupname": "People",
    "id": 2,
    "type": "groups"
    }
    """;

    var union = new UnionSchema({
      "users": user,
      "groups": group
    }, schemaAttribute: 'type');

    var testJson1 = { "id": 1, "schema": "users"};
    expect(N.denormalize(testJson1, union, entities), fromJson(expectedJson1));
    var testJson2 = { 'id': 2, 'schema': 'groups'};
    expect(N.denormalize(testJson2, union, entities), fromJson(expectedJson2));
  });
}
