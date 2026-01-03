class CommunityModel {
  final String communityId;
  final String fieldId;
  final String createdBy;
  final String name;
  final String description;
  final String photo;
  final List<String> memberList;
  final bool isApproved;
  // Weekly schedule for community session (optional for legacy docs)
  final int? weeklyWeekday; // 1=Mon ... 7=Sun
  final String? weeklyStart; // 'HH:mm'
  final String? weeklyEnd; // 'HH:mm'

  CommunityModel({
    required this.communityId,
    required this.fieldId,
    required this.createdBy,
    required this.name,
    required this.description,
    required this.photo,
    required this.memberList,
    required this.isApproved,
    this.weeklyWeekday,
    this.weeklyStart,
    this.weeklyEnd,
  });

  Map<String, dynamic> toMap() => {
    "communityId": communityId,
    "fieldId": fieldId,
    "createdBy": createdBy,
    "name": name,
    "description": description,
    "photo": photo,
    "memberList": memberList,
    "isApproved": isApproved,
    if (weeklyWeekday != null) "weeklyWeekday": weeklyWeekday,
    if (weeklyStart != null) "weeklyStart": weeklyStart,
    if (weeklyEnd != null) "weeklyEnd": weeklyEnd,
  };

  factory CommunityModel.fromMap(Map<String, dynamic> map) => CommunityModel(
    communityId: map["communityId"],
    fieldId: map["fieldId"] ?? '',
    createdBy: map["createdBy"],
    name: map["name"],
    description: map["description"],
    photo: map["photo"],
    memberList: List<String>.from(map["memberList"]),
    isApproved: map["isApproved"],
    weeklyWeekday: map.containsKey('weeklyWeekday')
        ? (map['weeklyWeekday'] as num?)?.toInt()
        : null,
    weeklyStart: map['weeklyStart'] as String?,
    weeklyEnd: map['weeklyEnd'] as String?,
  );
}
