class MessageModel {
  MessageModel({
    required this.message,
    required this.sentBy,
  });
  late final String message;
  late final String sentBy;
  
  MessageModel.fromJson(Map<String, dynamic> json){
    message = json['message'];
    sentBy = json['sentBy'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['message'] = message;
    _data['sentBy'] = sentBy;
    return _data;
  }
}