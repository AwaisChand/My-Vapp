import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/components/app_button.dart';
import 'package:provider/provider.dart';

import '../../../res/components/app_text_field.dart';
import '../../../utils/utils.dart';
import '../../../view_models/auth_view_model/auth_view_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final currentPasswordController = TextEditingController();

  final newPasswordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, auth, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/background_img.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20, top: 50),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.arrow_back_ios_new_outlined,
                            ),
                          ),
                          Flexible(
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Settings",
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: Utils.setHeight(context) * 0.2),
                      AppTextField(
                        controller: currentPasswordController,
                        hintText: "Enter current password",
                        textInputType: TextInputType.visiblePassword,
                        isPassword: true,
                      ),
                      SizedBox(height: 20),
                      AppTextField(
                        controller: newPasswordController,
                        hintText: "Enter new password",
                        textInputType: TextInputType.visiblePassword,
                        isPassword: true,
                      ),
                      SizedBox(height: 20),
                      AppTextField(
                        controller: confirmPasswordController,
                        hintText: "Confirm Password",
                        textInputType: TextInputType.visiblePassword,
                        isPassword: true,
                      ),
                      SizedBox(height: 25),
                      AppButton(
                        btnText: "Update",
                        isLoading: auth.isLoading,
                        onPressed: () {
                          if (currentPasswordController.text.isEmpty) {
                            Utils.toastMessage('Please Enter Current Password');
                          } else if (newPasswordController.text.isEmpty) {
                            Utils.toastMessage('Please Enter New password');
                          } else if (newPasswordController.text.length < 8) {
                            Utils.toastMessage('Please Enter 8 digit password');
                          } else if (newPasswordController.text !=
                              confirmPasswordController.text) {
                            Utils.toastMessage('Password does not match');
                          } else {
                            Map data = {
                              'current_password':
                                  currentPasswordController.text.toString(),
                              'new_password':
                                  newPasswordController.text.toString(),
                              'new_password_confirmation':
                                  confirmPasswordController.text.toString(),
                            };
                            auth.settingsApi(context, data);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
