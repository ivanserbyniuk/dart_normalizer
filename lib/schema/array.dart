import 'package:dart_normalizer/schema/polymorfic.dart';

var validateSchema = (definition) => definition[0];

getValues(input) => (input is List) ? input : input.values;

normalize(schema, input, parent, key, visit, addEntity) {
  schema = validateSchema(schema);
  var values = getValues(input);
// Special case: Arrays pass *their* parent on to their children, since there
// is not any special information that can be gathered from themselves directly
  return values.map((value) => visit(value, parent, key, schema, addEntity))
      .toList();
}

denormalize(schema, input, unvisit) {
  schema = validateSchema(schema);
  return (input != null && input is Iterable) ? input.map((entityOrId) =>
      unvisit(entityOrId, schema)) : input;
}

class ArraySchema extends PolymorphicSchema {
  ArraySchema(definition, {String schemaAttribute, dynamic schemaAttributeFunc(input, parent, key)})
      : super(definition, schemaAttribute, schemaAttributeFunc);

  normalize(input, parent, key, visit, addEntity) {
    final values = getValues(input);
    var list = values
        .map((value) =>
        this.normalizeValue(value, parent, key, visit, addEntity))
        .where((value) => value != null).toList();
    return list;
  }

  denormalize(input, unvisit) {
    return input != null && input is Iterable ? input.map((value) =>
        this.denormalizeValue(value, unvisit)) : input;
  }
}




