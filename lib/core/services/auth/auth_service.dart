import 'dart:io';
import 'package:harvestly/core/models/chat_user.dart';
// import 'package:chat/core/services/auth/auth_mock_service.dart';

import 'auth_firebase_service.dart';

abstract class AuthService {
  ChatUser? get currentUser;

  List<ChatUser> get users;

  bool get isLoggingIn;

  bool get isProducer;

  void setProducerState(bool state);

  void setLoggingInState(bool state);
  
  Stream<ChatUser?> get userChanges;

  Future<void> signup(
    String firstName,
    String lastName,
    String email,
    String password,
    File? image,
    String gender,
    String phone,
    String recoverEmail,
    String dateOfBirth,
  );

  Future<void> login(String email, String password, String typeOfLogin);

  Future<void> logout();

  Future<void> recoverPassword(String email);

  Future<void> updateProfileImage(File? profileImage);

  Future<void> updateBackgroundImage(File? backgroundImage);

  Future<void> updateSingleUserField({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? nickname,
    String? status,
    String? iconStatus,
    String? aboutMe,
    String? dateOfBirth,
    String? customStatus,
    String? customIconStatus,
    String? gender,
    String? recoveryEmail,
  });

  Future<void> syncEmailWithFirestore();

  Future<void> addFriend(String userId);
  Future<void> removeFriend(String userId);

  factory AuthService() {
    // return AuthMockService();
    return AuthFirebaseService();
  }
}
