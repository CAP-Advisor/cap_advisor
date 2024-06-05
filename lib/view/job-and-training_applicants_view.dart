import 'package:cap_advisor/view/post_position_view.dart';
import 'package:cap_advisor/view/student_search_view.dart';
import 'package:cap_advisor/view/student_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view-model/job-and-training_applicants_viewmodel.dart';
import '../widgets/custom_appbar.dart';

class JobAndTrainingApplicantsView extends StatefulWidget {
  final String hrDocumentId;
  final String positionId;
  final String positionType;

  JobAndTrainingApplicantsView({
    super.key,
    required this.hrDocumentId,
    required this.positionId,
    required this.positionType,
  });

  @override
  _JobAndTrainingApplicantsViewState createState() =>
      _JobAndTrainingApplicantsViewState();
}

class _JobAndTrainingApplicantsViewState
    extends State<JobAndTrainingApplicantsView> {
  late JobAndTrainingApplicantsViewModel viewModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    viewModel = JobAndTrainingApplicantsViewModel(
      hrDocumentId: widget.hrDocumentId,
      positionId: widget.positionId,
      positionType: widget.positionType,
    );

    fetchData(widget.positionId, widget.positionType);
  }

  void fetchData(String positionId, String positionType) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await viewModel.fetchApplicants(positionId, positionType);
      await viewModel.fetchSupervisors();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch data: $e'),
      ));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    viewModel.filterApplicants(query);
  }

  void _showFilterDialog(BuildContext context) {
    List<String> filterTypes = ['GPA', 'Address', 'Skill'];
    String selectedFilterType = filterTypes.first;
    String filterValue = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Options'),
        content: Container(
          width: double.minPositive,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Filter Type:'),
              DropdownButton<String>(
                value: selectedFilterType,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedFilterType = newValue!;
                  });
                },
                items:
                filterTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 10),
              Text('Enter Filter Value:'),
              TextField(
                onChanged: (value) {
                  filterValue = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.updateFilter(selectedFilterType, filterValue);
              Navigator.of(context).pop();
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.check, color: Colors.green),
                title: Text('Approve'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await viewModel.approveApplicant(context, index);
                },
              ),
              ListTile(
                leading: Icon(Icons.close, color: Colors.red),
                title: Text('Reject'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showRejectConfirmationDialog(context, index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRejectConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Reject'),
          content: Text('Are you sure you want to reject this applicant?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.rejectApplicant(index);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => viewModel,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Position Applicants",
          onBack: () {
            Navigator.of(context).pop();
          },
          onNotificationPressed: () {
            // Handle notifications
          },
          onMenuPressed: () {
            Navigator.of(context).pushNamed('/menu');
          },
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              SizedBox(height: 8),
              Text(
                "Gain hands-on experience, enhance skills, and contribute to real-world projects in a collaborative environment. Your gateway to growth and innovation in software development.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.filter_alt),
                    onPressed: () {
                      _showFilterDialog(context);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Color(0xFFEBEBEB),
                ),
                onChanged: _onSearchChanged,
              ),
              SizedBox(height: 16),
              Consumer<JobAndTrainingApplicantsViewModel>(
                builder: (context, viewModel, child) {
                  return viewModel.filteredApplicants.isEmpty
                      ? Text(
                    "No applicants yet",
                    style:
                    TextStyle(fontSize: 18, color: Colors.grey),
                  )
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: viewModel.filteredApplicants.length,
                    itemBuilder: (context, index) {
                      final applicant =
                      viewModel.filteredApplicants[index];
                      return Card(
                        key: ValueKey<int>(applicant.hashCode),
                        color: Color(0xFFDDF2FD),
                        margin:
                        const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[200],
                            backgroundImage: applicant.photoUrl !=
                                null
                                ? NetworkImage(applicant.photoUrl!)
                                : null,
                            child: applicant.photoUrl == null
                                ? Icon(Icons.person)
                                : null,
                          ),
                          title: Text(applicant.name),
                          subtitle: Text(applicant.email),
                          trailing: IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: () {
                              _showActionSheet(context, index);
                            },
                          ),
                          onTap: () {
                            // Navigate to the StudentView page when a card is tapped
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StudentView(
                                  uid: applicant.uid,
                                  isHR: true,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF9DB2CE),
          unselectedItemColor: Color(0xFF9DB2CE),
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PostPositionView()),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => StudentSearchScreen()),
                );
                break;
            }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Positions'),
            BottomNavigationBarItem(
                icon: Icon(Icons.school), label: 'Student Search'),
          ],
        ),
      ),
    );
  }
}