import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/data/repository/pot.repository.dart';
import 'package:sudonym/logic/bloc/list/list.cubit.dart';

import '../../injection.dart';
import '../widgets/pot/pot.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  // ListCubit<Pot> potList;

  PageController controller = PageController();

  @override
  void initState() {
    // potList.loadNext();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => ListCubit(getIt<PotRepository>())..loadNext())
        ],
        child: BlocBuilder<ListCubit<dynamic>, ListCubitState<dynamic>>(
          builder: (context, state) {
            var children = <Widget>[];
            state.data.forEach((el) {
              children.add(Pot(
                potId: el.id,
              ));
            });

            return Container(
                color: Theme.of(context).colorScheme.background,
                child: SafeArea(
                    bottom: false,
                    child: Scaffold(
                        appBar: AppBar(actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                            icon: FaIcon(FontAwesomeIcons.cog, size: 14),
                          )
                        ]),
                        body: state.loading
                            ? Center(child: CircularProgressIndicator())
                            : Column(
                                children: [
                                  Expanded(
                                    child: PageView(
                                      controller: controller,
                                      scrollDirection: Axis.horizontal,
                                      children: children,
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.all(padding),
                                      child: SmoothPageIndicator(
                                        controller:
                                            controller, // PageController
                                        count: children.length > 0
                                            ? children.length
                                            : 1,

                                        // forcing the indicator to use a specific direction
                                        effect: ExpandingDotsEffect(
                                            dotHeight: 6,
                                            dotWidth: 6,
                                            activeDotColor:
                                                Theme.of(context).primaryColor),
                                      ))
                                ],
                              ))));
          },
        ));
  }
}
