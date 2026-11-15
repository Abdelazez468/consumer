import 'package:dio/dio.dart';
import 'package:cunsumer/models/model.dart';

class PrayerTimesService {
  final Dio dio = Dio();

  Future<PrayerTimesModel> getPrayerTimes() async {
    final response = await dio.get(
      'https://api.aladhan.com/v1/timingsByCity/15-11-2026',
      queryParameters: {'city': 'Giza', 'country': 'Egypt', 'method': 2},
    );

    return PrayerTimesModel.fromJson(response.data);
    
  }


}
