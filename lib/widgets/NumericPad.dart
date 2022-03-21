import 'package:clay_containers/clay_containers.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
String countryCode  ;

class NumericPad extends StatelessWidget {

  final Function(int) onNumberSelected;

  NumericPad({@required this.onNumberSelected});

  @override
  Widget build(BuildContext context) {
    return  ClayContainer(
      color: Get.isDarkMode? Colors.grey[800] :  Colors.grey[100],
      curveType: CurveType.convex,

      depth: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[

          Container(
            height: MediaQuery.of(context).size.height * 0.11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildNumber(1),
                buildNumber(2),
                buildNumber(3),
              ],
            ),
          ),

          Container(
            height: MediaQuery.of(context).size.height * 0.11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildNumber(4),
                buildNumber(5),
                buildNumber(6),
              ],
            ),
          ),

          Container(
            height: MediaQuery.of(context).size.height * 0.11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildNumber(7),
                buildNumber(8),
                buildNumber(9),
              ],
            ),
          ),

          Container(
            height: MediaQuery.of(context).size.height * 0.11,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ClayContainer(
                      color: Get.isDarkMode? Colors.grey[800] :  Colors.grey[100],
                      spread: Get.isDarkMode? 0.5:1,
                      curveType: CurveType.concave,
                      height: 80,

                      borderRadius: 15,
                      depth: 20,

                      child: CountryCodePicker(
                        onChanged: ( country) {
                          print(country.dialCode);
                          countryCode = country.dialCode;
                        },
                        initialSelection: 'EG',
                        favorite: ['+20','EG'],
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        onInit: (code) => countryCode = code.dialCode,
                      ),
                    ),
                  ),
                ),
                buildNumber(0),
                buildBackspace(),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget buildNumber(int number) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onNumberSelected(number);
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child:ClayContainer(
            color:Get.isDarkMode? Colors.grey[800] :  Colors.grey[100],
            curveType: CurveType.concave,
            borderRadius: 15,
            depth: 20,
            spread: Get.isDarkMode ? 0.5 : 1,

            child: Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color:Get.isDarkMode? Colors.white70 :  Color(0xFF1F1F1F),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBackspace() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          onNumberSelected(-1);
        },
        child: Padding(
          padding: EdgeInsets.all(10),
          child: ClayContainer(
            color: Get.isDarkMode? Colors.grey[800] : Colors.grey[100],
            spread: Get.isDarkMode ? 0.5 : 1,

            curveType: CurveType.concave,

            borderRadius: 15,
            depth: 30,
            child: Center(
              child: Icon(
                Icons.backspace,
                size: 28,
                color:Get.isDarkMode? Colors.white70 : Color(0xFF1F1F1F),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptySpace() {
    return Expanded(
      child: Container(),
    );
  }

}