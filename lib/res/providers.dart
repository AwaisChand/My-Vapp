import 'package:lim_crm/view_models/bottom_nav_view_model/bottom_nav_view_model.dart';
import 'package:lim_crm/view_models/vape_savings_view_model/vape_savings_view_model.dart';
import 'package:lim_crm/view_models/home_view_model/home_view_model.dart';
import 'package:lim_crm/view_models/order_history_view_model/order_history_view_model.dart';
import 'package:lim_crm/view_models/promotions_view_model/promotions_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../view_models/auth_view_model/auth_view_model.dart';

List<SingleChildWidget> providers = [...independentProviders];
List<SingleChildWidget> independentProviders = [
  ChangeNotifierProvider(create: (_) => AuthViewModel()),
  ChangeNotifierProvider(create: (_) => BottomNavViewModel()),
  ChangeNotifierProvider(create: (_) => HomeViewModel()),
  ChangeNotifierProvider(create: (_) => OrderHistoryViewModel()),
  ChangeNotifierProvider(create: (_) => PromotionsViewModel()),
  ChangeNotifierProvider(create: (_) => VapeSavingsViewModel()),
];
