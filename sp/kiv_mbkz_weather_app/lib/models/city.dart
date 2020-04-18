import 'package:equatable/equatable.dart';

class City extends Equatable {
  static const FIELD_SEPARATOR = "#:]";

  final String name;
  final int woeid;

  City(this.name, this.woeid);

  @override
  String toString() => "$name$FIELD_SEPARATOR$woeid";

  @override
  List<Object> get props => [name, woeid];
}
