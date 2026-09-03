import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/screens/BottomNavBar/bottom_nav_bar.dart';
import 'package:lim_crm/view_models/bottom_nav_view_model/bottom_nav_view_model.dart';
import 'package:provider/provider.dart';
import 'package:lim_crm/utils/app_colors.dart';
import 'package:lim_crm/utils/utils.dart';
import 'package:lim_crm/view_models/promotions_view_model/promotions_view_model.dart';

import '../../res/app_assets.dart';

class HappyBirthdayScreen extends StatefulWidget {
  const HappyBirthdayScreen({super.key});

  @override
  State<HappyBirthdayScreen> createState() => _HappyBirthdayScreenState();
}

class _HappyBirthdayScreenState extends State<HappyBirthdayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PromotionsViewModel>();
      provider.getBirthday(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PromotionsViewModel>(
      builder: (context, birthday, _) {
        return Scaffold(
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppAssets.birthdayAppImg),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 50,
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          top: Utils.setHeight(context) * 0.4,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFFDF2E9),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            birthday.birthday.map((b) => b.code).join(", "),
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFC49A6C),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: MaterialButton(
                          color: Color(0xFFD49A89),
                          height: 55,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          onPressed: () {
                            context.read<BottomNavViewModel>().goHome();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BottomNavBar(),
                              ),
                            );
                          },
                          child: Text(
                            "Claim Offer",
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
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
