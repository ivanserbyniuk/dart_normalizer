import 'package:dart_normalizer/normolizer.dart';
import 'package:dart_normalizer/schema/entity.dart';
import 'package:test/test.dart';
import 'entity.dart';

void main() {
  test('normalizes entities', () {
    var expectedJson = """ {
  "entities": {
    "tacos": {
      "1": {
        "id": 1,
        "type": "foo"
      },
      "2": {
        "id": 2,
        "type": "bar"
      }
    }
  },
  "result": [
    1,
    2
  ]
}""";
    var mySchema = new EntitySchema('tacos');
    var input = [{ "id": 1, "type": 'foo'}, { "id": 2, "type": 'bar'}];
    expect(normalize(input, [mySchema]), fromJson(expectedJson));
  });

  //=====================

  test('normalizes nested entities', () {
    var expectedJson = """ {
  "entities": {
    "articles": {
      "123": {
        "author": "8472",
        "body": "This article is great.",
        "comments": [
          "comment-123-4738"
        ],
        "id": "123",
        "title": "A Great Article"
      }
    },
    "comments": {
      "comment-123-4738": {
        "comment": "I like it!",
        "id": "comment-123-4738",
        "user": "10293"
      }
    },
    "users": {
      "10293": {
        "id": "10293",
        "name": "Jane"
      },
      "8472": {
        "id": "8472",
        "name": "Paul"
      }
    }
  },
  "result": "123"
} """;
    var user = new EntitySchema('users');
    var comment = new EntitySchema('comments', definition: {
      "user": user
    });
    var article = new EntitySchema('articles', definition: {
      "author": user,
      "comments": [comment]
    });

    const input = {
      "id": '123',
      "title": 'A Great Article',
      "author": {
        "id": '8472',
        "name": 'Paul'
      },
      "body": 'This article is great.',
      "comments": [
        {
          "id": 'comment-123-4738',
          "comment": 'I like it!',
          "user": {
            "id": '10293',
            "name": 'Jane'
          }
        }
      ]
    };
    expect(normalize(input, article), fromJson(expectedJson));
  });

  //================

  test('ignores null values', () {
    var expectedJson = """ {
  "entities": {},
  "result":  [
   null
  ]
}""";

    var expectedJson2 = """ {
      "entities": {},
  "result":  [
  false
  ]
}""";
    var myEntity = new EntitySchema('myentities');
    expect(normalize([null], [myEntity]), fromJson(expectedJson));
    expect(normalize([{}], [myEntity]), fromJson(expectedJson));
    expect(normalize([false], [myEntity]), fromJson(expectedJson2));
  });

  //==================

  test('passes over pre-normalized values', () {
    var expectedJson = """ {
  "entities": {
    "articles": {
      "123": {
        "author": 1,
        "id": "123",
        "title": "normalizr is great!"
      }
    }
  },
  "result": "123"
} """;
    var userEntity = new EntitySchema('users');
    var articleEntity = new EntitySchema(
        'articles', definition: { "author": userEntity});

    var input = { "id": '123', "title": 'normalizr is great!', "author": 1};
    expect(normalize(input, articleEntity), fromJson(expectedJson));
  });

  //=====================

  test('denormalizes entities', () {
    var expectedJson = """ 
     [
       {
    "id": 1,
    "type": "foo"
  },
       {
    "id": 2,
    "type": "bar"
  }
]""";
    var mySchema = new EntitySchema('tacos');
    var entities = {
      "tacos": {
        1: { "id": 1, "type": 'foo'},
        2: { "id": 2, "type": 'bar'}
      }
    };
    var input = [1, 2];
    expect(denormalize(input, [mySchema], entities), fromJson(expectedJson));
  });

  //======================

  test('denormalizes nested entities', () {
    var expectedJson = """ 
     {
  "author":  {
    "id": "8472",
    "name": "Paul"
  },
  "body": "This article is great.",
  "comments":  [
     {
      "comment": "I like it!",
      "id": "comment-123-4738",
      "user":  {
        "id": "10293",
        "name": "Jane"
      }
    }
  ],
  "id": "123",
  "title": "A Great Article"
}
    """;
    var user = new EntitySchema('users');
    var comment = new EntitySchema('comments', definition: {
      "user": user
    });
    var article = new EntitySchema('articles', definition: {
      "author": user,
      "comments": [comment]
    });

    const entities = {
      "articles": {
        '123': {
          "author": '8472',
          "body": 'This article is great.',
          "comments": ['comment-123-4738'],
          "id": '123',
          "title": 'A Great Article'
        }
      },
      "comments": {
        'comment-123-4738': {
          "comment": 'I like it!',
          "id": 'comment-123-4738',
          "user": '10293'
        }
      },
      "users": {
        '10293': {
          "id": '10293',
          "name": 'Jane'
        },
        '8472': {
          "id": '8472',
          "name": 'Paul'
        }
      }
    };
    expect(denormalize('123', article, entities), fromJson(expectedJson));
  });

  //=============================

  test('denormalizes with function as idAttribute', () {
    var expectedJson = """
     [
       {
      "guest": null,
      "id": "1",
      "name": "Esther"
    },
       {
    "guest": {
    "guest_id": 1
    },
    "id": "2",
    "name": "Tom"
    }
    ]""";
    const normalizedData = {
      "entities": {
        "patrons": {
          '1': { "id": '1', "guest": null, "name": 'Esther'},
          '2': { "id": '2', "guest": 'guest-2-1', "name": 'Tom'}
        },
        "guests": { 'guest-2-1': { "guest_id": 1}}
      },
      "result": ['1', '2']
    };

    var guestSchema = new EntitySchema(
        'guests',
        idAttributeFunc: (value, parent, key) => "${key}-${parent.id}-${value
            .guest_id}");

    var patronsSchema = new EntitySchema('patrons', definition: {
      "guest": guestSchema
    });

    expect(denormalize(
        normalizedData["result"], [patronsSchema], normalizedData["entities"]),
        fromJson(expectedJson));
  });
}