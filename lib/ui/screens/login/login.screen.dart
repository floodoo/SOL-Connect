import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/exceptions.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table/time_table.screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static final routeName = (LoginScreen).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController usernameController = TextEditingController(text: ref.watch(timeTableService).username);
    final TextEditingController passwordController = TextEditingController(text: ref.watch(timeTableService).password);
    final _timeTableService = ref.read(timeTableService);
    final _isLoggedIn = ref.watch(timeTableService).isLoggedIn;
    final _isLoading = ref.watch(timeTableService).isLoading;
    final _loginError = ref.watch(timeTableService).loginError;
    String? loginErrorMessage;

    if (_isLoggedIn) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, TimeTableScreen.routeName);
      });
    }

    if (_loginError != null) {
      if (_loginError is WrongCredentialsException) {
        loginErrorMessage = "Incorrect username or password";
      } else if (_loginError is MissingCredentialsException) {
        loginErrorMessage = "Missing username or password";
      } else {
        loginErrorMessage = "Please check your internet connection";
      }
    }

    void _login() {
      _timeTableService.toggleLoading(true);
      _timeTableService.login(usernameController.text, passwordController.text);
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
                        "Untis Login",
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
                          hintText: "Benutzername",
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
                          hintText: "Passwort",
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                    ),
                    if (loginErrorMessage != null)
                      Text(
                        loginErrorMessage,
                        style: const TextStyle(color: Colors.red),
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
