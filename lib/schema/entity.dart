import 'package:dart_normalizer/schema/immutable_utils.dart';


var getDefaultGetId = (idAttribute) => (input) => input[idAttribute];


class Entity {

  String key;
  var idAttribute = 'id';
  var getDefaultGetId = (idAttribute) => (input) => input[idAttribute];
  //Map<String, dynamic> schema = {};
  var _processStrategy = (input, parent, key) => [input];

  getId(input, parent, key) => input[idAttribute];//getDefaultGetId(idAttribute);



  Entity(this.key, {definition, options}){
  }

/*  denormalize(Map entity, unvisit) {
    if (isImmutable(entity)) {
      return denormalizeImmutable(this.schema, entity, unvisit);
    }

    this.schema.keys.forEach((key) {
      if (entity.containsKey(key)) {
        var schema = this.schema[key];
        entity[key] = unvisit(entity[key], schema);
      }
    });
    return entity;
  }*/

  normalize(Map input, parent, key, visit, addEntity) {
    //   final processedEntity = this._processStrategy(input, parent, key);
    final processedEntity = input;
/*    this.schema.keys.forEach((key) {
      if (processedEntity.containsKey(key)) {
        var schema = key;
        processedEntity[key] = visit(
            processedEntity[key], processedEntity, key, schema, addEntity);
      }
    });*/

    if (this.key == key) {
      var schema = key;
      processedEntity[key] = visit(
          processedEntity[key], processedEntity, key, schema, addEntity);
    }

    addEntity(this, processedEntity, input, parent, key);

    return input[idAttribute];
  }

}

