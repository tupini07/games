import 'dart:math';

extension RandomSample<T> on Random {
  T sample(List<T> list) {
    return list[nextInt(list.length)];
  }
}
