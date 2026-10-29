import 'package:app/core/services/auth_service.dart';
import 'package:app/features/family_link/services/family_link_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseApp emulatorApp;
  late FirebaseAuth auth;
  late FirebaseFirestore firestore;
  late _EmulatorFixture fixture;

  setUpAll(() async {
    emulatorApp = await Firebase.initializeApp(
      name: 'task023-emulator-${DateTime.now().microsecondsSinceEpoch}',
      options: const FirebaseOptions(
        apiKey: 'demo-task023-key',
        appId: '1:1234567890:web:task023',
        messagingSenderId: '1234567890',
        projectId: 'lacos-dev',
      ),
    );
    auth = FirebaseAuth.instanceFor(app: emulatorApp);
    firestore = FirebaseFirestore.instanceFor(app: emulatorApp);
    firestore.settings = const Settings(persistenceEnabled: false);

    await auth.useAuthEmulator('127.0.0.1', 9099);
    firestore.useFirestoreEmulator('127.0.0.1', 8080);
  });

  setUp(() async {
    await auth.signOut();
    fixture = _EmulatorFixture(auth: auth, firestore: firestore);
  });

  tearDown(() => fixture.cleanup());

  tearDownAll(() async {
    await auth.signOut();
    await emulatorApp.delete();
  });

  testWidgets('cria familiar sem vínculo', (tester) async {
    await tester.runAsync(() async {
      final family = await fixture.signUpFamily();
      final familySnapshot =
          await firestore.collection('familiares').doc(family.uid).get();

      expect(familySnapshot.data(), containsPair('role', 'familiar'));
      expect(familySnapshot.data(), containsPair('linkedElderEmail', null));
      expect(familySnapshot.data(), containsPair('familyLinkStatus', 'none'));
      expect(familySnapshot.data(), isNot(contains('linkedElderUid')));
    });
  });

  testWidgets('trata linkedElderEmail vazio como vínculo opcional',
      (tester) async {
    await tester.runAsync(() async {
      final family = await fixture.signUpFamily(linkedElderEmail: '');
      final familySnapshot =
          await firestore.collection('familiares').doc(family.uid).get();

      expect(familySnapshot.data(), containsPair('linkedElderEmail', null));
      expect(familySnapshot.data(), containsPair('familyLinkStatus', 'none'));
      expect(familySnapshot.data(), isNot(contains('linkedElderUid')));
    });
  });

  testWidgets('remove conta Auth quando o e-mail não corresponde a um idoso',
      (tester) async {
    await tester.runAsync(() async {
      final elder = await fixture.createElder();
      final family = fixture.newAccount('family');

      await expectLater(
        fixture.signUpFamily(
          account: family,
          linkedElderEmail: 'outro-${elder.email}',
        ),
        throwsA(
          isA<FirebaseAuthException>().having(
            (error) => error.code,
            'code',
            'linked-elder-not-found',
          ),
        ),
      );

      expect(auth.currentUser, isNull);
      await fixture.expectAccountDoesNotExist(family);
      await auth.signInWithEmailAndPassword(
        email: elder.email,
        password: elder.password,
      );
      final elderSnapshot =
          await firestore.collection('idosos').doc(elder.uid).get();
      expect(elderSnapshot.data(), isNot(contains('linkedFamilyUid')));
    });
  });

  testWidgets('trata linkedElderEmail com espaços como vínculo opcional',
      (tester) async {
    await tester.runAsync(() async {
      final family = await fixture.signUpFamily(linkedElderEmail: '   ');
      final familySnapshot =
          await firestore.collection('familiares').doc(family.uid).get();

      expect(familySnapshot.data(), containsPair('linkedElderEmail', null));
      expect(familySnapshot.data(), containsPair('familyLinkStatus', 'none'));
    });
  });

  testWidgets('vincula automaticamente e normaliza espaços do e-mail',
      (tester) async {
    await tester.runAsync(() async {
      final elder = await fixture.createElder();
      final family = await fixture.signUpFamily(
        linkedElderEmail: '  ${elder.email}  ',
      );

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: elder.email,
        password: elder.password,
      );
      final elderSnapshot =
          await firestore.collection('idosos').doc(elder.uid).get();
      final notifications = await firestore
          .collection('idosos')
          .doc(elder.uid)
          .collection('notificacoes')
          .where('type', isEqualTo: 'family_link_created')
          .get();

      expect(elderSnapshot.data(), containsPair('linkedFamilyUid', family.uid));
      expect(elderSnapshot.data(), containsPair('familyLinkStatus', 'active'));
      expect(notifications.docs, hasLength(1));
      expect(notifications.docs.single.data(),
          containsPair('familyUid', family.uid));
      expect(notifications.docs.single.data(),
          containsPair('familyName', 'Familiar TASK-023'));

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: family.email,
        password: family.password,
      );
      final familySnapshot =
          await firestore.collection('familiares').doc(family.uid).get();

      expect(familySnapshot.data(), containsPair('linkedElderUid', elder.uid));
      expect(
          familySnapshot.data(), containsPair('linkedElderEmail', elder.email));
      expect(familySnapshot.data(), containsPair('familyLinkStatus', 'active'));
    });
  });

  testWidgets('remove conta Auth quando o idoso informado não existe',
      (tester) async {
    await tester.runAsync(() async {
      final family = fixture.newAccount('family');

      await expectLater(
        fixture.signUpFamily(
          account: family,
          linkedElderEmail: 'missing-${family.email}',
        ),
        throwsA(
          isA<FirebaseAuthException>().having(
            (error) => error.code,
            'code',
            'linked-elder-not-found',
          ),
        ),
      );
      expect(auth.currentUser, isNull);
      await fixture.expectAccountDoesNotExist(family);
    });
  });

  testWidgets('rejeita linkedElderEmail malformado e remove a conta Auth',
      (tester) async {
    await tester.runAsync(() async {
      final family = fixture.newAccount('family');

      await expectLater(
        fixture.signUpFamily(
          account: family,
          linkedElderEmail: 'not-an-email',
        ),
        throwsA(
          isA<FirebaseAuthException>().having(
            (error) => error.code,
            'code',
            'linked-elder-not-found',
          ),
        ),
      );

      expect(auth.currentUser, isNull);
      await fixture.expectAccountDoesNotExist(family);
    });
  });

  testWidgets('remove conta Auth quando o idoso já tem familiar ativo',
      (tester) async {
    await tester.runAsync(() async {
      final elder = await fixture.createElder(initialData: {
        'linkedFamilyUid': 'existing-family',
        'familyLinkStatus': 'active',
      });
      final family = fixture.newAccount('family');

      await expectLater(
        fixture.signUpFamily(
          account: family,
          linkedElderEmail: elder.email,
        ),
        throwsA(
          isA<FirebaseAuthException>().having(
            (error) => error.code,
            'code',
            'elder-already-linked',
          ),
        ),
      );

      expect(auth.currentUser, isNull);
      await fixture.expectAccountDoesNotExist(family);
      await auth.signInWithEmailAndPassword(
        email: elder.email,
        password: elder.password,
      );
      final elderSnapshot =
          await firestore.collection('idosos').doc(elder.uid).get();
      expect(
        elderSnapshot.data(),
        containsPair('linkedFamilyUid', 'existing-family'),
      );
    });
  });

  testWidgets('remove conta Auth quando o documento não tem role de idoso',
      (tester) async {
    await tester.runAsync(() async {
      final invalidProfile = await fixture.createElder(
        initialData: {'role': 'familiar'},
      );
      final family = fixture.newAccount('family');

      await expectLater(
        fixture.signUpFamily(
          account: family,
          linkedElderEmail: invalidProfile.email,
        ),
        throwsA(
          isA<FirebaseAuthException>().having(
            (error) => error.code,
            'code',
            'linked-elder-not-found',
          ),
        ),
      );

      expect(auth.currentUser, isNull);
      await fixture.expectAccountDoesNotExist(family);
    });
  });

  testWidgets('bloqueia o vínculo e gera notificação de status',
      (tester) async {
    await tester.runAsync(() async {
      final elder = await fixture.createElder();
      final family = await fixture.signUpFamily(
        linkedElderEmail: elder.email,
      );

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: elder.email,
        password: elder.password,
      );
      final linkService = FamilyLinkService(
        auth: auth,
        firestore: firestore,
      );
      await linkService.blockFamilyMember(
        elderUid: elder.uid!,
        familyUid: family.uid!,
      );

      final elderSnapshot =
          await firestore.collection('idosos').doc(elder.uid).get();
      final familySnapshot =
          await firestore.collection('familiares').doc(family.uid).get();
      expect(elderSnapshot.data(), containsPair('familyLinkStatus', 'blocked'));
      expect(
          familySnapshot.data(), containsPair('familyLinkStatus', 'blocked'));
      expect(
        elderSnapshot.data()?['familyLinkBlockedAt'],
        isA<Timestamp>(),
      );
      expect(
        familySnapshot.data()?['familyLinkBlockedAt'],
        isA<Timestamp>(),
      );
      expect(
        elderSnapshot.data(),
        containsPair('familyLinkBlockedBy', elder.uid),
      );
      expect(
        familySnapshot.data(),
        containsPair('familyLinkBlockedBy', elder.uid),
      );
      expect(
        FamilyLinkService.hasActiveLink(
          elderData: elderSnapshot.data()!,
          familyData: familySnapshot.data()!,
          familyUid: family.uid!,
          elderUid: elder.uid!,
        ),
        isFalse,
      );

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: family.email,
        password: family.password,
      );
      final familyNotifications = await firestore
          .collection('familiares')
          .doc(family.uid)
          .collection('notificacoes')
          .where('type', isEqualTo: 'family_link_blocked')
          .get();
      final activeElder = await FamilyLinkService(
        auth: auth,
        firestore: firestore,
      ).getActiveElderForFamily();

      expect(familyNotifications.docs, hasLength(1));
      expect(activeElder, isNull);
    });
  });

  testWidgets('desbloqueia o vínculo, remove metadados e notifica',
      (tester) async {
    await tester.runAsync(() async {
      final elder = await fixture.createElder();
      final family = await fixture.signUpFamily(
        linkedElderEmail: elder.email,
      );

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: elder.email,
        password: elder.password,
      );
      final linkService = FamilyLinkService(
        auth: auth,
        firestore: firestore,
      );
      await linkService.blockFamilyMember(
        elderUid: elder.uid!,
        familyUid: family.uid!,
      );
      await linkService.unblockFamilyMember(
        elderUid: elder.uid!,
        familyUid: family.uid!,
      );

      final elderSnapshot =
          await firestore.collection('idosos').doc(elder.uid).get();
      final familySnapshot =
          await firestore.collection('familiares').doc(family.uid).get();
      expect(elderSnapshot.data(), containsPair('familyLinkStatus', 'active'));
      expect(familySnapshot.data(), containsPair('familyLinkStatus', 'active'));
      expect(elderSnapshot.data(), isNot(contains('familyLinkBlockedAt')));
      expect(elderSnapshot.data(), isNot(contains('familyLinkBlockedBy')));
      expect(familySnapshot.data(), isNot(contains('familyLinkBlockedAt')));
      expect(familySnapshot.data(), isNot(contains('familyLinkBlockedBy')));

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: family.email,
        password: family.password,
      );
      final reactivationNotifications = await firestore
          .collection('familiares')
          .doc(family.uid)
          .collection('notificacoes')
          .where('type', isEqualTo: 'family_link_reactivated')
          .get();
      final activeElder = await FamilyLinkService(
        auth: auth,
        firestore: firestore,
      ).getActiveElderForFamily();

      expect(reactivationNotifications.docs, hasLength(1));
      expect(activeElder?['uid'], elder.uid);
    });
  });

  testWidgets('rejeita bloqueio com documento ausente ou UIDs incompatíveis',
      (tester) async {
    await tester.runAsync(() async {
      final elder = await fixture.createElder();
      final family = await fixture.signUpFamily(
        linkedElderEmail: elder.email,
      );

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: elder.email,
        password: elder.password,
      );
      final linkService = FamilyLinkService(
        auth: auth,
        firestore: firestore,
      );

      await expectLater(
        linkService.blockFamilyMember(
          elderUid: 'missing-${elder.uid}',
          familyUid: family.uid!,
        ),
        throwsA(isA<StateError>()),
      );

      await firestore.collection('idosos').doc(elder.uid).update({
        'linkedFamilyUid': 'different-family-uid',
      });
      await expectLater(
        linkService.blockFamilyMember(
          elderUid: elder.uid!,
          familyUid: family.uid!,
        ),
        throwsA(isA<StateError>()),
      );
      await expectLater(
        linkService.unblockFamilyMember(
          elderUid: elder.uid!,
          familyUid: family.uid!,
        ),
        throwsA(isA<StateError>()),
      );

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: family.email,
        password: family.password,
      );
      await firestore.collection('familiares').doc(family.uid).delete();
      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: elder.email,
        password: elder.password,
      );
      await expectLater(
        linkService.blockFamilyMember(
          elderUid: elder.uid!,
          familyUid: family.uid!,
        ),
        throwsA(
          isA<FirebaseException>().having(
            (error) => error.code,
            'code',
            'permission-denied',
          ),
        ),
      );

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: family.email,
        password: family.password,
      );
      final familySnapshot =
          await firestore.collection('familiares').doc(family.uid).get();
      expect(familySnapshot.exists, isFalse);
    });
  });

  testWidgets('fallback por e-mail localiza o idoso vinculado', (tester) async {
    await tester.runAsync(() async {
      final elder = await fixture.createElder();
      final family = fixture.newAccount('family');
      final familyCredential = await auth.createUserWithEmailAndPassword(
        email: family.email,
        password: family.password,
      );
      family.uid = familyCredential.user!.uid;
      await firestore.collection('familiares').doc(family.uid).set({
        'uid': family.uid,
        'name': 'Familiar TASK-023',
        'email': family.email,
        'role': 'familiar',
        'linkedElderEmail': elder.email,
        'familyLinkStatus': 'active',
      });

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: elder.email,
        password: elder.password,
      );
      await firestore.collection('idosos').doc(elder.uid).update({
        'linkedFamilyUid': family.uid,
        'familyLinkStatus': 'active',
      });

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: family.email,
        password: family.password,
      );
      final activeElder = await FamilyLinkService(
        auth: auth,
        firestore: firestore,
      ).getActiveElderForFamily();

      expect(activeElder?['uid'], elder.uid);
      expect(activeElder?['familyUid'], family.uid);
    });
  });

  testWidgets('regras negam leitura anônima de documento familiar',
      (tester) async {
    await tester.runAsync(() async {
      final family = await fixture.signUpFamily();
      await auth.signOut();

      await expectLater(
        firestore.collection('familiares').doc(family.uid).get(),
        throwsA(
          isA<FirebaseException>().having(
            (error) => error.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });
  });

  testWidgets('regra permite leitura ao idoso vinculado e nega a terceiros',
      (tester) async {
    await tester.runAsync(() async {
      final elder = await fixture.createElder();
      final family = await fixture.signUpFamily(
        linkedElderEmail: elder.email,
      );
      final unrelatedElder = await fixture.createElder();

      await auth.signInWithEmailAndPassword(
        email: unrelatedElder.email,
        password: unrelatedElder.password,
      );
      await expectLater(
        firestore.collection('familiares').doc(family.uid).get(),
        throwsA(
          isA<FirebaseException>().having(
            (error) => error.code,
            'code',
            'permission-denied',
          ),
        ),
      );

      await auth.signOut();
      await auth.signInWithEmailAndPassword(
        email: elder.email,
        password: elder.password,
      );
      final familySnapshot =
          await firestore.collection('familiares').doc(family.uid).get();
      expect(familySnapshot.data(), containsPair('uid', family.uid));
    });
  });
}

class _EmulatorFixture {
  _EmulatorFixture({required this.auth, required this.firestore});

  static int _nextId = 0;

  static const _password = 'Task023-emulator-pass';

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final List<_TestAccount> _accounts = [];

  _TestAccount newAccount(String role) {
    final id = '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';
    final account = _TestAccount(
      email: '$role-$id@example.test',
      password: _password,
      role: role,
    );
    _accounts.add(account);
    return account;
  }

  Future<_TestAccount> createElder({
    Map<String, dynamic> initialData = const {},
  }) async {
    final elder = newAccount('elder');
    final credential = await auth.createUserWithEmailAndPassword(
      email: elder.email,
      password: elder.password,
    );
    elder.uid = credential.user!.uid;
    await firestore.collection('idosos').doc(elder.uid).set({
      'uid': elder.uid,
      'name': 'Idoso TASK-023',
      'email': elder.email,
      'role': 'idoso',
      'familyLinkStatus': 'none',
      ...initialData,
    });
    await auth.signOut();
    return elder;
  }

  Future<_TestAccount> signUpFamily({
    _TestAccount? account,
    String? linkedElderEmail,
  }) async {
    final family = account ?? newAccount('family');
    await AuthService.signUpFamily(
      name: 'Familiar TASK-023',
      email: family.email,
      password: family.password,
      relationship: 'Filha',
      linkedElderEmail: linkedElderEmail,
      auth: auth,
      firestore: firestore,
    );
    family.uid = auth.currentUser!.uid;
    return family;
  }

  Future<void> expectAccountDoesNotExist(_TestAccount account) async {
    await expectLater(
      auth.signInWithEmailAndPassword(
        email: account.email,
        password: account.password,
      ),
      throwsA(isA<FirebaseAuthException>()),
    );
    await auth.signOut();
  }

  Future<void> cleanup() async {
    await auth.signOut();
    for (final account in _accounts.reversed) {
      try {
        final credential = await auth.signInWithEmailAndPassword(
          email: account.email,
          password: account.password,
        );
        final user = credential.user!;
        final uid = user.uid;
        final collection = account.role == 'elder' ? 'idosos' : 'familiares';
        final document = firestore.collection(collection).doc(uid);
        final notifications = await document.collection('notificacoes').get();
        for (final notification in notifications.docs) {
          await notification.reference.delete();
        }
        if ((await document.get()).exists) await document.delete();
        await user.delete();
      } on FirebaseAuthException catch (error) {
        if (error.code != 'user-not-found' &&
            error.code != 'invalid-credential') {
          rethrow;
        }
      }
      await auth.signOut();
    }
  }
}

class _TestAccount {
  _TestAccount({
    required this.email,
    required this.password,
    required this.role,
  });

  final String email;
  final String password;
  final String role;
  String? uid;
}
