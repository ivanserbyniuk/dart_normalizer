import 'package:dart_normalizer/schema/polymorfic.dart';

class  Values extends PolymorphicSchema {
  Values(definition, schemaAttribute) : super(definition, schemaAttribute);

  normalize2(Map input, parent, String key, visit, addEntity) {
    return {key: normalizeValue(input[key], parent, key, visit, addEntity)};
  }

}