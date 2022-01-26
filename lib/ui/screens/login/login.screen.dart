import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:untis_phasierung/core/exceptions.dart';
import 'package:untis_phasierung/core/service/services.dart';
import 'package:untis_phasierung/ui/screens/time_table/time_table.screen.dart';
import 'package:untis_phasierung/util/user_secure_stotage.dart';

class LoginScreen extends ConsumerWidget {
  LoginScreen({Key? key}) : super(key: key);
  static final routeName = (LoginScreen).toString();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController schoolNameController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeService).theme;

    final _timeTableService = ref.read(timeTableService);

    final _isLoggedIn = ref.watch(timeTableService).isLoggedIn;
    final _isLoading = ref.watch(timeTableService).isLoading;
    final _loginError = ref.watch(timeTableService).loginError;

    usernameController.text = ref.watch(timeTableService).username;
    passwordController.text = ref.watch(timeTableService).password;
    schoolNameController.text = ref.watch(timeTableService).schoolName;
    usernameController.selection = TextSelection.fromPosition(TextPosition(offset: usernameController.text.length));
    passwordController.selection = TextSelection.fromPosition(TextPosition(offset: passwordController.text.length));
    schoolNameController.selection = TextSelection.fromPosition(TextPosition(offset: schoolNameController.text.length));

    String? loginErrorMessage;

    if (_isLoggedIn) {
      Future.delayed(Duration.zero, () => Navigator.pushReplacementNamed(context, TimeTableScreen.routeName));
      ref.read(timeTableService).isLoggedIn = false;
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

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                theme.colors.loginBackgroundGradient1,
                theme.colors.loginBackgroundGradient2,
              ],
            )
          ),
          //color: theme.mode == ThemeMode.light ? theme.colors.primary : theme.colors.background,
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: MediaQuery.of(context).size.height / 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colors.background,
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 8,
                        offset: Offset(0, 0.8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0, top: 26.0),
                              child: Text(
                                "Login",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 30, color: theme.colors.textBackground, fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(padding: const EdgeInsets.only(bottom: 15),
                              child: Text(
                                "Melde dich mit deinem Schulkonto an.",
                                style: TextStyle(fontSize: 13, color: theme.colors.textLightInverted),
                                ),
                            ),
                          ],
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
                            onChanged: (value) {
                              ref.read(timeTableService).setUsername(value);
                            },
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: "Benutzername",
                              prefixIcon: Icon(Icons.person, color: theme.colors.textInverted),
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
                            onChanged: (value) {
                              ref.read(timeTableService).setPassword(value);
                            },
                            obscureText: true,
                            autocorrect: false,
                            decoration: InputDecoration(
                              hintText: "Passwort",
                              prefixIcon: Icon(Icons.lock, color: theme.colors.textInverted,),
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
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
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
                          onTap: () {
                            if (_isLoading == false) {
                              _login(usernameController.text, passwordController.text);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                  child: ListTile(
                    title: TextField(
                      controller: schoolNameController,
                      onChanged: (value) {
                        ref.read(timeTableService).saveSchoolName(value);
                      },
                      textAlignVertical: TextAlignVertical.center,
                      autocorrect: false,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        hintText: ref.watch(timeTableService).schoolName,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
