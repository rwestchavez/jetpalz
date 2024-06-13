import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jet_palz/components/my_button.dart';
import 'package:jet_palz/components/my_textField.dart';
import '../components/my_appBar.dart';
import '../components/my_snack_bar.dart';
import '../constants.dart';
import '../helpers/is_username_available.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<EditProfile> {
  User? _user;
  Map<String, dynamic>? _userData;
  String? selectedIndustry = '';
  late List<String?> selectedIndustries;
  late List<String?> selectedCountries;
  final TextEditingController _usernameTextController = TextEditingController();
  final TextEditingController _descriptionTextController =
      TextEditingController();
  late SingleSelectController<String?> industryController;
  late MultiSelectController<String> countriesController;
  late MultiSelectController<String> industriesController;
  final _formKey = GlobalKey<FormState>();
  late FocusNode _usernameFocusNode;
  late FocusNode _descriptionFocusNode;

  bool _isSavingChanges = false;

  bool _isLoading = true;

  String? _temporaryImageUrl;
  String? _oldImageUrl;
  File? _imageFile;
  bool _imagePicked = false;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode = FocusNode();
    _descriptionFocusNode = FocusNode();
    _user = FirebaseAuth.instance.currentUser;
    _initializeUserData();
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _descriptionFocusNode.dispose();
    //_cancelChanges();
    super.dispose();
  }

  Future<void> _initializeUserData() async {
    try {
      final userData = await _fetchUserData();
      setState(() {
        _userData = userData;
        _isLoading = false;

        final profession = _userData!['profession'] as String?;
        industryController = SingleSelectController<String?>(
          profession != null && industries.contains(profession)
              ? profession
              : null,
        );

        final userCountries =
            _userData!['countries_interest'] as List<dynamic>?;
        countriesController = MultiSelectController<String>(
          userCountries != null
              ? userCountries
                  .cast<String>()
                  .where((e) => countries.contains(e))
                  .toList()
              : [],
        );

        final userProfessions =
            _userData!['professions_interest'] as List<dynamic>?;
        industriesController = MultiSelectController<String>(
          userProfessions != null
              ? userProfessions
                  .cast<String>()
                  .where((e) => industries.contains(e))
                  .toList()
              : [],
        );
        _usernameTextController.text = _userData!['username'] ?? '';
        _descriptionTextController.text = _userData!['description'] ?? '';
      });
    } catch (e) {
      print('Error initializing user data: $e');
    }
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    if (_user != null) {
      try {
        final userDataSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .get();
        return userDataSnapshot.data() as Map<String, dynamic>;
      } catch (e) {
        print('Error fetching user data: $e');
        throw e;
      }
    }
    throw Exception('User is null');
  }

  Future<void> _pickImage() async {
    final imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text("Select Image Source"),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(ImageSource.gallery);
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _imageFile = File(pickedFile.path);
                        _temporaryImageUrl = null; // Clear temporary image URL
                        _imagePicked = true; // Mark that an image is picked
                      });
                    } else {
                      print('No image selected.');
                    }
                  },
                  child: Text("Gallery"),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(ImageSource.camera);
                    final pickedFile = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    if (pickedFile != null) {
                      setState(() {
                        _imageFile = File(pickedFile.path);
                        _temporaryImageUrl = null; // Clear temporary image URL
                        _imagePicked = true; // Mark that an image is picked
                      });
                    } else {
                      print('No image selected.');
                    }
                  },
                  child: Text("Camera"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (!_imagePicked) return; // || _imageFile == null

    try {
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_photos')
            .child(
                '${_user!.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg'); // Unique filename

        await storageRef.putFile(_imageFile!);

        final downloadUrl = await storageRef.getDownloadURL();

        // Set the temporary image URL to display it in the UI
        setState(() {
          _temporaryImageUrl = downloadUrl;
        });
        print("Updated image");
      } else {
        setState(() {
          _temporaryImageUrl =
              "https://firebasestorage.googleapis.com/v0/b/jet-palz-backend-dcwyg2.appspot.com/o/assets%2Fpfp.png?alt=media&token=92f34e08-89ff-4de0-8076-4a2e9ec0576f";
        });
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSavingChanges = true;
      });

      _saveChangesAsync().then((_) {
        setState(() {
          _isSavingChanges = false;
        });
      });
    }
  }

  Future<void> _saveChangesAsync() async {
    if (_formKey.currentState!.validate()) {
      try {
        final isAvailable =
            await isUsernameAvailable(_usernameTextController.text);

        if (!isAvailable) {
          MySnackBar.show(
            context,
            content: Text('Username is not available'),
          );
          return; // Stop the saving process if the username is not available
        }
        // Save the current photo URL before uploading the new one
        _oldImageUrl = _userData?['photo_url'];

        // Check if a new image was picked
        if (_imageFile != null) {
          // _imagePicked &&
          // Upload image to Firestore
          await _uploadImage();
        }

        // Update other user data
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.uid)
            .update({
          'username': _usernameTextController.text.trim(),
          'profession': industryController.value,
          'professions_interest': industriesController.value,
          'countries_interest': countriesController.value,
          'description': _descriptionTextController.text.trim(),
          // Only update photo_url if a new image was picked
          if (_imagePicked && _temporaryImageUrl != null)
            'photo_url': _temporaryImageUrl,
        });

        Navigator.pop(context, true);
      } catch (e) {
        print('Error saving changes: $e');
        MySnackBar.show(
          context,
          content: Text('Failed to save changes'),
        );
      }
    }
  }

  void _cancelChanges() {
    setState(() {
      _temporaryImageUrl =
          "https://firebasestorage.googleapis.com/v0/b/jet-palz-backend-dcwyg2.appspot.com/o/assets%2Fpfp.png?alt=media&token=92f34e08-89ff-4de0-8076-4a2e9ec0576f";
      // Clear image file
      _imageFile = null;
      // Mark image as not picked
      _imagePicked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: _isLoading
          ? Scaffold(body: Center(child: CircularProgressIndicator()))
          : Scaffold(
              appBar: MyAppBar(
                title: "Edit Profile",
              ),
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.lightBlue[200],
                                child: _imageFile != null
                                    ? ClipOval(
                                        child: Image.file(
                                          _imageFile!,
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : (_temporaryImageUrl != null
                                        ? ClipOval(
                                            child: Image.network(
                                              _temporaryImageUrl!,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : (_userData != null &&
                                                _userData!['photo_url'] != null
                                            ? ClipOval(
                                                child: Image.network(
                                                  _userData!['photo_url'],
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.white,
                                              ))),
                              ),
                              Column(
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      await _pickImage();
                                    },
                                    child: Text('Change Photo'),
                                  ),
                                  SizedBox(height: 12),
                                  ElevatedButton(
                                    onPressed: () async {
                                      _cancelChanges();
                                    },
                                    child: Text('Reset Photo'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 24),
                          MyTextField(
                            focusNode: _usernameFocusNode,
                            controller: _usernameTextController,
                            hintText: "  Username",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username is required';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters long';
                              }
                              if (value.length > 30) {
                                return 'Username must be less than 30 characters';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                                return 'Username can only contain letters, numbers, and underscores';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24),
                          MyTextField(
                            maxLines: null,
                            focusNode: _descriptionFocusNode,
                            controller: _descriptionTextController,
                            hintText: "  Description",
                            validator: (value) {
                              if (value!.length > 400) {
                                // Adjust the maximum character limit as needed
                                return 'Description must be less than 400 characters';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 24),
                          CustomDropdown<String>(
                            controller: industryController,
                            decoration: CustomDropdownDecoration(
                              closedBorder: Border.all(
                                width: 2,
                                color: Colors.grey,
                              ),
                            ),
                            hintText: 'My Profession',
                            items: industries,
                            onChanged: (selected) {
                              setState(() {
                                industryController.value = selected;
                                selectedIndustry = selected;
                                print('changing value to: $selected');
                              });
                            },
                          ),
                          SizedBox(height: 24),
                          CustomDropdown<String?>.multiSelect(
                            multiSelectController: industriesController,
                            decoration: CustomDropdownDecoration(
                              closedBorder: Border.all(
                                width: 2,
                                color: Colors.grey,
                              ),
                            ),
                            hintText: 'Professions interested with',
                            items: industries,
                            onListChanged: (selected) {
                              setState(() {
                                industriesController.value =
                                    selected as List<String>;
                                selectedIndustries = selected;
                                print('changing value to: $selected');
                              });
                            },
                          ),
                          SizedBox(height: 24),
                          CustomDropdown<String?>.multiSelect(
                            multiSelectController: countriesController,
                            decoration: CustomDropdownDecoration(
                              closedBorder: Border.all(
                                width: 2,
                                color: Colors.grey,
                              ),
                            ),
                            hintText: 'Desired Destinations',
                            items: countries,
                            onListChanged: (selected) {
                              setState(() {
                                countriesController.value =
                                    selected as List<String>;
                                selectedCountries = selected;
                                print('changing value to: $selected');
                              });
                            },
                          ),
                          SizedBox(height: 24),
                          Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: 300,
                              child: MyButton(
                                onPressed: _isSavingChanges
                                    ? null
                                    : _saveChanges, // Disable button during data saving process
                                child: _isSavingChanges
                                    ? CircularProgressIndicator() // Display loading indicator when saving changes
                                    : Text(
                                        "Save changes",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
