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

  DateTime date;
  DateTime? endDate;

  double karat;

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
    this.specificGravity,
    this.net = 0,
    this.setting,
    this.endDate,
    this.taxValue = 0,
    this.bankFeeValue = 0,
    this.createdAt = 0,
    this.isCompleted = false,
  }) {
    if (createdAt == 0) {
      createdAt = (DateTime.now().millisecondsSinceEpoch / 1000).toInt();
    }
  }

  double getRemaining(Setting setting) {
    return ((athPrice * (1 + (setting.bonusByNBEInPercentage / 100))) *
            (karat / 24) *
            gram) -
        ((initialPrice * (1 + (setting.bonusByNBEInPercentage / 100))) *
            (karat / 24) *
            gram *
            ((100 - setting.holdPercentage) / 100));
  }

  double getIncreases(Setting setting) {
    return ((((athPrice - initialPrice) *
        (1 + (setting.bonusByNBEInPercentage / 100)) *
        (karat / 24) *
        gram)));
  }

  factory Transaction.fromJson(Map<String, dynamic> data) {
    return Transaction(
      data["id"],
      DateTime.parse(data["date"]),
      data["gram"],
      data["karat"],
      data["settingID"],
      data["initialPrice"],
      createdAt: data["createdAt"],
      endDate: data["endDate"] != null ? DateTime.parse(data["endDate"]) : null,
      athPrice: data["athPrice"],
      taxValue: data["taxValue"],
      bankFeeValue: data["bankFeeValue"],
      net: data["net"],
      isCompleted: data["isCompleted"] == 1,
    );
  }

  static DateTime intToDateTime(int input) {
    if (input == 0) {
      return DateTime.now();
    }
    final day = input % 100;
    input = (input / 100).floor();
    final month = (input % 100);
    input = (input / 100).floor();
    return DateTime(
      input,
      month,
      day,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "gram": gram,
      "createdAt": createdAt,
      "settingID": settingID,
      "date": DateFormat('yyyy-MM-dd').format(date),
      "karat": karat,
      "endDate":
          endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : "",
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
