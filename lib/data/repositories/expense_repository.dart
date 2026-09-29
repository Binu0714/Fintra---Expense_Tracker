import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ExpenseRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User is not authenticated.');
    return user.uid;
  }

  // Reference to current user's expenses sub-collection
  CollectionReference<Map<String, dynamic>> get _expensesCollection =>
      _firestore.collection('users').doc(_userId).collection('expenses');

  // add user expense
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      debugPrint('➡️ Current User UID: $_userId');
      final docRef = _expensesCollection.doc();
      debugPrint('➡️ Writing to path: users/$_userId/expenses/${docRef.id}');

      final newExpense = ExpenseModel(
        id: docRef.id,
        title: expense.title,
        amount: expense.amount,
        category: expense.category,
        date: expense.date,
        note: expense.note,
      );

      await docRef.set(newExpense.toMap()).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw 'Firestore write timed out. Check your internet connection.';
        },
      );

      debugPrint('✅ Document successfully written to Firestore!');
    } catch (e) {
      debugPrint('❌ Error in addExpense: $e');
      throw 'Failed to add expense: $e';
    }
  }

  // get all user expenses
  Stream<List<ExpenseModel>> getExpensesStream() {
    try {
      return _expensesCollection
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ExpenseModel.fromMap(doc.data(), doc.id);
        }).toList();
      });
    } catch (e) {
      throw 'Failed to fetch expenses: $e';
    }
  }

  // update user expense
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _expensesCollection.doc(expense.id).update(expense.toMap());
    } catch (e) {
      throw 'Failed to update expense: $e';
    }
  }

  // delete user expense
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _expensesCollection.doc(expenseId).delete();
    } catch (e) {
      throw 'Failed to delete expense: $e';
    }
  }

}