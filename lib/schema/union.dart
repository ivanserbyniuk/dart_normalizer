import 'package:dart_normalizer/schema/polymorfic.dart';


class UnionSchema extends PolymorphicSchema {
  UnionSchema( definition, { String schemaAttribute, dynamic schemaAttributeFunc(input, parrent, key)})
      :super(definition, schemaAttribute,schemaAttributeFunc) {
    if (schemaAttribute == null && schemaAttributeFunc == null) {
      throw new Exception(
          'Expected option "schemaAttribute" not found on UnionSchema.');
    }
  }

  normalize(input, parent, key, visit, addEntity) {
    return this.normalizeValue(input, parent, key, visit, addEntity);
  }

  denormalize(input, unvisit) {
    return this.denormalizeValue(input, unvisit);
  }
}