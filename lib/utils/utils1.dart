import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimetableScreen1 extends StatefulWidget {
  const TimetableScreen1({Key? key}) : super(key: key);

  @override
  State<TimetableScreen1> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen1> {
  List<ClassEvent> todaysClasses = [];
  String session = '';

  @override
  void initState() {
    super.initState();
    todaysClasses = getTodaysClasses();
    _determineSession();
  }

  void _determineSession() {
    final today = DateTime.now().weekday;
    if (today == DateTime.monday || today == DateTime.wednesday || today == DateTime.friday) {
      session = 'Afternoon Classes';
    } else if(today == DateTime.sunday){
      session = '';
    } else {
      session = 'Morning Classes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DateTime.now().weekday == DateTime.sunday
              ? DecorationImage(
            image: AssetImage('assets/sunday.jpg'),
            fit: BoxFit.cover,
          )
              : DecorationImage(
            image: AssetImage('assets/OIP.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                session,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todaysClasses.length,
                itemBuilder: (context, index) {
                  return _ClassTile(event: todaysClasses[index], currentTime: DateTime.now());
                },
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}




class _ClassTile extends StatelessWidget {
  final ClassEvent event;
  final DateTime currentTime;
  final bool isCompleted;

  const _ClassTile({Key? key, required this.event, required this.currentTime, this.isCompleted = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isCurrentClass = currentTime.isAfter(event.startTime) && currentTime.isBefore(event.endTime);
    final Color highlightColor = Colors.cyan.shade50;

    return Card(
      color: isCurrentClass ? highlightColor : Colors.cyan[200],
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.subject,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${DateFormat('h:mm a').format(event.startTime)} - ${DateFormat('h:mm a').format(event.endTime)}',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
                      ),



                      if (isCurrentClass) // Show "Current" label if it's the current class
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.cyan,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Current',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}







class ClassEvent {
  String subject;
  DateTime startTime;
  DateTime endTime;

  ClassEvent({required this.subject, required this.startTime, required this.endTime});
}



List<ClassEvent> getTodaysClasses() {
  final today = DateTime.now().weekday;
  switch (today) {
    case DateTime.monday:
      return [
        ClassEvent(subject: 'WT Lab', startTime: _getDateTime(13, 30), endTime: _getDateTime(15, 10)),
        ClassEvent(subject: 'CD', startTime: _getDateTime(16, 10), endTime: _getDateTime(17, 00)),
        ClassEvent(subject: 'Sports', startTime: _getDateTime(17, 10), endTime: _getDateTime(17, 50)),

      ];
    case DateTime.tuesday:
      return [
        ClassEvent(subject: 'Carer Guidance', startTime: _getDateTime(8, 40), endTime: _getDateTime(9, 30)),
        ClassEvent(subject: 'DSP', startTime: _getDateTime(9, 30), endTime: _getDateTime(10, 20)),
        ClassEvent(subject: 'COA', startTime: _getDateTime(10, 20), endTime: _getDateTime(11, 10)),
        ClassEvent(subject: 'CD', startTime: _getDateTime(11, 20), endTime: _getDateTime(12, 10)),
        ClassEvent(subject: 'WT', startTime: _getDateTime(12, 10), endTime: _getDateTime(13, 0)),
      ];
    case DateTime.wednesday:
      return [
        ClassEvent(subject: 'COA Lab', startTime: _getDateTime(13, 30), endTime: _getDateTime(16, 10)),
        ClassEvent(subject: 'Library', startTime: _getDateTime(16, 10), endTime: _getDateTime(17, 00)),
        ClassEvent(subject: 'Yoga', startTime: _getDateTime(17, 00), endTime: _getDateTime(17, 50)),
      ];
    case DateTime.thursday:
      return [
        ClassEvent(subject: 'IOR', startTime: _getDateTime(8, 40), endTime: _getDateTime(9, 30)),
        ClassEvent(subject: 'DSP', startTime: _getDateTime(9, 30), endTime: _getDateTime(10, 20)),
        ClassEvent(subject: 'COA', startTime: _getDateTime(10, 20), endTime: _getDateTime(11, 10)),
        ClassEvent(subject: 'WT', startTime: _getDateTime(11, 20), endTime: _getDateTime(12, 10)),
        ClassEvent(subject: 'IOR', startTime: _getDateTime(12, 10), endTime: _getDateTime(13, 0)),
      ];
    case DateTime.friday:
      return [
        ClassEvent(subject: 'DSP Lab', startTime: _getDateTime(13, 30), endTime: _getDateTime(16, 10)),
        ClassEvent(subject: 'Career Guidance', startTime: _getDateTime(16, 10), endTime: _getDateTime(16,50)),
        ClassEvent(subject: 'IOR', startTime: _getDateTime(16, 50), endTime: _getDateTime(17, 50)),
      ];
    case DateTime.saturday:
      return [
        ClassEvent(subject: 'Career Guidance', startTime: _getDateTime(8, 40), endTime: _getDateTime(9, 30)),
        ClassEvent(subject: 'DSP', startTime: _getDateTime(9, 30), endTime: _getDateTime(10, 20)),
        ClassEvent(subject: 'COA', startTime: _getDateTime(10, 20), endTime: _getDateTime(11, 10)),
        ClassEvent(subject: 'CD', startTime: _getDateTime(11, 20), endTime: _getDateTime(12, 10)),
        ClassEvent(subject: 'WT', startTime: _getDateTime(12, 10), endTime: _getDateTime(13, 0)),
      ];
    default:
      return [];
  }
}







DateTime _getDateTime(int hour, int minute) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, hour, minute);
}
