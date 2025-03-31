class ServerException implements Exception {
  final int? status;
  final String message;

  ServerException({
    this.status = 500,
    this.message = 'Some error occurred on the server side.',
  });
}

class UserException implements Exception {
  final int? status;
  final String message;

  UserException({
    this.status = 400,
    this.message = 'Some error occurred on the user side.',
  });
}

class SupabaseException implements Exception {
  final int? status;
  final String message;

  SupabaseException({
    this.status = 500,
    this.message = 'Some error occurred on the Supabase side.',
  });
}
