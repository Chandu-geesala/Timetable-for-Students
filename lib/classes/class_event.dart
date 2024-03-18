class ClassEvent {
  int? id; // Add an id field for database interaction
  String day;
  String className;
  String startTime;
  String endTime;

  ClassEvent({
    this.id,
    required this.day,
    required this.className,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'day': day,
      'class_name': className,
      'start_time': startTime,
      'end_time': endTime,
    };
  }



}
