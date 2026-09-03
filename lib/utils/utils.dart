import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/view_models/home_view_model/home_view_model.dart';
import 'package:provider/provider.dart';

import 'app_colors.dart';

class Utils {
  static toastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      textColor: Colors.black,
      backgroundColor: Colors.blue,
    );
  }

  //  set height

  static setHeight(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return height;
  }

  // set width

  static setWidth(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return width;
  }

  static redeemDialog(context) {
    return showDialog(
      context: context,
      builder: (context) {
        TextEditingController pointsController = TextEditingController();
        TextEditingController notesController = TextEditingController();
        final homeProvider = context.read<HomeViewModel>();
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Redeem Points",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: pointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter Points",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Available Points: ${homeProvider.redeemPointsHistoryModel?.currentBalance}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 15),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: "Notes",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // close dialog
              },
              child: Text("Cancel", style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () {
                String points = pointsController.text.trim();
                String notes = notesController.text.trim();

                if (points.isEmpty) {
                  Utils.toastMessage("Please enter redeem points");
                } else {
                  Map data = {'points': points, 'notes': notes};

                  homeProvider.redeemNowApi(context, data);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  homeProvider.redeemLoading
                      ? Center(
                        child: SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      )
                      : Text(
                        "Redeem Points",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                      ),
            ),
          ],
        );
      },
    );
  }

  static showBirthdayPopup(BuildContext context) {
    final confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => Center(
            // ✅ Center the dialog
            child: Material(
              color: Colors.transparent,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // ✅ Shrinks the height
                      children: [
                        Text(
                          "🎉 Happy Birthday! 🎉",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Wishing you joy, success, and birthday discounts!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.tomatoRedColor,
                          ),
                          onPressed: () {
                            confettiController.stop();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Celebrate 🎁",
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: ConfettiWidget(
                      confettiController: confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      numberOfParticles: 30,
                      maxBlastForce: 10,
                      minBlastForce: 5,
                      colors: const [
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.orange,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
