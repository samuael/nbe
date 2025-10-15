import 'setting_types.dart';

class SellRecord {
  int id;
  double gram;
  double specificGravity;
  double subTotal;
  double remaining;
  double net;
  String settingID;
  Setting? setting;
  late int createdAt;
  bool isCompleted;

  SellRecord(this.id, this.gram, this.specificGravity, this.subTotal,
      this.remaining, this.net, this.settingID,
      {this.setting, this.isCompleted = false}) {
    createdAt =
        ((DateTime.now().microsecondsSinceEpoch / 1000).floor()).toInt();
  }

  factory SellRecord.fromJson(Map<String, dynamic> data, {Setting? setting}) {
    return SellRecord(
      data["id"],
      data["gram"],
      data["specificGravity"],
      data["subTotal"],
      data["remaining"],
      data["net"],
      data["setting_id"],
      setting: setting,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) "id": id,
      "gram": gram,
      "specificGravity": specificGravity,
      "subTotal": subTotal,
      "remaining": remaining,
      "net": net,
      "createdAt": createdAt,
      "setting_id": setting?.id,
    };
  }
}
