import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../view-model/add_task_viewmodel.dart';

class CustomDeadline extends StatelessWidget {
  final AddTaskViewModel model;

  const CustomDeadline({
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        InkWell(
          onTap: () {
            _showDatePicker(context, model);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Color(0xFFF5F8F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  model.selectedDeadline == null
                      ? "Select Deadline"
                      : DateFormat.yMMMMd().format(model.selectedDeadline!),
                  style: TextStyle(
                    color: model.selectedDeadline == null
                        ? Colors.grey
                        : Colors.black,
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Icon(Icons.calendar_today),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showDatePicker(BuildContext context, AddTaskViewModel model) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ).then((picked) {
      if (picked != null && picked != model.selectedDeadline) {
        model.selectedDeadline = picked;
        model.notifyListeners();
      }
    });
  }
}
