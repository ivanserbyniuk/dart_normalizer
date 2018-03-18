import 'package:dart_normalizer/schema/immutable_utils.dart';
import 'package:dart_normalizer/schema/object.dart';
import 'package:dart_normalizer/schema/entity.dart';




normalize(Map<String, dynamic>input, Entity schema) {
  var entities = {};
  var addEntity = addEntities(entities);
//  print("Lol");

  var result = visit(input, input, null, schema, addEntity);
  print("Lol");

  return { "entities": entities, "result": result};
}


visit(Map value, Map parent, key,  schema, addEntity) {
  if (!(value is Map)) {
    return value;
  }
 // var fun = value.runtimeType.toString() == "function";
  //if ((!schema.normalize || !fun)) {
    var method = /*schema is List ? ArrayUtils.normalize :*/ normalize2;
    return method(schema, value, parent, key, visit, addEntity);
  //}

 // return schema.normalize(value, parent, key, visit, addEntity);
}

addEntities(entities) =>
        (schema, processedEntity, value, parent, key) {
  print("lol");
      var schemaKey = schema.key;
      var id = schema.getId(value, parent, key);
      if (!entities.contain(schemaKey)) {
        entities[schemaKey] = {};
      }

      var existingEntity = entities[schemaKey][id];
      print(existingEntity);
      if (existingEntity!= null) {
        entities[schemaKey][id] = schema.merge(existingEntity, processedEntity);
      } else {
        entities[schemaKey][id] = processedEntity;
      }
    };

/*
export const schema = {
  Array: ArraySchema,
  Entity: EntitySchema,
  Object: ObjectSchema,
  Union: UnionSchema,
  Values: ValuesSchema
};
*/


unvisitEntity(id, schema, unvisit, getEntity, cache) {
  var entity = getEntity(id, schema);
  if (entity is Map) {
    return entity;
  }

  if (!cache[schema.key]) {
    cache[schema.key] = {};
  }

  if (!cache[schema.key][id]) {
// Ensure we don't mutate it non-immutable objects
    var entityCopy = isImmutable(entity) ? entity : [entity];

// Need to set this first so that if it is referenced further within the
// denormalization the reference will already exist.
    cache[schema.key][id] = entityCopy;
    cache[schema.key][id] = schema.denormalize(entityCopy, unvisit);
  }

  return cache[schema.key][id];
}

/*getUnvisit(entities){
var cache = {};
var getEntity = getEntities(entities);
var unvisit =  unvisit(input, schema) {
  if (typeof schema === 'object' && (!schema.denormalize || typeof schema.denormalize !== 'function')) {
   const method = Array.isArray(schema) ? ArrayUtils.denormalize : ObjectUtils.denormalize;
   return method(schema, input, unvisit);
   }

   if (input === undefined || input === null) {
   return input;
   }

   if (schema instanceof EntitySchema) {
   return unvisitEntity(input, schema, unvisit, getEntity, cache);
   }

   return schema.denormalize(input, unvisit);
 }
return  unvisit;
};
*/
getEntities(entities) {
  var isIm = isImmutable(entities);

  return (entityOrId, schema) {
    var schemaKey = schema.key;

    if (entityOrId is Map) {
      return entityOrId;
    }

    return isIm
        ? entities.getIn([schemaKey, entityOrId.toString()])
        : entities[schemaKey][entityOrId];
  };
}

/* denormalize (input, schema, entities)  {
if (input !=null) {
return getUnvisit(entities)(input, schema);
}*/

