import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/chat.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';

import '../repository/property_details_repository.dart';

class InitializeChat implements Usecase<Chat, InitializeChatParams> {
  final PropertyDetailsRepository propertyDetailsRepository;

  const InitializeChat({required this.propertyDetailsRepository});

  @override
  Future<Either<Failure, Chat>> call(InitializeChatParams params) async {
    return await propertyDetailsRepository.initializeChat(
      propertyId: params.propertyId,
      token: params.token,
    );
  }
}

class InitializeChatParams {
  final String propertyId;
  final String token;

  InitializeChatParams({
    required this.propertyId,
    required this.token,
  });
}
