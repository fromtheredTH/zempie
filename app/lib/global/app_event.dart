import 'package:event_bus_plus/event_bus_plus.dart';

class ChatProcEvent extends AppEvent {
  ChatProcEvent(this.chat, this.room);

  final dynamic chat;
  final dynamic room;

  @override
  List<Object?> get props => [chat, room];
}

class ChatReceivedEvent extends AppEvent {
  ChatReceivedEvent(this.chat, this.room);

  final dynamic chat;
  final dynamic room;

  @override
  List<Object?> get props => [chat, room];
}

// class ChatLeaveEvent extends AppEvent {
//   ChatLeaveEvent(this.room);
//
//   final dynamic room;
//
//   @override
//   List<Object?> get props => [room];
// }

class ChatLeaveEvent2 extends AppEvent {
  ChatLeaveEvent2(this.user_id, this.room_id);

  final dynamic user_id;
  final dynamic room_id;

  @override
  List<Object?> get props => [user_id, room_id];
}
