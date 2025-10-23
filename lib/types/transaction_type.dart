import 'package:intl/intl.dart';
import "package:nbe/libs.dart";

class Transaction {
  String id;
  double gram; // r
  double? specificGravity; // r
  double net; // r

  late int createdAt;
  String settingID;
  Setting? setting;

  String date;
  DateTime? dateTime;
  double karat;

  int extraDays;

  double initialPrice; // r
  PriceRecord? initialPriceRecord;
  double athPrice; // r

  double taxValue; // r
  double bankFeeValue;

  bool isCompleted;

  Transaction(
    this.id,
    this.date,
    this.gram,
    this.karat,
    this.settingID,
    this.initialPrice, {
    required this.athPrice,
    required this.specificGravity,
    this.net = 0,
    this.setting,
    this.extraDays = 0,
    this.taxValue = 0,
    this.bankFeeValue = 0,
    this.createdAt = 0,
    this.isCompleted = false,
  }) {
    if (createdAt == 0) {
      createdAt = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
    }
  }

  factory Transaction.fromJson(Map<String, dynamic> data) {
    return Transaction(
      data["id"],
      data["date"],
      data["gram"],
      data["karat"],
      data["settingID"],
      data["initialPrice"],
      specificGravity: data["specificGravity"],
      createdAt: data["createdAt"],
      extraDays: data["extraDays"],
      athPrice: data["athPrice"],
      taxValue: data["taxValue"],
      bankFeeValue: data["bankFeeValue"],
      net: data["net"],
      isCompleted: data["isCompleted"] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "gram": gram,
      "specificGravity": specificGravity,
      "createdAt": createdAt,
      "settingID": settingID,
      "date": date,
      "karat": karat,
      "extraDays": extraDays,
      "athPrice": athPrice,
      "initialPrice": initialPrice,
      "taxValue": taxValue,
      "bankFeeValue": bankFeeValue,
      "net": net,
      "isCompleted": isCompleted ? 1 : 0,
    };
  }
}

String currencyFormatter(double value, {int decimals = 4}) {
  final formatter = NumberFormat('#,##0.${() {
    String dfinal = "";
    for (int i = 0; i < decimals; i++) {
      dfinal += "#";
    }
    return dfinal;
  }()}');
  return formatter.format(value);
}

String currencyFormatWith2DecimalValues(double value) {
  return NumberFormat('#,##0.00').format(value - (value % 0.01));
}

String currencyFormatterForPrint(double value) {
  final formatter = NumberFormat('#,##0.##');
  final formattedValue = formatter.format(value);
  return '$formattedValue Birr';
}
