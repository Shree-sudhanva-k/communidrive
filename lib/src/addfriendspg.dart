import 'package:communidrive/src/homepage.dart';
import 'package:flutter/material.dart';

class AddFriend extends StatefulWidget {
  final String phoneNumber;
  const AddFriend({super.key, required this.phoneNumber});

  @override
  State<AddFriend> createState() => _AddFriendState();
}

class _AddFriendState extends State<AddFriend> {
  String _phoneno = '';
  _AddFriendState();

  @override
  void initState() {
    super.initState();
    _phoneno = widget.phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("CommuniDrive!")),
        backgroundColor: const Color.fromARGB(230, 223, 222, 215),
        leading: const Icon(Icons.menu),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.logout)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20, // Number of columns
          children: <Widget>[
            Container(
                color: const Color.fromARGB(255, 239, 142, 122),
                height: 50,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Image.network(
                          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmvJ14anYdkKq4d0LRhRh0a_u_Kh6DUQGHsQ&s",
                          width: 70,
                        ),
                      ),
                    ),
                    const Text("SHREYAS",
                        style: TextStyle(color: Colors.black87, fontSize: 20)),
                    ElevatedButton(
                        onPressed: () {}, child: const Text("ADD FRIEND +"))
                  ],
                )),
            Container(
              color: const Color.fromARGB(255, 239, 142, 122),
              height: 50,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmvJ14anYdkKq4d0LRhRh0a_u_Kh6DUQGHsQ&s",
                        width: 70,
                      ),
                    ),
                  ),
                  const Text("SHREYAS",
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                  ElevatedButton(
                      onPressed: () {}, child: const Text("ADD FRIEND +"))
                ],
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 239, 142, 122),
              height: 50,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmvJ14anYdkKq4d0LRhRh0a_u_Kh6DUQGHsQ&s",
                        width: 70,
                      ),
                    ),
                  ),
                  const Text("SHREYAS",
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                  ElevatedButton(
                      onPressed: () {}, child: const Text("ADD FRIEND +"))
                ],
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 239, 142, 122),
              height: 50,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmvJ14anYdkKq4d0LRhRh0a_u_Kh6DUQGHsQ&s",
                        width: 70,
                      ),
                    ),
                  ),
                  const Text("SHREYAS",
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                  ElevatedButton(
                      onPressed: () {}, child: const Text("ADD FRIEND +"))
                ],
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 239, 142, 122),
              height: 50,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmvJ14anYdkKq4d0LRhRh0a_u_Kh6DUQGHsQ&s",
                        width: 70,
                      ),
                    ),
                  ),
                  const Text("SHREYAS",
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                  ElevatedButton(
                      onPressed: () {}, child: const Text("ADD FRIEND +"))
                ],
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 239, 142, 122),
              height: 50,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmvJ14anYdkKq4d0LRhRh0a_u_Kh6DUQGHsQ&s",
                        width: 70,
                      ),
                    ),
                  ),
                  const Text("SHREYAS",
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                  ElevatedButton(
                      onPressed: () {}, child: const Text("ADD FRIEND +"))
                ],
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 239, 142, 122),
              height: 50,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmvJ14anYdkKq4d0LRhRh0a_u_Kh6DUQGHsQ&s",
                        width: 70,
                      ),
                    ),
                  ),
                  const Text("SHREYAS",
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                  ElevatedButton(onPressed: () {}, child: Text("ADD FRIEND +"))
                ],
              ),
            ),
            Container(
              color: const Color.fromARGB(255, 239, 142, 122),
              height: 20,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: Image.network(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRmvJ14anYdkKq4d0LRhRh0a_u_Kh6DUQGHsQ&s",
                        width: 70,
                      ),
                    ),
                  ),
                  const Text("SHREYAS",
                      style: TextStyle(color: Colors.black87, fontSize: 20)),
                  ElevatedButton(
                      onPressed: () {}, child: const Text("ADD FRIEND +"))
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomePage(
                              phoneNumber: _phoneno,
                            )));
              },
              child: const Text("submit"),
            )
          ],
        ),
      ),
    );
  }
}
