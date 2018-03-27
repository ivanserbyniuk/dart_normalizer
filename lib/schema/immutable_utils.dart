bool isImmutable(Map<dynamic, dynamic> object) {
  return object.containsKey("_ownerID");
}


Map<dynamic, dynamic> denormalizeImmutable(Map schema, Map input, unvisit) {
  Map toReduce(object, key) {
    String keyString = key.toString();
    if ((object is Map) && object.containsKey(keyString)) {
      object.remove(keyString);
      object.putIfAbsent(
          keyString, unvisit(object[keyString], schema[keyString]));
      return object;
    }
    else
      return object;
  }
  return schema.keys.reduce(toReduce);
}

