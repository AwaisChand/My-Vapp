class VapeCalcResult {
  final int totalDays;
  final double cigUnitPrice;
  final double totalCigCost;
  final double vapeCostBeforeFidelity;
  final double fidelityDiscountValue;
  final double totalVapeCostAfterFidelity;
  final double freeBottleValue;
  final double totalRetailAllBottles;
  final double pricePerBottleInclFree;
  final double eurosSaved;
  final double savingPercent;
  final double savingPerDay;
  final double savingPerMonth;
  final double savingPerYear;

  const VapeCalcResult({
    this.totalDays = 0,
    this.cigUnitPrice = 0,
    this.totalCigCost = 0,
    this.vapeCostBeforeFidelity = 0,
    this.fidelityDiscountValue = 0,
    this.totalVapeCostAfterFidelity = 0,
    this.freeBottleValue = 0,
    this.totalRetailAllBottles = 0,
    this.pricePerBottleInclFree = 0,
    this.eurosSaved = 0,
    this.savingPercent = 0,
    this.savingPerDay = 0,
    this.savingPerMonth = 0,
    this.savingPerYear = 0,
  });

  String euro(double v) => '${v.toStringAsFixed(2)} €';
}

class VapeCalculatorEngine {
  static const weekdaysEn = [
    'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
  ];
  static const weekdaysFr = [
    'Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi',
  ];

  static VapeCalcResult calculate({
    DateTime? firstDate,
    DateTime? todayDate,
    required double packPrice,
    required int cigsPerPack,
    required int cigsPerDay,
    required double vapeUnitPrice,
    required int bottlesCount,
    required int freeBottles,
    required int daysPerBottle,
    required double fidelityPercent,
  }) {
    var totalDays = 0;
    if (firstDate != null && todayDate != null) {
      totalDays = todayDate.difference(firstDate).inDays;
      if (totalDays < 0) totalDays = 0;
    }

    final pack = cigsPerPack > 0 ? cigsPerPack : 1;
    final cigUnitPrice = pack > 0 ? packPrice / pack : 0.0;
    final totalCigCost = cigUnitPrice * cigsPerDay * totalDays;

    final vapeCostBeforeFidelity = vapeUnitPrice * bottlesCount;
    final fidelityDiscountValue = vapeCostBeforeFidelity * (fidelityPercent / 100);
    final totalVapeCostAfterFidelity = vapeCostBeforeFidelity - fidelityDiscountValue;
    final freeBottleValue = vapeUnitPrice * freeBottles;
    final totalBottles = (bottlesCount + freeBottles).clamp(1, 1 << 30);
    final totalRetailAllBottles = vapeUnitPrice * (bottlesCount + freeBottles);
    final pricePerBottleInclFree =
        totalBottles > 0 ? totalVapeCostAfterFidelity / totalBottles : 0.0;

    final cigCostPerDay = cigUnitPrice * cigsPerDay;
    final economyBottle = daysPerBottle > 0
        ? cigCostPerDay - (pricePerBottleInclFree / daysPerBottle)
        : cigCostPerDay;

    final eurosSaved = totalCigCost - totalVapeCostAfterFidelity;
    final pct = (totalCigCost > 0 && eurosSaved > 0)
        ? (eurosSaved / totalCigCost * 100).clamp(0, 100)
        : 0.0;

    final savingPerDay = economyBottle;
    return VapeCalcResult(
      totalDays: totalDays,
      cigUnitPrice: cigUnitPrice,
      totalCigCost: totalCigCost,
      vapeCostBeforeFidelity: vapeCostBeforeFidelity,
      fidelityDiscountValue: fidelityDiscountValue,
      totalVapeCostAfterFidelity: totalVapeCostAfterFidelity,
      freeBottleValue: freeBottleValue,
      totalRetailAllBottles: totalRetailAllBottles,
      pricePerBottleInclFree: pricePerBottleInclFree,
      eurosSaved: eurosSaved,
      savingPercent: pct.toDouble(),
      savingPerDay: savingPerDay,
      savingPerMonth: savingPerDay * 30,
      savingPerYear: savingPerDay * 365,
    );
  }

  static String weekdayName(DateTime date, {required bool french}) {
    return (french ? weekdaysFr : weekdaysEn)[date.weekday % 7];
  }
}
