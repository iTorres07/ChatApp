import 'dart:io';

import 'package:chat_app_1/features/user/domain/entities/user_entity.dart';
import 'package:chat_app_1/features/user/domain/usecases/get_single_user_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'single_user_state.dart';

class SingleUserCubit extends Cubit<SingleUserState> {
  final GetSingleUserUseCase getSingleUserUseCase;
  SingleUserCubit({required this.getSingleUserUseCase})
      : super(SingleUserInitial());

  Future<void> getSingleUserProfile({required UserEntity user}) async {
    emit(SingleUserLoading());

    try {
      final streamResponse = getSingleUserUseCase.call(user);
      streamResponse.listen((user) {
        emit(SingleUserLoaded(currentUser: user.first));
      });
    } on SocketException catch (_) {
      emit(SingleUserFailure());
    } catch (_) {
      emit(SingleUserFailure());
    }
  }
}
