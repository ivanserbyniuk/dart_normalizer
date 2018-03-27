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

  //=================

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
    expect(N.normalize(test, [userSchema]), fromJson(expectedJson));
  });

  //===================

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
    var input = {
      "foo": { "id": 1}, "bar": { "id": 2}
    };
    expect(N.normalize(input, [userSchema]), fromJson(expectedJson));
  });

  //========================

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
    var test = [{"id": 1}, {"id": 2}];
    expect(N.normalize(test, listSchema), fromJson(expectedJson));
  });

  //=========================

  test('normalizes multiple entities', () { //todo check order
    var inferSchemaFunc = ((input, parent, key) => input["type"]);
    var catSchema = new EntitySchema('cats');
    var peopleSchema = new EntitySchema('person');
    var listSchema = new ArraySchema({
      "cats": catSchema,
      "people": peopleSchema
    }, schemaAttributeFunc: inferSchemaFunc);

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
    [{ "type": 'cats', "id": '123'},
    { "type": 'people', "id": '123'},
    { "id": '789', "name": 'fido'},
    { "type": 'cats', "id": '456'}
    ];
    expect(N.normalize(test, listSchema), fromJson(expectedJson));
  });

  //===========================

  test('normalizes Objects using their values', () {
    var expectedJson = """ {
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
}""";
    var userSchema = new EntitySchema('user');
    var users = new ArraySchema(userSchema);
    var test = { "foo": { "id": 1}, "bar": { "id": 2}};
    expect(N.normalize(test, users), fromJson(expectedJson));
  });

  //===========================

  test('filters out undefined and null normalized values', () {
    var expectedJson = """ {
        "entities": {
    "user": {
      "123": {
        "id": 123
        }
      }
     },
    "result": [
    123
    ]
  }""";
    var userSchema = new EntitySchema('user');
    var users = new ArraySchema(userSchema);
    var test = [ null, { "id": 123}, null];
    expect(N.normalize([ null, { "id": 123}, null], users),
        fromJson(expectedJson));
  });

  //===========================

  test('denormalizes a single entity', () {
    var expectedJson = """
    [
     {
    "id": 1,
    "name": "Milo"
  },
     {
    "id": 2,
    "name": "Jake"
  }
]
    """;
    var cats = new EntitySchema('cats');
    var entities = {
      "cats": {
        1: { "id": 1, "name": 'Milo'},
        2: { "id": 2, "name": 'Jake'}
      }
    };
    expect(N.denormalize([ 1, 2], [ cats], entities), fromJson(expectedJson));
  });

  //=========================

  test('returns the input value if is not an array', () {
    var expectedJson = """ {
  "fillings": {},
  "id": "123"
}""";
    var filling = new EntitySchema('fillings');
    var taco = new EntitySchema('tacos', definition: { "fillings": [ filling]});

    const entities1 = {
      "tacos": {
        '123': {
          "id": '123',
          "fillings": {}
        }
      }
    };

    expect(N.denormalize('123', taco, entities1), fromJson(expectedJson));
  });

  //======================

  test('denormalizes a single entity', () {
    var expectedJson = """ [
     {
    "id": 1,
    "name": "Milo"
  },
     {
    "id": 2,
    "name": "Jake"
  }
]
    """;
    var cats = new EntitySchema('cats');
    const entities = {
      "cats": {
        1: { "id": 1, "name": 'Milo'},
        2: { "id": 2, "name": 'Jake'}
      }
    };
    var catList = new ArraySchema(cats);
    expect(N.denormalize([ 1, 2], catList, entities), fromJson(expectedJson));
  });

  //=========================

  test('denormalizes multiple entities', () {
    var expectedJson = """ [
     {
        "id": "123",
        "type": "cats"
      },
     {
        "id": "123",
        "type": "people"
      },
     {
         "id": "789"
      },
     {
        "id": "456",
        "type": "cats"
    }
]""";
    var catSchema = new EntitySchema('cats');
    var peopleSchema = new EntitySchema('person');
    var listSchema = new ArraySchema({
      "cats": catSchema,
      "dogs": {},
      "people": peopleSchema
    }, schemaAttributeFunc: (input, parent, key) =>
    input["type"] != null
        ? input["type"]
        : 'dogs');

    const entities = {
      "cats": {
        '123': {
          "id": '123',
          "type": 'cats'
        },
        '456': {
          "id": '456',
          "type": 'cats'
        }
      },
      "person": {
        '123': {
          "id": '123',
          "type": 'people'
        }
      }
    };

    const input = [
      { "id": '123', "schema": 'cats'},
      { "id": '123', "schema": 'people'},
      { "id": { "id": '789'}, "schema": 'dogs'},
      { "id": '456', "schema": 'cats'}
    ];

    expect(N.denormalize(input, listSchema, entities), fromJson(expectedJson));
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
