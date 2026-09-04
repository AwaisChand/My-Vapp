import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/res/components/app_button.dart';
import 'package:lim_crm/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import '../../../res/app_assets.dart';
import '../../../utils/app_colors.dart';
import '../../../view_models/auth_view_model/auth_view_model.dart';

class VerifyOtpScreen extends StatefulWidget {
  const VerifyOtpScreen({super.key, this.email});

  final String? email;



  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final emailController = TextEditingController();

  final otpControllers = List.generate(4, (index) => TextEditingController());



  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      emailController.text = widget.email!;
    }
  }
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image(
                                  image: AssetImage(AppAssets.appLogo),
                                  fit: BoxFit.fill,
                                  height: 140,
                                ),
                              ),
                            ),
                            SizedBox(height: 50),
                            Text(
                              "Email",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.darkGrayColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                emailController.text,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(4, (index) {
                          return SizedBox(
                            width: 60,
                            child: TextField(
                              controller: otpControllers[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: "",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.darkGrayColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: AppColors.darkGrayColor,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                if (value.length == 1 && index < 3) {
                                  FocusScope.of(context).nextFocus();
                                } else if (value.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 30),

                      AppButton(
                        btnText: "Verify Otp",
                        isLoading: auth.isLoading,
                        onPressed: () {
                          String otp = otpControllers.map((c) => c.text).join();
                          if (emailController.text.isEmpty) {
                            Utils.toastMessage(
                              "Please enter your email to proceed",
                            );
                          } else if (otp.isEmpty) {
                            Utils.toastMessage(
                              "Please enter your 4-digit otp code",
                            );
                          } else {
                            Map data = {
                              'email': emailController.text.toString(),
                              'otp': otp,
                            };
                            auth.verifyOtpApi(context, data);
                          }
                        },
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Call your resend OTP logic here
                            if (emailController.text.isEmpty) {
                              Utils.toastMessage(
                                "Please enter your email to resend OTP",
                              );
                            } else {
                              Map data = {
                                'email': emailController.text.toString(),
                              };
                              auth.resendOtpApi(
                                context,
                                data,
                              );
                            }
                          },
                          child:
                              auth.resendLoading
                                  ? Center(
                                    child: SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    "Resend OTP",
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
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
        );
      },
    );
  }
}
