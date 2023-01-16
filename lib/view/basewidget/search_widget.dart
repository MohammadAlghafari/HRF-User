import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/search_provider.dart';
import '../../provider/theme_provider.dart';
import '../../utill/color_resources.dart';
import '../../utill/custom_themes.dart';
import '../../utill/dimensions.dart';
import '../../utill/images.dart';

class SearchWidget extends StatelessWidget {
  final String hintText;
  final Function onTextChanged;
  final Function onClearPressed;
  final Function onSubmit;
  SearchWidget({@required this.hintText, this.onTextChanged, @required this.onClearPressed, this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController(text: Provider.of<SearchProvider>(context).searchText);
    return Stack(children: [
      ClipRRect(
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5), bottomRight: Radius.circular(5)),
        child: Image.asset(
          Images.toolbar_background,
          fit: BoxFit.fill,
          height: 50 + MediaQuery.of(context).padding.top,
          width: MediaQuery.of(context).size.width,
          color: Provider.of<ThemeProvider>(context).darkTheme ? Colors.black : null,
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        padding: EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        height: 50,
        alignment: Alignment.center,
        child: Row(children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
              decoration: BoxDecoration(color: ColorResources.getTextBg(context), borderRadius: BorderRadius.circular(8.0)),
              child: TextFormField(
                controller: _controller,
                onFieldSubmitted: onSubmit!= null ? (query) {
                  if(query.isNotEmpty)
                  onSubmit(query);
                } : null,
                onChanged: onTextChanged != null ? (query) {
                  onTextChanged(query);
                } : null,
                textInputAction: TextInputAction.search,
                maxLines: 1,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: hintText,
                  isDense: true,
                  hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: ColorResources.getColombiaBlue(context), size: Dimensions.ICON_SIZE_DEFAULT),
                  suffixIcon:  IconButton(
                    icon: Icon(Icons.clear, color: Colors.black45),
                    onPressed: () {
                      onClearPressed();
                      _controller.clear();
                      onTextChanged('');
                    },
                  )
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
        ]),
      ),
    ]);
  }
}
