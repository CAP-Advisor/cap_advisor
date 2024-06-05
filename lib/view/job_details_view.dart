import 'package:flutter/material.dart';
import '../widgets/custom_appbar.dart';
import '../model/job_model.dart';

class JobDetailsView extends StatelessWidget {
  final Job jobData;

  const JobDetailsView({Key? key, required this.jobData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color iconColor = Color(0xFF164863);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Job Details',
        onNotificationPressed: () {
          // Add functionality for notification pressed
        },
        onMenuPressed: () {
          Navigator.of(context).pushNamed('/menu');
        },
        onBack: () {
          Navigator.of(context).pop();
        },
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Title Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.title, color: iconColor),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              jobData.title,
                              style: TextStyle(
                                fontSize: 24.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Description Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: iconColor),
                          SizedBox(width: 8),
                          Text(
                            "Description",
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        jobData.description,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Requirements Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.list, color: iconColor),
                          SizedBox(width: 8),
                          Text(
                            "Required Skills",
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        jobData.skills.join('\n'),
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
