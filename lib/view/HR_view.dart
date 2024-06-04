import 'package:cap_advisor/view/post_position_view.dart';
import 'package:cap_advisor/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/HR_model.dart';
import '../model/job_model.dart';
import '../view-model/HR_viewmodel.dart';
import '../view/student_search_view.dart';
import '../widgets/custom_search_field.dart';
import 'job-and-training_applicants_view.dart';
import 'job_details_view.dart';

class HRView extends StatefulWidget {
  @override
  _HRViewState createState() => _HRViewState();
  final String uid;
  const HRView({Key? key, required this.uid}) : super(key: key);
}

class _HRViewState extends State<HRView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HRViewModel(),
      child: Consumer<HRViewModel>(
        builder: (context, model, child) {
          return Scaffold(
            appBar: CustomAppBar(
              title: "CAP Advisor",
              onNotificationPressed: () {},
              onMenuPressed: () {
                Navigator.of(context).pushNamed('/menu');
              },
            ),
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  _buildProfileHeader(context, model),
                  SizedBox(height: 80),
                  _buildInfoSection(context, model),
                  SizedBox(height: 20),
                  _buildToggleButtons(),
                  _buildSearchBar(),
                  Consumer<HRViewModel>(
                    builder: (context, model, _) {
                      if (model.isLoading) {
                        return Center(child: CircularProgressIndicator());
                      } else if (model.errorMessage != null) {
                        return Center(child: Text(model.errorMessage!));
                      } else {
                        return Column(
                          children: model.filteredPositions
                              .map((job) =>
                                  _buildPositionCard(context, job, model))
                              .toList(),
                        );
                      }
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
                      MaterialPageRoute(
                          builder: (context) => PostPositionView()),
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
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: 'Positions'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.school), label: 'Student Search'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, HRViewModel viewModel) {
    HR? hr = viewModel.currentHR;
    if (hr == null) return SizedBox.shrink();

    List<Widget> infoSection = [];

    if (hr.name.isNotEmpty) {
      infoSection.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hr.name,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ));
    }

    if (hr.email.isNotEmpty) {
      infoSection.add(SizedBox(height: 10));
      infoSection.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(hr.email,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        ],
      ));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: infoSection,
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, HRViewModel _viewModel) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            image: (_viewModel.currentHR?.coverPhotoUrl != null)
                ? DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(_viewModel.currentHR!.coverPhotoUrl!),
                    onError: (error, stackTrace) {
                      print("Error loading cover photo: $error");
                    },
                  )
                : null,
            color: Colors.grey[300],
          ),
        ),
        Positioned(
          top: 130,
          left: 20,
          child: CircleAvatar(
            radius: 75,
            backgroundColor: Colors.grey[300],
            backgroundImage: _viewModel.currentHR?.photoUrl != null
                ? NetworkImage(_viewModel.currentHR!.photoUrl!)
                : null,
            onBackgroundImageError: _viewModel.currentHR?.photoUrl != null
                ? (error, stackTrace) {
                    print("Error loading profile photo: $error");
                  }
                : null,
            child: _viewModel.currentHR?.photoUrl == null
                ? Text(_viewModel.currentHR?.name.substring(0, 1) ?? 'A',
                    style: TextStyle(fontSize: 40))
                : null,
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: PopupMenuButton<String>(
            onSelected: (String value) {
              _viewModel.handleProfileAction(context, value);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'view_profile_photo',
                child: Text('View Profile Photo'),
              ),
              const PopupMenuItem<String>(
                value: 'choose_profile_photo',
                child: Text('Choose Profile Photo'),
              ),
              const PopupMenuItem<String>(
                value: 'view_cover_photo',
                child: Text('View Cover Photo'),
              ),
              const PopupMenuItem<String>(
                value: 'choose_cover_photo',
                child: Text('Choose Cover Photo'),
              ),
            ],
            child: CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: const Icon(Icons.add_a_photo, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Consumer<HRViewModel>(
      builder: (context, model, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToggleButton('Job Position', PositionType.job, model),
              _buildToggleButton(
                  'Training Position', PositionType.training, model),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(
      String text, PositionType positionType, HRViewModel model) {
    bool isSelected = model.currentType == positionType;
    return Container(
      width: 220,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
      ),
      child: TextButton(
        onPressed: () => model.togglePositionType(positionType),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          backgroundColor: isSelected ? Color(0xFF9BBEC8) : Colors.grey[200],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Consumer<HRViewModel>(
      builder: (context, model, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomSearchField(
            controller: model.searchController,
            onChanged: (query) => model.searchPositions(query),
            hintText: 'position search',
          ),
        );
      },
    );
  }

  Widget _buildPositionCard(BuildContext context, Job job, HRViewModel model) {
    return Stack(
      children: [
        Container(
          width: 390,
          height: 100,
          margin: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFCFE0E9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Position Title',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          job.title,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 20,
          top: 40,
          child: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.info),
                          title: Text('Details'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    JobDetailsView(jobData: job),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.people),
                          title: Text('Applicants'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    JobAndTrainingApplicantsView(
                                  hrDocumentId: job.hrId,
                                  positionId: job.id, // Pass position ID
                                  positionType: model.currentType ==
                                          PositionType.job
                                      ? 'Job Position'
                                      : 'Training Position', // Pass position type
                                ),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          onTap: () {
                            Navigator.pop(context);
                            model.editJobDescription(context, job);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Delete'),
                          onTap: () {
                            Navigator.pop(context);
                            _showDeleteConfirmationDialog(context, model, job);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, HRViewModel model, Job job) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Job'),
          content: Text('Are you sure you want to delete this job?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                model.deleteJob(job);
              },
            ),
          ],
        );
      },
    );
  }
}
