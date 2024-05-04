import 'package:flutter/material.dart';
class SignUpView extends StatelessWidget {
  const SignUpView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          iconTheme: IconThemeData(color: Color(0xFF164863)),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: EdgeInsets.only(bottom: 10),
              padding: EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "CREATE ACCOUNT",
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 40,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9A9A9A),
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    width: 370,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        hintText: "User Type",
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Color(0xFFF5F8F9),
                        filled: true,
                        hintStyle: TextStyle(
                          color: Color(0xFF9A9A9A),
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                      items: ["HR", "Student", "Supervisor", "Instructor"].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        // Handle dropdown value change
                      },
                    ),
                  ),
                  SizedBox(height: 35),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Name",
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Color(0xFFF5F8F9),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Username",
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Color(0xFFF5F8F9),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: "Email",
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Color(0xFFF5F8F9),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password",
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Color(0xFFF5F8F9),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 35),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Re-enter password",
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Color(0xFFF5F8F9),
                      filled: true,
                      hintStyle: TextStyle(
                        color: Color(0xFF9A9A9A),
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 42),
                  SizedBox(
                    width: 138,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle submit button press
                      },
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF427D9D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 87),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
