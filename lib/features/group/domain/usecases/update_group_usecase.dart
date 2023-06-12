import 'package:chat_app_1/features/group/domain/entities/group_entity.dart';
import 'package:chat_app_1/features/group/domain/repository/group_repository.dart';

class UpdateGroupUseCase {
  final GroupRepository repository;

  UpdateGroupUseCase({required this.repository});
  Future<void> call(GroupEntity groupEntity) {
    return repository.updateGroup(groupEntity);
  }
}
