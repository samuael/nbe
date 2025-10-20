class PriceRecordResponse {
  bool? success;
  String? message;
  int? status;
  List<PriceRecord>? data;

  PriceRecordResponse(
      {this.success = false, this.message, this.status, this.data});

  PriceRecordResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    status = json['status'];
    if (json['data'] != null) {
      data = <PriceRecord>[];
      json['data'].forEach((v) {
        data!.add(PriceRecord.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      if (data != null) 'data': data!.map((v) => v.toJson()).toList(),
    };
  }

  PriceRecord? get24KaratRecord() {
    if (data == null) {
      return null;
    }
    for (int i = 0; i < data!.length; i++) {
      if (data![i].goldType!.karat == "24") {
        return data![i];
      }
    }
    return null;
  }
}

class PriceRecord {
  String? id;
  String? goldTypeId;
  String? priceUsd;
  String? priceBirr;
  String? date;
  GoldType? goldType;

  PriceRecord(
      {this.id,
      this.goldTypeId,
      this.priceUsd,
      this.priceBirr,
      this.date,
      this.goldType});

  PriceRecord.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    goldTypeId = json['gold_type_id'];
    priceUsd = json['price_usd'];
    priceBirr = json['price_birr'];
    date = json['date'];
    goldType =
        json['gold_type'] != null ? GoldType.fromJson(json['gold_type']) : null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gold_type_id': goldTypeId,
      'price_usd': priceUsd,
      'price_birr': priceBirr,
      'date': date,
      if (goldType != null) 'gold_type': goldType!.toJson(),
    };
  }
}

class GoldType {
  String? id;
  String? karat;
  String? level;

  GoldType({this.id, this.karat, this.level});

  factory GoldType.fromJson(Map<String, dynamic> json) {
    return GoldType(id: json['id'], karat: json['karat'], level: json['level']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'karat': karat,
      'level': level,
    };
  }
}
