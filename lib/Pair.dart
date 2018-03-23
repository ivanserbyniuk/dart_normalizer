class Pair <T,R> {
  final T first;
  final R second;

  Pair(this.first, this.second);

}

List<Pair<T,R>> mapToList<T,R>(Map<T,R> map) {
  final List<Pair<T, R>> list = [];
  map.forEach((key, value)=>list.add(new Pair(key, value)));
  return list;
}

Map<T,R> listToMap<T,R>(List<Pair<T,R>>list){
  Map<T,R> map = {};
  list.forEach((value){
    map[value.first] = value.second;
  });
  return map;
}

Map<T,R> mapEntity<T,R,T1,R1>(Map<T, R> map, Pair<T1,R1> fun(T key, R value)){
  Map<T1,R1> mapRes = {};
  mapToList(map).map((value) => fun(value.first, value.second)).forEach((value) {
    mapRes[value.first] = value.second;
  });
  return map;
}

Map<T,V> mapValue<T, R, V>(Map<T,R> map, V func(R value)){
  Map mapRes = mapEntity(map, (key, value)=> Pair(key, func(value)));
  return mapRes;
}