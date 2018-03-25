import 'package:dart_normalizer/Pair.dart';
import 'package:dart_normalizer/normolizer.dart';
import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/object.dart';
import 'package:dart_normalizer/schema/value.dart';
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
/*  test('ignores null values', ()  {
      const myEntity = new schema.Entity('myentities');
  expect(normalize([null], [myEntity])).toMatchSnapshot();
  expect(normalize([undefined], [myEntity])).toMatchSnapshot();
  expect(normalize([false], [myEntity])).toMatchSnapshot();
});*/


}