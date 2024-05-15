import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view-model/assigning_feedback_viewmodel.dart';
import 'display_feedback_view.dart';
import '../widgets/custom_appbar.dart';
import 'student_view.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_search_field.dart';

class AssigningFeedbackView extends StatefulWidget {
  @override
  _AssigningFeedbackViewState createState() => _AssigningFeedbackViewState();
}

class _AssigningFeedbackViewState extends State<AssigningFeedbackView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          title: "CAP Advisor",
          onNotificationPressed: () {},
          onMenuPressed: () {},
        ),
        body: Consumer<AssigningFeedbackViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 10.0),
                      child: Text(
                        "Feedback",
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 40,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF9A9A9A),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomSearchField(
                    controller: viewModel.searchController,
                    onChanged: viewModel.filterFeedbacks,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.filteredFeedbacks.length,
                    itemBuilder: (context, index) {
                      final feedback = viewModel.filteredFeedbacks[index];
                      return CustomCard(
                        feedback: feedback,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  StudentView( uid:feedback.uid),
                            ),
                          );
                        },
                        onAddFeedbackPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisplayFeedbackView(
                                feedback: feedback.toFeedbackModel(),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
