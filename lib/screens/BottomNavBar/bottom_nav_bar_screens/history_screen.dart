import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lim_crm/view_models/order_history_view_model/order_history_view_model.dart';
import 'package:provider/provider.dart';

import '../../../res/app_localization.dart';
import '../../../res/components/time_range_dropdown_widget.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/utils.dart';

class HistoryScreen extends StatefulWidget {
  final bool embedded;

  const HistoryScreen({super.key, this.embedded = false});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderHistoryViewModel>().getOrderHistory(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderHistoryViewModel>(
      builder: (context, orderHistory, _) {
        final content = Column(
          children: [
            if (!widget.embedded) ...[
              SizedBox(height: Utils.setHeight(context) * 0.08),
              Text(
                AppLocalizations.of(context)?.translate("purchaseHistory") ?? '',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                ),
              ),
            ],
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(
                  top: widget.embedded ? 8 : 16,
                  right: widget.embedded ? 8 : 0,
                ),
                child: TimeRangeDropdown(),
              ),
            ),
            Expanded(
              child: orderHistory.orderHistoryLoading
                  ? const Center(child: CircularProgressIndicator())
                  : orderHistory.orders.isEmpty
                      ? Center(
                          child: Text(
                            AppLocalizations.of(context)!.translate("noOrder") ?? '',
                            style: GoogleFonts.poppins(color: AppColors.textMuted),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.all(widget.embedded ? 16 : 0),
                          itemCount: orderHistory.orders.length,
                          physics: const BouncingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final order = orderHistory.orders[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    order.orderNumber ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _row('Customer', order.customer ?? ''),
                                  _row('Cashback', '${order.totalPoints} pts'),
                                  _row('Total', '€${order.totalAmount}'),
                                  const SizedBox(height: 6),
                                  Text(
                                    order.date ?? '',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),
          ],
        );

        if (widget.embedded) {
          return content;
        }

        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: content,
          ),
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
          Text(value, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
