import 'package:dio/dio.dart';
import 'package:watch_it/core/errors/exceptions.dart';
import 'package:watch_it/core/network/api_consumer.dart';
import 'package:watch_it/core/network/endpoint.dart';
import 'package:watch_it/features/videos/data/models/video_model.dart';


abstract class VideosRemoteDataSource {

  Future<List<VideoModel>> getVideos();
}

class VideosRemoteDataSourceImpl implements VideosRemoteDataSource {
  const VideosRemoteDataSourceImpl({required ApiConsumer apiConsumer})
    : _apiConsumer = apiConsumer;

  final ApiConsumer _apiConsumer;


  static const Duration _latency = Duration(milliseconds: 400);

  @override
  Future<List<VideoModel>> getVideos() async {

    await Future<void>.delayed(_latency);
    return VideoModel.seedCatalogue;
  }


  Future<List<VideoModel>> fetchFromApi() async {
    final Response<List<dynamic>> response = await _apiConsumer
        .get<List<dynamic>>(Endpoint.videos);

    final List<dynamic>? data = response.data;
    if (data == null) {
      throw const InvalidDataException('The server returned an empty payload');
    }
    return VideoModel.listFromJson(data);
  }


  static String get endpointUrl => '${Endpoint.baseUrl}${Endpoint.videos}';
}
