import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RegistrationWidgets {
  static Widget buildDropdown(
    String label,
    List<String> items,
    String? selectedValue,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
        value: selectedValue,
        items:
            items
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
        onChanged: onChanged,
      ),
    );
  }

  static Widget buildTextField(
    String label,
    TextEditingController controller,
    TextInputType inputType,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  static Widget buildDatePicker(
    BuildContext context,
    String label,
    DateTime selectedDate,
    Function(DateTime) onDateChanged,
  ) {
    return ListTile(
      title: Text("$label: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
      trailing: Icon(Icons.calendar_today, color: Colors.green),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null && pickedDate != selectedDate) {
          onDateChanged(pickedDate);
        }
      },
    );
  }

  static void showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }
}
