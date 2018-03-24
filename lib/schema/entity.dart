import 'package:dart_normalizer/schema/immutable_utils.dart' as ImmutableUtils;


class EntitySchema {
  String key;
  var idAttribute = 'id';
  var _getId;
  var _mergeStrategy;
  var _processStrategy;
  var schema;


  var getDefaultGetId = (idAttribute) =>
      (input, paremt, key) => input[idAttribute];

  EntitySchema(this.key, {definition, options, idAttribute, processStrategy, mergeStrategy}) {
    if (key == null) {
      throw new Exception();
    }
    print((input,parent, key) => input);
    _processStrategy= processStrategy!= null ? processStrategy : (input,parent, key) => input;
    if (idAttribute == null) {
      // this.idAttribute = "id";
      this._getId = getDefaultGetId("id");
    }
    else {
      this._getId = idAttribute is String
          ? getDefaultGetId(idAttribute)
          : idAttribute;
    }
    _mergeStrategy = (mergeStrategy != null) ? mergeStrategy :( entityA, entityB) =>entityA..addAll(entityB);
    this.define(definition);
  }

  define(Map definition) {
    if (definition != null) {
      this.schema = definition.map((key, value) {
        final schema = definition[key];
        return MapEntry(key, schema);
      });
    }
    if (schema == null) {
      this.schema = {};
    }
  }

  merge(entityA, entityB) {
    print("mergeSt$entityA, $entityB $_mergeStrategy");
    return this._mergeStrategy(entityA, entityB);
  }

  normalize(input, parent, key, visit, addEntity) {
    final processedEntity = this._processStrategy(input, parent, key);
    (this.schema.keys).forEach((key) {
      if (processedEntity.containsKey(key) && processedEntity[key] is Map) {
        final schema = this.schema[key];
        processedEntity[key] = visit(processedEntity[key], processedEntity, key, schema, addEntity);
      }
    });
    addEntity(this, processedEntity, input, parent, key);
    return getId(input, parent, key);
  }

  getId(input, parent, key) {
    return this._getId(input, parent, key);
  }

  denormalize(Map entity, unvisit) {
    print ("denorm");
 /*   if (ImmutableUtils.isImmutable(entity)) {
      return ImmutableUtils.denormalizeImmutable(this.schema, entity, unvisit);
    }*/

    this.schema.keys.forEach((key1) {
      if (entity.containsKey((key1))) {
      var schema = this.schema[key];
      entity[key] = unvisit(entity[key], schema);
      }
      });
    return entity;
  }

}


