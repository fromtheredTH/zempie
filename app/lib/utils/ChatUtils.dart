
import 'dart:convert';

import 'package:app/global/global.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_sound/public/flutter_sound_player.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../models/dto/chat_msg_dto.dart';
import '../models/dto/chat_room_dto.dart';

class ChatUtils {
  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  static final _storage = new FlutterSecureStorage(aOptions: _getAndroidOptions());

  static Future<void> saveChats(int roomId, List<ChatMsgDto> chats) async {
    chats.sort((a, b) => (b.id).compareTo(a.id));
    final encode = jsonEncode(chats);
    await _storage.write(key: "ChatMsgs_${roomId}", value: encode);
  }

  static Future<void> saveChat(int roomId, ChatMsgDto chatRoom) async {
    List<ChatMsgDto> models = await getChats(roomId);
    bool isExist = false;
    for(int i=0;i<models.length;i++){
      if(isSameChat(models[i], chatRoom)){
        int? audioTime = models[i].audioTime;
        models[i] = chatRoom;
        if(models[i].type == eChatType.AUDIO.index) {
          if (audioTime != null) {
            models[i].audioTime = audioTime;
          } else {
            FlutterSoundPlayer playerModule = FlutterSoundPlayer();
            await playerModule?.closePlayer();
            await playerModule?.openPlayer();

            Duration duration = await playerModule?.startPlayer(
                fromURI: chatRoom.contents ?? '',
                codec: Codec.pcm16WAV,
                sampleRate: 44000,
                whenFinished: () {}) ??
                const Duration();
            audioTime = duration.inSeconds;
            await playerModule?.stopPlayer();
            await playerModule?.closePlayer();
            models[i].audioTime = audioTime;
          }
        }
        isExist = true;
        break;
      }
    }
    if(!isExist) {
      models.add(chatRoom);
    }
    saveChats(roomId, models);
  }

  static Future<void> saveMultiChats(int roomId, List<ChatMsgDto> chats) async {
    List<ChatMsgDto> models = await getChats(roomId);

    for(int k=0;k<chats.length;k++){
      bool isExist = false;
      for(int i=0;i<models.length;i++){
        if(isSameChat(models[i], chats[k])){
          int? audioTime = models[i].audioTime;
          models[i] = chats[k];
          if(models[i].type == eChatType.AUDIO.index) {
            if (audioTime != null) {
              models[i].audioTime = audioTime;
            } else {
              FlutterSoundPlayer playerModule = FlutterSoundPlayer();
              await playerModule?.closePlayer();
              await playerModule?.openPlayer();

              Duration duration = await playerModule?.startPlayer(
                  fromURI: chats[k].contents ?? '',
                  codec: Codec.pcm16WAV,
                  sampleRate: 44000,
                  whenFinished: () {}) ??
                  const Duration();
              audioTime = duration.inSeconds;
              await playerModule?.stopPlayer();
              await playerModule?.closePlayer();
              models[i].audioTime = audioTime;
            }
          }
          isExist = true;
          break;
        }
      }
      if(!isExist) {
        if(chats[k].type == eChatType.AUDIO.index) {
          FlutterSoundPlayer playerModule = FlutterSoundPlayer();
          await playerModule?.closePlayer();
          await playerModule?.openPlayer();

          Duration duration = await playerModule?.startPlayer(
              fromURI: chats[k].contents ?? '',
              codec: Codec.pcm16WAV,
              sampleRate: 44000,
              whenFinished: () {}) ??
              const Duration();
          int audioTime = duration.inSeconds;
          await playerModule?.stopPlayer();
          await playerModule?.closePlayer();
          chats[k].audioTime = audioTime;
        }
        models.add(chats[k]);
      }
    }

    saveChats(roomId, models);
  }

  static Future<void> deleteAllChats(int roomId) async {
    await _storage.delete(key: "ChatMsgs_${roomId}");
  }

  static Future<void> deleteChat(int roomId, ChatMsgDto chatRoom) async {
    List<ChatMsgDto> models = await getChats(roomId);
    for(int i=0;i<models.length;i++){
      if(isSameChat(models[i], chatRoom)){
        models.removeAt(i);
        break;
      }
    }
    await saveChats(roomId, models);
  }

  static Future<void> deleteChatFromId(int roomId, int id) async {
    List<ChatMsgDto> models = await getChats(roomId);
    for(int i=0;i<models.length;i++){
      if(models[i].id == id){
        models.removeAt(i);
        break;
      }
    }
    await saveChats(roomId, models);
  }

  static bool isSameChat(ChatMsgDto model1, ChatMsgDto model2) {
    if(model1.id == model2.id){
      return true;
    }
    return false;
  }

  static Future<List<ChatMsgDto>> getChats(int roomId) async {
    String result = await _storage.read(key: "ChatMsgs_${roomId}") ?? "[]";
    final decode = jsonDecode(result);
    List<ChatMsgDto> models = [];
    if(decode is List<dynamic>) {
      for(final e in decode){
        models.add(ChatMsgDto.fromJson(e));
      }
    }
    models.sort((a, b) => (b.id).compareTo(a.id));
    return models;
  }
}