// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LocationModelImpl _$$LocationModelImplFromJson(Map<String, dynamic> json) =>
    _$LocationModelImpl(
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String?,
      admin1: json['admin1'] as String?,
      country: json['country'] as String?,
    );

Map<String, dynamic> _$$LocationModelImplToJson(_$LocationModelImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timezone': instance.timezone,
      'admin1': instance.admin1,
      'country': instance.country,
    };
