// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surah_cache_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SurahCacheModelAdapter extends TypeAdapter<SurahCacheModel> {
  @override
  final int typeId = 0;

  @override
  SurahCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SurahCacheModel(
      id: fields[0] as int,
      nameSimple: fields[1] as String,
      nameArabic: fields[2] as String,
      versesCount: fields[3] as int,
      revelationPlace: fields[4] as String,
      pages: (fields[5] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, SurahCacheModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nameSimple)
      ..writeByte(2)
      ..write(obj.nameArabic)
      ..writeByte(3)
      ..write(obj.versesCount)
      ..writeByte(4)
      ..write(obj.revelationPlace)
      ..writeByte(5)
      ..write(obj.pages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurahCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
