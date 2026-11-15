import 'package:flutter/material.dart';
import '../models/model.dart';
import '../service/service.dart';

class PrayerProvider extends ChangeNotifier {


  final PrayerTimesService service = PrayerTimesService();


  PrayerTimesModel? prayer;


  bool isLoading = false;

  String? error;


  Future<void> getPrayerTimes() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      prayer = await service.getPrayerTimes();
    } catch (e) {
      error = e.toString();
    }

    isLoading = false;
    notifyListeners();

  }
  


}


 
