# dart_normalizer

Dart port of normalizr library https://github.com/paularmstrong/normalizr

Normalizr is a small, but powerful utility for taking JSON with a schema definition and returning nested entities with their IDs, gathered in dictionaries.

## Quick Start

Consider a typical blog post. The API response for a single post might look something like this:

```json
{
  "id": "123",
  "author": {
    "id": "1",
    "name": "Paul"
  },
  "title": "My awesome blog post",
  "comments": [
    {
      "id": "324",
      "commenter": {
        "id": "2",
        "name": "Nicole"
      }
    }
  ]
}
```

We have two nested entity types within our `article`: `users` and `comments`. Using various `schema`, we can normalize all three entity types down:

```js
import 'dart:convert';
import 'package:dart_normalizer/normolizer.dart';
import 'package:dart_normalizer/schema/entity.dart';

// Define a users schema
final user = new EntitySchema('users');

// Define your comments schema
final comment = new EntitySchema('comments', {
  'commenter': user
});

// Define your article 
final article = new EntitySchema('articles', { 
  'author': user,
  'comments': [ comment ]
});

// convert json string to Map
var inputMap = JSON.decode(jsonString)
Map normalizedData = normalize(originalData, article);
```

Now, `normalizedData` will be:

```js
{
  result: "123",
  entities: {
    "articles": { 
      "123": { 
        id: "123",
        author: "1",
        title: "My awesome blog post",
        comments: [ "324" ]
      }
    },
    "users": {
      "1": { "id": "1", "name": "Paul" },
      "2": { "id": "2", "name": "Nicole" }
    },
    "comments": {
      "324": { id: "324", "commenter": "2" }
    }
  }
}
```

## Dependencies

None.


