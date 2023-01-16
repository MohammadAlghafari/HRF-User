import 'package:flutter/material.dart';
import 'package:place_picker/place_picker.dart';
import 'package:provider/provider.dart';

import '../../../../data/model/response/address_model.dart';
import '../../../../localization/language_constrants.dart';
import '../../../../provider/localization_provider.dart';
import '../../../../provider/profile_provider.dart';
import '../../../../provider/splash_provider.dart';
import '../../../../utill/color_resources.dart';
import '../../../../utill/custom_themes.dart';
import '../../../../utill/dimensions.dart';
import '../../../basewidget/button/custom_button.dart';
import '../../../basewidget/textfield/custom_textfield.dart';

class AddAddressBottomSheet extends StatefulWidget {
  final LocationResult locationResult;

  AddAddressBottomSheet({@required this.locationResult});
  @override
  _AddAddressBottomSheetState createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<AddAddressBottomSheet> {
  final FocusNode _buttonAddressFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _buildingFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _zipCodeFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityNameController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  LocationResult _locationResult;

  @override
  void initState() {
    super.initState();
    Provider.of<ProfileProvider>(context, listen: false)
        .setAddAddressErrorText(null);
    _addressController.text = widget.locationResult.formattedAddress;
    _cityNameController.text = widget.locationResult.country.name +
        ' ' +
        widget.locationResult.city.name;
    _locationResult = widget.locationResult;
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityNameController.dispose();
    _buildingController.dispose();
    _descriptionController.dispose();
    _zipCodeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _buttonAddressFocus.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _cityFocus.dispose();
    _buildingFocus.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_DEFAULT),
      decoration: BoxDecoration(
          color: Theme.of(context).highlightColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Form(
        key: _formKey,
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).highlightColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 1)) // changes position of shadow
                    ],
                  ),
                  child: TextFormField(
                    //controller: controller,
                    maxLines: 1,
                    readOnly: true,
                    onTap: () async {
                      LocationResult result =
                          await Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => PlacePicker(
                                    Provider.of<SplashProvider>(context,
                                            listen: false)
                                        .configModel
                                        .googleMapsKey,
                                  )));
                      if (result != null) {
                        _locationResult = result;
                        _addressController.text =
                            _locationResult.formattedAddress;
                        _cityNameController.text =
                            _locationResult.country.name +
                                ' ' +
                                _locationResult.city.name;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: getTranslated('SELECT_ADDRESS_ON_MAP', context),
                      suffixIcon: Padding(
                        padding: Provider.of<LocalizationProvider>(context)
                                    .locale
                                    .languageCode ==
                                'en'
                            ? const EdgeInsets.only(right: 6)
                            : const EdgeInsets.only(left: 6),
                        child: Icon(
                          Icons.location_on_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        ),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 12.0, horizontal: 15),
                      isDense: true,
                      counterText: '',
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      hintStyle: titilliumRegular.copyWith(color: Colors.black),
                      errorStyle: TextStyle(height: 1.5),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Consumer<ProfileProvider>(
                    builder: (context, profileProvider, child) {
                  return Container(
                    padding: EdgeInsets.only(
                      left: Dimensions.PADDING_SIZE_DEFAULT,
                      right: Dimensions.PADDING_SIZE_DEFAULT,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).highlightColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 7,
                          offset: Offset(0, 1), // changes position of shadow
                        )
                      ],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6)),
                    ),
                    alignment: Alignment.center,
                    child: DropdownButtonFormField<String>(
                      value: profileProvider.addressType,
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down,
                          color: Theme.of(context).primaryColor),
                      decoration: InputDecoration(border: InputBorder.none),
                      iconSize: 24,
                      elevation: 16,
                      style: titilliumRegular,
                      //underline: SizedBox(),

                      onChanged: profileProvider.updateCountryCode,
                      items: profileProvider.addressTypeList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                              style: titilliumRegular.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .color)),
                        );
                      }).toList(),
                    ),
                  );
                }),
                //Divider(thickness: 0.7, color: ColorResources.GREY),
                /* CustomTextField(
                  hintText: getTranslated('ENTER_YOUR_NAME', context),
                  controller: _nameController,
                  textInputType: TextInputType.streetAddress,
                  focusNode: _nameFocus,
                  nextNode: _cityFocus,
                  textInputAction: TextInputAction.next,
                ), */
                Divider(thickness: 0.7, color: ColorResources.GREY),
                CustomTextField(
                  hintText: getTranslated('ENTER_YOUR_CITY', context),
                  controller: _cityNameController,
                  textInputType: TextInputType.streetAddress,
                  focusNode: _cityFocus,
                  nextNode: _buttonAddressFocus,
                  textInputAction: TextInputAction.next,
                ),
                Divider(thickness: 0.7, color: ColorResources.GREY),
                CustomTextField(
                  hintText: getTranslated('ENTER_YOUR_ADDRESS', context),
                  controller: _addressController,
                  textInputType: TextInputType.streetAddress,
                  focusNode: _buttonAddressFocus,
                  nextNode: _buildingFocus,
                  textInputAction: TextInputAction.next,
                ),
                Divider(thickness: 0.7, color: ColorResources.GREY),
                CustomTextField(
                  hintText: getTranslated('ENTER_YOUR_BUILDING_NO', context),
                  controller: _buildingController,
                  textInputType: TextInputType.streetAddress,
                  focusNode: _buildingFocus,
                  nextNode: _phoneFocus,
                  textInputAction: TextInputAction.next,
                ),
                Divider(thickness: 0.7, color: ColorResources.GREY),
                CustomTextField(
                  hintText: getTranslated('ENTER_YOUR_PHONE', context),
                  controller: _phoneController,
                  textInputType: TextInputType.phone,
                  focusNode: _phoneFocus,
                  nextNode: _descriptionFocus,
                  textInputAction: TextInputAction.next,
                ),
                Divider(thickness: 0.7, color: ColorResources.GREY),
                CustomTextField(
                  hintText: getTranslated('ENTER_DESCRIPTION', context),
                  controller: _descriptionController,
                  textInputType: TextInputType.streetAddress,
                  focusNode: _descriptionFocus,
                  nextNode: _zipCodeFocus,
                  textInputAction: TextInputAction.next,
                ),
                //Divider(thickness: 0.7, color: ColorResources.GREY),
                /* CustomTextField(
                  hintText: getTranslated('ENTER_YOUR_ZIP_CODE', context),
                  isPhoneNumber: true,
                  controller: _zipCodeController,
                  textInputType: TextInputType.number,
                  focusNode: _zipCodeFocus,
                  textInputAction: TextInputAction.done,
                ), */
                //SizedBox(height: 30),
                Provider.of<ProfileProvider>(context).addAddressErrorText !=
                        null
                    ? Text(
                        Provider.of<ProfileProvider>(context)
                            .addAddressErrorText,
                        style: titilliumRegular.copyWith(
                            color: ColorResources.RED))
                    : SizedBox.shrink(),
                Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    return profileProvider.isLoading
                        ? CircularProgressIndicator(
                            key: Key(''),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor))
                        : CustomButton(
                            buttonText:
                                getTranslated('UPDATE_ADDRESS', context),
                            onTap: () {
                              _addAddress();
                            },
                          );
                  },
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _addAddress() {
    if (Provider.of<ProfileProvider>(context, listen: false).addressType ==
        Provider.of<ProfileProvider>(context, listen: false)
            .addressTypeList[0]) {
      Provider.of<ProfileProvider>(context, listen: false)
          .setAddAddressErrorText(
              getTranslated('SELECT_ADDRESS_TYPE', context));
    } else if (_addressController.text.isEmpty) {
      Provider.of<ProfileProvider>(context, listen: false)
          .setAddAddressErrorText(
              getTranslated('ADDRESS_FIELD_MUST_BE_REQUIRED', context));
    } else if (_phoneController.text.isEmpty) {
      Provider.of<ProfileProvider>(context, listen: false)
          .setAddAddressErrorText(
              getTranslated('PHONE_FIELD_MUST_BE_REQUIRED', context));
    } else if (_cityNameController.text.isEmpty) {
      Provider.of<ProfileProvider>(context, listen: false)
          .setAddAddressErrorText(
              getTranslated('CITY_FIELD_MUST_BE_REQUIRED', context));
    } else if (_buildingController.text.isEmpty) {
      Provider.of<ProfileProvider>(context, listen: false)
          .setAddAddressErrorText(
              getTranslated('BUILDING_FIELD_MUST_BE_REQUIRED', context));
    } else {
      Provider.of<ProfileProvider>(context, listen: false)
          .setAddAddressErrorText(null);
      AddressModel addressModel = AddressModel();
      addressModel.contactPersonName = _nameController.text;
      addressModel.addressType =
          Provider.of<ProfileProvider>(context, listen: false).addressType;
      addressModel.city = _cityNameController.text;
      addressModel.address = _addressController.text;
      addressModel.phone = _phoneController.text;
      addressModel.building = _buildingController.text;
      addressModel.description = _descriptionController.text ?? '';
      addressModel.zip = _zipCodeController.text;
      addressModel.lat = _locationResult.latLng.latitude.toString();
      addressModel.lng = _locationResult.latLng.longitude.toString();

      Provider.of<ProfileProvider>(context, listen: false)
          .addAddress(addressModel, route);
    }
  }

  route(bool isRoute, String message) {
    if (isRoute) {
      _cityNameController.clear();
      _zipCodeController.clear();
      Provider.of<ProfileProvider>(context, listen: false)
          .initAddressList(context);
      Navigator.pop(context);
    }
  }
}
