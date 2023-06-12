import 'package:chat_app_1/features/user/domain/repository/user_repository.dart';

class ForgotPasswordUseCase {
  final UserRepository repository;

  ForgotPasswordUseCase({required this.repository});

  Future<void> call(String email) {
    return repository.forgotPassword(email);
  }
}
