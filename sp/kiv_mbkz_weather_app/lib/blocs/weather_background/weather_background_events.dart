import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class WeatherBackgroundEvent extends Equatable {
  const WeatherBackgroundEvent();
}

class WeatherBackgroundChanged extends WeatherBackgroundEvent {
  final int tabIndex;

  const WeatherBackgroundChanged({@required this.tabIndex}) : assert(tabIndex != null);

  @override
  List<Object> get props => [tabIndex];
}
