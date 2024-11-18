import 'package:chatting_app/auth/select_contacts/Model/contact_users.dart';
import 'package:chatting_app/auth/select_contacts/repository/select_contact_repo.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// final getContactsProvidercontacts = StreamProvider<List<Contacts>>((ref) {
//   final selectContactRepository = ref.watch(selectContactsRepositoryProvider);

//   return selectContactRepository.getContactsStream();
// });
final getContactsProvidercontactsstream = StreamProvider<List<Contacts>>((ref) {
  final selectContactRepository = ref.watch(selectContactsRepositoryProvider);

  return selectContactRepository.getContactsStream();
});
final selectContactControllerProvidercontacts = Provider((ref) {
  final selectContactRepository = ref.watch(selectContactsRepositoryProvider);
  return SelectContactController(
    ref: ref,
    selectContactRepository: selectContactRepository,
  );
});

class SelectContactController {
  final ProviderRef ref;
  final SelectContactRepository selectContactRepository;

  SelectContactController({
    required this.ref,
    required this.selectContactRepository,
  });

  void selectContact(Contacts selectedContact, BuildContext context) {
    // print('controller select contact');
    selectContactRepository.selectContact(selectedContact, context);
  }

  Stream<List<Contacts>> getcontactslist() {
    print("controller select");
    print(
        "selectContactRepository.getContactsStream();${selectContactRepository.getContactsStream()}");
    return selectContactRepository.getContactsStream();
  }
}
