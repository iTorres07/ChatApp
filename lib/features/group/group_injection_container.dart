import 'package:chat_app_1/features/group/data/datasources/firebase_datasource/group_firebase_datasource.dart';
import 'package:chat_app_1/features/group/data/datasources/firebase_datasource/group_firebase_datasource_impl.dart';
import 'package:chat_app_1/features/group/data/repository/group_firebase_repository_impl.dart';
import 'package:chat_app_1/features/group/domain/repository/group_repository.dart';
import 'package:chat_app_1/features/group/domain/usecases/get_create_group_usecase.dart';
import 'package:chat_app_1/features/group/domain/usecases/get_groups_usecase.dart';
import 'package:chat_app_1/features/group/domain/usecases/get_message_usecase.dart';
import 'package:chat_app_1/features/group/domain/usecases/send_text_message_usecase.dart';
import 'package:chat_app_1/features/group/domain/usecases/update_group_usecase.dart';
import 'package:chat_app_1/features/group/presentation/cubits/chat/chat_cubit.dart';
import 'package:chat_app_1/features/group/presentation/cubits/group/group_cubit.dart';
import 'package:chat_app_1/features/injection_container.dart';

Future<void> groupInjectionContainer() async {
  //Future Cubit/Bloc
  sl.registerFactory<GroupCubit>(() => GroupCubit(
        getGroupsUseCase: sl.call(),
        getCreateGroupUseCase: sl.call(),
        updateGroupUseCase: sl.call(),
      ));
  sl.registerFactory<ChatCubit>(() => ChatCubit(
        getMessageUseCase: sl.call(),
        sendTextMessageUseCase: sl.call(),
      ));

  //UseCases

  sl.registerLazySingleton<GetCreateGroupUseCase>(
      () => GetCreateGroupUseCase(repository: sl.call()));
  sl.registerLazySingleton<GetGroupsUseCase>(
      () => GetGroupsUseCase(repository: sl.call()));
  sl.registerLazySingleton<UpdateGroupUseCase>(
      () => UpdateGroupUseCase(repository: sl.call()));
  sl.registerLazySingleton<GetMessageUseCase>(
      () => GetMessageUseCase(repository: sl.call()));
  sl.registerLazySingleton<SendTextMessageUseCase>(
      () => SendTextMessageUseCase(repository: sl.call()));

  //Repository
  sl.registerLazySingleton<GroupRepository>(
      () => GroupRepositoryImpl(remoteDataSource: sl.call()));

  //Remote DataSource
  sl.registerLazySingleton<GroupFirebaseDataSource>(
      () => GroupFirebaseDataSourceImpl(
            firestore: sl.call(),
          ));
}
