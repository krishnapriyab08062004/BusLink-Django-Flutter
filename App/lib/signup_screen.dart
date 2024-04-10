import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formSignupKey = GlobalKey<FormState>();
  bool agreePersonalData = true;
  XFile? _selectedImage;
  String? _imageUrl;
  String? filePath;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stuphoneController = TextEditingController();
  final TextEditingController _guardiannameController = TextEditingController();
  final TextEditingController _guardianphoneController =TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _stupinController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _stubatchController = TextEditingController();
  final TextEditingController _sturollnoController = TextEditingController();

  FirebaseFirestore db = FirebaseFirestore.instance;
  List<Map<String, dynamic>> district = [];
  List<Map<String, dynamic>> place = [];
  String? selectdistrict;
  String? selectplace;

  Future<void> _registerUser() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );

      // ignore: unnecessary_null_comparison
      userCredential != null;
      await _storeUserData(userCredential.user!.uid);
    } catch (e) {
      print("Error registering user: $e");
      // Handle error, show message, or take appropriate action
    }
  }

  Future<void> _storeUserData(String userId) async {
    try {
      await db.collection('tbl_student').add({
        'stu_id': userId,
        'stu_name': _nameController.text,
        'stu_mail': _emailController.text,
        'stu_pass': _passController.text,
        'dob': _dobController.text,
        'City': _cityController.text,
        'place': selectplace,
        'gender': selectedGender,
        'stu_img':""
        // Add more fields as needed
      });

      await _uploadImage(userId);
    } catch (e) {
      print("Error storing user data: $e");
      // Handle error, show message or take appropriate action
    }
  }

   Future<void> _uploadImage(String userId) async {
    try {
      if (_selectedImage != null) {
       final Reference ref =
                FirebaseStorage.instance.ref().child('user_photo/$userId.jpg');
            await ref.putFile(File(_selectedImage!.path));
            final imageUrl = await ref.getDownloadURL();

      // Check if the document exists before updating
      await db.collection('tbl_student')
          .where('stu_id', isEqualTo: userId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.update({
            'stu_img': imageUrl,
          });
        });
      });
    }

    } catch (e) {
      print("Error uploading image: $e");
      // Handle error, show message or take appropriate action
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = XFile(pickedFile.path);
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        setState(() {
          filePath = result.files.single.path;
        });
      } else {
        // User canceled file picking
        print('File picking canceled.');
      }
    } catch (e) {
      // Handle exceptions
      print('Error picking file: $e');
    }
  }

  Future<void> fetchDistrict() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await db.collection('tbl_district').get();

      List<Map<String, dynamic>> dist = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'district': doc['district_name'].toString(),
              })
          .toList();
      setState(() {
        district = dist;
      });
      print(district);
    } catch (e) {
      print('Error fetching department data: $e');
    }
  }

  Future<void> fetchPlace(String id) async {
    try {
      selectplace = null;
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await db
          .collection('tbl_place')
          .where('district_id', isEqualTo: id)
          .get();
      List<Map<String, dynamic>> plc = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'place': doc['place_name'].toString(),
              })
          .toList();
      setState(() {
        place = plc;
      });
    } catch (e) {
      print(e);
    }
  }

  String? selectedGender;

  @override
  void initState() {
    super.initState();
    fetchDistrict();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(25.0, 50.0, 25.0, 20.0),
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/back.jpg'), fit: BoxFit.cover),
          color: Color.fromARGB(255, 255, 252, 252),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.0),
            topRight: Radius.circular(40.0),
          ),
        ),
        child: SingleChildScrollView(
          // get started form
          child: Form(
            key: _formSignupKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // get started text
                const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w900,
                    color: Color.fromARGB(255, 254, 255, 255),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Color.fromARGB(255, 223, 5, 180),
                          backgroundImage: _selectedImage != null
                              ? FileImage(File(_selectedImage!.path))
                              : _imageUrl != null
                                  ? NetworkImage(_imageUrl!)
                                  : const AssetImage('assets/dummy.jpg')
                                      as ImageProvider,
                          child: _selectedImage == null && _imageUrl == null
                              ? const Icon(
                                  Icons.add,
                                  size: 40,
                                  color: Color.fromARGB(255, 110, 104, 107),
                                )
                              : null,
                        ),
                        if (_selectedImage != null || _imageUrl != null)
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 18,
                              child: Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.black,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                // full name
                TextFormField(
                  controller: _nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Full name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: const Text('Full Name'),
                    hintText: 'Enter Full Name',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(66, 241, 227, 227),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),

                //Contact
                TextFormField(
                  controller: _stuphoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter student phone number ';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    label: const Text(' Phone Number'),
                    hintText: 'Enter Your Phone Number',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),

                //Email
                TextFormField(
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: const Text('Email'),
                    hintText: 'Enter Email',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),

//Gender
                Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gender: ',
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 15,
                        ),
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            activeColor: Colors.blue,
                            value: 'Male',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value!;
                              });
                            },
                          ),
                          const Text('Male')
                        ],
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            activeColor: Colors.blue,
                            value: 'Female',
                            groupValue: selectedGender,
                            onChanged: (value) {
                              setState(() {
                                selectedGender = value!;
                              });
                            },
                          ),
                          const Text('Female')
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),

                //City
                TextFormField(
                  controller: _cityController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter City';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    label: const Text('City'),
                    hintText: 'Enter City',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),

