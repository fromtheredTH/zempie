

import 'package:app/models/dto/user_dto.dart';
import 'package:app/pages/components/item/TagCreator.dart';
import 'package:app/pages/components/item/TagDev.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import '../app_text.dart';

class UserNameWidget extends StatelessWidget {
  UserDto? user;
  UserNameWidget({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: AppText(
            text: user?.nickname ?? "unknown".tr(),
            fontSize: 16,
            overflow: TextOverflow.ellipsis,
            maxLength: 1,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(width: 10,),

        // if((user?.is_developer ?? 0) == 1)
        //   Row(
        //     children: [
        //       TagCreatorWidget(),
        //
        //       SizedBox(width: 10,),
        //     ],
        //   ),
        //
        // if((user?.is_developer ?? 0) == 1)
        //   TagDevWidget(positionIndex: "0",)
      ],
    );
  }
}