// import 'package:firstapp/models/finance/expense.dart';
// import 'package:flutter/material.dart';

// class ExpenseDetailScreen extends StatelessWidget {
//   final Expense expense;

//   ExpenseDetailScreen({required this.expense});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Détail Dépense')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Description: ${expense.description}'),
//             Text('Montant: ${expense.amount} €'),
//             Text('Catégorie: ${expense.category}'),
//             Text('Date: ${expense.date.toLocal().toString().split(" ")[0]}'),
//             if (expense.invoiceNumber != null)
//               Text('Facture: ${expense.invoiceNumber}'),
//             Text('Statut: ${expense.status}'),
//           ],
//         ),
//       ),
//     );
//   }
// }
