import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sol_connect/core/exceptions.dart';
import 'package:sol_connect/core/service/services.dart';
import 'package:sol_connect/ui/screens/time_table/time_table.screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static final routeName = (LoginScreen).toString();

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final twoFactorController = TextEditingController();
  final schoolController = TextEditingController(text: "bbs1-mainz");
  final passwordFocusNode = FocusNode();
  final schoolFocusNode = FocusNode();

  @override
  void initState() {
    getUserDataFromStorage();
    schoolFocusNode.addListener(onSchoolFocusChange);
    super.initState();
  }

  void onSchoolFocusChange() {
    ref.read(timeTableService).setIsChangingSchool(schoolFocusNode.hasFocus);
  }

  Future<void> getUserDataFromStorage() async {
    final username = await ref.read(timeTableService).getUserName();
    final password = await ref.read(timeTableService).getPassword();
    const school = "bbs1-mainz";

    usernameController.text = username;
    passwordController.text = password;
    schoolController.text = "bbs1-mainz";

    if (username.isNotEmpty && password.isNotEmpty && school.isNotEmpty) {
      ref.read(timeTableService).login(
            username: username,
            password: password,
            school: school,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeTableServiceInstance = ref.read(timeTableService);
    final theme = ref.watch(themeService).theme;
    final loginError = ref.watch(timeTableService).loginException;
    final twoFactorAuth = ref.watch(timeTableService).twoFactorAuth;

    String? loginErrorMessage;

    if (loginError != null) {
      passwordController.clear();

      if (loginError is WrongCredentialsException) {
        loginErrorMessage = "Benutzername oder Passwort falsch";
      } else if (loginError is MissingCredentialsException) {
        loginErrorMessage = "Fehlender Benutzername oder Passwort";
      } else if (loginError is ApiConnectionError) {
        loginErrorMessage = loginError.cause;
      } else if (loginError is SecurityTokenRequired) {
        loginErrorMessage = loginError.cause;
      } else if (loginError is InvalidSecurityToken) {
        loginErrorMessage = loginError.cause;
      } else {
        loginErrorMessage = "Bitte überprüfe deine Internetverbindung";
      }
    }

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        // School text field should not be on top of the keyboard, if it isn't focused
        resizeToAvoidBottomInset: ref.watch(timeTableService).isChangingSchool,
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
            ),
          ),
          child: Column(
            children: [
              Expanded(
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
                                      style: TextStyle(
                                          fontSize: 30,
                                          color: theme.colors.textBackground,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 15),
                                    child: Text(
                                      "Melde dich mit deinem Schulkonto an.",
                                      style: TextStyle(fontSize: 13, color: theme.colors.textLightInverted),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            twoFactorAuth
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
                                    child: TextField(
                                      obscureText: false,
                                      autocorrect: false,
                                      controller: twoFactorController,
                                      cursorColor: theme.colors.textInverted,
                                      decoration: InputDecoration(
                                        hintText: "2 Faktor code",
                                        prefixIcon: Icon(
                                          Icons.lock_clock,
                                          color: theme.colors.textInverted,
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(color: theme.colors.textInverted),
                                        ),
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
                                        child: TextField(
                                          autocorrect: false,
                                          onEditingComplete: () =>
                                              FocusScope.of(context).requestFocus(passwordFocusNode),
                                          controller: usernameController,
                                          cursorColor: theme.colors.textInverted,
                                          decoration: InputDecoration(
                                            hintText: "Benutzername",
                                            prefixIcon: Icon(Icons.person, color: theme.colors.textInverted),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: theme.colors.textInverted),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
                                        child: TextField(
                                          obscureText: true,
                                          autocorrect: false,
                                          focusNode: passwordFocusNode,
                                          controller: passwordController,
                                          cursorColor: theme.colors.textInverted,
                                          decoration: InputDecoration(
                                            hintText: "Passwort",
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color: theme.colors.textInverted,
                                            ),
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(color: theme.colors.textInverted),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            if (loginErrorMessage != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                loginErrorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: InkWell(
                                onTap: () {
                                  timeTableServiceInstance.login(
                                    username: usernameController.text,
                                    password: passwordController.text,
                                    school: schoolController.text,
                                    twoFactorAuthToken: twoFactorController.text,
                                  );
                                  timeTableServiceInstance.setIsChangingSchool(false);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colors.primary,
                                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(13)),
                                  ),
                                  // Consumer Widget to avoid re-rendering the whole widget
                                  child: Consumer(
                                    builder: (context, ref, _) {
                                      if (ref.watch(timeTableService).isLoggedIn) {
                                        // Hack so i don't get an error on pushing
                                        Future.delayed(
                                          Duration.zero,
                                          () => Navigator.pushReplacementNamed(context, TimeTableScreen.routeName),
                                        );
                                      }
                                      return SizedBox(
                                        height: 70,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            if (ref.watch(timeTableService).isLoading)
                                              CircularProgressIndicator(
                                                color: theme.colors.icon,
                                              )
                                            else ...[
                                              Text(
                                                "Login",
                                                style: TextStyle(
                                                  color: theme.colors.text,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ]
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !twoFactorAuth,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
                  child: TextField(
                    controller: schoolController,
                    textAlignVertical: TextAlignVertical.center,
                    autocorrect: false,
                    focusNode: schoolFocusNode,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.colors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Deine Schul-ID",
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
