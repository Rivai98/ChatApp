import 'package:chatapp/helper/show_snack_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(LoginLoading());

    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      emit(LoginSuccess());
    } on FirebaseAuthException catch (ex) {
      if (ex.code == 'user-not-found') {
        emit(LoginFailure(errorMessage: "User not found."));
      } else if (ex.code == 'wrong-password') {
        emit(LoginFailure(errorMessage: 'Wrong password'));
      } else if (ex.code == 'requires-recaptcha' || 
                 ex.code == 'recaptcha-required' ||
                 ex.message?.contains('reCAPTCHA') == true) {
        emit(LoginFailure(
          errorMessage: 
              'Suspicious activity detected. Please try again in a few minutes or verify your account.'
        ));
      } else if (ex.code == 'too-many-requests') {
        emit(LoginFailure(
          errorMessage: 'Too many login attempts. Please try again later.'
        ));
      } else if (ex.code == 'invalid-credential') {
        emit(LoginFailure(errorMessage: 'Invalid email or password.'));
      } else {
        emit(LoginFailure(
          errorMessage: ex.message ?? 
              "An error occurred during login. Please try again later.",
        ));
      }
    } catch (e) {
      emit(
        LoginFailure(
          errorMessage:
              "An error occurred during login. Please try again later.",
        ),
      );
    }
  }
}
