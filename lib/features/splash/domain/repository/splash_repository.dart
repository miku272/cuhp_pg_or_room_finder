import 'package:fpdart/fpdart.dart';

import '../../../../core/common/entities/user.dart';
import '../../../../core/error/failures.dart';

abstract interface class SplashRepository {
  Future<Either<Failure, User?>> getCurrentUser(
    String? token,
    String? id,
  );
}
