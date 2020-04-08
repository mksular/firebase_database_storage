import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:the_validator/the_validator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CloudFirestorePage extends StatefulWidget {
  final String _title;
  CloudFirestorePage(this._title);

  @override
  _CloudFirestorePageState createState() => _CloudFirestorePageState();
}

class _CloudFirestorePageState extends State<CloudFirestorePage> {
  final Firestore _firestore = Firestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  var _formKey = GlobalKey<FormState>();
  int _sayac = 1;
  String _email;
  String _password;
  String _name;
  String _lastname;
  bool _driveLicense = false;
  String _driveLicenseType;
  var _imageUrl;

  File _image;

  List<DocumentSnapshot> _documentSnapshot;

  @override
  void initState() {
    super.initState();
    _getDocSnap();
  }

  List<String> _driveLicenseTypes = [
    "M",
    "A1",
    "A2",
    "A",
    "B1",
    "B",
    "BE",
    "C1",
    "C1E",
    "C",
    "CE",
    "D1",
    "D1E",
    "D",
    "DE",
    "F",
    "G"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text("CloudFirestore | ${widget._title}"),
      ),
      body: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onSaved: (x) {
                        setState(() {
                          _email = x;
                        });
                      },
                      autofocus: true,
                      validator: (x) {
                        if (x.isEmpty) {
                          return "Doldurulması Zorunludur!";
                        } else {
                          if (EmailValidator.validate(x) != true) {
                            return "Geçerli Bir Email Adresi Giriniz!";
                          } else {
                            return null;
                          }
                        }
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          errorStyle: TextStyle(fontSize: 20),
                          labelText: "Email",
                          labelStyle: TextStyle(fontSize: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.purple))),
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      onSaved: (x) {
                        setState(() {
                          _password = x;
                        });
                      },
                      keyboardType: TextInputType.text,
                      obscureText: true,
                      validator: FieldValidator.password(
                          minLength: 8,
                          shouldContainNumber: true,
                          shouldContainCapitalLetter: true,
                          shouldContainSpecialChars: true,
                          errorMessage:
                              "Minimum 8 Karakter uzunluğunda Olmalıdır!",
                          isNumberNotPresent: () {
                            return "Rakam İçermelidir!";
                          },
                          isSpecialCharsNotPresent: () {
                            return "Özel Karakter İçermelidir!";
                          },
                          isCapitalLetterNotPresent: () {
                            return "Büyük Harf İçermelidir!";
                          }),
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          errorStyle: TextStyle(fontSize: 20),
                          labelText: "Şifre",
                          labelStyle: TextStyle(fontSize: 20),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.purple))),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Flexible(
                          child: TextFormField(
                            onSaved: (x) {
                              setState(() {
                                _name = x;
                              });
                            },
                            validator: FieldValidator.required(
                                message: "Lütfen Doldurunuz!"),
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.person),
                                errorStyle: TextStyle(fontSize: 20),
                                labelText: "Adınız",
                                labelStyle: TextStyle(fontSize: 20),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.purple))),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextFormField(
                            onSaved: (x) {
                              setState(() {
                                _lastname = x;
                              });
                            },
                            validator: FieldValidator.required(
                                message: "Lütfen Doldurunuz!"),
                            decoration: InputDecoration(
                                errorStyle: TextStyle(fontSize: 20),
                                labelText: "Soyadınız",
                                labelStyle: TextStyle(fontSize: 20),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(
                                        width: 1, color: Colors.purple))),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Flexible(
                            flex: 2,
                            child: SwitchListTile(
                                activeColor: Colors.purple,
                                title: Text("Sürücü Belgesi",
                                    style: TextStyle(fontSize: 20)),
                                value: _driveLicense,
                                onChanged: (x) {
                                  setState(() {
                                    _driveLicense = x;
                                  });
                                })),
                        SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: _driveLicense == true
                                ? DropdownButton(
                                    hint: Text("Seçiniz",
                                        style: TextStyle(fontSize: 20)),
                                    value: _driveLicenseType,
                                    items: _driveLicenseTypes.map((item) {
                                      return DropdownMenuItem(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: TextStyle(fontSize: 20),
                                          ));
                                    }).toList(),
                                    onChanged: (x) {
                                      setState(() {
                                        _driveLicenseType = x;
                                      });
                                    })
                                : Text(""))
                      ],
                    ),
                    SizedBox(height: 10),
                    RaisedButton.icon(
                      icon: Icon(
                        Icons.person_add,
                        color: Colors.white,
                      ),
                      onPressed: _kayitEkle,
                      color: Colors.purple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      hoverColor: Colors.black,
                      label: Text(
                        " Kayıt Ol",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                  ],
                )),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                child: _documentSnapshot.isNotEmpty
                    ? ListView.builder(
                        itemCount: _documentSnapshot.length,
                        itemBuilder: (BuildContext context, int index) {
                          var _snapShot = _documentSnapshot[index].data;
                          return Dismissible(
                            key: Key(_sayac.toString()),
                            direction: DismissDirection.startToEnd,
                            onDismissed: (direction) {
                              _sayac += 1;
                              _firestore
                                  .document("users/" + _snapShot["id"])
                                  .delete();
                            },
                            child: Card(
                              margin: EdgeInsets.only(top: 10),
                              color: index % 2 == 0
                                  ? Colors.blue.shade50
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side:
                                      BorderSide(color: Colors.blue.shade900)),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: ListTile(
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        _snapShot["name"] +
                                            " " +
                                            _snapShot["lastname"],
                                        style: TextStyle(fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.navigate_next,
                                    size: 36,
                                  ),
                                  subtitle: Flexible(
                                    child: Row(
                                      children: <Widget>[
                                        IconButton(
                                          onPressed: () {
                                            _firestore
                                                .runTransaction((transaction) {
                                              var docRef = _firestore.document(
                                                  "users/" + _snapShot["id"]);
                                              transaction.update(docRef, {
                                                "views": FieldValue.increment(1)
                                              });
                                              return null;
                                            }).catchError((hata) {
                                              debugPrint("Hata Kodu: " + hata);
                                            });
                                          },
                                          icon: Icon(Icons.visibility),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          _snapShot["views"].toString(),
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Icon(
                                          Icons.textsms,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "0",
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            _firestore
                                                .runTransaction((transaction) {
                                              var docRef = _firestore.document(
                                                  "users/" + _snapShot["id"]);
                                              transaction.update(docRef, {
                                                "likes": FieldValue.increment(1)
                                              });
                                              return null;
                                            }).catchError((hata) {
                                              debugPrint("Hata Kodu: " + hata);
                                            });
                                          },
                                          icon: Icon(Icons.thumb_up,
                                              color: Colors.blue.shade900),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          _snapShot["likes"].toString(),
                                          style: TextStyle(fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                  leading: InkWell(
                                    onTap: () async {
                                      Alert(
                                          image: Image(
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              image: _image != null
                                                  ? FileImage(_image)
                                                  : _snapShot["image"] != null
                                                      ? NetworkImage(
                                                          _snapShot["image"])
                                                      : AssetImage(
                                                          "assets/images/logo.jpg")),
                                          context: context,
                                          title: "Profil Resmi Resmi Yükle",
                                          desc: "Lütfen Yükleme Tipini Seçiniz",
                                          buttons: [
                                            DialogButton(
                                                width: double.infinity,
                                                child: Text("Kamera",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white)),
                                                onPressed: () async {
                                                  var image = await ImagePicker
                                                      .pickImage(
                                                          source: ImageSource
                                                              .camera);

                                                  setState(() {
                                                    _image = image;
                                                  });

                                                  StorageReference _refStorage =
                                                      _firebaseStorage
                                                          .ref()
                                                          .child("users")
                                                          .child("user")
                                                          .child("profile")
                                                          .child(
                                                              _snapShot["id"]);

                                                  StorageUploadTask
                                                      _uploadTask = _refStorage
                                                          .putFile(_image);

                                                  _imageUrl =
                                                      await (await _uploadTask
                                                              .onComplete)
                                                          .ref
                                                          .getDownloadURL();

                                                  _firestore.runTransaction(
                                                      (transaction) {
                                                    var docRef = _firestore
                                                        .document("users/" +
                                                            _snapShot["id"]);
                                                    transaction.update(docRef,
                                                        {"image": _imageUrl});
                                                    return null;
                                                  }).catchError((hata) {
                                                    debugPrint(
                                                        "Hata Kodu: " + hata);
                                                  });

                                                  Navigator.pop(context);
                                                }),
                                            DialogButton(
                                                width: double.infinity,
                                                child: Text(
                                                  "Kütüphane",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      color: Colors.white),
                                                ),
                                                onPressed: () async {
                                                  var image = await ImagePicker
                                                      .pickImage(
                                                          source: ImageSource
                                                              .gallery);

                                                  setState(() {
                                                    _image = image;
                                                  });
                                                  StorageReference _refStorage =
                                                      _firebaseStorage
                                                          .ref()
                                                          .child("users")
                                                          .child("user")
                                                          .child("profile")
                                                          .child(
                                                              _snapShot["id"]);

                                                  StorageUploadTask
                                                      _uploadTask = _refStorage
                                                          .putFile(_image);

                                                  _imageUrl =
                                                      await (await _uploadTask
                                                              .onComplete)
                                                          .ref
                                                          .getDownloadURL();

                                                  _firestore.runTransaction(
                                                      (transaction) {
                                                    var docRef = _firestore
                                                        .document("users/" +
                                                            _snapShot["id"]);
                                                    transaction.update(docRef,
                                                        {"image": _imageUrl});
                                                    return null;
                                                  }).catchError((hata) {
                                                    debugPrint(
                                                        "Hata Kodu: " + hata);
                                                  });
                                                  Navigator.pop(context);

                                                })
                                          ]).show();
                                    },
                                    child: Stack(
                                      children: <Widget>[
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.blue.shade900)),
                                          child: CircleAvatar(
                                            backgroundImage:
                                                _snapShot["image"] == null
                                                    ? AssetImage(
                                                        "assets/images/logo.jpg",
                                                      )
                                                    : NetworkImage(
                                                        _snapShot["image"]),
                                            radius: 20,
                                            backgroundColor: Colors.purple,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            child: CircleAvatar(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Icon(Icons.photo_camera,
                                                  color: Colors.black54,
                                                  size: 28),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Text(
                        "Kayıt Bulunamadı",
                        style: TextStyle(color: Colors.red, fontSize: 24),
                      ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _kayitEkle() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      String _id = _firestore.collection("users").document().documentID;

      Map<String, dynamic> _user = Map();
      _user["id"] = _id;
      _user["name"] = _name;
      _user["lastname"] = _lastname;
      _user["email"] = _email;
      _user["password"] = _password;
      _user["driveLicense"] = _driveLicense;
      _user["driveType"] = _driveLicenseType;
      _user["dateTime"] = FieldValue.serverTimestamp();
      _user["views"] = 0;
      _user["likes"] = 0;
      _user["image"] = null;

      _firestore.document("users/$_id").setData(_user).then((value) {
        Alert(
            context: context,
            title: "Kayıt Eklendi",
            type: AlertType.success,
            buttons: [
              DialogButton(
                  child: Text(
                    "Kapat",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ]).show();

        _formKey.currentState.reset();
        setState(() {
          _driveLicenseType = null;
          _driveLicense = false;
        });
      }).catchError((hata) {
        Alert(
            context: context,
            title: "Kayıt Eklenemedi",
            type: AlertType.warning,
            buttons: [
              DialogButton(
                  child: Text(
                    "Kapat",
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ]).show();
      });
    }
  }

  _getDocSnap() {
    _firestore.collection("users").snapshots().listen((snap) {
      setState(() {
        _documentSnapshot = snap.documents;
      });
    });
  }
}
