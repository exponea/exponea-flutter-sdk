extension ObjectExt<T> on T {
  R let<R>(R function(T value)) => function.call(this);
}
