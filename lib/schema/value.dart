import 'package:dart_normalizer/schema/polymorfic.dart';

class  Values extends PolymorphicSchema {
  Values(definition, {schemaAttribute}) : super(definition, schemaAttribute);

  normalize(Map input, parent, String key, visit, addEntity) {
    print("values1 $input");
    Map<dynamic, dynamic> object ={};
   /* if(input.length == 1) {
      var nomalized = normalizeValue(input.values.first, parent, key, visit, addEntity);
      print("normalized$nomalized");
      return {"output":{ "output": {}, "id": nomalized },
        "type": nomalized };
    }*/
    object.addAll(input);
    var res =  object.keys.reduce((output, key) {
        var value = object[key];
        print("value valuees $value");
        return (value !=  null) ? {
          output:this.normalizeValue(object[output], input, key, visit, addEntity),
          key: this.normalizeValue(value, input, key, visit, addEntity)
        }
        : output;
    });
    print("res$res");
   /* { output: { output: {}, id: 'normalizeValue' },
    type: 'normalizeValue' }*/
    return res;
  }  }

