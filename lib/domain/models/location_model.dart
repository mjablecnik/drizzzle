import 'package:freezed_annotation/freezed_annotation.dart';
part 'location_model.freezed.dart';
part 'location_model.g.dart';

@freezed
class LocationModel with _$LocationModel {
  const factory LocationModel({
    required String name,
    required double latitude,
    required double longitude,
    required String? timezone,
    required String? admin1,
    required String? country,
  }) = _LocationModel;

  factory LocationModel.fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);
}
