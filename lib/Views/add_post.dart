import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Add_Post_Sceen extends StatefulWidget {
  const Add_Post_Sceen({Key? key}) : super(key: key);

  @override
  State<Add_Post_Sceen> createState() => _Add_Post_SceenState();
}

class _Add_Post_SceenState extends State<Add_Post_Sceen> {
  bool loading = false;
  final postController = TextEditingController();
  final databaserRef = FirebaseDatabase.instance.ref('Post');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1E425D),
        title: Text("Add Post Data"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextFormField(
              controller: postController,
              maxLines: 2,
              decoration: InputDecoration(
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  helperText: 'What is in your mind?'),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width/2,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(Color(0xff1E425D)),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)))),
                // loading:loading,
                onPressed: () {
                  String id = DateTime.now().millisecondsSinceEpoch.toString();
                  databaserRef.child(id).set({
                    'id': id,
                    'Name': postController.text.toString(),
                    'title': postController.text.toString(),
                    // 'profile': '',
                  }).then((value) {
                    setState(() {
                      loading = false;
                    });
                    Fluttertoast.showToast(
                        msg: "Post Added",
                        // toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0);
                  }).onError((error, stackTrace) {
                    Fluttertoast.showToast(
                        msg: error.toString(),
                        gravity: ToastGravity.CENTER,
                        timeInSecForIosWeb: 1,
                        textColor: Colors.white,
                        fontSize: 16.0);
                    setState(() {
                      loading = false;
                    });
                  });
                  setState(() {
                    loading = true;
                  });
                },
                child: Text("Add Data")),
          ),
        ],
      ),
    );
  }
}
