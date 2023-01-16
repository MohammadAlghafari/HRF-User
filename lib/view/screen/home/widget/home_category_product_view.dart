import 'package:flutter/material.dart';
import '../../../../data/model/response/home_category_product_model.dart';
import '../../../../provider/home_category_product_provider.dart';
import '../../../../utill/dimensions.dart';
import '../../../basewidget/product_widget.dart';
import '../../../basewidget/title_row.dart';
import '../../product/brand_and_category_product_screen.dart';
import '../../product/product_details_screen.dart';
import 'package:provider/provider.dart';

class HomeCategoryProductView extends StatelessWidget {
  final bool isHomePage;
  HomeCategoryProductView({@required this.isHomePage});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeCategoryProductProvider>(
      builder: (context, homeCategoryProductProvider, child) {
        List<HomeCategoryProduct> categories = homeCategoryProductProvider
            .homeCategoryProductList
            .where((element) => element.products.length != 0).toList();
        return categories.length != 0
            ? ListView.builder(
                itemCount:
                    categories.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (ctx, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isHomePage
                          ? Padding(
                              padding: EdgeInsets.fromLTRB(
                                  Dimensions.PADDING_SIZE_SMALL,
                                  20,
                                  Dimensions.PADDING_SIZE_SMALL,
                                  Dimensions.PADDING_SIZE_SMALL),
                              child: TitleRow(
                                title: categories[index].name,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              BrandAndCategoryProductScreen(
                                                isBrand: false,
                                                id: categories[
                                                        index]
                                                    .id
                                                    .toString(),
                                                name:categories[
                                                        index]
                                                    .name,
                                              )));
                                },
                              ),
                            )
                          : SizedBox(),
                      ConstrainedBox(
                        constraints: categories[index]
                                    .products
                                    .length >
                                0
                            ? BoxConstraints(maxHeight: 240)
                            : BoxConstraints(maxHeight: 0),
                        child: ListView.builder(
                            itemCount: categories[index].products.length,
                            padding: EdgeInsets.all(0),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int i) {
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        transitionDuration:
                                            Duration(milliseconds: 1000),
                                        pageBuilder: (context, anim1, anim2) =>
                                            ProductDetails(
                                                product:
                                                    homeCategoryProductProvider
                                                        .productList[i]),
                                      ));
                                },
                                child: Container(
                                    width: (MediaQuery.of(context).size.width /
                                            2) -
                                        20,
                                    child: ProductWidget(
                                        productModel:
                                           categories[index]
                                                .products[i])),
                              );
                            }),
                      )
                    ],
                  );
                })
            : SizedBox();
      },
    );
  }
}
