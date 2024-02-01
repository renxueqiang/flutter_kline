class Pointer {
  double x = 0;
  double y = 0;
  void setX(double x) {
    this.x = x;
  }

  void setY(double y) {
    this.y = y;
  }
}

class ChartModel {
  int timestamp = 0;
  double closePrice = 0;
  double openPrice = 0;
  double maxPrice = 0;
  double minPrice = 0;
  double volume = 0;

  ///kline data
  ChartModel(this.timestamp, this.openPrice, this.closePrice, this.maxPrice, this.minPrice, this.volume);

  ///Main chart view
  double leftStartX = 0;
  double rightEndX = 0;
  double closeY = 0;
  double openY = 0;
  void setLeftStartX(double leftStartX) {
    this.leftStartX = leftStartX;
  }

  void setRightEndX(double rightEndX) {
    this.rightEndX = rightEndX;
  }

  void setCloseY(double closeY) {
    this.closeY = closeY;
  }

  void setOpenY(double openY) {
    this.openY = openY;
  }

  ///MA
  double priceMA5 = 0;
  double priceMA10 = 0;
  double priceMA30 = 0;
  double volumeMA5 = 0;
  double volumeMA10 = 0;
  // price MA
  void setPriceMA5(double priceMA5) {
    this.priceMA5 = priceMA5;
  }

  void setPriceMA10(double priceMA10) {
    this.priceMA10 = priceMA10;
  }

  void setPriceMA30(double priceMA30) {
    this.priceMA30 = priceMA30;
  }

  // volume ma
  void setVolumeMA5(double volumeMA5) {
    this.volumeMA5 = volumeMA5;
  }

  void setVolumeMA10(double volumeMA10) {
    this.volumeMA10 = volumeMA10;
  }

  /// BOLL
  double bollMB = 0;
  double bollUP = 0;
  double bollDN = 0;
  void setBollMB(double bollMB) {
    this.bollMB = bollMB;
  }

  void setBollUP(double bollUP) {
    this.bollUP = bollUP;
  }

  void setBollDN(double bollDN) {
    this.bollDN = bollDN;
  }

  /// MACD
  double macd = 0;
  double dea = 0;
  double dif = 0;
  void setMACD(double macd) {
    this.macd = macd;
  }

  void setDEA(double dea) {
    this.dea = dea;
  }

  void setDIF(double dif) {
    this.dif = dif;
  }

  /// KDJ
  double k = 0;
  double d = 0;
  double j = 0;
  void setK(double k) {
    this.k = k;
  }

  void setD(double d) {
    this.d = d;
  }

  void setJ(double j) {
    this.j = j;
  }

  /// RSI
  double rs1 = 0;
  double rs2 = 0;
  double rs3 = 0;
  void setRS1(double rs1) {
    this.rs1 = rs1;
  }

  void setRS2(double rs2) {
    this.rs2 = rs2;
  }

  void setRS3(double rs3) {
    this.rs3 = rs3;
  }
}
