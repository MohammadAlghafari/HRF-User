import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/model/response/seller_model.dart';
import '../../../helper/product_type.dart';
import '../../../helper/url_helper.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/product_provider.dart';
import '../../../provider/splash_provider.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/custom_themes.dart';
import '../../../utill/dimensions.dart';
import '../../../utill/images.dart';
import '../../basewidget/animated_custom_dialog.dart';
import '../../basewidget/guest_dialog.dart';
import '../../basewidget/search_widget.dart';
import '../chat/chat_screen.dart';
import '../home/widget/products_view.dart';

class SellerScreen extends StatefulWidget {
  final SellerModel seller;
  SellerScreen({@required this.seller});

  @override
  State<SellerScreen> createState() => _SellerScreenState();
}

class _SellerScreenState extends State<SellerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<ProductProvider>(context, listen: false)
            .removeFirstLoading());
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<ProductProvider>(context, listen: false).clearSellerData());
    WidgetsBinding.instance.addPostFrameCallback((_) =>
        Provider.of<ProductProvider>(context, listen: false)
            .initSellerProductList(widget.seller.id.toString(), 1, context));
  }

  @override
  Widget build(BuildContext context) {
    ScrollController _scrollController = ScrollController();

    return Scaffold(
      backgroundColor: ColorResources.getIconBg(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(
          Icons.directions,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          SearchWidget(
            hintText: 'Search product...',
            onTextChanged: (String newText) =>
                Provider.of<ProductProvider>(context, listen: false)
                    .filterData(newText),
            onClearPressed: () {
              UrlHelper.openMap(widget.seller.shop.lat, widget.seller.shop.lng);
            },
          ),
          Expanded(
            child: ListView(
              controller: _scrollController,
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(0),
              children: [
                // Banner
                Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl:
                            '${Provider.of<SplashProvider>(context, listen: false).baseUrls.shopImageUrl}/banner/${widget.seller.shop != null ? widget.seller.shop.image : ''}',
                        placeholder: (context, url) => Image.asset(
                          Images.placeholder,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                        height: 120,
                        errorWidget: (c, o, s) => Image.asset(
                            Images.placeholder,
                            height: 120,
                            fit: BoxFit.cover),
                      )
                      /* FadeInImage.assetNetwork(
                      placeholder: Images.placeholder,
                      height: 120,
                      fit: BoxFit.cover,
                      image:
                          '${Provider.of<SplashProvider>(context, listen: false).baseUrls.shopImageUrl}/banner/${widget.seller.shop != null ? widget.seller.shop.image : ''}',
                      imageErrorBuilder: (c, o, s) => Image.asset(
                          Images.placeholder,
                          height: 120,
                          fit: BoxFit.cover),
                    ), */
                      ),
                ),

                Container(
                  color: Theme.of(context).highlightColor,
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  child: Column(children: [
                    // Seller Info
                    Row(children: [
                      ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: CachedNetworkImage(
                            imageUrl:
                                '${Provider.of<SplashProvider>(context, listen: false).baseUrls.sellerImageUrl}/${widget.seller.image}',
                            placeholder: (context, url) => Image.asset(
                              Images.placeholder,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                            width: 80,
                            height: 80,
                            errorWidget: (c, o, s) => Image.asset(
                                Images.placeholder,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover),
                          )
                          /* FadeInImage.assetNetwork(
                          placeholder: Images.placeholder,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                          image:
                              '${Provider.of<SplashProvider>(context, listen: false).baseUrls.sellerImageUrl}/${widget.seller.image}',
                          imageErrorBuilder: (c, o, s) => Image.asset(
                              Images.placeholder,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover),
                        ), */
                          ),
                      SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                      Expanded(
                        child: Text(
                          widget.seller.fName + ' ' + widget.seller.lName,
                          style: titilliumSemiBold.copyWith(
                              fontSize: Dimensions.FONT_SIZE_LARGE),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (!Provider.of<AuthProvider>(context, listen: false)
                              .isLoggedIn()) {
                            showAnimatedDialog(context, GuestDialog(),
                                isFlip: true);
                          } else if (widget.seller != null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ChatScreen(seller: widget.seller)));
                          }
                        },
                        icon: Image.asset(Images.chat_image,
                            color: ColorResources.SELLER_TXT,
                            height: Dimensions.ICON_SIZE_DEFAULT),
                      ),
                    ]),
                  ]),
                ),
                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                Padding(
                  padding: EdgeInsets.all(Dimensions.PADDING_SIZE_EXTRA_SMALL),
                  child: ProductView(
                      isHomePage: false,
                      productType: ProductType.SELLER_PRODUCT,
                      scrollController: _scrollController,
                      sellerId: widget.seller.id.toString()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
