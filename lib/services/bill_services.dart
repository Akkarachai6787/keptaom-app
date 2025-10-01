import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bill.dart';

class BillService {
  final CollectionReference _billCollection = FirebaseFirestore.instance
      .collection('bills');

  Future<void> addBill({
    required String title,
    required double amount,
    required DateTime date,
    required bool isTransfer,
    String? toWalletId,
    required String typeId,
    required bool isPaid,
    String? walletId,
    required String uidId,
    required bool repeatEnabled,
    String? repeatFrequency,
    int? repeatInterval,
    DateTime? repeatEndDate,
  }) async {
    late String titleRepeat;
    DateTime? nextBill;
    if (repeatEnabled && repeatFrequency != null && repeatInterval != null) {
      switch (repeatFrequency) {
        case 'day':
          nextBill = date.add(Duration(days: repeatInterval));
          break;
        case 'week':
          nextBill = date.add(Duration(days: 7 * repeatInterval));
          break;
        case 'month':
          nextBill = DateTime(date.year, date.month + repeatInterval, date.day);
          break;
        case 'year':
          nextBill = DateTime(date.year + repeatInterval, date.month, date.day);
          break;
      }

      if (repeatEndDate != null &&
          nextBill != null &&
          nextBill.isAfter(repeatEndDate)) {
        nextBill = null;
      }

      titleRepeat =
          '$title - ${date.month.toString().padLeft(2, '0')}-${date.year.toString().padLeft(4, '0')}';
    }

    final data = {
      'title': repeatEnabled ? titleRepeat : title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'yearMonth':
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}',
      'isTransfer': isTransfer,
      'toWalletId': toWalletId,
      'type': FirebaseFirestore.instance.collection('types').doc(typeId),
      'typeId': typeId,
      'isPaid': isPaid,
      'walletId': walletId,
      'user': FirebaseFirestore.instance.collection('users').doc(uidId),
      'userId': uidId,
      'repeat': {
        'enabled': repeatEnabled,
        'frequency': repeatFrequency,
        'interval': repeatInterval,
        'endDate': repeatEndDate != null
            ? Timestamp.fromDate(repeatEndDate)
            : null,
        'nextBill': nextBill != null ? Timestamp.fromDate(nextBill) : null,
      },
    };

    await _billCollection.add(data);
  }

  Future<void> updateBill(String billId, Bill bill) async {
    await _billCollection.doc(billId).update(bill.toMap());
  }

  Future<void> markAsPaid(String billId) async {
    await _billCollection.doc(billId).update({'isPaid': true});
  }

  Future<void> addRepeatBill({required Bill bill}) async {
    String baseTitle = bill.title;

    final regex = RegExp(r' - \d{2}-\d{4}$');
    baseTitle = baseTitle.replaceAll(regex, '');

    String titleRepeat = baseTitle;

    DateTime? nextBill;
    DateTime? dateTS = bill.nextBillDate!.toDate();

    if (bill.repeatEnabled &&
        bill.repeatFrequency != null &&
        bill.repeatInterval != null) {
      switch (bill.repeatFrequency) {
        case 'day':
          nextBill = dateTS.add(Duration(days: bill.repeatInterval!));
          break;
        case 'week':
          nextBill = dateTS.add(Duration(days: 7 * bill.repeatInterval!));
          break;
        case 'month':
          nextBill = DateTime(
            dateTS.year,
            dateTS.month + bill.repeatInterval!,
            dateTS.day,
          );
          break;
        case 'year':
          nextBill = DateTime(
            dateTS.year + bill.repeatInterval!,
            dateTS.month,
            dateTS.day,
          );
          break;
      }

      if (bill.repeatEndDate != null &&
          nextBill != null &&
          nextBill.isAfter(bill.repeatEndDate!.toDate())) {
        nextBill = null;
      }

      titleRepeat =
          '$baseTitle - ${dateTS.month.toString().padLeft(2, '0')}-${dateTS.year.toString().padLeft(4, '0')}';
    }

    final data = {
      'title': titleRepeat,
      'amount': bill.amount,
      'date': Timestamp.fromDate(dateTS),
      'yearMonth':
          '${dateTS.year.toString().padLeft(4, '0')}-${dateTS.month.toString().padLeft(2, '0')}',
      'isTransfer': bill.isTransfer,
      'toWalletId': bill.toWalletId,
      'type': FirebaseFirestore.instance.collection('types').doc(bill.typeId),
      'typeId': bill.typeId,
      'isPaid': false,
      'walletId': bill.walletId,
      'user': FirebaseFirestore.instance.collection('users').doc(bill.uidId),
      'userId': bill.uidId,
      'repeat': {
        'enabled': bill.repeatEnabled,
        'frequency': bill.repeatFrequency,
        'interval': bill.repeatInterval,
        'endDate': bill.repeatEndDate != null
            ? Timestamp.fromDate(bill.repeatEndDate!.toDate())
            : null,
        'nextBill': nextBill != null ? Timestamp.fromDate(nextBill) : null,
      },
    };

    await _billCollection.add(data);
  }

  Future<void> deleteBill(String billId) async {
    await _billCollection.doc(billId).delete();
  }

  Future<Bill?> getBillById(String billId) async {
    final doc = await _billCollection.doc(billId).get();
    if (doc.exists) {
      return Bill.fromFirestore(doc);
    }
    return null;
  }

  Future<List<Bill>> getBillsByUser(String userId) async {
    final snapshot = await _billCollection
        .where('userId', isEqualTo: userId)
        .get();

    final bills = snapshot.docs.map((doc) => Bill.fromFirestore(doc)).toList();

    bills.sort((a, b) => b.date.compareTo(a.date));

    return bills.toList();
  }

  Future<List<Bill>> getBillsLimitByUser(String userId, int limit) async {
    final snapshot = await _billCollection
        .where('userId', isEqualTo: userId)
        .where('isPaid', isEqualTo: false)
        .get();

    final bills = snapshot.docs.map((doc) => Bill.fromFirestore(doc)).toList();

    bills.sort((a, b) => a.date.compareTo(b.date));

    return bills.take(limit).toList();
  }

  Future<List<Bill>> getRepeatingBills(String userId) async {
    final snapshot = await _billCollection
        .where('userId', isEqualTo: userId)
        .where('repeat.enabled', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => Bill.fromFirestore(doc)).toList();
  }
}
