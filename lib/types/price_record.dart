import 'package:intl/intl.dart';

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
  double? priceBirr;
  DateTime? date;
  GoldType? goldType;

  PriceRecord(
      {this.id,
      this.goldTypeId,
      this.priceUsd,
      this.priceBirr,
      this.date,
      this.goldType});

  PriceRecord.fromJson(Map<String, dynamic> json) {
    // if (json['date'] is int) {
    //   print(
    //       "DateFormat('yyyy-MM-dd').format(json['date']): ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(json['date']))}\n");
    // }
    id = json['id'];
    goldTypeId = json['gold_type_id'];
    priceUsd = json['price_usd'];
    priceBirr = double.parse(json['price_birr'] ?? "0");
    date = (json['date'] is int)
        ? DateTime.fromMillisecondsSinceEpoch((json['date'] * 1000))
        : DateTime.parse(json['date']);
    goldType = json['gold_type'] != null
        ? GoldType.fromJson(json['gold_type'])
        : GoldType(karat: "24");
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // 'gold_type_id': goldTypeId,
      'price_usd': priceUsd,
      'price_birr': priceBirr != null ? "$priceBirr" : "",
      'date': (date!.millisecondsSinceEpoch / 1000).toInt(),
      // if (goldType != null) 'gold_type': goldType!.toJson(),
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
