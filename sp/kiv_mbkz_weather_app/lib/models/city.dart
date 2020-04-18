import 'package:equatable/equatable.dart';

class City extends Equatable {
  static const SEPEARATOR = "#:]";

  final String name;
  final int woeid;

  City(this.name, this.woeid);

  @override
  String toString() => "$name$SEPEARATOR$woeid";

  @override
  List<Object> get props => [name, woeid];
}
