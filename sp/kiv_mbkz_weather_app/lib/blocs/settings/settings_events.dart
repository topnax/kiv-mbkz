import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {}

class UnitsToggled extends SettingsEvent {
  @override
  List<Object> get props => [];
}

class LoadUnits extends SettingsEvent {
  @override
  List<Object> get props => [];
}
