import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/immutable_utils.dart';


normalize1(schema, input, parent, key, visit, addEntity) {
  Map<dynamic, dynamic> object = {};
  object.addAll(input);
  (schema.keys).forEach((key) {
    var localSchema = schema[key];
    // if(input[key]!= null) { //todo #hack need to check
    var value = visit(input[key], input, key, localSchema, addEntity);
    if (value == null) {
      object.remove(key);
    } else {
      object[key] = value;
    }
    // }
  });
  print("print object $object");
  return object;
}

denormalize1(schema, input, unvisit) {
 // return denormalizeImmutable(schema, input, unvisit);

  Map object = {};
  (schema.keys).forEach((key) {
    print("key$key");

    if (object[key] != null) {
      print("key$key");
      object[key] = unvisit(object[key], schema[key]);
    }
  });
  return object;
}


class ObjectSchema {
  Map schema;

  ObjectSchema(definition) {
    this.define(definition);
  }

  define(Map definition) {
    this.schema = definition.map((key, value) => MapEntry(key, value));

/*    if(definition.length == 1 ) {
      var key = definition.keys.first;
      this.schema = { key :definition[key] };
    } else {
      this.schema=(definition.keys).reduce((entitySchema, key) {
        var schema = definition[key];
        return { "entirySchema": entitySchema, key: schema};
      }); }*/

  }


  normalize(input, parent, key, visit, addEntity) {
    return normalize1(this.schema, input, parent, key, visit, addEntity);
  }

  denormalize( input, unvisit){
    return denormalize1(schema, input, unvisit);
  }

}