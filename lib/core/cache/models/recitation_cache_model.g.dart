// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recitation_cache_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecitationCacheModelAdapter extends TypeAdapter<RecitationCacheModel> {
  @override
  final int typeId = 2;

  @override
  RecitationCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecitationCacheModel(
      chapterId: fields[0] as int,
      audioUrl: fields[1] as String,
      reciterName: fields[2] as String,
      edition: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, RecitationCacheModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.chapterId)
      ..writeByte(1)
      ..write(obj.audioUrl)
      ..writeByte(2)
      ..write(obj.reciterName)
      ..writeByte(3)
      ..write(obj.edition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecitationCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
