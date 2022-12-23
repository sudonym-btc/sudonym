import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

const loadingCircle = CustomPadding(
    multiplier: 2,
    child: Center(
        child: SizedBox(
            width: 20, height: 20, child: CircularProgressIndicator())));

class ListWidget extends StatefulWidget with ListLogger {
  final String? emptyText;
  final ListCubit Function() list;
  final Widget Function(dynamic el) builder;
  final Widget? appendItem;

  const ListWidget(
      {this.emptyText,
      required this.list,
      required this.builder,
      this.appendItem,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget>
    with ListLogger, TickerProviderStateMixin {
  final ScrollController controller = ScrollController();
  late ListCubit c;
  late final AnimationController _previousLoadingController =
      AnimationController(
    duration: const Duration(milliseconds: 50),
    vsync: this,
  );
  late final Animation<double> _previousLoadingAnimation = CurvedAnimation(
    parent: _previousLoadingController,
    curve: Curves.slowMiddle,
  );
  late final AnimationController _nextLoadingController = AnimationController(
    duration: const Duration(milliseconds: 50),
    vsync: this,
  );
  late final Animation<double> _nextLoadingAnimation = CurvedAnimation(
    parent: _nextLoadingController,
    curve: Curves.slowMiddle,
  );

  @override
  void initState() {
    c = widget.list();
    controller.addListener(() {
      if (controller.position.pixels == 0 && !controller.position.outOfRange) {
        loggy.v('Loading previous due to scroll');
        c.loadPrevious();
      }
      if (controller.position.pixels >= controller.position.maxScrollExtent &&
          !controller.position.outOfRange) {
        loggy.v('Loading next due to scroll');
        c.loadNext();
      }
    });
    loggy.v('Loading next due to init');
    c.loadNext();
    _nextLoadingController.forward();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    _previousLoadingController.dispose();
    _nextLoadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => c,
        child: BlocConsumer<ListCubit<dynamic>, ListCubitState<dynamic>>(
          listener: (context, state) {
            if (state.loadingPrevious) {
              _previousLoadingController.forward();
            } else {
              _previousLoadingController.reverse();
            }

            if (state.loadingNext) {
              _nextLoadingController.forward();
            } else {
              _nextLoadingController.reverse();
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                SizeTransition(
                    sizeFactor: _previousLoadingAnimation,
                    child: loadingCircle),
                ...(!state.loading &&
                        state.data.isEmpty &&
                        widget.emptyText != null)
                    ? [
                        AnimatedContainer(
                            duration: const Duration(milliseconds: 50),
                            child: Info(widget.emptyText!))
                      ]
                    : [],
                state.data.isNotEmpty
                    ? Expanded(
                        child: LiveList(
                        showItemInterval: const Duration(milliseconds: 50),
                        showItemDuration: const Duration(milliseconds: 50),
                        shrinkWrap: true,
                        controller: controller,
                        itemBuilder: (context, index, animation) =>
                            FadeTransition(
                                opacity: animation,
                                child: widget.builder(state.data[index])),
                        itemCount: state.data.length,
                      ))
                    : Container(),
                ...(!state.loading && widget.appendItem != null
                    ? [widget.appendItem!]
                    : []),
                SizeTransition(
                    sizeFactor: _nextLoadingAnimation, child: loadingCircle)
              ],
            );
          },
        ));
  }
}
