import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'as firebase_storage;

class UploadImageScreen extends StatefulWidget {
  const UploadImageScreen({Key? key}) : super(key: key);

  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  bool loading = false;
  File?_image;
  final picker=ImagePicker();
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
  DatabaseReference databaseRef =FirebaseDatabase.instance.ref('Post');

  Future getImageGallery()async{
    final pickedFile = await picker.pickImage(source: ImageSource.gallery,imageQuality: 80);
      if(pickedFile!= null){
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Cropper',
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );
        setState(() {
          _image = File(croppedFile!.path);
        });

      }
      else{
        print("No Image is Selected");
      }

  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          InkWell(
            onTap: (){
              getImageGallery();
            },
            child: Container(
              child: _image!= null ? ClipRRect(
                borderRadius: BorderRadius.circular(150),
                  child: Image.file(_image!.absolute,height: 150,width: 150,fit: BoxFit.cover,
                  ))
                  :ClipRRect(
                borderRadius: BorderRadius.circular(150),
                  child: Image.asset("Assets/Images/add-user.png",height: 150,width: 150,fit: BoxFit.cover,)
              ),
            ),
          ),

          SizedBox(
            height: 15,
          ),
          Container(
              height: 50,
            width: MediaQuery.of(context).size.width/2,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0xff1E425D)),
                shape: MaterialStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))),
              ),
                onPressed: () async{
                  setState(() {
                   loading=true;
                  });
                  Future.delayed(Duration(seconds: 4),(){
                    setState(() {
                      loading=false;
                    });
                  });
                  firebase_storage.Reference ref =firebase_storage.FirebaseStorage.instance.ref('/ProfileImages/'+DateTime.now().millisecondsSinceEpoch.toString());
                  firebase_storage.UploadTask uploadTask = ref.putFile(_image!.absolute);

                   Future.value(uploadTask).then((value) async{
                     var newUrl =await ref.getDownloadURL();
                     databaseRef.child('1').set({
                       'id':'1221',
                       'title':newUrl.toString()
                     }).then((value) {
                       setState(() {
                         loading=false;
                       });
                       Fluttertoast.showToast(msg: "Uploaded");
                     }).onError((error, stackTrace) {
                       setState(() {
                         loading=false;
                       });
                     });

                   }).onError((error, stackTrace) {
                     Fluttertoast.showToast(msg: error.toString());
                     setState(() {
                       loading=false;
                     });
                   });
                },
                child: loading? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Loading.....",style: TextStyle(fontSize: 20),),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(color: Colors.white,),
                    ),
                  ],
                ):Text("UPLOAD")),
          ),
        ],
      ),
    );
  }
}
