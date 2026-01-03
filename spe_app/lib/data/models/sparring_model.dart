class SparringModel {
  final String sparringId;
  final String fieldId;
  final String ownerId;
  final DateTime date;
  final String time;
  final int maxPlayer;
  final List<String> participantList;
  final String? ownerTeamName;
  final String? challengerTeamName;
  final String? bookingId;
  final String? paymentStatus;

  SparringModel({
    required this.sparringId,
    required this.fieldId,
    required this.ownerId,
    required this.date,
    required this.time,
    required this.maxPlayer,
    required this.participantList,
    this.ownerTeamName,
    this.challengerTeamName,
    this.bookingId,
    this.paymentStatus,
  });

  Map<String, dynamic> toMap() => {
    "sparringId": sparringId,
    "fieldId": fieldId,
    "ownerId": ownerId,
    "date": date.toIso8601String(),
    "time": time,
    "maxPlayer": maxPlayer,
    "participantList": participantList,
    if (ownerTeamName != null) "ownerTeamName": ownerTeamName,
    if (challengerTeamName != null) "challengerTeamName": challengerTeamName,
    if (bookingId != null) "bookingId": bookingId,
    if (paymentStatus != null) "paymentStatus": paymentStatus,
  };

  factory SparringModel.fromMap(Map<String, dynamic> map) => SparringModel(
    sparringId: map["sparringId"],
    fieldId: map["fieldId"],
    ownerId: map["ownerId"],
    date: DateTime.parse(map["date"]),
    time: map["time"],
    maxPlayer: map["maxPlayer"],
    participantList: List<String>.from(map["participantList"]),
    ownerTeamName: map['ownerTeamName'] as String?,
    challengerTeamName: map['challengerTeamName'] as String?,
    bookingId: map['bookingId'] as String?,
    paymentStatus: map['paymentStatus'] as String?,
  );
}
