import 'package:dart_normalizer/schema/immutable_utils.dart' as ImmutableUtils;

/*

var getDefaultGetId = (idAttribute) => (input) => input[idAttribute];
class Entity {

  String key;
  var idAttribute = 'id';
  var getDefaultGetId = (idAttribute) => (input) => input[idAttribute];
  //Map<String, dynamic> schema = {};
  var _processStrategy = (input, parent, key) => [input];

  getId(input, parent, key) => input[idAttribute];//getDefaultGetId(idAttribute);



  Entity(this.key, {String idAttribute ,definition, options}){
    if(idAttribute != null) {
      this.idAttribute = idAttribute;
    }
  }

  normalize(Map input, parent, key, visit, addEntity) {
    final processedEntity = input;
    if (this.key == key) {
      var schema = key;
      processedEntity[key] = visit(
          processedEntity[key], processedEntity, key, schema, addEntity);
      print("prossesed entity $processedEntity");
    }

    addEntity(this, processedEntity, input, parent, key);

    return input[idAttribute];
  }

}
*/

class EntitySchema {
  String key;
  var idAttribute = 'id';
  var _getId;
  var _mergeStrategy;
  var _processStrategy;
  var schema;


  var getDefaultGetId = (idAttribute) {
   return (input) => input[idAttribute];};

  EntitySchema(this.key, {definition, options, idAttribute, idAttributeFun}) {
    if (key == null) {
      throw new Exception();
    }

    var mergeStrategy = (entityA, entityB) {
      return {entityA: [entityA], entityA: [entityB]};
    };
    var processStrategy = (input) => ([input]);
    this.idAttribute = "id";

    if (idAttribute != null) {
      _getId = getDefaultGetId(idAttribute);
      this.idAttribute = idAttribute;
    }
    else if (idAttributeFun != null) {
      _getId = idAttributeFun;
      idAttribute = idAttributeFun;
    }
    else {
      print(idAttribute);
      _getId = getDefaultGetId(this.idAttribute);
    }
    this._mergeStrategy = mergeStrategy;
    this._processStrategy = processStrategy;
    this.define(definition);
  }


  define(definition) {
    if (definition != null) {
      this.schema = (definition.keys).reduce((entitySchema, key) {
        final schema = definition[key];
        return { "entitySchema": entitySchema, "key": schema};
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
    final processedEntity = input; // this._processStrategy(input, parent, key);
    (this.schema.keys).forEach((key) {
      if (processedEntity.containsKey(key) && processedEntity[key] is Map) {
        final schema = this.schema[key];
        processedEntity[key] = visit(
            processedEntity[key], processedEntity, key, schema, addEntity);
      }
    });
    addEntity(this, input, input, parent, key);
    print("normalize");
    return getId(input, parent, key);
  }

  getId(input, parent, key) {
    return this._getId(input);//, parent, key);
  }

/* denormalize(entity, unvisit) {
    if (ImmutableUtils.isImmutable(entity)) {
      return ImmutableUtils.denormalizeImmutable(this.schema, entity, unvisit);
    }

    Object.keys(this.schema).forEach((key) => {
        if (entity.hasOwnProperty(key)) {
    const schema = this.schema[key];
    entity[key] = unvisit(entity[key], schema);
    }
  });
    return entity;
  }*/
}


