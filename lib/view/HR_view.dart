import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../model/job_model.dart';
import '../view-model/HR_viewmodel.dart';
import '../view/student_search_view.dart';
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
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'CAP Advisor',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFF164863),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pushNamed('/menu');
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildHeader(),
              _buildProfileSection(),
              _buildBioSection(),
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
                      children: model.filteredPositions.map((job) => _buildJobDescriptionCard(job, model)).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Color(0xFF164863),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          currentIndex: 0,
          onTap: (index) {
            switch (index) {
              case 0:
              // Already on HR View, no action needed
                break;
              case 1:
              // Navigate to Feedback View
                break;
              case 2:
              // Navigate to Student Search View
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => StudentSearchScreen()),
                );
                break;
            }
          },
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Positions'),
            BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Feedback'),
            BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Student Search'),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<HRViewModel>(
      builder: (context, model, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            FutureBuilder(
              future: model.fetchImageUrl(type: ImageType.background),  // Use unified fetch method
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey.shade200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Image.network(
                    'https://via.placeholder.com/500x300',
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  );
                }
                return Image.network(
                  snapshot.data!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                );
              },
            ),
            Positioned(
              right: 10,
              top: 10,
              child: IconButton(
                icon: Icon(Icons.camera_alt, color: Colors.white),
                onPressed: () => model.pickImage(ImageSource.gallery,type: ImageType.background),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileSection() {
    return Consumer<HRViewModel>(
      builder: (context, model, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Column( // Wrap profile photo and content in a Column
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      FutureBuilder(
                        future: model.fetchImageUrl(type: ImageType.profile),
                        builder: (context, AsyncSnapshot<String> snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade200,
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                            );
                          }
                          return CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(snapshot.data!),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => model.pickImage(ImageSource.gallery, type: ImageType.profile),
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Add some space between photo and content
                  Text(
                    model.user?.username ?? 'error',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(width: 16),
              Expanded(
                child: SizedBox(), // Spacer to fill remaining space
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildBioSection() {
    return Consumer<HRViewModel>(
      builder: (context, model, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                // Handling potential null value for user and user's email
                child: Text(model.user?.bio ?? "No email available", style: TextStyle(fontSize: 16)),
              ),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => model.editBio(context),
              ),
            ],
          ),
        );
      },
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
              _buildToggleButton('Training Position', PositionType.training, model),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleButton(String text, PositionType positionType, HRViewModel model) {
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
          child: TextField(
            onChanged: (query) => model.searchPositions(query),
            decoration: InputDecoration(
              labelText: 'Search',
              suffixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildJobDescriptionCard(Job job, HRViewModel model) {
    return Container(
      width: 600,
      height: 122,
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
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          job.title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (model.is_account_owner(job.hrId))
                          IconButton(
                            icon: Icon(Icons.edit, size: 20),
                            onPressed: () => model.editJobDescription(context, job),
                          ),
                      ],
                    ),
                  ],
                ),
                Text(
                  job.skills.join(' , '),
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                SizedBox(height: 20,)
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Job Details View
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => JobDetailsView(jobData: job)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF164863), // Background color
                  ),
                  child: Text(
                    'Details',
                    style: TextStyle(
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // Show Applicants on the same page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobAndTrainingApplicantsView(
                          hrDocumentId: job.hrId,
                          positionId: job.id, // Pass position ID
                          positionType: model.currentType == PositionType.job ? 'Job Position' : 'Training Position', // Pass position type
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF164863), // Background color
                  ),
                  child: Text(
                    'Applicants',
                    style: TextStyle(
                      color: Colors.white, // Text color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}