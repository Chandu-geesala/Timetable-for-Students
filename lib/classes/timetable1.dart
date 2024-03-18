import 'package:flutter/material.dart';
import 'package:students/classes/class_event.dart';
import 'package:students/classes/class_event_database_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TimetableScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: TimetablePageView(),
    );
  }
}

class TimetablePageView extends StatefulWidget {
  @override
  _TimetablePageViewState createState() => _TimetablePageViewState();
}

class _TimetablePageViewState extends State<TimetablePageView> {
  final PageController _pageController = PageController();
  final Map<int, List<ClassEvent>> _classEventsCache = {}; // Cache for class events

  int _currentPageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(), // Disable slide animation
            itemCount: 6,
            onPageChanged: (index) {
              setState(() {
                _currentPageIndex = index;
              });
              _preloadData(index - 1); // Preload data for previous day
              _preloadData(index);     // Preload data for current day
              _preloadData(index + 1); // Preload data for next day
            },
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  FutureBuilder<List<ClassEvent>>(
                    future: _getClassEvents(index),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No classes for this day'));
                      } else {
                        return _buildDayView(snapshot.data!, index);
                      }
                    },
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: _buildNavigationIconButton(
                      icon: Icons.arrow_back,
                      onPressed: _currentPageIndex > 0 ? () => _changePage(-1) : null,
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: _buildNavigationIconButton(
                      icon: Icons.arrow_forward,
                      onPressed: _currentPageIndex < 5 ? () => _changePage(1) : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _getDayName(int index) {
    List<String> days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
    return days[index];
  }


  Widget _buildDayView(List<ClassEvent> classEvents, int index) {
    bool isMorningClass = classEvents.first.startTime.contains("AM");

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/OIP.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getDayName(index),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  isMorningClass ? "Morning Classes" : "Afternoon Classes",
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          for (var classEvent in classEvents)
            if (!_classEventsCache[index]!.contains(classEvent))
              SizedBox.shrink()
            else
              _buildClassBox(classEvent),
        ],
      ),
    );
  }



  Widget _buildClassBox(ClassEvent classEvent) {
    return GestureDetector(
      onTap: () {
        _showEditClassNameDialog(classEvent);
      },
      onLongPress: () {
        _showEditTimingsDialog(classEvent);
      },
      child: Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: Card(
          color: Colors.cyan[200],
          elevation: 3,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classEvent.className,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${classEvent.startTime} - ${classEvent.endTime}',
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        secondaryActions: <Widget>[
          GestureDetector(
            onTap: () {
              // Implement call functionality here
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
              ),
              child: Icon(
                Icons.call,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _deleteClassEvent(classEvent);
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red,
              ),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }




  Widget _buildNavigationIconButton({required IconData icon, required Function()? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),
      child: IconButton(
        icon: Icon(icon, size: 36, color: Colors.black), // Customize icon size and color
        onPressed: onPressed,
      ),
    );
  }

  Future<void> _deleteClassEvent(ClassEvent classEvent) async {
    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this class?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false to cancel delete
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true to confirm delete
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    // Check if user confirmed delete
    if (confirmDelete != null && confirmDelete) {
      // Delete class event from the database
      await ClassEventDatabaseHelper().deleteClassEvent(classEvent.id!);
      // Remove the deleted class event from the cache
      _classEventsCache.values.forEach((events) {
        events.removeWhere((event) => event.id == classEvent.id);
      });
      // Forcefully refresh the UI
      setState(() {});
    }
  }

  void _changePage(int delta) {
    final newIndex = _currentPageIndex + delta;
    _pageController.animateToPage(
      newIndex,
      duration: Duration(milliseconds: 300), // Adjust animation speed as needed
      curve: Curves.easeInOut,
    );
  }

  void _preloadData(int index) {
    if (index < 0 || index >= 6 || _classEventsCache.containsKey(index)) {
      return;
    }
    _getClassEvents(index); // Preload data for the specified index
  }

  Future<List<ClassEvent>> _getClassEvents(int index) async {
    if (_classEventsCache.containsKey(index)) {
      return _classEventsCache[index]!;
    }
    final classEvents = await ClassEventDatabaseHelper().getClassEvents(_getDayName(index));
    _classEventsCache[index] = classEvents;
    return classEvents;
  }



  void _showEditTimingsDialog(ClassEvent classEvent) {
    TextEditingController startTimeController = TextEditingController(text: classEvent.startTime);
    TextEditingController endTimeController = TextEditingController(text: classEvent.endTime);

    TimeOfDay? selectedStartTime = _parseTimeOfDay(classEvent.startTime);
    TimeOfDay? selectedEndTime = _parseTimeOfDay(classEvent.endTime);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Timings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              GestureDetector(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedStartTime ?? TimeOfDay.now(),
                  );
                  if (picked != null && picked != selectedStartTime) {
                    setState(() {
                      selectedStartTime = picked;
                      startTimeController.text = picked.format(context);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: startTimeController,
                    decoration: InputDecoration(labelText: 'Start Time'),
                  ),
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedEndTime ?? TimeOfDay.now(),
                  );
                  if (picked != null && picked != selectedEndTime) {
                    setState(() {
                      selectedEndTime = picked;
                      endTimeController.text = picked.format(context);
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: endTimeController,
                    decoration: InputDecoration(labelText: 'End Time'),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newStartTime = selectedStartTime?.format(context) ?? classEvent.startTime;
                String newEndTime = selectedEndTime?.format(context) ?? classEvent.endTime;

                classEvent.startTime = newStartTime;
                classEvent.endTime = newEndTime;

                await ClassEventDatabaseHelper().updateClassEvent(classEvent);
                setState(() {});
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  TimeOfDay? _parseTimeOfDay(String timeString) {
    List<String> parts = timeString.split(':');
    if (parts.length == 2) {
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }


  void _showEditClassNameDialog(ClassEvent classEvent) {
    String editedClassName = classEvent.className;

    TextEditingController _controller =
    TextEditingController(text: classEvent.className);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Class Name'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter new class name'),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.access_time),
              onPressed: () {
                _showEditTimingsDialog(classEvent);
                // Handle onTap function for the clock icon here
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String newClassName = _controller.text;
                classEvent.className = newClassName;
                await ClassEventDatabaseHelper().updateClassEvent(classEvent);
                setState(() {});
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

}
