import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../res/app_localization.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';
import '../../../view_models/home_view_model/home_view_model.dart';

class PointsScreen extends StatefulWidget {
  const PointsScreen({super.key});

  @override
  State<PointsScreen> createState() => _PointsScreenState();
}

class _PointsScreenState extends State<PointsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = context.read<HomeViewModel>();
      homeProvider.getRedeemPointsHistory(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeViewModel>(
      builder: (context, homeView, _) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.only(
              top: Utils.setHeight(context) * 0.08,
              right: 20,
              left: 20,
            ),
            child:
                homeView.redeemLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                    AppLocalizations.of(context)!
                                        .translate("loyaltyPts") ??'',
                                  style: GoogleFonts.poppins(
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                        Text(
                          (AppLocalizations.of(context)!.translate("tPoints") ??
                                  '')
                              .toUpperCase(),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: AppColors.ashGrayColor,
                            ),
                          ),
                        ),
                        Text(
                          "${homeView.redeemPointsHistoryModel?.totalEarnedPoints}"
                              .toUpperCase(),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: MaterialButton(
                            color: AppColors.royalPurpleColor,
                            height: 55,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onPressed: () {
                              Utils.redeemDialog(context);
                            },
                            child: Text(
                              AppLocalizations.of(
                                    context,
                                  )!.translate("RedeemPts") ??
                                  '',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ),

                        Expanded(
                          child: ListView.builder(
                            itemCount: homeView.history.length,
                            physics: BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  // Align(
                                  //   alignment: Alignment.topLeft,
                                  //   child: Column(
                                  //     crossAxisAlignment:
                                  //         CrossAxisAlignment.start,
                                  //     children: [
                                  //       Text(
                                  //         homeView.history[index].points ?? '',
                                  //         style: GoogleFonts.poppins(
                                  //           fontSize: 16,
                                  //           fontWeight: FontWeight.w700,
                                  //         ),
                                  //       ),
                                  //       SizedBox(height: 4),
                                  //       Text(
                                  //         "Order #1234",
                                  //         style: GoogleFonts.poppins(
                                  //           fontSize: 16,
                                  //           fontWeight: FontWeight.w400,
                                  //           color: AppColors.ashGrayColor,
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // _dividerWidget(),
                                  // SizedBox(height: 10),
                                  SizedBox(height: 10),
                                  _rowWidget(
                                    context,
                                    "${homeView.history[index].points}",
                                    "${homeView.history[index].notes}",
                                  ),
                                  SizedBox(height: 10),
                                  _dividerWidget(),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  Widget _dividerWidget() {
    return Divider(color: AppColors.neutralGrayColor, thickness: 0.3);
  }

  Row _rowWidget(context, String text1, text2) {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.en,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        Text(
          text1,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(width: Utils.setWidth(context) * 0.1),
        Text(
          text2,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.ashGrayColor,
          ),
        ),
      ],
    );
  }
}
