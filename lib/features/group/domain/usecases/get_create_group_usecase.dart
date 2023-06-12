import 'package:chat_app_1/features/group/domain/entities/group_entity.dart';
import 'package:chat_app_1/features/group/domain/repository/group_repository.dart';

class GetCreateGroupUseCase {
  final GroupRepository repository;

  GetCreateGroupUseCase({required this.repository});

  Future<void> call(GroupEntity group) {
    return repository.getCreateGroup(group);
  }
}
