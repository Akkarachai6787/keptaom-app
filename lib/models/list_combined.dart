class ListCombined {
  final String id;
  final String label;
  final double amount;
  final String uidId;

  ListCombined({
    required this.id,
    required this.label,
    required this.amount,
    required this.uidId,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'name': label,     
      'balance': amount, 
      'uidId' : uidId,
    };
  }
}
