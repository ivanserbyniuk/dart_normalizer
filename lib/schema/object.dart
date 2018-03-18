import 'package:dart_normalizer/schema/entity.dart';


 normalize2(Entity schema, Map input, parent, key, visit, addEntity) {
var object = input ;
var localSchema = schema.key;
var value = visit(input[key], input, key, localSchema, addEntity);
if (value == null) {
  input.remove(key);
} else {
  object[key] = value;
}
/*(schema.keys).forEach((key) {
var localSchema = schema[key];
var value = visit(input[key], input, key, localSchema, addEntity);
if (value == null) {
input.remove(key);
} else {
object[key] = value;
}
});*/
return object;
}
