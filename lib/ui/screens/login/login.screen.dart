import 'package:flutter/material.dart';
import 'package:untis_phasierung/ui/screens/time_table/time_table.screen.dart';
import 'package:untis_phasierung/ui/screens/time_table/widgets/time_table.arguments.dart';
import 'package:untis_phasierung/core/api/usersession.dart';
import 'package:untis_phasierung/util/logger.util.dart';
import 'package:untis_phasierung/util/user_secure_stotage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static final routeName = (LoginScreen).toString();

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final log = getLogger();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  loadUserData() async {
    final storedUsername = await UserSecureStorage.getUsername();
    final storedPassword = await UserSecureStorage.getPassword();

    setState(() {
      usernameController.text = storedUsername ?? "";
      passwordController.text = storedPassword ?? "";
    });
  }

  setUserData(String username, String password) async {
    await UserSecureStorage.setUsername(username);
    await UserSecureStorage.setPassword(password);
  }

  @override
  Widget build(BuildContext context) {
    void _login() async {
      setState(() {
        _isLoading = true;
      });

      await UserSecureStorage.setUsername(usernameController.text);
      UserSession session = UserSession(school: "bbs1-mainz", appID: "untis-phasierung");
      session.createSession(username: usernameController.text, password: passwordController.text).then(
        (value) {
          Navigator.pushReplacementNamed(context, TimeTableScreen.routeName, arguments: TimetableArguments(session));
          log.i("Successfully logged in");
        },
      ).catchError(
        (error) {
          log.e("Error logging in: $error");

          if (error.toString() == "Exception: Benutzename oder Passwort falsch") {
            log.d("Clearing user data");
            UserSecureStorage.clear();
          }
          setState(() {
            _isLoading = false;
          });
        },
      );
      setUserData(usernameController.text, passwordController.text);
      usernameController.clear();
      passwordController.clear();
    }

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
          physics: const NeverScrollableScrollPhysics(),
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
                      padding: EdgeInsets.only(bottom: 10.0, top: 20.0),
                      child: Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
                      child: TextField(
                        controller: usernameController,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "User",
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
                      child: TextField(
                        controller: passwordController,
                        onEditingComplete: () => _login(),
                        obscureText: true,
                        autocorrect: false,
                        decoration: const InputDecoration(
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
                            color: Colors.blue,
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (_isLoading)
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        onTap: () => _login(),
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
  }
}
