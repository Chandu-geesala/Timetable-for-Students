import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:students/database/profile.dart';
import 'database/database_helper.dart';



class SettingsPage extends StatefulWidget {
  final Future<Database> database;
  final Profile? selectedProfile;

  SettingsPage({required this.database, this.selectedProfile});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}





class _SettingsPageState extends State<SettingsPage> {
  late Future<List<Profile>> _profiles;

  @override
  void initState() {
    super.initState();
    _profiles = _loadProfiles();
  }

  Future<List<Profile>> _loadProfiles() async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    return databaseHelper.profiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _profiles = _loadProfiles();
          });
        },
        child: FutureBuilder<List<Profile>>(
          future: _profiles,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Profile>? profiles = snapshot.data;
              if (profiles != null && profiles.isNotEmpty) {
                return ListView.builder(
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    Profile profile = profiles[index];
                    return ListTile(
                      leading: InkWell(
                        onTap: () {
                          _openCamera(); // Function to open the camera
                        },
                        child: CircleAvatar(
                          backgroundImage: AssetImage(profile.imagePath),
                        ),
                      ),
                      title: Text(profile.name),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _editProfileName(profile, context);
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context, profile);
                      },
                    );
                  },
                );
              } else {
                return Center(child: Text('No profiles found.'));
              }
            }
          },
        ),
      ),
    );
  }

  // Function to open the camera
  void _openCamera() {
    // Implement the code to open the camera here
    // For example, you can use packages like camera or image_picker
    // Here's a simple example using image_picker:
    // _getImageFromCamera();
  }

  // Function to edit profile name
  void _editProfileName(Profile profile, BuildContext context) {
    TextEditingController _controller =
    TextEditingController(text: profile.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Profile Name'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter new name'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),


            TextButton(
              onPressed: () async {
                String newName = _controller.text;
                Profile updatedProfile = Profile(
                  id: profile.id,
                  name: newName,
                  imagePath: profile.imagePath,
                );
                await _updateProfile(updatedProfile);
                Navigator.of(context).pop(); // Close the dialog
                setState(() {
                  _profiles = _loadProfiles();
                });
              },

              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to update profile
  Future<void> _updateProfile(Profile profile) async {
    final DatabaseHelper databaseHelper = DatabaseHelper();
    await databaseHelper.updateProfile(profile);
  }
}
