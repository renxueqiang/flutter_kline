import 'package:flutter_demo/chart_model.dart';
import 'package:flutter_demo/kline_datas.dart';

class HomePageViewModel {
  List<ChartModel> dataList = [];

  HomePageViewModel() {
    dataList = getKlineDataList1(KlineData.lines1min);
  }

  List<ChartModel> getKlineDataList1(List data) {
    List<ChartModel> kDataList = [];
    for (int i = 0; i < data.length; i++) {
      int timestamp = data[i][0].toInt();
      //timestamp
      double openPrice = data[i][1].toDouble();
      // open
      double closePrice = data[i][4].toDouble();
      // close
      double maxPrice = data[i][2].toDouble();
      // max
      double minPrice = data[i][3].toDouble();
      // min
      double volume = data[i][5].toDouble();
      if (volume > 0) {
        kDataList.add(ChartModel(timestamp, openPrice, closePrice, maxPrice, minPrice, volume));
      }
    }
    return kDataList;
  }
}