//Pincode

                TextFormField(
                  controller: _stupinController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Pin code ';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    label: const Text(' Pincode'),
                    hintText: 'Enter Your Pin',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),

                //House Name
                TextFormField(
                  controller: _houseController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter House Name';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    label: const Text('House Name'),
                    hintText: 'Enter Your House Name',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),

//Batch

                TextFormField(
                  controller: _stubatchController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Batch ';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    label: const Text(' Batch Year'),
                    hintText: 'Enter Your Batch Year',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),

//Roll nUm

                TextFormField(
                  controller: _sturollnoController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Class Roll Number ';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    label: const Text(' Roll Number'),
                    hintText: 'Enter Your Roll Number',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),

                TextFormField(
                  controller: _dobController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Date of birth';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    label: const Text('DOB'),
                    hintText: 'Enter Date of Birth',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 15.0,
                ),

                DropdownButtonFormField<String>(
                  value: selectdistrict,
                  decoration: InputDecoration(
                    label: const Text('District'),
                    hintText: 'Select District',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectdistrict = newValue;
                      fetchPlace(newValue!);
                    });
                  },
                  isExpanded: true,
                  items: district.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> dist) {
                      return DropdownMenuItem<String>(
                        value: dist['id'],
                        child: Text(dist['district']),
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  value: selectplace,
                  decoration: InputDecoration(
                    label: const Text('Place'),
                    hintText: 'Select Place',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectplace = newValue;
                    });
                  },
                  isExpanded: true,
                  items: place.map<DropdownMenuItem<String>>(
                    (Map<String, dynamic> place) {
                      return DropdownMenuItem<String>(
                        value: place['id'],
                        child: Text(place['place']),
                      );
                    },
                  ).toList(),
                ),

                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickFile,
                            child: const Text('Upload File'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (filePath != null)
                      Text(
                        'Selected File: $filePath',
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
                TextFormField(
                  controller: _guardiannameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Full name';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: const Text('Guardian Name'),
                    hintText: 'Enter Full Name',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(255, 242, 242, 242),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                TextFormField(
                  controller: _guardianphoneController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter guardian phone number ';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    label: const Text('Guardian Phone Number'),
                    hintText: 'Enter Guardian Phone Number',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                // password

                TextFormField(
                  controller: _passController,
                  obscureText: true,
                  obscuringCharacter: '*',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    label: const Text('Password'),
                    hintText: 'Enter Password',
                    hintStyle: const TextStyle(
                      color: Colors.black26,
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.black12, // Default border color
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 25.0,
                ),
                // signup button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formSignupKey.currentState!.validate() &&
                          agreePersonalData) {
                        _registerUser();
                      } else if (!agreePersonalData) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please agree to the processing of personal data')),
                        );
                      }
                    },
                    child: const Text('Sign up'),
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                // already have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 241, 241, 241),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (e) => const LoginScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 229, 231, 232),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
