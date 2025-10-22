class Setting {
  String id;
  double taxPerGram;
  double bankFeePercentage;
  double holdPercentage;
  double bonusByNBEInPercentage;
  int createdAt;

  Setting(this.id, this.taxPerGram, this.bankFeePercentage, this.holdPercentage,
      this.bonusByNBEInPercentage,
      {this.createdAt = 0}) {
    if (createdAt == 0) {
      createdAt =
          ((DateTime.now().microsecondsSinceEpoch / 1000).floor()).toInt();
    }
  }

  factory Setting.fromJson(Map<String, dynamic> data) {
    return Setting(
      data["id"],
      data["taxPerGram"],
      data["bankFeePercentage"],
      data["holdPercentage"],
      data["bonusByNBEInPercentage"],
      createdAt: data["createdAt"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != "") "id": id,
      "taxPerGram": taxPerGram,
      "bankFeePercentage": bankFeePercentage,
      "bonusByNBEInPercentage": bonusByNBEInPercentage,
      "holdPercentage": holdPercentage,
      "createdAt": createdAt,
    };
  }
}
