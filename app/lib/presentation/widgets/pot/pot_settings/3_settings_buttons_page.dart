// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:sudonym/presentation/widgets/pot/pot_settings/credit_card/creditcard.dart';
// import 'package:sudonym/presentation/widgets/pot/pot_settings/add_money/add_money_page.dart';
// import 'package:sudonym/presentation/widgets/pot/pot_settings/edit_pot/edit_pot_page.dart';
// import 'package:sudonym/presentation/widgets/pot/pot_settings/setting_button.dart';

// class SettingsButton extends StatelessWidget {
//   const SettingsButton({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         SettingButtons(
//           icon1: const FaIcon(
//             FontAwesomeIcons.piggyBank,
//             size: 15,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const AddMoneyPage()),
//             );
//           },
//         ),
//         SettingButtons(
//           icon1: const FaIcon(
//             FontAwesomeIcons.edit,
//             size: 15,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const EditPot()),
//             );
//           },
//         ),
//         SettingButtons(
//           icon1: const FaIcon(
//             FontAwesomeIcons.creditCard,
//             size: 15,
//             color: Colors.white,
//           ),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => CreditCard()),
//             );
//           },
//         )
//       ],
//     );
//   }
// }
