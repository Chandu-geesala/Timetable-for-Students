import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:students/settings.dart';
import 'package:students/classes/display.dart';
import 'package:students/database/profile.dart';
import 'package:students/database/database_helper.dart';
import 'package:students/classes/class_event.dart';
import 'package:students/classes/class_event_database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize profile database
  final profileDatabase = await _initializeProfileDatabase();

  // Initialize class event database
  final classEventDatabase = await _initializeClassEventDatabase();

  runApp(MyApp(profileDatabase: profileDatabase, classEventDatabase: classEventDatabase));
}

Future<Database> _initializeProfileDatabase() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = join(directory.path, 'profiles_database.db');
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE profiles(id INTEGER PRIMARY KEY, name TEXT, imagePath TEXT)",
      );
    },
  ).then((db) async {
    await _initializeProfiles(db);
    return db;
  });
}
Future<void> _initializeProfiles(Database db) async {
  final List<Profile> profiles = [
    Profile(id: 1, name: 'Chandu', imagePath: 'assets/chandu.jpg'),
    Profile(id: 2, name: 'Pavan', imagePath: 'assets/pavan.jpeg'),
    Profile(id: 3, name: 'Omkar', imagePath: 'assets/om.jpeg'),
    Profile(id: 4, name: 'Karthik', imagePath: 'assets/kar.jpeg'),
    Profile(id: 5, name: 'Jaswanth', imagePath: 'assets/jas.jpg'),
  ];

  // Check if profiles already exist
  final List<Map<String, dynamic>> existingProfiles = await db.query('profiles');
  if (existingProfiles.isEmpty) {
    // Insert profiles into the database
    final batch = db.batch();
    for (var profile in profiles) {
      batch.insert('profiles', profile.toMap());
    }
    await batch.commit(noResult: true);
  }
}


Future<Database> _initializeClassEventDatabase() async {
  final directory = await getApplicationDocumentsDirectory();
  final path = join(directory.path, 'class_events_database.db');
  return openDatabase(
    path,
    version: 1,
    onCreate: (db, version) {
      return db.execute(
        "CREATE TABLE class_events(id INTEGER PRIMARY KEY, day TEXT, class_name TEXT, start_time TEXT, end_time TEXT)",
      );
    },
  ).then((db) async {
    await _initializeClassEvents(db);
    return db;
  });
}



Future<void> _initializeClassEvents(Database db) async {

  final List<ClassEvent> classEvents = [
    // Monday
    ClassEvent(day: 'Monday', className: 'WT Lab', startTime: '1:30 PM', endTime: '3:10 PM'),
    ClassEvent(day: 'Monday', className: 'CD', startTime: '4:10 PM', endTime: '5:00 PM'),
    ClassEvent(day: 'Monday', className: 'Sports', startTime: '5:10 PM', endTime: '5:50 PM'),

    // Tuesday
    ClassEvent(day: 'Tuesday', className: 'Career Guidance', startTime: '8:40 AM', endTime: '9:30 AM'),
    ClassEvent(day: 'Tuesday', className: 'DSP', startTime: '9:30 AM', endTime: '10:20 AM'),
    ClassEvent(day: 'Tuesday', className: 'COA', startTime: '10:20 AM', endTime: '11:10 AM'),
    ClassEvent(day: 'Tuesday', className: 'CD', startTime: '11:20 AM', endTime: '12:10 PM'),
    ClassEvent(day: 'Tuesday', className: 'WT', startTime: '12:10 PM', endTime: '1:00 PM'),

    // Wednesday
    ClassEvent(day: 'Wednesday', className: 'COA Lab', startTime: '1:30 PM', endTime: '4:10 PM'),
    ClassEvent(day: 'Wednesday', className: 'Library', startTime: '4:10 PM', endTime: '5:00 PM'),
    ClassEvent(day: 'Wednesday', className: 'Yoga', startTime: '5:00 PM', endTime: '5:50 PM'),

    // Thursday
    ClassEvent(day: 'Thursday', className: 'IOR', startTime: '8:40 AM', endTime: '9:30 AM'),
    ClassEvent(day: 'Thursday', className: 'DSP', startTime: '9:30 AM', endTime: '10:20 AM'),
    ClassEvent(day: 'Thursday', className: 'COA', startTime: '10:20 AM', endTime: '11:10 AM'),
    ClassEvent(day: 'Thursday', className: 'WT', startTime: '11:20 AM', endTime: '12:10 PM'),
    ClassEvent(day: 'Thursday', className: 'IOR', startTime: '12:10 PM', endTime: '1:00 PM'),

    // Friday
    ClassEvent(day: 'Friday', className: 'DSP Lab', startTime: '1:30 PM', endTime: '4:10 PM'),
    ClassEvent(day: 'Friday', className: 'Career Guidance', startTime: '4:10 PM', endTime: '4:50 PM'),
    ClassEvent(day: 'Friday', className: 'IOR', startTime: '4:50 PM', endTime: '5:50 PM'),

    // Saturday
    ClassEvent(day: 'Saturday', className: 'Career Guidance', startTime: '8:40 AM', endTime: '9:30 AM'),
    ClassEvent(day: 'Saturday', className: 'DSP', startTime: '9:30 AM', endTime: '10:20 AM'),
    ClassEvent(day: 'Saturday', className: 'COA', startTime: '10:20 AM', endTime: '11:10 AM'),
    ClassEvent(day: 'Saturday', className: 'CD', startTime: '11:20 AM', endTime: '12:10 PM'),
    ClassEvent(day: 'Saturday', className: 'WT', startTime: '12:10 PM', endTime: '1:00 PM'),
  ];


  // Check if class events already exist
  final List<Map<String, dynamic>> existingClassEvents = await db.query('class_events');
  if (existingClassEvents.isEmpty) {
    // Insert class events into the database
    final batch = db.batch();
    for (final event in classEvents) {
      batch.insert('class_events', event.toMap());
    }
    await batch.commit(noResult: true);
  }
}



