class Setting {
  int id;
  double nbe24KaratRate;
  double taxPerGram;
  double bankFeePercentage;
  double excludePercentage;
  late int createdAt;

  Setting(this.id, this.nbe24KaratRate, this.taxPerGram, this.bankFeePercentage,
      this.excludePercentage) {
    createdAt =
        ((DateTime.now().microsecondsSinceEpoch / 1000).floor()).toInt();
  }

  factory Setting.fromJson(Map<String, dynamic> data) {
    return Setting(
      data["id"],
      data["nbe24KaratRate"],
      data["taxPerGram"],
      data["bankFeePercentage"],
      data["excludePercentage"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "nbe24KaratRate": nbe24KaratRate,
      "taxPerGram": taxPerGram,
      "bankFeePercentage": bankFeePercentage,
      "excludePercentage": excludePercentage,
      "createdAt": createdAt,
    };
  }
}
