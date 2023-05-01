class MessageModel {
  MessageModel({
     this.message,
     this.sentBy,
  });
   String message;
   String sentBy;
  
  MessageModel.fromJson(Map<String, dynamic> json, this.message, this.sentBy){
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