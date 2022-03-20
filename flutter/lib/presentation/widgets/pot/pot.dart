import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sudonym/logic/bloc/pot.cubit.dart';
import 'package:sudonym/presentation/widgets/pot/pot_header.dart';
import 'package:sudonym/presentation/widgets/pot/send_receive.dart';
import 'package:sudonym/presentation/widgets/transactions/transactions.dart';

import '../../../injection.dart';

class Pot extends StatelessWidget {
  final num potId;
  const Pot({required this.potId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [BlocProvider(create: (_) => getIt<PotCubit>())],
        child: BlocBuilder<PotCubit, PotCubitState>(
            builder: (BuildContext context, state) {
          if (state.loading) {
            return Center(child: const CircularProgressIndicator());
          }
          return Stack(
            children: <Widget>[
              Positioned.fill(
                bottom: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                    children: [const PotHeader(), SendReceive(potId: potId)]),
              ),
              TransactionsSlidable(),
            ],
          );
        }));
  }
}


class TransactionsSlidable extends StatefulWidget {
  @override
  _TransactionsSlidableState createState() => _TransactionsSlidableState();
}

class _TransactionsSlidableState extends State<TransactionsSlidable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double get minHeight => MediaQuery.of(context).size.height * 0.2;


  double get maxHeight =>
      MediaQuery.of(context).size.height -
      Scaffold.of(context).appBarMaxHeight! -
      MediaQuery.of(context).padding.top -
      20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      //<-- initialize a controller
      vsync: this,
      duration: Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); //<-- and remember to dispose it!
    super.dispose();
  }

  double lerp(double min, double max) => lerpDouble(min, max,
      _controller.value)!; //<-- lerp any value based on the controller

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          height: lerp(minHeight, maxHeight),
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: _toggle,
            onVerticalDragUpdate: _handleDragUpdate,
            onVerticalDragEnd: _handleDragEnd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Transactions(),
            ),
          ),
        );
      },
    );
  }

  void _toggle() {
    final bool isOpen = _controller.status == AnimationStatus.completed;
    _controller.fling(
        velocity: isOpen ? -2 : 2); //<-- ...snap the sheet in proper direction
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _controller.value -= details.primaryDelta! / maxHeight;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_controller.isAnimating ||
        _controller.status == AnimationStatus.completed) return;

    final double flingVelocity =
        details.velocity.pixelsPerSecond.dy / maxHeight;
    if (flingVelocity < 0.0)
      _controller.fling(velocity: math.max(2.0, -flingVelocity));
    else if (flingVelocity > 0.0)
      _controller.fling(velocity: math.min(-2.0, -flingVelocity));
    else
      _controller.fling(velocity: _controller.value < 0.5 ? -2.0 : 2.0);
  }
}
