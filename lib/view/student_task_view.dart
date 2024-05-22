import 'package:cap_advisor/view/task_details_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view-model/student_task_viewmodel.dart';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_search_field.dart';
import '../widgets/custom_task_card.dart';

class StudentTasksView extends StatelessWidget {
  const StudentTasksView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Tasks",
        onNotificationPressed: () {
          // Add functionality for notification pressed
        },
        onMenuPressed: () {
          Navigator.of(context).pushNamed('/menu');
        },
        onBack: () {
          Navigator.of(context).pushNamed('/Student');
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Consumer<StudentTasksViewModel>(
              builder: (context, viewModel, _) => CustomSearchField(
                controller: viewModel.searchController,
                hintText: "Search by task name",
                onChanged: (value) {
                  viewModel.filterTasks(value);
                },
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Consumer<StudentTasksViewModel>(
                builder: (context, viewModel, _) {
                  return ListView.separated(
                    itemCount: viewModel.tasks.length,
                    separatorBuilder: (context, index) => SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return CustomTaskCard(
                        taskData: viewModel.tasks[index],
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TaskDetailsView(taskData: viewModel.tasks[index]),
                            ),
                          );
                        },
                        buttonTitle: "Details",
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}