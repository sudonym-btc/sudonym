import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class PotSliderCubit extends Cubit<int> {
  PotSliderCubit(int initialState) : super(initialState);

  set(id) {
    emit(id);
  }
}
