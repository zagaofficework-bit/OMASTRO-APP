class BillingEngine {
  /// Calculates the exact pro-rata deduction based on seconds elapsed.
  /// 
  /// Uses the formula: (elapsedSeconds / 60) * pricePerMinute
  /// Safely rounded to 2 decimal places to prevent floating-point errors.
  static double calculateProRataDeduction({
    required int elapsedSeconds,
    required double pricePerMinute,
  }) {
    if (elapsedSeconds <= 0 || pricePerMinute <= 0) return 0.0;
    
    double exactDeduction = (elapsedSeconds / 60.0) * pricePerMinute;
    
    // Round to exactly 2 decimal places (currency standard)
    return double.parse(exactDeduction.toStringAsFixed(2));
  }
}
