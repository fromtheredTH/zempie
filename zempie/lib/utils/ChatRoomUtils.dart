
import 'dart:convert';

import 'package:app/utils/ChatUtils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/dto/chat_room_dto.dart';

class ChatRoomUtils {
  static AndroidOptions _getAndroidOptions() => const AndroidOptions(
    encryptedSharedPreferences: true,
  );
  static final _storage = new FlutterSecureStorage(aOptions: _getAndroidOptions());

  static Future<void> saveChatRooms(List<ChatRoomDto> chatRooms) async {
    chatRooms.sort((a, b) => (b.last_chat_at ?? "").compareTo(a.last_chat_at ?? ""));
    final encode = jsonEncode(chatRooms);
    await _storage.write(key: "ChatRooms", value: encode);
  }

  static Future<void> deleteAllRooms() async {
    List<ChatRoomDto> models = await getChatRooms();
    for(int i=0;i<models.length;i++){
      deleteChatRoom(models[i]);
    }
  }

  static Future<void> saveChatRoom(ChatRoomDto chatRoom) async {
    List<ChatRoomDto> models = await getChatRooms();
    bool isExist = false;
    for(int i=0;i<models.length;i++){
      if(isSameChatRoom(models[i], chatRoom)){
        models[i] = chatRoom;
        isExist = true;
        break;
      }
    }
    if(!isExist) {
      models.add(chatRoom);
    }
    saveChatRooms(models);
  }

  static Future<void> saveMultiChatRoom(List<ChatRoomDto> chatRooms) async {
    List<ChatRoomDto> models = await getChatRooms();

    for(int k=0;k<chatRooms.length;k++){
      bool isExist = false;
      for(int i=0;i<models.length;i++){
        if(isSameChatRoom(models[i], chatRooms[k])){
          models[i] = chatRooms[k];
          isExist = true;
          break;
        }
      }
      if(!isExist) {
        models.add(chatRooms[k]);
      }
    }

    saveChatRooms(models);
  }

  static Future<void> deleteChatRoom(ChatRoomDto chatRoom) async {
    List<ChatRoomDto> models = await getChatRooms();
    for(int i=0;i<models.length;i++){
      if(isSameChatRoom(models[i], chatRoom)){
        ChatUtils.deleteAllChats(chatRoom.id);
        models.removeAt(i);
        break;
      }
    }
    await saveChatRooms(models);
  }

  static Future<void> deleteChatRoomFromId(int id) async {
    List<ChatRoomDto> models = await getChatRooms();
    for(int i=0;i<models.length;i++){
      if(models[i].id == id){
        ChatUtils.deleteAllChats(id);
        models.removeAt(i);
        break;
      }
    }
    await saveChatRooms(models);
  }

  static bool isSameChatRoom(ChatRoomDto model1, ChatRoomDto model2) {
    if(model1.id == model2.id){
      return true;
    }
    return false;
  }

  static Future<List<ChatRoomDto>> getChatRooms() async {
    String result = await _storage.read(key: "ChatRooms") ?? "[]";
    final decode = jsonDecode(result);
    List<ChatRoomDto> models = [];
    if(decode is List<dynamic>) {
      for(final e in decode){
        models.add(ChatRoomDto.fromJson(e));
      }
    }
    models.sort((a, b) => (b.last_chat_at ?? "").compareTo(a.last_chat_at ?? ""));
    return models;
  }
}