import 'package:flutter/material.dart';
import 'package:sudonym/constants.dart';

class EditPotName extends StatefulWidget {
  const EditPotName({Key? key}) : super(key: key);

  @override
  State<EditPotName> createState() => _EditPotNameState();
}

class _EditPotNameState extends State<EditPotName> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Pot Name:',
            style: TextStyle(fontSize: 17, color: textColor),
          ),
          Container(
            height: 75,
            width: 350,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 2),
              child: Center(
                child: TextField(
                  style: TextStyle(fontSize: 17),
                  decoration: InputDecoration(
                    hintText: 'Edit Pot Name',
                    suffixIcon: Icon(Icons.wallet),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DropDownCurrencyMenu extends StatefulWidget {
  const DropDownCurrencyMenu({Key? key}) : super(key: key);

  @override
  State<DropDownCurrencyMenu> createState() => _DropDownCurrencyMenuState();
}

class _DropDownCurrencyMenuState extends State<DropDownCurrencyMenu> {
  String dropdownValue = 'Bitcoin';
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            'Currency:',
            style: TextStyle(fontSize: 17, color: textColor),
          ),
          Container(
            height: 75,
            width: 350,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black, width: 1)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: dropdownValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  style: const TextStyle(fontSize: 17, color: textColor),
                  underline: null,
                  items: <String>['Bitcoin', 'Satoshis', 'USD']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SaveChanges extends StatelessWidget {
  const SaveChanges({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: null,
        child: Container(
          height: 50,
          width: 350,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: primary),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Save Changes',
                style: TextStyle(fontSize: 17, color: textColor),
              )
            ],
          ),
        ),
      ),
    );
  }
}
