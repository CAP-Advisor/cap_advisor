import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  _JobAndTrainingApplicantsViewState createState() => _JobAndTrainingApplicantsViewState();
}


class _JobAndTrainingApplicantsViewState extends State<JobAndTrainingApplicantsView> {
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
      // Handle errors appropriately, e.g., show a snackbar
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
    setState(() {
      viewModel.filterApplicants(query);
    });
  }

  void _showFilterDialog(BuildContext context) {
    List<String> filterTypes = ['GPA', 'Address', 'Skill'];
    String selectedFilterType = filterTypes.first; // Initialize with the first item
    String filterValue = ''; // Store filter value

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
                items: filterTypes.map<DropdownMenuItem<String>>((String value) {
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
              // Call ViewModel method to update filter options and apply filter
              viewModel.updateFilter(selectedFilterType, filterValue);
              Navigator.of(context).pop();
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              "Gain hands-on experience, enhance skills, and contribute to real-world projects in a collaborative environment. Your gateway to growth and innovation in software development.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
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
            Expanded(
              child: viewModel.filteredApplicants.isEmpty
                  ? Center(
                child: Text(
                  "No applicants yet",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: viewModel.filteredApplicants.length,
                itemBuilder: (context, index) {
                  final applicant = viewModel.filteredApplicants[index];
                  return Card(
                    key: ValueKey<int>(applicant.hashCode),
                    color: Color(0xFFDDF2FD),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(applicant.name[0]),
                      ),
                      title: Text(applicant.name),
                      subtitle: Text(applicant.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check, color: Colors.green),
                            onPressed: () async {
                              await viewModel.approveApplicant(context, index);
                              setState(() {
                                viewModel.filteredApplicants.removeAt(index);
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                viewModel.rejectApplicant(index);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Positions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feedback),
            label: 'Feedback',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Student Search',
          ),
        ],
        onTap: (index) {
          // Handle bottom navigation tap
        },
      ),
    );
  }

}