class MyApp extends StatelessWidget {
  final Database profileDatabase;
  final Database classEventDatabase;

  MyApp({required this.profileDatabase, required this.classEventDatabase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(profileDatabase: profileDatabase, classEventDatabase: classEventDatabase),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Database profileDatabase;
  final Database classEventDatabase;

  MyHomePage({required this.profileDatabase, required this.classEventDatabase});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Profile? _selectedProfile;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadSelectedProfile();
  }

  Future<void> _loadSelectedProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? selectedProfileId = prefs.getInt('selected_profile_id');
    if (selectedProfileId != null) {
      final List<Profile> profiles = await _profiles();
      final Profile selectedProfile = profiles.firstWhere(
            (profile) => profile.id == selectedProfileId,
        orElse: () =>
            Profile(id: -1, name: 'Default', imagePath: 'assets/default.jpg'),
      );
      setState(() {
        _selectedProfile = selectedProfile;
      });
    }
  }

  Future<List<Profile>> _profiles() async {
    return _databaseHelper.profiles();
  }

  void _showPopupMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context)!.context
        .findRenderObject() as RenderBox;
    final Offset offset = Offset(0.0, overlay.size.height);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, 75, 25, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: Text('Change Profile'),
          value: 'change_profile',
        ),
      ],
      elevation: 8.0,
    ).then((value) {
      if (value == 'change_profile') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>
              SettingsPage(
                database: Future.value(widget.profileDatabase),
                selectedProfile: _selectedProfile,
              ),
          ),
        ).then((selectedProfile) {
          if (selectedProfile != null) {
            setState(() {
              _selectedProfile = selectedProfile;
            });
            _saveSelectedProfile(selectedProfile.id);
          }
        });
      }
    });
  }

  Future<void> _saveSelectedProfile(int profileId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_profile_id', profileId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedProfile != null
            ? Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage(_selectedProfile!.imagePath),
            ),
            SizedBox(width: 20),
            Text(_selectedProfile!.name),
          ],
        )
            : Text('Profile Selection'),
        actions: _selectedProfile != null
            ? [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              _showPopupMenu(context);
            },
          ),
        ]
            : [],
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/OIP.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Class display widget
          Center(
            child: _selectedProfile != null
                ? TimetableScreen() // Display class events directly
                : ElevatedButton(
              onPressed: () {
                _showProfileSelectionDialog(context);
              },
              child: Text('Select Profile'),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Profile'),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: FutureBuilder<List<Profile>>(
              future: _profiles(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Profile>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(
                              snapshot.data![index].imagePath),
                        ),
                        title: Text(snapshot.data![index].name),
                        onTap: () {
                          setState(() {
                            _selectedProfile = snapshot.data![index];
                          });
                          _saveSelectedProfile(snapshot.data![index].id ?? 0);
                          Navigator.pop(context,
                              _selectedProfile); // Close the SettingsPage
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                return Center(child: CircularProgressIndicator());
              },
            ),
          ),
        );
      },
    );
  }
}
