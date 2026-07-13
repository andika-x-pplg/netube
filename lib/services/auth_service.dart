import 'package:firebase_auth/firebase_auth.dart';

class AuthService {

  static final FirebaseAuth auth =
      FirebaseAuth.instance;

  static Future<UserCredential> login(
      String email,
      String password) async {

    return await auth
        .signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> register(
      String email,
      String password) async {

    return await auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> logout() async {
    await auth.signOut();
  }
}