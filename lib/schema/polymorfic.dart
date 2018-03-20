import 'package:dart_normalizer/schema/immutable_utils.dart';

 class PolymorphicSchema {
  dynamic _schemaAttribute;
  dynamic schema;

  PolymorphicSchema(definition, dynamic schemaAttribute) {
    if (schemaAttribute !=null) {
      this._schemaAttribute = schemaAttribute is String  ? (input) => input[schemaAttribute] : schemaAttribute;
    }
    this.define(definition);
  }

  get isSingleSchema {
    return  _schemaAttribute != null;
  }

  define(definition) {
    this.schema = definition;
  }

  getSchemaAttribute(input, parent, key) {
    return !this.isSingleSchema && this._schemaAttribute(input, parent, key);
  }

  inferSchema(input, parent, key) {
    if (this.isSingleSchema) {
      return this.schema;
    }
    var attr = getSchemaAttribute(input, parent, key);
    return this.schema[attr];
  }

  normalizeValue(value, parent, key, visit, addEntity) {
    final schema = inferSchema(value, parent, key);
    if (schema == null) {
      return value;
    }
    final normalizedValue = visit(value, parent, key, schema, addEntity);
    return this.isSingleSchema || normalizedValue == null
    ? normalizedValue
        : { "id": normalizedValue, "schema": this.getSchemaAttribute(value, parent, key) };
  }

  denormalizeValue(value, unvisit) {
    final schemaKey = isImmutable(value) ? value.get('schema') : value.schema;
    if (!this.isSingleSchema && schemaKey!=null) {
      return value;
    }
    final  id = isImmutable(value) ? value.get('id') : value.id;
    final schema = this.isSingleSchema ? this.schema : this.schema[schemaKey];
    return unvisit(id || value, schema);
  }
}