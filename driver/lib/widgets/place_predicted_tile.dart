import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../assistance/request_assistant.dart';
import '../global/global.dart';
import '../global/map_key.dart';
import '../infoHandler/app_info.dart';
import '../models/directions.dart';
import '../models/predicted_places.dart';
import '../widgets/progress_dialog.dart';

class PlacePredictionTileDesign extends StatefulWidget {


  final PredictedPlaces? predictedPlaces;

  PlacePredictionTileDesign({this.predictedPlaces});

  @override
  State<PlacePredictionTileDesign> createState() => _PlacePredictionTileDesignState();
}

class _PlacePredictionTileDesignState extends State<PlacePredictionTileDesign> {

  getplaceDirectionDetails(String? placeId, context) async {
    showDialog(context: context,
        builder: (BuildContext context)=>ProgressDialog(
          message: "Setting up Drop-Off . please wait ....",
        )
    );
    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

    print("here is response api $responseApi");

    Navigator.pop(context);

    if(responseApi == "Error Occured. Failed No Response."){
      return ;
    }

    if(responseApi["status"]=="OK"){
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];



      Provider.of<AppInfo>(context,listen: false).updateDropOffLocationAddress(directions);
      setState(() {
        // userDropOffAddress = directions.locationName!;

      });

      Navigator.pop(context,"obtainedDropOff");

    }


  }


  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
        onPressed: (){
          if (widget.predictedPlaces!.place_id != null) {
            getplaceDirectionDetails(
                widget.predictedPlaces!.place_id!, context);
          }

        },
        style: ElevatedButton.styleFrom(primary: darkTheme? Colors.black : Colors.white),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(children: [

            Icon(Icons.add_location),
            SizedBox(width: 10.0,),
            Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                        widget.predictedPlaces!.main_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            color: darkTheme ?Colors.amber.shade400 : Colors.blue
                        )
                    ),
                    Text(
                        widget.predictedPlaces!.secondary_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            color: darkTheme ?Colors.amber.shade400 : Colors.blue
                        )
                    )
                  ],)

            )

          ]),

        ));
  }
}