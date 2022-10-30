import 'package:injectable/injectable.dart';
import 'package:sudonym.models/index.dart';
import 'package:sudonym/data/index.dart';

import 'package:sudonym/logic/index.dart';

@injectable
class ContactCubit
    extends EntityCubit<ContactRepository, ContactCubitState, Contact> {
  ContactCubit()
      : super(
            initialState: ContactCubitState(),
            stateClass: ContactCubitState.init);
}

class ContactCubitState extends EntityCubitState<Contact> {
  ContactCubitState({Contact? entity, bool loading = false})
      : super(entity: entity, loading: loading);

  ContactCubitState.init({Contact? entity, bool loading = false})
      : super(entity: entity, loading: loading);
}
