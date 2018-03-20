import 'package:dart_normalizer/schema/entity.dart';


normalize2(schema, input, parent, key, visit, addEntity) {
  Map object = input;
  print("input");
  (schema.schema.keys).forEach((key) {
    var localSchema = schema.schema[key];
    var value = visit(input[key], input, key, localSchema, addEntity);
    if (value == null) {
      object.remove(key);
    } else {
      object[key] = value;
    }
  });
  return object;
}

class ObjectSchema {
  var schema;

  ObjectSchema(definition) {
    this.define(definition);
  }

  define(definition) {
    this.schema = definition;
  }

  normalizeSelf(input, parent, key, visit, addEntity) {
    return normalize2(schema, input, parent, key, visit, addEntity);
  }


}