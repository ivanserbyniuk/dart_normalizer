import 'package:dart_normalizer/schema/immutable_utils.dart' as ImmutableUtils;
import 'package:dart_normalizer/schema/schema.dart';
import 'package:dart_normalizer/schema/utils.dart';


class EntitySchema extends BaseSchema {
  String key;
  var idAttribute = 'id';
  var _getId;
  var _mergeStrategy;
  var _processStrategy;
  var schema;

  var getDefaultGetId = (idAttribute) =>
      (input, paremt, key) => input[idAttribute];

  EntitySchema(this.key,
      {definition, String idAttribute, idAttributeFunc(input, parent,
          key), processStrategy(input, parent, key), mergeStrategy(entityA,
          entityB)}) {
    if (key == null) {
      throw new Exception();
    }
    _processStrategy =
    processStrategy != null ? processStrategy : (input, parent, key) => input;
    if (idAttributeFunc == null && idAttribute == null) {
      this._getId = getDefaultGetId("id");
    }
    else if (idAttributeFunc != null && idAttribute == null) {
      this._getId = idAttributeFunc;
    }
    else if (idAttributeFunc == null && idAttribute != null) {
      this._getId = getDefaultGetId(idAttribute);
    } else if (idAttribute != null && idAttributeFunc != null) {
      throw new Exception("You must use idAttribute or idAttibuteTitle");
    }


    _mergeStrategy = (mergeStrategy != null) ? mergeStrategy : (entityA,
        entityB) => entityA..addAll(entityB);
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
    return this._mergeStrategy(entityA, entityB);
  }

  normalize(input, parent, key, visit, addEntity) {
    Map map = {};
    final processedEntity = this._processStrategy(input, parent, key);
    map.addAll(processedEntity);
    (this.schema.keys).forEach((key) {
      if (processedEntity.containsKey(key) && isObject(processedEntity[key])) {
        final schema = this.schema[key];
        map[key] = visit(
            processedEntity[key], processedEntity, key, schema, addEntity);
      }
    });
    addEntity(this, map, input, parent, key);
    return getId(input, parent, key);
  }

  getId(input, parent, key) {
    return this._getId(input, parent, key);
  }

  denormalize(Map entity, unvisit) {
    this.schema.keys.forEach((key) {
      if (entity.containsKey((key))) {
        var schema = this.schema[key];
        entity[key] = unvisit(entity[key], schema);
      }
    });
    return entity.map((key, value) =>
        MapEntry(key, unvisit(entity[key], schema)));
  }

}


