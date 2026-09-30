import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watch_it/core/helper/cache_helper.dart';
import 'package:watch_it/core/network/api_consumer.dart';
import 'package:watch_it/core/network/network_info.dart';
import 'package:watch_it/features/videos/data/datasources/videos_cache_data_source.dart';
import 'package:watch_it/features/videos/data/datasources/videos_remote_data_source.dart';
import 'package:watch_it/features/videos/data/repos/videos_repository.dart';
import 'package:watch_it/features/videos/data/repos/videos_repository_impl.dart';
import 'package:watch_it/features/videos/presentation/cubit/video_cubit.dart';


final GetIt getIt = GetIt.instance;

Future<void> initServiceLocator() async {
  final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  getIt
    // ---------------------------------------------------------- external ---
    ..registerLazySingleton<SharedPreferences>(() => sharedPreferences)
    // -------------------------------------------------------------- core ---
    ..registerLazySingleton<CacheHelper>(() => CacheHelper(getIt()))
    ..registerLazySingleton<NetworkInfo>(() => const NetworkInfoImpl())
    ..registerLazySingleton<Dio>(() => buildDio(getIt()))
    ..registerLazySingleton<ApiConsumer>(() => ApiConsumer(getIt()))
    // ------------------------------------------------------------ videos ---
    ..registerLazySingleton<VideosRemoteDataSource>(
      () => VideosRemoteDataSourceImpl(apiConsumer: getIt()),
    )
    ..registerLazySingleton<VideosCacheDataSource>(
      () => VideosCacheDataSourceImpl(cacheHelper: getIt()),
    )
    ..registerLazySingleton<VideosRepository>(
      () => VideosRepositoryImpl(
        remoteDataSource: getIt(),
        cacheDataSource: getIt(),
        networkInfo: getIt(),
      ),
    )
    ..registerFactory<VideoCubit>(
      () => VideoCubit(videosRepository: getIt()),
    );
}

Future<void> resetServiceLocator() => getIt.reset();
