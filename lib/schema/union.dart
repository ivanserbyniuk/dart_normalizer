import 'package:dart_normalizer/schema/polymorfic.dart';


class UnionSchema extends PolymorphicSchema {
  UnionSchema(definition, schemaAttribute):super(definition, schemaAttribute){
    if (schemaAttribute==null) {
      throw new Exception('Expected option "schemaAttribute" not found on UnionSchema.');
    }
  }

  normalize(input, parent, key, visit, addEntity) {
    return this.normalizeValue(input, parent, key, visit, addEntity);
  }

  denormalize(input, unvisit) {
    return this.denormalizeValue(input, unvisit);
  }
}