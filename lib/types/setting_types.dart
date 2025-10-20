class Setting {
  String id;
  double taxPerGram;
  double bankFeePercentage;
  double holdPercentage;
  int createdAt;

  Setting(this.id, this.taxPerGram, this.bankFeePercentage, this.holdPercentage,
      {this.createdAt = 0}) {
    if (createdAt == 0) {
      createdAt =
          ((DateTime.now().microsecondsSinceEpoch / 1000).floor()).toInt();
    }
  }

  factory Setting.fromJson(Map<String, dynamic> data) {
    return Setting(
      data["id"],
      data["nbe24KaratRate"],
      data["taxPerGram"],
      data["holdPercentage"],
      createdAt: data["createdAt"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != "") "id": id,
      "taxPerGram": taxPerGram,
      "bankFeePercentage": bankFeePercentage,
      "holdPercentage": holdPercentage,
      "createdAt": createdAt,
    };
  }
}
