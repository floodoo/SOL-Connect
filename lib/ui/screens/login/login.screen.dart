import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/exceptions.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table/time_table.screen.dart';
import 'package:untis_phasierung/util/user_secure_stotage.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({Key? key}) : super(key: key);
  static final routeName = (LoginScreen).toString();
  int autoLoginCounter = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController usernameController = TextEditingController(text: ref.watch(timeTableService).username);
    final TextEditingController passwordController = TextEditingController(text: ref.watch(timeTableService).password);
    final _timeTableService = ref.read(timeTableService);
    final _isLoggedIn = ref.watch(timeTableService).isLoggedIn;
    final _isLoading = ref.watch(timeTableService).isLoading;
    final _loginError = ref.watch(timeTableService).loginError;
    final theme = ref.watch(themeService).theme;

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

    void _login(String username, String password) {
      _timeTableService.toggleLoading(true);
      _timeTableService.login(username, password);
    }

    void checkAutoLogin() async {
      UserSecureStorage.getPassword().then(
        (password) {
          UserSecureStorage.getUsername().then(
            (username) {
              if (password != null && username != null && _isLoading == false && autoLoginCounter <= 1) {
                _login(username, password);
                autoLoginCounter++;
              }
            },
          );
        },
      );
    }

    checkAutoLogin();

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
                  color: theme.colors.background,
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
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0, top: 20.0),
                      child: Text(
                        "Untis Login",
                        style: TextStyle(fontSize: 30, color: theme.colors.textBackground),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
                      child: Focus(
                        onFocusChange: (value) {
                          if (value == false) {
                            ref.read(timeTableService).setUsername(usernameController.text);
                          }
                        },
                        child: TextField(
                          controller: usernameController,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            hintText: "Benutzername",
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
                      child: Focus(
                        onFocusChange: (value) {
                          if (value == false) {
                            ref.read(timeTableService).setPassword(passwordController.text);
                          }
                        },
                        child: TextField(
                          controller: passwordController,
                          onEditingComplete: () => _login(usernameController.text, passwordController.text),
                          obscureText: true,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            hintText: "Passwort",
                            prefixIcon: Icon(Icons.lock),
                          ),
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
                          decoration: BoxDecoration(
                            color: theme.colors.primary,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(20),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              (_isLoading)
                                  ? CircularProgressIndicator(
                                      color: theme.colors.icon,
                                    )
                                  : Text(
                                      "Login",
                                      style: TextStyle(
                                        color: theme.colors.text,
                                        fontSize: 20,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        onTap: () => _login(usernameController.text, passwordController.text),
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
