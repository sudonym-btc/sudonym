import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/logic/index.dart';
import 'package:sudonym/presentation/index.dart';

const loadingCircle = Padding(
    padding: EdgeInsets.all(padding * 2),
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
    duration: const Duration(milliseconds: 200),
    vsync: this,
  );
  late final Animation<double> _previousLoadingAnimation = CurvedAnimation(
    parent: _previousLoadingController,
    curve: Curves.slowMiddle,
  );
  late final AnimationController _nextLoadingController = AnimationController(
    duration: const Duration(milliseconds: 200),
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
      if (controller.position.pixels == 0) {
        loggy.v('Loading previous due to scroll');
        c.loadPrevious();
      }
      if (controller.position.pixels >= controller.position.maxScrollExtent) {
        loggy.v('Loading next due to scroll');
        c.loadNext();
      }
    });
    loggy.v('Loading next due to init');
    c.loadNext();
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
            List<Widget> children = [];

            children.add(SizeTransition(
                sizeFactor: _previousLoadingAnimation, child: loadingCircle));

            children
                .addAll(state.data.map<Widget>((e) => Container()).toList());

            children.add(SizeTransition(
                sizeFactor: _nextLoadingAnimation, child: loadingCircle));

            if (!state.loading) {
              if (state.data.isEmpty && widget.emptyText != null) {
                children.add(AnimatedContainer(
                    duration: const Duration(milliseconds: 2000),
                    child: Info(widget.emptyText!)));
              }
              if (widget.appendItem != null) {
                children.add(widget.appendItem!);
              }
            }

            return LiveList(
              showItemInterval: const Duration(milliseconds: 50),
              showItemDuration: const Duration(milliseconds: 100),
              shrinkWrap: true,
              controller: controller,
              itemBuilder: (context, index, animation) {
                if (index > 0 && index < state.data.length + 1) {
                  return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0,
                            end: 1,
                          ).animate(animation),
                          child: widget.builder(state.data[index - 1])));
                } else {
                  return children[index];
                }
              },
              itemCount: children.length,
            );
          },
        ));
  }
}
