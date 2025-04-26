// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class RegistrationWidgets {
//   static Widget buildTextField(
//     String label,
//     TextEditingController controller,
//     TextInputType keyboardType,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           labelText: label,
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//             borderSide: BorderSide(color: Colors.green),
//           ),
//         ),
//       ),
//     );
//   }

//   static Widget buildDropdown<T>(
//     String label,
//     List<T> items,
//     T? selectedValue,
//     Function(T?) onChanged,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: DropdownButtonFormField<T>(
//         decoration: InputDecoration(
//           labelText: label,
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//             borderSide: BorderSide(color: Colors.grey.shade300),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.0),
//             borderSide: BorderSide(color: Colors.green),
//           ),
//         ),
//         value: selectedValue,
//         onChanged: onChanged,
//         items:
//             items.map<DropdownMenuItem<T>>((T value) {
//               return DropdownMenuItem<T>(
//                 value: value,
//                 child: Text(value.toString()),
//               );
//             }).toList(),
//       ),
//     );
//   }

//   static Widget buildDatePicker(
//     BuildContext context,
//     String label,
//     DateTime selectedDate,
//     Function(DateTime) onChanged,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: InkWell(
//         onTap: () async {
//           final DateTime? picked = await showDatePicker(
//             context: context,
//             initialDate: selectedDate,
//             firstDate: DateTime(2000),
//             lastDate: DateTime(2101),
//             builder: (context, child) {
//               return Theme(
//                 data: Theme.of(context).copyWith(
//                   colorScheme: ColorScheme.light(
//                     primary: Colors.green,
//                     onPrimary: Colors.white,
//                     onSurface: Colors.black,
//                   ),
//                 ),
//                 child: child!,
//               );
//             },
//           );
//           if (picked != null) {
//             onChanged(picked);
//           }
//         },
//         child: InputDecorator(
//           decoration: InputDecoration(
//             labelText: label,
//             filled: true,
//             fillColor: Colors.white,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.0),
//               borderSide: BorderSide(color: Colors.grey.shade300),
//             ),
//             suffixIcon: Icon(Icons.calendar_today),
//           ),
//           child: Text(
//             DateFormat('yyyy-MM-dd').format(selectedDate),
//             style: TextStyle(fontSize: 16),
//           ),
//         ),
//       ),
//     );
//   }

//   static void showSnackbar(
//     BuildContext context,
//     String message,
//     Color backgroundColor,
//   ) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
//         ),
//         backgroundColor: backgroundColor,
//         duration: Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//       ),
//     );
//   }
// }
