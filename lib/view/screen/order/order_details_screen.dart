import 'package:flutter/material.dart';
import '../../../data/model/response/seller_model.dart';
import '../../../helper/date_converter.dart';
import '../../../provider/localization_provider.dart';
import '../../../provider/splash_provider.dart';
import '../../basewidget/shimmer_loading.dart';
import '../seller/seller_screen.dart';
import '../../../data/model/response/order_details.dart';
import '../../../data/model/response/order_model.dart';

import '../../../helper/price_converter.dart';
import '../../../localization/language_constrants.dart';
import '../../../provider/order_provider.dart';
import '../../../provider/profile_provider.dart';
import '../../../provider/seller_provider.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/custom_themes.dart';
import '../../../utill/dimensions.dart';
import '../../basewidget/amount_widget.dart';
import '../../basewidget/button/custom_button.dart';
import '../../basewidget/custom_app_bar.dart';
import '../../basewidget/show_custom_snakbar.dart';
import '../../basewidget/title_row.dart';
import 'widget/order_details_widget.dart';
import '../payment/payment_screen.dart';
import '../support/support_ticket_screen.dart';
import '../tracking/tracking_screen.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel orderModel;
  final int orderId;
  OrderDetailsScreen({@required this.orderModel, @required this.orderId});

  void _loadData(BuildContext context) async {
    await Provider.of<OrderProvider>(context, listen: false)
        .initTrackingInfo(orderId.toString(), orderModel, true, context);
    if (orderModel == null) {
      await Provider.of<SplashProvider>(context, listen: false)
          .initConfig(context);
    }
    Provider.of<SellerProvider>(context, listen: false).removePrevOrderSeller();
    await Provider.of<ProfileProvider>(context, listen: false)
        .initAddressList(context);
    if (Provider.of<SplashProvider>(context, listen: false)
            .configModel
            .shippingMethod ==
        'sellerwise_shipping') {
      await Provider.of<OrderProvider>(context, listen: false).initShippingList(
        context,
        Provider.of<OrderProvider>(context, listen: false)
            .trackingModel
            .sellerId,
      );
    } else {
      await Provider.of<OrderProvider>(context, listen: false)
          .initShippingList(context, 1);
    }
    Provider.of<OrderProvider>(context, listen: false).getOrderDetails(
      orderId.toString(),
      context,
      Provider.of<LocalizationProvider>(context, listen: false)
          .locale
          .countryCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    _loadData(context);

    return Scaffold(
      backgroundColor: ColorResources.getIconBg(context),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomAppBar(title: getTranslated('ORDER_DETAILS', context)),
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, order, child) {
                List<int> sellerList = [];
                List<List<OrderDetailsModel>> sellerProductList = [];
                double _order = 0;
                double _discount = 0;
                double _tax = 0;
                String shippingPartner = '';
                double _shippingFee = 0;
                String shippingAddress = '';

                if (order.orderDetails != null) {
                  order.orderDetails.forEach((orderDetails) {
                    if (!sellerList
                        .contains(orderDetails.productDetails.userId)) {
                      sellerList.add(orderDetails.productDetails.userId);
                    }
                  });
                  sellerList.forEach((seller) {
                    Provider.of<SellerProvider>(context, listen: false)
                        .initSeller(seller.toString(), context);
                    List<OrderDetailsModel> orderList = [];
                    order.orderDetails.forEach((orderDetails) {
                      if (seller == orderDetails.productDetails.userId) {
                        orderList.add(orderDetails);
                      }
                    });
                    sellerProductList.add(orderList);
                  });

                  order.orderDetails.forEach((orderDetails) {
                    _order = _order + (orderDetails.price * orderDetails.qty);
                    _discount = _discount + orderDetails.discount;
                    _tax = _tax + (orderDetails.tax * orderDetails.qty);
                  });

                  if (order.shippingList != null) {
                    order.shippingList.forEach((shipping) {
                      if (order.trackingModel != null &&
                          shipping.id == order.trackingModel.shippingMethodId) {
                        shippingPartner = shipping.title;
                        _shippingFee = shipping.cost;
                      }
                    });
                  }
                }

                return order.orderDetails != null
                    ? ListView(
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.all(0),
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
                                horizontal: Dimensions.PADDING_SIZE_SMALL),
                            child: Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: getTranslated(
                                              'ORDER_ID', context),
                                          style: titilliumRegular.copyWith(
                                            fontSize:
                                                Dimensions.FONT_SIZE_SMALL,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyText1
                                                .color,
                                          )),
                                      TextSpan(
                                          text: order.trackingModel != null
                                              ? order.trackingModel.id
                                                  .toString()
                                              : '',
                                          style: titilliumSemiBold.copyWith(
                                              color: ColorResources.getPrimary(
                                                  context))),
                                    ],
                                  ),
                                ),
                                Expanded(child: SizedBox()),
                                Text(
                                    DateConverter.localDateToIsoStringAMPM(
                                        order.trackingModel != null
                                            ? DateTime.parse(
                                                order.trackingModel.createdAt)
                                            : DateTime(0)),
                                    style: titilliumRegular.copyWith(
                                        color: ColorResources.getTextTitle(
                                            context),
                                        fontSize: Dimensions.FONT_SIZE_SMALL)),
                              ],
                            ),
                          ),

                          Container(
                            padding:
                                EdgeInsets.all(Dimensions.MARGIN_SIZE_SMALL),
                            decoration: BoxDecoration(
                                color: Theme.of(context).highlightColor),
                            child: Column(
                              children: [
                                if (shippingPartner != 'Pickup')
                                  Row(children: [
                                    Expanded(
                                        child: Text(
                                            getTranslated(
                                                'SHIPPING_TO', context),
                                            style: titilliumRegular)),
                                    Consumer<ProfileProvider>(
                                      builder: (context, profile, child) {
                                        print(
                                            '=====Addreesss====>$shippingAddress');

                                        if (profile.addressList != null) {
                                          profile.addressList
                                              .forEach((address) {
                                            if ( order.trackingModel != null &&address.id ==
                                                order.trackingModel
                                                    .shippingAddress) {
                                              shippingAddress = address.address;
                                            }
                                          });
                                        }
                                        return Text(shippingAddress,
                                            style: titilliumRegular.copyWith(
                                                fontSize: Dimensions
                                                    .FONT_SIZE_SMALL));
                                      },
                                    ),
                                  ]),
                                if (shippingPartner != 'Pickup') Divider(),
                                Row(children: [
                                  Expanded(
                                      child: Text(
                                          getTranslated(
                                              'SHIPPING_PARTNER', context),
                                          style: titilliumRegular)),
                                  Text(shippingPartner,
                                      style: titilliumSemiBold.copyWith(
                                          color: ColorResources.getPrimary(
                                              context))),
                                ]),
                              ],
                            ),
                          ),
                          SizedBox(height: Dimensions.MARGIN_SIZE_DEFAULT),

                          Container(
                            padding:
                                EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                            color: Theme.of(context).highlightColor,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      getTranslated('ORDERED_PRODUCT', context),
                                      style: robotoBold.copyWith(
                                          color: Theme.of(context).hintColor)),
                                  Divider(),
                                ]),
                          ),

                          ListView.builder(
                            itemCount: sellerList.length,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.all(0),
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        Dimensions.MARGIN_SIZE_EXTRA_LARGE,
                                    vertical: Dimensions.MARGIN_SIZE_SMALL),
                                color: Theme.of(context).highlightColor,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (Provider.of<SellerProvider>(
                                                          context,
                                                          listen: false)
                                                      .orderSellerList
                                                      .length !=
                                                  0 &&
                                              sellerList[index] != 1) {
                                            SellerModel seller =
                                                Provider.of<SellerProvider>(
                                                        context,
                                                        listen: false)
                                                    .orderSellerList[index];
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) {
                                                return SellerScreen(
                                                    seller: seller);
                                              }),
                                            );
                                          }
                                        },
                                        child: Row(children: [
                                          Expanded(
                                              child: Text(
                                                  getTranslated(
                                                      'seller', context),
                                                  style: robotoBold)),
                                          Text(
                                            sellerList[index] == 1
                                                ? 'Admin'
                                                : Provider.of<SellerProvider>(
                                                                context)
                                                            .orderSellerList
                                                            .length <
                                                        index + 1
                                                    ? sellerList[index]
                                                        .toString()
                                                    : '${Provider.of<SellerProvider>(context).orderSellerList[index].fName} '
                                                        '${Provider.of<SellerProvider>(context).orderSellerList[index].lName}',
                                            style: titilliumRegular.copyWith(
                                                color: ColorResources
                                                    .HINT_TEXT_COLOR),
                                          ),
                                          SizedBox(
                                              width: Dimensions
                                                  .PADDING_SIZE_EXTRA_SMALL),
                                          Icon(Icons.chat,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 20),
                                        ]),
                                      ),
                                      Text(
                                          getTranslated(
                                              'ORDERED_PRODUCT', context),
                                          style: robotoBold.copyWith(
                                              color: ColorResources
                                                  .HINT_TEXT_COLOR)),
                                      Divider(),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(0),
                                        itemCount:
                                            sellerProductList[index].length,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, i) =>
                                            OrderDetailsWidget(
                                                orderDetailsModel:
                                                    sellerProductList[index][i],
                                                callback: () {
                                                  showCustomSnackBar(
                                                      'Review submitted successfully',
                                                      context,
                                                      isError: false);
                                                }),
                                      ),
                                    ]),
                              );
                            },
                          ),
                          SizedBox(height: Dimensions.MARGIN_SIZE_DEFAULT),

                          // Amounts
                          Container(
                            padding:
                                EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                            color: Theme.of(context).highlightColor,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TitleRow(
                                      title: getTranslated('TOTAL', context)),
                                  AmountWidget(
                                      title: getTranslated('ORDER', context),
                                      amount: PriceConverter.convertPrice(
                                          context, _order)),
                                  AmountWidget(
                                      title: getTranslated(
                                          'SHIPPING_FEE', context),
                                      amount: PriceConverter.convertPrice(
                                          context, _shippingFee)),
                                  AmountWidget(
                                      title: getTranslated('DISCOUNT', context),
                                      amount: PriceConverter.convertPrice(
                                          context, _discount)),
                                  AmountWidget(
                                    title: getTranslated(
                                        'coupon_voucher', context),
                                    amount:order.trackingModel!= null ? PriceConverter.convertPrice(context,
                                        order.trackingModel.discountAmount) : '',
                                  ),
                                  AmountWidget(
                                      title: getTranslated('TAX', context),
                                      amount: PriceConverter.convertPrice(
                                          context, _tax)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: Dimensions
                                            .PADDING_SIZE_EXTRA_SMALL),
                                    child: Divider(
                                        height: 2,
                                        color: ColorResources.HINT_TEXT_COLOR),
                                  ),
                                  AmountWidget(
                                    title:
                                        getTranslated('TOTAL_PAYABLE', context),
                                    amount: PriceConverter.convertPrice(
                                        context,
                                        (_order +
                                            _shippingFee -
                                            _discount -(
                                            order.trackingModel != null ? order.trackingModel?.discountAmount : 0 )+
                                            _tax)),
                                  ),
                                ]),
                          ),
                          SizedBox(height: Dimensions.MARGIN_SIZE_DEFAULT),

                          // Payment
                          Container(
                            padding:
                                EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                            decoration: BoxDecoration(
                                color: Theme.of(context).highlightColor),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(getTranslated('PAYMENT', context),
                                      style: robotoBold),
                                  SizedBox(
                                      height:
                                          Dimensions.MARGIN_SIZE_EXTRA_SMALL),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            getTranslated(
                                                'PAYMENT_STATUS', context),
                                            style: titilliumRegular.copyWith(
                                                fontSize: Dimensions
                                                    .FONT_SIZE_SMALL)),
                                        Text(
                                          (order.trackingModel !=null && order.trackingModel.paymentStatus !=
                                                      null &&
                                                  order.trackingModel
                                                      .paymentStatus.isNotEmpty)
                                              ? order
                                                  .trackingModel.paymentStatus
                                              : 'Digital Payment',
                                          style: titilliumRegular.copyWith(
                                              fontSize:
                                                  Dimensions.FONT_SIZE_SMALL),
                                        ),
                                      ]),
                                  SizedBox(
                                      height:
                                          Dimensions.MARGIN_SIZE_EXTRA_SMALL),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            getTranslated(
                                                'PAYMENT_PLATFORM', context),
                                            style: titilliumRegular.copyWith(
                                                fontSize: Dimensions
                                                    .FONT_SIZE_SMALL)),
                                        (order.trackingModel != null && order.trackingModel.paymentMethod !=
                                                    'cash_on_delivery' &&
                                                order.trackingModel
                                                        .paymentStatus ==
                                                    'unpaid')
                                            ? InkWell(
                                                onTap: () async {
                                                  String userID = await Provider
                                                          .of<ProfileProvider>(
                                                              context,
                                                              listen: false)
                                                      .getUserInfo(context);
                                                  Navigator.pushReplacement(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (_) =>
                                                              PaymentScreen(
                                                                customerID:
                                                                    userID,
                                                                couponCode: '',
                                                                addressID: order.trackingModel!= null? order
                                                                    .trackingModel
                                                                    .shippingAddress
                                                                    .toString() : '0',
                                                              )));
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: Dimensions
                                                          .PADDING_SIZE_EXTRA_SMALL),
                                                  decoration: BoxDecoration(
                                                    color: ColorResources
                                                        .getPrimary(context),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Text(
                                                      getTranslated(
                                                          'pay_now', context),
                                                      style: titilliumSemiBold
                                                          .copyWith(
                                                        fontSize: Dimensions
                                                            .FONT_SIZE_EXTRA_SMALL,
                                                        color: Theme.of(context)
                                                            .highlightColor,
                                                      )),
                                                ),
                                              )
                                            : Text( order.trackingModel != null &&
                                                order.trackingModel
                                                            .paymentMethod !=
                                                        null
                                                    ? order.trackingModel
                                                        .paymentMethod
                                                        .replaceAll('_', ' ')
                                                    : 'Digital Payment',
                                                style: titilliumBold.copyWith(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                )),
                                      ]),
                                ]),
                          ),
                          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                          // Buttons
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: Dimensions.PADDING_SIZE_LARGE,
                                vertical: Dimensions.PADDING_SIZE_SMALL),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    buttonText:
                                        getTranslated('TRACK_ORDER', context),
                                    onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TrackingScreen(
                                                    orderID:
                                                        orderId.toString()))),
                                  ),
                                ),
                                SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                                Expanded(
                                  child: SizedBox(
                                    height: 45,
                                    child: TextButton(
                                      onPressed: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  SupportTicketScreen())),
                                      child: Text(
                                        getTranslated(
                                            'SUPPORT_CENTER', context),
                                        style: titilliumSemiBold.copyWith(
                                            fontSize: 16,
                                            color: ColorResources.getPrimary(
                                                context)),
                                      ),
                                      style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        side: BorderSide(
                                            color: ColorResources.getPrimary(
                                                context)),
                                      )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : LoadingPage(); //Center(child: CustomLoader(color: Theme.of(context).primaryColor));
              },
            ),
          )
        ],
      ),
    );
  }
}
