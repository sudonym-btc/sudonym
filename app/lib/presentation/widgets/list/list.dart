import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/config/logger.dart';
import 'package:sudonym/presentation/index.dart';
import 'package:sudonym/logic/index.dart';

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

class _ListWidgetState extends State<ListWidget> with ListLogger {
  final ScrollController controller = ScrollController();
  late ListCubit c;

  @override
  void initState() {
    c = widget.list();
    controller.addListener(() {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => c,
        child: BlocBuilder<ListCubit<dynamic>, ListCubitState<dynamic>>(
          builder: (context, state) {
            List<Widget> children =
                state.data.map<Widget>((e) => widget.builder(e)).toList();

            if (state.loading) {
              children.add(Center(
                  child: Column(children: const [
                SizedBox(
                  height: padding * 2,
                ),
                SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator())
              ])));
            } else {
              if (state.data.isEmpty && widget.emptyText != null) {
                children.add(Text(widget.emptyText!));
              }
              if (widget.appendItem != null) {
                children.add(widget.appendItem!);
              }
            }

            return ListView.builder(
              controller: controller,
              itemBuilder: (context, index) => children[index],
              itemCount: children.length,
            );
          },
        ));
  }
}
