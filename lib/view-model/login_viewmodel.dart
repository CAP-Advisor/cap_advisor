import 'package:cap_advisor/utils/validation_utils.dart';
import '../service/firebase_service.dart';

class LoginViewModel {
  final FirebaseService _firebaseService = FirebaseService();
  late String userType;

  Future<bool> login(String email, String password) async {
    try {
      // Validate email format
      if (!ValidationUtils.isValidEmail(email)) {
        return false;
      }

      // Check if email exists
      bool emailExists = await _firebaseService.checkEmailExists(email);
      if (!emailExists) {
        return false; // Email does not exist
      }
      Map<String, dynamic>? userData = await _firebaseService.getUserData(email);
      if (userData != null) {
        userType = userData['userType']; // Store user type
        // Get hashed password from Firestore
        String hashedPassword = await _firebaseService.getHashedPassword(email);

        // Hash the entered password
        String enteredPasswordHashed = _firebaseService.hashPassword(password);

        // Check if passwords match
        if (hashedPassword == enteredPasswordHashed) {
          // Passwords match, login successful
          return true;
        } else {
          return false; // Passwords do not match
        }
      }else{
        print('user data not found');
        return false;
      }

    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }
}
