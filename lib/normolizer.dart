import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/immutable_utils.dart';
import 'package:dart_normalizer/schema/object.dart' as ObjectUtils;
import 'package:dart_normalizer/schema/array.dart' as ArrayUtils;
import 'package:dart_normalizer/schema/object.dart';
import 'package:dart_normalizer/schema/schema.dart';
import 'package:dart_normalizer/schema/utils.dart';




normalize(input, schema) {
  Map entities = {};
  var addEntity = addEntities(entities);
  var result = visit(input, input, null, schema, addEntity);
  return { "entities": entities, "result": result};
}


visit( value,  parent, key,  schema, addEntity) {
if( value == null || (value is Map && isUndefined(value))||(!isObject(value) ) && !isSchema(value)) {
  return (value is Map)&& isUndefined(value) ? null :value;
}
  if (schema is List || (!isSchema(schema)) ) {
    var method = schema is List ? ArrayUtils.normalize : ObjectUtils.normalize1;
    return method(schema, value, parent, key, visit, addEntity);
  }
  var result = schema.normalize(value, parent, key, visit, addEntity);

  return result;
}

addEntities(entities) =>
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


unvisitEntity(id, schema, unvisit, getEntity, Map cache) {
  var entity = getEntity(id, schema);
  if (entity == null || isObject(entity)) {
    return entity;
  }

  if (!cache.containsKey(schema.key)) {
    cache[schema.key] = {};
  }

  if(cache.containsKey(schema.key) && cache[schema.key][id] != null) {
// Ensure we don't mutate it non-immutable objects
    var entityCopy = isImmutable(entity) ? entity : new Map()..addAll(entity);

// Need to set this first so that if it is referenced further within the
// denormalization the reference will already exist.
    cache[schema.key][id] = entityCopy;
    cache[schema.key][id] = schema.denormalize(entityCopy, unvisit);
  }

  return cache[schema.key][id];
}


getEntities(entities) {
  var isIm = false;//isImmutable(entities);

  return (entityOrId, schema) {
    var schemaKey = schema.key;

    if (isObject(entityOrId)) {
      return entityOrId;
    }

    return isIm
        ? entities.getIn([schemaKey, entityOrId.toString()])
        : entities[schemaKey][entityOrId];
  };
}



getUnvisit(entities)  {
  var cache = {};
  var getEntity = getEntities(entities);
  unvisit (input, schema) {
    if (isObject(schema) && !isSchema(schema)) {

      var method = (schema is List) ? ArrayUtils.denormalize : ObjectUtils.denormalize1;
      return method(schema, input, unvisit);
    }

    if (input == null) {
      return input;
    }

    if (schema is EntitySchema) {
      return unvisitEntity(input, schema, unvisit, getEntity, cache);
    }
    return schema.denormalize(input, unvisit);
  }

  return (input, schema) => unvisit(input, schema);
}

 denormalize (input, schema, entities)  {
if (input !=null) {
return getUnvisit(entities)(input, schema);
}
//else {return {};}
}
