import 'package:dart_normalizer/schema/polymorfic.dart';

class Values extends PolymorphicSchema {
  Values(definition,
      { String schemaAttribute, dynamic schemaAttributeFunc(input, parrent,
          key)}) : super(definition,  schemaAttribute,
       schemaAttributeFunc);

  normalize(Map input, parent, String key, visit, addEntity) {
    Map<dynamic, dynamic> object = {};
    input.forEach((key, value) {
      if (value != null) {
        object[key] = value;
      }
    });
    object.addAll(object.map((key, value) =>
        MapEntry(key, normalizeValue(value, input, key, visit, addEntity))));
    return object;
  }

  denormalize(input, unvisit) {
    return input.map((key, value) =>
        MapEntry(key, denormalizeValue(value, unvisit)));
  }
}

