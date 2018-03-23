import 'package:dart_normalizer/schema/immutable_utils.dart';

class PolymorphicSchema {
  dynamic _schemaAttribute;
  dynamic schema;

  PolymorphicSchema(definition, schemaAttribute) {
    if (schemaAttribute != null) {
      this._schemaAttribute = schemaAttribute is String
          ? (input,p1,p2) => input[schemaAttribute]
          : schemaAttribute;
    }

    this.define(definition);
  }

   isSingleSchema() {
    return _schemaAttribute == null;
  }

  define(definition) {
    this.schema = definition;
  }

  getSchemaAttribute(input, parent, key) {
    return  this._schemaAttribute(input, parent, key);
  }

  inferSchema(input, parent, key) {

    var attr = getSchemaAttribute(input, parent, key);
    print("attr $attr");
    return this.schema[attr];
  }

  normalizeValue(value, parent, key, visit, addEntity) {
    final schema = inferSchema(value, parent, key);
    if (schema == null) {
      return value;
    }
    final normalizedValue = visit(value, parent, key, schema, addEntity);
    return this.isSingleSchema() || normalizedValue == null
        ? normalizedValue
        : {
      "id": normalizedValue,
      "schema": this.getSchemaAttribute(value, parent, key)
    };
  }


  denormalizeValue(value, unvisit) {
    var schemaKey =  value["schema"];;
    if (!isSingleSchema() && schemaKey==null) {
      return value;
    }
    var id =  value["id"];
    print(value);
    var schema = isSingleSchema() ? this.schema : this.schema[schemaKey];
    var key = id == null ? value : id;
    return unvisit(key, schema);
  }
}