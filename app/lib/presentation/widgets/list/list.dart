import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/logic/bloc/list/list.cubit.dart';

class List extends StatefulWidget {
  final String emptyText;
  final ListCubit list;
  final Function builder;

  const List(
      {required this.emptyText,
      required this.list,
      required this.builder,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ListState();
}

class _ListState extends State<List> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    controller.addListener(() {
      if (controller.position.pixels >= controller.position.maxScrollExtent) {
        print("Scroller triggering next");
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
            var children = <Widget>[];
            state.data.forEach((el) {
              children.add(widget.builder(el));
            });
            if (state.loading) {
              children.add(Center(
                  child: Container(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator())));
            } else {
              if (state.data.isEmpty) {
                children.add(Text(widget.emptyText));
              }
            }

            return ListView(
              children: children,
              controller: controller,
            );
          },
        ));
  }
}
