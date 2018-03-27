import 'dart:convert';

import 'package:dart_normalizer/normolizer.dart' as N;
import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/object.dart';
import 'package:test/test.dart';

import 'array.dart';


void main() {
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

  //=======================

  test("normalizes an object", () {
    var userSchema = new EntitySchema('user');
    var schema = new ObjectSchema({
      "user": userSchema,
    });
    var test = { "user": { "id": 1}};
    expect(N.normalize(test, schema), fromJson(expectedJson));
  });

  //=====================

  test("normalizes plain objects as shorthand for ObjectSchema ", () {
    var userSchema = new EntitySchema('user');
    expect(N.normalize({ "user": { "id": 1}}, { "user": userSchema}),
        fromJson(expectedJson));
  });

  //======================

  test('filters out undefined and null values', () {
    var expectedJson = """{
      "entities": {
    "user": {
      "1": {
        "id": "1"
      }
    }
  },
  "result": {
    "bar": "1"
  }
}""";
    var userSchema = new EntitySchema('user');
    var users = { "foo": userSchema, "bar": userSchema, "baz": userSchema};
    expect(N.normalize({ "bar": { "id": '1'}}, users), fromJson(expectedJson));
  });

  //========================

  test('denormalizes an object', () {
    var expectedJson = """
      {
  "user": {
    "id": 1,
    "name": "Nacho"
  }
}""";
    var userSchema = new EntitySchema('user');
    var object = new ObjectSchema({
      "user": userSchema
    });
    var entities = {
      "user": {
        1: { "id": 1, "name": 'Nacho'}
      }
    };
    expect(
        N.denormalize({ "user": 1}, object, entities), fromJson(expectedJson));
  });
}