import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/immutable_utils.dart';
import 'package:dart_normalizer/schema/object.dart' as ObjectUtils;
import 'package:dart_normalizer/schema/array.dart' as ArrayUtils;
import 'package:dart_normalizer/schema/object.dart';
import 'package:dart_normalizer/schema/schema.dart';
import 'package:dart_normalizer/schema/utils.dart';


normalize(input, schema) {
  Map entities = {};
  var addEntity = _addEntities(entities);
  var result = _visit(input, input, null, schema, addEntity);
  return { "entities": entities, "result": result};
}


_visit(value, parent, key, schema, addEntity) {
  if (value == null || (value is Map && isUndefined(value)) ||
      (!isObject(value)) && !isSchema(value)) {
    return (value is Map) && isUndefined(value) ? null : value;
  }
  if (schema is List || (!isSchema(schema))) {
    var method = schema is List ? ArrayUtils.normalize : ObjectUtils.normalize1;
    return method(schema, value, parent, key, _visit, addEntity);
  }
  var result = schema.normalize(value, parent, key, _visit, addEntity);

  return result;
}

_addEntities(entities) =>
        (EntitySchema schema, processedEntity, value, parent, key) {
      var schemaKey = schema.key;
      var id = schema.getId(value, parent, key).toString();
      if (!entities.containsKey(schemaKey)) {
        entities[schemaKey] = {};
      }
      var existingEntity = entities[schemaKey][id];
      if (existingEntity != null) {
        entities[schemaKey][id] = schema.merge(existingEntity, processedEntity);
      } else {
        entities[schemaKey][id] = processedEntity;
      }
    };

denormalize(input, schema, entities) {
  if (input != null) {
    return _getUnvisit(entities)(input, schema);
  }
}

_unvisitEntity(id, schema, unvisit, getEntity, cache) {
  var entity = getEntity(id, schema);
  if (((!isObject(entity))) || entity == null || entity is int) {
    ///todo CHECK
    return entity;
  }

  if (cache[schema.key] == null) {
    cache[schema.key] = {};
  }
  if (cache[schema.key] [id] == null) {
// Ensure we don't mutate it non-immutable objects

    final entityCopy = {};
    entityCopy.addAll(entity);

// Need to set this first so that if it is referenced further within the
// denormalization the reference will already exist.
    cache[schema.key][id] = entityCopy;

    var denormalize = schema.denormalize(entityCopy, unvisit);
    cache[schema.key][id] = denormalize;
  }

  return cache[schema.key][id];
}

_getUnvisit(entities) {
  final cache = {};
  final getEntity = _getEntities(entities);

  unvisit(input, schema) {
    if (isObject(schema)) {
      final method = schema is Iterable ? ArrayUtils.denormalize : ObjectUtils
          .denormalize1;
      return method(schema, input, unvisit);
    }
    if (input == null) {
      return input;
    }
    if (schema is EntitySchema) {
      return _unvisitEntity(input, schema, unvisit, getEntity, cache);
    }
    return schema.denormalize(input, unvisit);
  }
  return (input, schema) => unvisit(input, schema);
}

_getEntities(entities) {
  return (entityOrId, schema) {
    var schemaKey = schema.key;

    if (isObject(entityOrId)) {
      return entityOrId;
    }

    return entities[schemaKey][entityOrId];
  };
}



