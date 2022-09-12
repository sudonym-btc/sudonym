import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/constants.dart';
import 'package:sudonym/logic/bloc/list/list.cubit.dart';

class ListWidget extends StatefulWidget {
  final String emptyText;
  final ListCubit list;
  final Widget Function(dynamic el) builder;

  const ListWidget(
      {required this.emptyText,
      required this.list,
      required this.builder,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    controller.addListener(() {
      if (controller.position.pixels >= controller.position.maxScrollExtent) {
        widget.list.loadNext();
      }
    });
    widget.list.loadNext();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => widget.list)],
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
              if (state.data.isEmpty) {
                children.add(Text(widget.emptyText));
              }
            }

            return ListView(
              controller: controller,
              children: children,
            );
          },
        ));
  }
}
