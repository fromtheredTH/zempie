

import 'package:flutter/cupertino.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/get_utils/get_utils.dart';

class JoinMembershipController extends GetxController{

  TextEditingController emailId = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController password = TextEditingController();



  enterNameValidation(String value) {
    if (value.isEmpty) {
      return "이름은 필수입니다";
    }
    return null;
  }

  passwordValidation(String value) {
    if (value.isEmpty) {
      return "비밀번호가 필요합니다";
    }
    return null;
  }

  validateConfirmPasswordReg(String value) {
    if (value.isEmpty) {
      return "비밀번호 확인이 필요합니다";
    } else if (value != password.text) {
      return "비밀번호를 동일하게 입력해 주세요.";
    }
    return null;
  }


  emailValidation(String value) {
    if (value.isEmpty) {
      return "이메일은 필수입니다";
    } else if (!GetUtils.isEmail(value)) {
      return "유효한 이메일을 입력해주세요";
    }
    return null;
  }



  enterOtpValidation(String value) {
    if (value.isEmpty) {
      return "OTP가 필요합니다";
    }
    return null;
  }

}