class ContractorVerifyResult {
  bool allowed;
  num accountsReceivable;
  num accountsPayable;
  DateTime lastPaymentDate;
  String stopFactor;
  ContractorVerifyResult({this.allowed, this.accountsReceivable, this.accountsPayable, this.lastPaymentDate, this.stopFactor});
}

extension ContractorVerifyResultDecode on ContractorVerifyResult {
  static ContractorVerifyResult decode(Map<String, dynamic> data) {
    final allowed = data['allowed'];
    final accountsReceivable = data['accountsReceivable'];
    final accountsPayable = data['accountsPayable'];
    final lastPaymentDate = data['lastPaymentDate'];
    final stopFactor = data['stopFactor'];
    if (allowed is! bool) {
      return null;
    }
    if (accountsReceivable != null && accountsReceivable is! num) {
      return null;
    }
    if (accountsPayable != null && accountsPayable is! num) {
      return null;
    }
    if (lastPaymentDate != null && lastPaymentDate is! int) {
      return null;
    }
    if (stopFactor != null && stopFactor is! String) {
      return null;
    }
    return ContractorVerifyResult(
      allowed: allowed,
      accountsReceivable: accountsReceivable,
      accountsPayable: accountsPayable,
      lastPaymentDate: lastPaymentDate != null ? DateTime.fromMillisecondsSinceEpoch(lastPaymentDate) : null,
      stopFactor: stopFactor,
    );
  }
}
