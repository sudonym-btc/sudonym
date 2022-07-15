import 'package:flutter/material.dart';
import 'package:sudonym/constants.dart';

class NFC extends StatelessWidget {
  const NFC({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 50),
        child: Container(
          width: 400,
          height: 125,
          decoration: const BoxDecoration(color: greyTint),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: greyTint,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.wifi,
                  color: textColor,
                  size: 40,
                ),
                Text(
                  'Tap to receiver device (NFC)',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}


//Widget build(BuildContext context) {
    //return ClipOval(
      //  child: Column(
      //children: const [
        //Icon(
         // Icons.person,
        //),
        //Text(
         // 'Tap to sender device(NFC',
          //style: TextStyle(
           // color: textColor,
            //fontSize: 17,
          //),
       // ),
      //],
   // ));

    //child:
    // Container(
    //  width: 400,
    //   height: 150,
    //   decoration: const BoxDecoration(color: greyTint),
    //   child: ElevatedButton(
       // style: ElevatedButton.styleFrom(primary: greyTint),
       // onPressed: () {},
        //child: const Text(
        //  'Tap to sender device (NFC)',
        //  style: TextStyle(color: textColor),
       // ),
      //),
    //);

    //Column(
     // children: const [
      //  Icon(Icons.person),
       // Text(
        //  'Tap to sender device(NFC',
        //  style: TextStyle(
         //   color: textColor,
          //  fontSize: 17,
          //),
       // ),
      //],
    //);

    //ClipOval(
     // child: Container(
      //  width: 400,
       // height: 100,
        //decoration: const BoxDecoration(color: greyTint),
        //child: ElevatedButton( // style: ElevatedButton.styleFrom(primary: greyTint),
//onPressed: () {},
//child: const Text('Tap to sender device (NFC)'),
       // ),
 //     ),
 //   );
 // }
//}



   // ClipOval(
     // child: Container(
       // width: 400,
        //height: 150,
        //decoration: const BoxDecoration(
         // color: greyTint,
        //),
        //child: ElevatedButton(
          //style: ElevatedButton.styleFrom(
            //primary: greyTint,
          //),
          //child: const Text(
            //'Tap to sender device (NFC)',
            //style: TextStyle(
              //color: textColor,
              //fontSize: 17,
            //),
          //),
          //onPressed: () {},
        //),
      //),
    //);
  //}
//}

