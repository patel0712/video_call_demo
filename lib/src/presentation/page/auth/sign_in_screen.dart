import 'package:bloc_clean_architecture/src/comman/constant.dart';
import 'package:bloc_clean_architecture/src/comman/enum.dart';
import 'package:bloc_clean_architecture/src/comman/routes.dart';
import 'package:bloc_clean_architecture/src/comman/toast.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/authenticator_watcher/authenticator_watcher_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/bloc/sign_in_form/sign_in_form_bloc.dart';
import 'package:bloc_clean_architecture/src/presentation/widget/custom_elevated_button.dart';
import 'package:bloc_clean_architecture/src/presentation/widget/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignInFormBloc, SignInFormState>(
      listener: (context, state) {
        if (state.state == RequestState.loaded) {
          // Show success message
          showToast(
            msg: 'Login successful!',
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );

          // Trigger authentication check and redirect to dashboard
          context.read<AuthenticatorWatcherBloc>().add(
                const AuthenticatorWatcherEvent.authCheckRequest(),
              );

          // Navigate to dashboard
          context.go(AppRoutes.DASHBOARD_ROUTE_PATH);
        }
        if (state.state == RequestState.error) {
          showToast(
            msg: state.message.isNotEmpty
                ? state.message
                : 'Login failed. Please try again.',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: MARGIN),
              child: Center(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const SizedBox(height: 50),
                      _buildHeader(context),
                      const SizedBox(height: SPACE25),
                      _buildTestCredentials(context),
                      const SizedBox(height: SPACE25),
                      CustomTextFormField(
                        hintText: 'Email',
                        textFieldType: TextFieldType.email,
                        prefixIcon: const Icon(Icons.mail),
                        onChanged: (v) {
                          context.read<SignInFormBloc>().add(
                                SignInFormEvent.emailOnChanged(v),
                              );
                        },
                      ),
                      const SizedBox(height: SPACE15),
                      CustomTextFormField(
                        obscureText: _obscureText,
                        hintText: 'Password',
                        textFieldType: TextFieldType.password,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: Icon(
                            _obscureText
                                ? FontAwesomeIcons.eye
                                : FontAwesomeIcons.eyeSlash,
                          ),
                        ),
                        onChanged: (v) {
                          context.read<SignInFormBloc>().add(
                                SignInFormEvent.passwordOnChanged(v),
                              );
                        },
                      ),
                      const SizedBox(height: SPACE25),
                      _buildForgotPassword(context),
                      const SizedBox(height: SPACE25),
                      CustomElevatedButton(
                        onTap: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<SignInFormBloc>().add(
                                  const SignInFormEvent.signInWithEmail(),
                                );
                          }
                        },
                        isLoading: (state.state == RequestState.loading)
                            ? true
                            : false,
                        labelLoading: 'Signing...',
                        label: 'Sign In',
                      ),
                      const SizedBox(height: SPACE25),
                      _buildDivider(context),
                      const SizedBox(height: SPACE12),
                      _buildOtherSignOption(context),
                      const SizedBox(height: SPACE12),
                      _buildRegisterButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Logo',
            style: GoogleFonts.pacifico(
              fontSize: 40,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: SPACE12),
          Text(
            'Welcome to Back',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: SPACE4),
          Text(
            'Sign in to continue',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTestCredentials(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Credentials:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Email: test@example.com\nPassword: password123',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Or use ReqRes API: eve.holt@reqres.in / cityslicka',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () {
          // Navigator.pushNamed(
          //   context,
          //   FORGOT_PASSWORD,
          // );
        },
        child: Text(
          'Forgot Password?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            width: double.infinity,
            height: .5,
            color: theme.disabledColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text('Or sign in with',
              style: TextStyle(color: theme.primaryColor)),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            height: .5,
            color: theme.disabledColor,
          ),
        ),
      ],
    );
  }

  Widget _buildOtherSignOption(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            FontAwesomeIcons.google,
            size: 30,
            color: Colors.white,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            FontAwesomeIcons.apple,
            size: 30,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Don\'t have an account?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(width: SPACE8),
        GestureDetector(
          onTap: () {
            context.goNamed(AppRoutes.SIGNUP_ROUTE_NAME);
          },
          child: Text(
            'Register',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
      ],
    );
  }
}
