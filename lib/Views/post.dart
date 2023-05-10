import 'package:crud_operations/Views/upload_images.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'add_post.dart';

class Post_Screen extends StatefulWidget {
  const Post_Screen({Key? key}) : super(key: key);

  @override
  State<Post_Screen> createState() => _Post_ScreenState();
}

class _Post_ScreenState extends State<Post_Screen> {
  final auth = FirebaseAuth.instance;
  final ref = FirebaseDatabase.instance.ref('Post');
  final editController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1E425D),
        title: Text("Post"),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 25.0),
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: FloatingActionButton(
            backgroundColor: Color(0xff1E425D),
            shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => Add_Post_Sceen()));
            },
            child: Text("Add Data to Firebase"),
          ),
        ),
      ),

      body: Column(
        children: [
          UploadImageScreen(),
          Expanded(
            child: StreamBuilder(
                stream: ref.onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  } else {
                    Map<dynamic, dynamic> map =
                        snapshot.data!.snapshot.value as dynamic;
                    List<dynamic> list = [];
                    list.clear();
                    list = map.values.toList();
                    return ListView.builder(
                        itemCount: snapshot.data!.snapshot.children.length,
                        itemBuilder: (context, index) {
                          final title = list[index]['title'];
                          return ListTile(
                            title: Text(list[index]['title'].toString()),
                            subtitle: Text(list[index]['id'].toString()),
                            trailing: PopupMenuButton(
                              icon: Icon(Icons.more_vert),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 1,
                                  child: ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text("Edit"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      ShowMyDialog(title, list[index]['id']);
                                    },
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 2,
                                  child: ListTile(
                                    leading: Icon(Icons.delete_outline),
                                    title: Text("Delete"),
                                    onTap: () {
                                      ref.child(list[index]['id'].toString()).remove();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  }
                }),
          ),

          // Expanded(
          //   child: FirebaseAnimatedList(
          //       query: ref,
          //       defaultChild: Text("Loading"),
          //       itemBuilder: (context,snapshot,animation,index){
          //         return ListTile(
          //           title: Text(snapshot.child('id').value.toString()),
          //           subtitle: Text(snapshot.child('title').value.toString()),
          //         );
          //       }
          //   ),
          // ),
          SizedBox(
            height: 80,
          ),
        ],
      ),
    );
  }

  Future<void> ShowMyDialog(String title, String id) async {
    editController.text = title;
    return showDialog(
      context: context,
      builder: (BuildContext Context) {
        return AlertDialog(
          title: Text("Update"),
          content: Container(
            child: TextField(
              controller: editController,
              decoration: InputDecoration(
                hintText: "Edit",
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel")),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.child(id).update({
                    'title': editController.text.toLowerCase(),
                  }).then((value) {
                    Fluttertoast.showToast(msg: "Post Updated");
                  }).onError((error, stackTrace) {
                    Fluttertoast.showToast(msg: error.toString());
                  });
                },
                child: Text("Update")),
          ],
        );
      },
    );
  }
}
