import 'package:flutter/services.dart';
import 'package:lim_crm/models/coupons_model/coupons_model.dart';
import 'package:lim_crm/models/dashboard_model/dashboard_model.dart';
import 'package:lim_crm/models/get_birthday_model/get_birthday_model.dart';
import 'package:lim_crm/models/offers_model/offers_model.dart';
import 'package:lim_crm/res/app_localization.dart';
import 'package:lim_crm/utils/utils.dart';

class PromotionItem {
  final dynamic id;
  final String? name;
  final String? code;
  final String type;
  final String? description;
  final String? discountType;
  final String? amount;
  final String? minimumCartAmount;
  final String? startDate;
  final String? expiryDate;
  final bool neverExpires;
  final bool availableNow;

  const PromotionItem({
    this.id,
    this.name,
    this.code,
    required this.type,
    this.description,
    this.discountType,
    this.amount,
    this.minimumCartAmount,
    this.startDate,
    this.expiryDate,
    this.neverExpires = false,
    this.availableNow = true,
  });

  bool get isBirthday => type == 'birthday';
  bool get isCoupon => type == 'coupon';
  bool get hasCode => (code ?? '').trim().isNotEmpty;

  factory PromotionItem.fromDashboard(DashboardPromotion item) {
    return PromotionItem(
      id: item.id,
      name: item.name,
      code: item.code,
      type: item.type ?? 'offer',
      description: item.description,
      discountType: item.discountType,
      amount: item.amount,
      minimumCartAmount: item.minimumCartAmount,
      startDate: item.startDate,
      expiryDate: item.expiryDate,
      neverExpires: item.neverExpires,
      availableNow: item.availableNow,
    );
  }

  factory PromotionItem.fromCoupon(Coupons item) {
    return PromotionItem(
      id: item.id,
      name: item.name,
      code: item.code,
      type: 'coupon',
      description: item.description,
      discountType: item.discountType,
      amount: item.amount,
      minimumCartAmount: item.minimumCartAmount,
      startDate: item.startDate,
      expiryDate: item.expiryDate,
      neverExpires: item.neverExpires,
      availableNow: item.availableNow,
    );
  }

  factory PromotionItem.fromOffer(Offers item) {
    return PromotionItem(
      id: item.id,
      name: item.name,
      code: item.code,
      type: 'offer',
      description: item.description,
      discountType: item.discountType,
      amount: item.amount,
      minimumCartAmount: item.minimumCartAmount,
      startDate: item.startDate,
      expiryDate: item.expiryDate,
      neverExpires: item.neverExpires,
      availableNow: item.availableNow,
    );
  }

  factory PromotionItem.fromBirthday(Birthdays item) {
    return PromotionItem(
      id: item.id,
      name: item.name,
      code: item.code,
      type: 'birthday',
      description: item.description,
      discountType: item.discountType,
      amount: item.amount,
      minimumCartAmount: item.minimumCartAmount,
      startDate: item.startDate,
      expiryDate: item.expiryDate,
      neverExpires: true,
      availableNow: item.availableNow,
    );
  }

  String typeLabel(AppLocalizations l10n) {
    if (isBirthday) return l10n.translate('birthdayReward') ?? 'Birthday Reward';
    if (isCoupon) return l10n.translate('coupon') ?? 'Coupon';
    return l10n.translate('offers') ?? 'Offer';
  }

  String badgeText(AppLocalizations l10n) {
    final amt = double.tryParse(amount ?? '');
    final off = l10n.translate('offSuffix') ?? 'OFF';
    if (amt != null && (discountType == 'percent' || discountType == 'percentage')) {
      return '${amt.toStringAsFixed(amt % 1 == 0 ? 0 : 2)}% $off';
    }
    if (amt != null && (amount ?? '').isNotEmpty) {
      return '${amt.toStringAsFixed(2)} € $off';
    }
    return typeLabel(l10n);
  }

  String expiryText(AppLocalizations l10n) {
    if (!availableNow) {
      if (isBirthday || type == 'anniversary') {
        return l10n.translate('rewardNotAvailable') ??
            'This reward is not available at the moment.';
      }
      if (isCoupon) {
        return l10n.translate('couponNotAvailableYet') ??
            'This coupon is not available yet.';
      }
    }
    if (isBirthday) {
      return l10n.translate('birthdayReward') ?? 'Birthday Reward';
    }
    if (neverExpires) {
      return l10n.translate('neverExpires') ?? 'Never expires';
    }
    if ((expiryDate ?? '').isNotEmpty) {
      return '${l10n.translate('expiresPrefix') ?? 'Expires'} ${_formatDate(expiryDate!)}';
    }
    return l10n.translate('limitedTimeOffer') ?? 'Limited time offer';
  }

  String resolvedDescription(AppLocalizations l10n) {
    if ((description ?? '').trim().isNotEmpty) return description!.trim();
    if (isCoupon) {
      return l10n.translate('couponFallbackDesc') ??
          'Apply this coupon at checkout to enjoy instant savings.';
    }
    if (isBirthday) {
      return l10n.translate('birthdayFallbackDesc') ??
          'Celebrate your birthday month with this exclusive reward.';
    }
    return l10n.translate('offerFallbackDesc') ??
        'Unlock this special offer on your next purchase.';
  }

  String? minSpendText(AppLocalizations l10n) {
    final amt = double.tryParse(minimumCartAmount ?? '');
    if (amt == null || amt <= 0) return null;
    return '${l10n.translate('minSpend') ?? 'Min. spend'} ${amt.toStringAsFixed(2)} €';
  }

  String applyLabel(AppLocalizations l10n) {
    if (isCoupon) return l10n.translate('applyCoupon') ?? 'Apply Coupon';
    if (isBirthday) return l10n.translate('useReward') ?? 'Use Reward';
    return l10n.translate('applyOffer') ?? 'Apply Offer';
  }

  String displayTitle(AppLocalizations l10n) {
    if ((name ?? '').trim().isNotEmpty) return name!.trim();
    return l10n.translate('specialReward') ?? 'Special Reward';
  }

  static String _formatDate(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static Future<void> copyCode(String code, AppLocalizations l10n) async {
    try {
      await Clipboard.setData(ClipboardData(text: code));
      Utils.toastMessage(l10n.translate('codeCopied') ?? 'Code copied to clipboard.');
    } catch (_) {
      Utils.toastMessage(l10n.translate('unableToCopyCode') ?? 'Unable to copy code.');
    }
  }
}
