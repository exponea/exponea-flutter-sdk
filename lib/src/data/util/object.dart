extension ObjectExt<T> on T {
  R let<R>(R Function(T value) function) => function.call(this);
}

extension MapExt on Map<dynamic, dynamic> {
  T? getOptional<T>(String key) {
    return this[key];
  }

  T getRequired<T>(String key) {
    final value = this[key] as T?;
    if (value == null) {
      throw StateError('$key is required!');
    }
    return value;
  }
}
