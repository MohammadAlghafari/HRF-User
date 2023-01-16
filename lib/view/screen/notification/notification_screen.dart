import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../helper/date_converter.dart';
import '../../../localization/language_constrants.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/notification_provider.dart';
import '../../../provider/splash_provider.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/custom_themes.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../basewidget/custom_app_bar.dart';
import '../../basewidget/no_internet_screen.dart';
import '../../basewidget/not_loggedin_widget.dart';
import 'widget/notification_dialog.dart';

// ignore: must_be_immutable
class NotificationScreen extends StatelessWidget {
  final bool isBacButtonExist;
  NotificationScreen({this.isBacButtonExist = true});

  bool isFirstTime = true;

  @override
  Widget build(BuildContext context) {
    bool isGuestMode =
        !Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if (isFirstTime) {
      if (!isGuestMode) {
        Provider.of<NotificationProvider>(context, listen: false)
            .initNotificationList(context);
      }

      isFirstTime = false;
    }

    return Scaffold(
      body: Column(children: [
        CustomAppBar(
            title: getTranslated('notification', context),
            isBackButtonExist: isBacButtonExist),
        isGuestMode
            ? Expanded(child: NotLoggedInWidget())
            : Expanded(
                child: Consumer<NotificationProvider>(
                  builder: (context, notification, child) {
                    return notification.notificationList != null
                        ? notification.notificationList.length != 0
                            ? RefreshIndicator(
                                backgroundColor: Theme.of(context).primaryColor,
                                onRefresh: () async {
                                  await Provider.of<NotificationProvider>(
                                          context,
                                          listen: false)
                                      .initNotificationList(context);
                                },
                                child: ListView.builder(
                                  itemCount:
                                      Provider.of<NotificationProvider>(context)
                                          .notificationList
                                          .length,
                                  padding: EdgeInsets.symmetric(
                                      vertical: Dimensions.PADDING_SIZE_SMALL),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () => showDialog(
                                          context: context,
                                          builder: (context) =>
                                              NotificationDialog(
                                                  notificationModel:
                                                      notification
                                                              .notificationList[
                                                          index])),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            bottom:
                                                Dimensions.PADDING_SIZE_SMALL),
                                        color: ColorResources.getGrey(context),
                                        child: ListTile(
                                          leading: ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl:
                                                  '${Provider.of<SplashProvider>(context, listen: false).baseUrls.notificationImageUrl}/${notification.notificationList[index].image}',
                                              placeholder: (context, url) =>
                                                  Image.asset(
                                                Images.placeholder,
                                                height: 50,
                                                width: 50,
                                                fit: BoxFit.cover,
                                              ),
                                              fit: BoxFit.cover,
                                              errorWidget: (c, o, s) =>
                                                  Image.asset(
                                                      Images.placeholder,
                                                      height: 50,
                                                      width: 50,
                                                      fit: BoxFit.cover),
                                            ),
                                            /*  FadeInImage.assetNetwork(
                                            placeholder: Images.placeholder,
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                            image:
                                                '${Provider.of<SplashProvider>(context, listen: false).baseUrls.notificationImageUrl}/${notification.notificationList[index].image}',
                                            imageErrorBuilder: (c, o, s) =>
                                                Image.asset(Images.placeholder,
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.cover),
                                          ) */
                                          ),
                                          title: Text(
                                              notification
                                                  .notificationList[index]
                                                  .title,
                                              style: titilliumRegular.copyWith(
                                                fontSize:
                                                    Dimensions.FONT_SIZE_SMALL,
                                              )),
                                          subtitle: Text(
                                            DateFormat('hh:mm  dd/MM/yyyy')
                                                .format(DateConverter
                                                    .isoStringToLocalDate(
                                                        notification
                                                            .notificationList[
                                                                index]
                                                            .createdAt)),
                                            style: titilliumRegular.copyWith(
                                                fontSize: Dimensions
                                                    .FONT_SIZE_EXTRA_SMALL,
                                                color: ColorResources.getHint(
                                                    context)),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : NoInternetOrDataScreen(isNoInternet: false)
                        : NotificationShimmer();
                  },
                ),
              ),
      ]),
    );
  }
}

class NotificationShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      padding: EdgeInsets.all(0),
      itemBuilder: (context, index) {
        return Container(
          height: 80,
          margin: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_SMALL),
          color: ColorResources.getGrey(context),
          alignment: Alignment.center,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300],
            highlightColor: Colors.grey[100],
            enabled:
                Provider.of<NotificationProvider>(context).notificationList ==
                    null,
            child: ListTile(
              leading: CircleAvatar(child: Icon(Icons.notifications)),
              title: Container(height: 20, color: ColorResources.WHITE),
              subtitle:
                  Container(height: 10, width: 50, color: ColorResources.WHITE),
            ),
          ),
        );
      },
    );
  }
}