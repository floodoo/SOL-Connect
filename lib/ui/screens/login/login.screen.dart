import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: MediaQuery.of(context).size.height / 6),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 7,
                      offset: Offset(0, 0.8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "User",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
                      child: TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: InkWell(
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {},
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    // return Stack(
    //   children: [
    //     Column(
    //       children: [
    //         Expanded(
    //           child: Container(
    //             color: Colors.blue,
    //           ),
    //         ),
    //         Expanded(
    //           flex: 2,
    //           child: Container(
    //             color: Colors.white,
    //           ),
    //         ),
    //       ],
    //     ),
    //     Center(
    //       child: Card(
    //         color: Colors.green,
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(20.0),
    //         ),
    //         child: ListTile(
    //           title: Column(
    //             children: [
    // TextField(
    //   style: const TextStyle(color: Colors.white),
    //   decoration: InputDecoration(
    //     hintText: "Username",
    //     hintStyle: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
    //     fillColor: Colors.cyan[900],
    //     filled: true,
    //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide.none),
    //   ),
    // ),
    //               TextField(
    //                 style: const TextStyle(color: Colors.white),
    //                 decoration: InputDecoration(
    //                   hintText: "Password",
    //                   hintStyle: const TextStyle(fontStyle: FontStyle.italic, color: Colors.white),
    //                   fillColor: Colors.cyan[900],
    //                   filled: true,
    //                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(25.0), borderSide: BorderSide.none),
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //       ),
    //     )
    //   ],
    // );
  }
}
