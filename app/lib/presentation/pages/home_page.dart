import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/data/index.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/injection.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => ListCubit(getIt<PotRepository>())..loadNext())
        ],
        child: BlocBuilder<ListCubit<dynamic>, ListCubitState<dynamic>>(
          builder: (context, state) {
            List<Widget> children =
                state.data.map<Widget>((e) => Pot(entity: e)).toList();
            children.add(const AddPotSlide());

            return Container(
                color: Theme.of(context).backgroundColor,
                child: SafeArea(
                    child: Scaffold(
                        appBar: AppBar(actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/settings');
                            },
                            icon: const FaIcon(FontAwesomeIcons.gear, size: 14),
                          )
                        ]),
                        body: state.loading
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
                                  Padding(
                                      padding: const EdgeInsets.all(padding),
                                      child: SmoothPageIndicator(
                                        controller:
                                            controller, // PageController
                                        count: (children.isNotEmpty
                                            ? children.length
                                            : 1),

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

class AddPotSlide extends StatelessWidget {
  const AddPotSlide({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Button(
            text: 'Add Pot',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const EditPot()));
            }));
  }
}
