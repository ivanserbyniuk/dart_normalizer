import 'package:dart_normalizer/schema/entity.dart';
import 'package:dart_normalizer/schema/object.dart';
import 'package:dart_normalizer/schema/schema.dart';

isObject(value) => value is Map || value is List;

isSchema(value) => value is BaseSchema;

isUndefined(value) => value.isEmpty;