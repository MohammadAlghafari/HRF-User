import 'package:flutter/material.dart';

import '../../../localization/language_constrants.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/profile_provider.dart';
import '../../../provider/theme_provider.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/custom_themes.dart';
import '../../../utill/images.dart';
import 'widget/sign_in_widget.dart';
import 'widget/sign_up_widget.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatelessWidget {
  final int initialPage;
  AuthScreen({this.initialPage = 0});

  @override
  Widget build(BuildContext context) {
    Provider.of<ProfileProvider>(context, listen: false)
        .initAddressTypeList(context);
    Provider.of<AuthProvider>(context, listen: false).isRemember;
    PageController _pageController = PageController(initialPage: initialPage);

    return Scaffold(
      body: Stack(
        clipBehavior: Clip.none,
        children: [
         

          // background
          Provider.of<ThemeProvider>(context).darkTheme
              ? SizedBox()
              : Image.asset(Images.background,
                  fit: BoxFit.fill,
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer<AuthProvider>(
              builder: (context, auth, child) => SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 70),

                      // for logo with text
                      Image.asset(Images.logo_blue, height: 100, width: 100),
                      SizedBox(
                        height: 50,
                      ),
                      // for decision making section like signin or register section

                      Consumer<AuthProvider>(
                        builder: (context, authProvider, child) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => _pageController.animateToPage(0,
                                    duration: Duration(seconds: 1),
                                    curve: Curves.easeInOut),
                                child: Column(
                                  children: [
                                    Text(getTranslated('SIGN_IN', context),
                                        style: authProvider.selectedIndex == 0
                                            ? titilliumSemiBold
                                            : titilliumRegular),
                                    Container(
                                      height: 1,
                                      width: 40,
                                      margin: EdgeInsets.only(top: 8),
                                      color: authProvider.selectedIndex == 0
                                          ? Theme.of(context).primaryColor
                                          : Colors.transparent,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 25),
                              InkWell(
                                onTap: () => _pageController.animateToPage(1,
                                    duration: Duration(seconds: 1),
                                    curve: Curves.easeInOut),
                                child: Column(
                                  children: [
                                    Text(getTranslated('SIGN_UP', context),
                                        style: authProvider.selectedIndex == 1
                                            ? titilliumSemiBold
                                            : titilliumRegular),
                                    Container(
                                        height: 1,
                                        width: 50,
                                        margin: EdgeInsets.only(top: 8),
                                        color: authProvider.selectedIndex == 1
                                            ? Theme.of(context).primaryColor
                                            : Colors.transparent),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        width: MediaQuery.of(context).size.width,
                        //margin: EdgeInsets.only(right: Dimensions.FONT_SIZE_LARGE),
                        height: 1,
                        color: ColorResources.getGainsBoro(context),
                      ),
                      // show login or register widget
                       Container(
                         height: 500,
                         child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) =>
                              PageView.builder(
                            itemCount: 2,
                            controller: _pageController,
                            itemBuilder: (context, index) {
                              if (authProvider.selectedIndex == 0) {
                                return SignInWidget();
                              } else {
                                return SignUpWidget();
                              }
                            },
                            onPageChanged: (index) {
                              authProvider.updateSelectedIndex(index);
                            },
                          ),
                                             ),
                       ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
