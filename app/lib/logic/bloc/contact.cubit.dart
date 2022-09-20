import 'package:injectable/injectable.dart';
import 'package:sudonym.models/contact.dart';

import '../../data/repository/contact.repository.dart';
import 'entity_cubit_state.dart';

@injectable
class ContactCubit extends EntityCubit<ContactCubitState, Contact> {
  @override
  final ContactRepository repository;

  ContactCubit(this.repository)
      : super(ContactCubitState(), ContactCubitState.init);
}

class ContactCubitState extends EntityCubitState<Contact> {
  ContactCubitState({Contact? entity = null, bool loading = false})
      : super(entity: entity, loading: loading);

  ContactCubitState.init({Contact? entity = null, bool loading = false})
      : super(entity: entity, loading: loading);
}
