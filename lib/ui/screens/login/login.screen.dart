import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/exceptions.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table/time_table.screen.dart';
import 'package:untis_phasierung/util/user_secure_stotage.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static final routeName = (LoginScreen).toString();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    final _timeTableService = ref.read(timeTableService);

    final _isLoggedIn = ref.watch(timeTableService).isLoggedIn;
    final _isLoading = ref.watch(timeTableService).isLoading;
    final _loginError = ref.watch(timeTableService).loginError;

    final TextEditingController usernameController = TextEditingController(text: ref.watch(timeTableService).username);
    final TextEditingController passwordController = TextEditingController(text: ref.watch(timeTableService).password);
    usernameController.selection = TextSelection.fromPosition(TextPosition(offset: usernameController.text.length));
    passwordController.selection = TextSelection.fromPosition(TextPosition(offset: passwordController.text.length));

    String? loginErrorMessage;

    if (_isLoggedIn) {
      Future.delayed(Duration.zero, () => Navigator.pushReplacementNamed(context, TimeTableScreen.routeName));
    }

    if (_loginError != null) {
      if (_loginError is WrongCredentialsException) {
        loginErrorMessage = "Benutzername oder Passwort falsch";
      } else if (_loginError is MissingCredentialsException) {
        loginErrorMessage = "Fehlender Benutzername oder Passwort";
      } else {
        loginErrorMessage = "Bitte überprüfe deine Internetverbindung";
      }
    }

    void _login(String username, String password) {
      _timeTableService.toggleIsLoading(true);
      _timeTableService.login(username, password);
    }

    void checkAutoLogin() async {
      UserSecureStorage.getPassword().then(
        (password) {
          UserSecureStorage.getUsername().then(
            (username) {
              if (password != null && username != null && _isLoading == false) {
                _login(username, password);
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
        color: theme.mode == ThemeMode.light ? theme.colors.primary : theme.colors.background,
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
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
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
