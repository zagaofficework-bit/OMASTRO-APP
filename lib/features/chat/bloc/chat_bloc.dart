import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/notification_service.dart';
import '../models/chat_conversation.dart';
import '../repository/firebase_chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseChatRepository _repository = FirebaseChatRepository();
  StreamSubscription? _roomsSubscription;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _authSubscription;

  ChatBloc() : super(ChatInitialState()) {
    on<InitChatSystemEvent>(_onInit);
    on<RoomsUpdatedEvent>(_onRoomsUpdated);
    on<OpenChatRoomEvent>(_onOpenChatRoom);
    on<MessagesUpdatedEvent>(_onMessagesUpdated);
    on<SendMessageEvent>(_onSendMessage);

    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        add(InitChatSystemEvent(
          userUid: user.uid,
          userName: user.displayName ?? 'Guest',
        ));
      } else {
        // Handle logout
        _roomsSubscription?.cancel();
        _messagesSubscription?.cancel();
        emit(ChatInitialState());
      }
    });
  }

  void _onInit(InitChatSystemEvent event, Emitter<ChatState> emit) {
    debugPrint('[ChatBloc] _onInit: userUid = ${event.userUid}');
    emit(ChatUpdatedState(
      userUid: event.userUid,
      userName: event.userName,
      activeConversations: const [],
      messages: const {},
    ));

    _roomsSubscription?.cancel();
    _roomsSubscription = _repository.listenRooms(event.userUid).listen((rooms) {
      debugPrint('[ChatBloc] Received new rooms from repository: ${rooms.length}');
      add(RoomsUpdatedEvent(rooms));
    }, onError: (e) {
      debugPrint('[ChatBloc] Error listening to rooms: $e');
    });
  }

  void _onRoomsUpdated(RoomsUpdatedEvent event, Emitter<ChatState> emit) {
    debugPrint('[ChatBloc] _onRoomsUpdated: updating state with ${event.rooms.length} active conversations');
    if (state is ChatUpdatedState) {
      final current = state as ChatUpdatedState;

      // Check for new messages to show notifications
      for (final newRoom in event.rooms) {
        if (newRoom.lastSenderId != null && newRoom.lastSenderId!.isNotEmpty && newRoom.lastSenderId != current.userUid) {
          final oldRoom = current.activeConversations.where((c) => c.roomId == newRoom.roomId).firstOrNull;
          if (oldRoom != null && oldRoom.lastMessage != newRoom.lastMessage && newRoom.lastMessage.isNotEmpty) {
            // New message from astrologer!
            if (current.activeRoomId != newRoom.roomId) {
              NotificationService().showChatNotification(
                title: 'New message from ${newRoom.astrologerName}',
                body: newRoom.lastMessage,
              );
            }
          }
        }
      }

      emit(current.copyWith(activeConversations: event.rooms));
    }
  }

  Future<void> _onOpenChatRoom(OpenChatRoomEvent event, Emitter<ChatState> emit) async {
    debugPrint('[ChatBloc] _onOpenChatRoom: astrologerId = ${event.astrologerId}');
    if (state is ChatUpdatedState) {
      final current = state as ChatUpdatedState;
      
      // We must ensure the chat room exists in Firestore
      final roomId = await _repository.ensureChatRoom(
        userUid: current.userUid,
        userName: current.userName,
        astrologerId: event.astrologerId,
        astrologerName: event.astrologerName,
        astrologerFirebaseUid: event.astrologerFirebaseUid,
      );

      debugPrint('[ChatBloc] roomId established: $roomId');
      emit(current.copyWith(activeRoomId: roomId));

      _messagesSubscription?.cancel();
      _messagesSubscription = _repository.listenMessages(roomId).listen((msgs) {
        debugPrint('[ChatBloc] Received ${msgs.length} messages for roomId $roomId');
        final chatMessages = msgs.map((m) => ChatMessage(
          id: m.id,
          text: m.text,
          time: m.time,
          isMe: m.senderId == current.userUid,
        )).toList();
        
        add(MessagesUpdatedEvent(roomId: roomId, messages: chatMessages));
      }, onError: (e) {
        debugPrint('[ChatBloc] Error listening to messages: $e');
      });
    } else {
      debugPrint('[ChatBloc] Cannot open chat room: state is not ChatUpdatedState!');
    }
  }

  void _onMessagesUpdated(MessagesUpdatedEvent event, Emitter<ChatState> emit) {
    debugPrint('[ChatBloc] _onMessagesUpdated: updating UI for roomId ${event.roomId}');
    if (state is ChatUpdatedState) {
      final current = state as ChatUpdatedState;
      final newMessages = Map<String, List<ChatMessage>>.from(current.messages);
      
      // Note: we key by the astrologer ID here for backwards compatibility with UI
      // since the UI routes using the astrologer ID, not the firestore roomId.
      // Let's find the astrologerId for this roomId from the activeConversations.
      String targetId = event.roomId; 
      try {
        final convo = current.activeConversations.firstWhere((c) => c.roomId == event.roomId);
        targetId = convo.id; // astrologerId
      } catch (_) {}
      
      newMessages[targetId] = event.messages;
      emit(current.copyWith(messages: newMessages));
    }
  }

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    debugPrint('[ChatBloc] _onSendMessage: text = ${event.text}');
    if (state is ChatUpdatedState) {
      final current = state as ChatUpdatedState;
      if (current.activeRoomId != null) {
        // Send message to firestore!
        await _repository.sendMessage(
          roomId: current.activeRoomId!,
          senderId: current.userUid,
          text: event.text,
        );
      } else {
        debugPrint('[ChatBloc] Warning: Attempted to send message but activeRoomId is null');
      }
    }
  }

  @override
  Future<void> close() {
    _roomsSubscription?.cancel();
    _messagesSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
