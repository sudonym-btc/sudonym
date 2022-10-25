import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

// Global options
final cacheOptions = CacheOptions(
  // A default store is required for interceptor.
  store: MemCacheStore(),

  // All subsequent fields are optional.

  // Returns a cached response on error but for statuses 401 & 403.
  // Also allows to return a cached response on network errors (e.g. offline usage).
  // Defaults to [null].
  // hitCacheOnErrorExcept: [401, 403],
  // maxStale: const Duration(seconds: 60),
  // allowPostMethod: false,
);

final cacheInterceptor = DioCacheInterceptor(options: cacheOptions);
