import 'package:flutter/material.dart';
import '../../../data/model/response/support_ticket_model.dart';
import '../../../helper/date_converter.dart';
import '../../../localization/language_constrants.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/support_ticket_provider.dart';
import '../../../utill/color_resources.dart';
import '../../../utill/custom_themes.dart';
import '../../../utill/dimensions.dart';
import '../../basewidget/custom_expanded_app_bar.dart';
import '../../basewidget/custom_loader.dart';
import 'package:provider/provider.dart';

class SupportConversationScreen extends StatelessWidget {
  final SupportTicketModel supportTicketModel;
  SupportConversationScreen({@required this.supportTicketModel});

  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if(Provider.of<AuthProvider>(context, listen: false).isLoggedIn()) {
      Provider.of<SupportTicketProvider>(context, listen: false).getSupportTicketReplyList(context, supportTicketModel.id);
    }

    return CustomExpandedAppBar(
      title: getTranslated('support_ticket_conversation', context),
      isGuestCheck: true,
      child: Column(children: [

        Container(
          padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
          decoration: BoxDecoration(
            color: ColorResources.getImageBg(context),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ColorResources.getSellerTxt(context), width: 2),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Place date: ${supportTicketModel.createdAt}',
              style: titilliumRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL),
            ),
            Text(supportTicketModel.subject, style: titilliumSemiBold),
            Row(children: [
              Icon(Icons.notifications, color: ColorResources.getPrimary(context), size: 20),
              SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
              Expanded(child: Text(supportTicketModel.type, style: titilliumSemiBold)),
              TextButton(
                onPressed: null,
                style: TextButton.styleFrom(
                  backgroundColor: supportTicketModel.status == 1 ? ColorResources.getGreen(context) : Theme.of(context).primaryColor,
                ),
                child: Text(
                  supportTicketModel.status == 0 ? getTranslated('opened', context) : getTranslated('solved', context),
                  style: titilliumSemiBold.copyWith(color: Colors.white),
                ),
              ),
            ]),
          ]),
        ),

        Expanded(child: Consumer<SupportTicketProvider>(builder: (context, support, child) {
          return support.supportReplyList != null ? ListView.builder(
            itemCount: support.supportReplyList.length,
            reverse: true,
            itemBuilder: (context, index) {
              bool _isMe = support.supportReplyList[index].customerMessage != null;
              String _message = _isMe ? support.supportReplyList[index].customerMessage : support.supportReplyList[index].adminMessage;
              String dateTime = DateConverter.isoStringToLocalDateAndTime(support.supportReplyList[index].createdAt);
              return Container(
                margin: _isMe ?  EdgeInsets.fromLTRB(50, 5, 10, 5) : EdgeInsets.fromLTRB(10, 5, 50, 5),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: _isMe ? Radius.circular(10) : Radius.circular(0),
                    bottomRight: _isMe ? Radius.circular(0) : Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: _isMe ? ColorResources.getImageBg(context) : Theme.of(context).highlightColor,
                ),
                child: Column(crossAxisAlignment: _isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
                  Text(dateTime, style: titilliumRegular.copyWith(
                    fontSize: 8,
                    color: ColorResources.getHint(context),
                  )),
                  _message != null ? Text(_message, style: titilliumRegular.copyWith(fontSize: Dimensions.FONT_SIZE_SMALL)) : SizedBox.shrink(),
                  //chat.image != null ? Image.file(chat.image) : SizedBox.shrink(),
                ]),
              );
            },
          ) : Center(child: CustomLoader(color: Theme.of(context).primaryColor));
        })),

        SizedBox(
          height: 70,
          child: Card(
            color: Theme.of(context).highlightColor,
            shadowColor: Colors.grey[200],
            elevation: 2,
            margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: titilliumRegular,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    expands: true,
                    decoration: InputDecoration(
                      hintText: 'Type here...',
                      hintStyle: titilliumRegular.copyWith(color: ColorResources.HINT_TEXT_COLOR),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if(_controller.text.isNotEmpty){
                      Provider.of<SupportTicketProvider>(context, listen: false).sendReply(context, supportTicketModel.id, _controller.text);
                      _controller.text = '';
                    }else {

                    }
                  },
                  child: Icon(
                    Icons.send,
                    color: Theme.of(context).primaryColor,
                    size: Dimensions.ICON_SIZE_DEFAULT,
                  ),
                ),
              ]),
            ),
          ),
        ),

      ]),
    );
  }
}
