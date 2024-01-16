import 'dart:async';

import 'package:flutter/material.dart';
import '../assistance/request_assistant.dart';
import '../global/map_key.dart';
import '../models/predicted_places.dart';
import '../widgets/place_predicted_tile.dart';

import 'dart:convert';

class SearchPlaceScreen extends StatefulWidget {
  const SearchPlaceScreen({super.key});

  @override
  State<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {


  List<PredictedPlaces> placesPredictedList =[];
  late final Function debounceSearch;

  @override
  void initState() {
    super.initState();
    debounceSearch = _debounce(findPlaceAutoCompleteSearch, Duration(milliseconds: 2000));
  }



  findPlaceAutoCompleteSearch(String inputText) async {

    if(inputText.length >3){
      String urlAutoCompleteSearch ="https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey&components=country:IN";

      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      print("$responseAutoCompleteSearch");

      if(responseAutoCompleteSearch == "Error Occured. Failed No response."){
        return ;
      }

      if(responseAutoCompleteSearch["status"]=="OK"){
        var placePrediction = responseAutoCompleteSearch["predictions"];
        var placePredictionsList = (placePrediction as List).map((jsonData)=>PredictedPlaces.fromJson(jsonData)).toList();


        setState(() {
          placesPredictedList = placePredictionsList;
        });
      }

    }

  }

  Function _debounce(Function func, Duration duration) {
    Timer? _timer;
    return () {
      if (_timer != null) {
        _timer!.cancel();
      }
      _timer = Timer(duration, () => func());
    };
  }

  @override
  Widget build(BuildContext context) {

    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;


    return GestureDetector(
      onTap: (){
        Focus.of(context).unfocus();
      },

      child:  Scaffold(
          backgroundColor: darkTheme?Colors.black :Colors.white,

          appBar: AppBar(
            backgroundColor: darkTheme?Colors.amber.shade400 :Colors.blue,
            leading: GestureDetector(
              onTap :(){
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back, color:darkTheme?Colors.black :Colors.white,),

            ),

            title: Text("Search & Set location"),
          ),
          body: Column(children: [
            Container(
                decoration: BoxDecoration(
                    color: darkTheme?Colors.amber.shade400 :Colors.blue,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.white54,
                          blurRadius: 8,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7)
                      )
                    ]

                ),
                child: Padding(padding: EdgeInsets.all(10.0),
                  child: Column(children: [
                    Row(
                      children: [
                        Icon(Icons.adjust_sharp,
                          color: darkTheme ? Colors.black : Colors.white,
                        ),
                        SizedBox(height: 10.0,),

                        Expanded(child: Padding(
                          padding: EdgeInsets.all(8),
                          child: TextField(
                            onChanged: (value){
                              findPlaceAutoCompleteSearch(value);
                            },
                            decoration: InputDecoration(
                                hintText : "Search loaction here ..",
                                fillColor: darkTheme ? Colors.black : Colors.white,
                                filled : true,
                                border : InputBorder.none,
                                contentPadding: EdgeInsets.only(
                                    left : 11,
                                    top : 8,
                                    bottom: 8
                                )

                            ),

                          ),
                        ))
                      ],)
                  ]),

                )
            ),

            //display place prediction reult

            (placesPredictedList.length>0)
                ? Expanded(
                child: ListView.separated(
                  itemCount: placesPredictedList.length,
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context,index){
                    return PlacePredictionTileDesign(
                        predictedPlaces: placesPredictedList[index]
                    );
                  },
                  separatorBuilder: (BuildContext context,int index){
                    return Divider(
                      height: 0,
                      color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                      thickness: 0,

                    );
                  },
                )
            ) : Container(),
          ],)




      ),

    );
  }


}