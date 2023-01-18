import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/injection.dart';
import 'package:sudonym/logic/bloc/current_pot.service.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym.models/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  PageController controller = PageController();
  late ListCubit<Pot> l;
  Color currentColor = Colors.orangeAccent;
  @override
  void initState() {
    l = ListCubit<Pot>(getIt<PotRepository>(),
        column: '\$PotUser.index\$',
        order: 'ASC',
        getId: (Pot element) => element.PotUser.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) {
            return PotListReorganizerCubit(list: l, controller: controller);
          }),
          BlocProvider(create: (_) {
            controller.addListener(() {
              setState(() {
                currentColor = Color.alphaBlend(
                  Theme.of(context)
                      .primaryColor
                      .withAlpha((255 * (min(controller.page!, 1.0))).toInt()),
                  Colors.orangeAccent,
                );
              });
              if ((controller.page! % 1) == 0) {
                getIt<CurrentPotService>().set(
                    l.state.data.length > controller.page!.toInt()
                        ? l.state.data[controller.page!.toInt()]
                        : null);
              }
            });
            l.loadNext().then(
                (value) => {getIt<CurrentPotService>().set(value.data[0])});
            return l;
          })
        ],
        child: BlocBuilder<ListCubit<Pot>, ListCubitState<dynamic>>(
          builder: (context, state) {
            List<Widget> children = state.data
                .map<Widget>((e) => OnePage(child: PotPage(entity: e)))
                .toList();
            if (state.data.length < 10) children.add(const AddPotSlide());

            return Container(
                color: Theme.of(context).backgroundColor,
                child: Scaffold(
                    appBar: AppBar(actions: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                        icon:
                            const FaIcon(FontAwesomeIcons.gear, size: iconSize),
                      )
                    ]),
                    body: SafeArea(
                        child: state.loading && state.data.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : Column(
                                children: [
                                  Expanded(
                                    child: PageView(
                                      controller: controller,
                                      scrollDirection: Axis.horizontal,
                                      children: children,
                                    ),
                                  ),
                                  CustomPadding(
                                      child: SmoothPageIndicator(
                                    controller: controller, // PageController
                                    count: (children.isNotEmpty
                                        ? children.length
                                        : 1),

                                    // forcing the indicator to use a specific direction
                                    effect: ExpandingDotsEffect(
                                        dotHeight: 6,
                                        dotWidth: 6,
                                        activeDotColor: currentColor),
                                  ))
                                ],
                              ))));
          },
        ));
  }
}

class OnePage extends StatefulWidget {
  final Widget child;

  const OnePage({required this.child}) : super();

  @override
  _OnePageState createState() => new _OnePageState();
}

class _OnePageState extends State<OnePage>
    with AutomaticKeepAliveClientMixin<OnePage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

class AddPotSlide extends StatelessWidget {
  const AddPotSlide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Button(
            text: AppLocalizations.of(context)!.createPot,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const EditPot()));
            }));
  }
}
