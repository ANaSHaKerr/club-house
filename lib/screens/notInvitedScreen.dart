import 'package:clay_containers/clay_containers.dart';
import 'package:flutter/material.dart';


class NotInvitedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body:  Container(
              color: Colors.grey[300],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Center(
                    child: ClayContainer(
                      color:  Colors.grey[300],
                      width: 200,
                      height: 200,
                      borderRadius: 20,
                      depth: 20,
                      curveType: CurveType.concave,
                      child:Center(
                          child:Icon(Icons.person_add_disabled,
                            size: 85,
                            color: Colors.black38,),


                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text("You have not been invited yet",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.black38
                      ),),
                  )

                ],
              ),
            )
        )



    );
  }
}