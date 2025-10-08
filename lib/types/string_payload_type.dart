class StringPayload {
  int id;
  String payload;
  int lastUpdated;
  StringPayload(this.id, this.payload, this.lastUpdated);

  factory StringPayload.fromJson(Map<String, dynamic> data) {
    return StringPayload(data["id"], data["payload"], data["lastUpdated"]);
  }
}
