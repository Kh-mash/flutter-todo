# AGENTS.md

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # codegen — run AFTER editing entities/DI annotations
flutter analyze                                            # lint
flutter test                                               # all tests
flutter test test/features/task/domain/usecases/create_task_test.dart   # single file
flutter test --plain-name "creates a task"                 # single test by name
```

Run codegen before `flutter analyze` / `flutter test` whenever models or DI annotations changed.

## Codegen (generated files are committed)

- `lib/objectbox.g.dart` and `lib/objectbox-model.json` come from `objectbox_generator`; `lib/app/di/injector.config.dart` comes from `injectable_generator`.
- Never hand-edit these files; regenerate with build_runner and commit the regenerated output together with your source changes.
- Never delete `lib/objectbox-model.json` — it stores ObjectBox schema UIDs/history used for migrations.
- Classes used via `getIt` must be annotated (`@injectable`, `@lazySingleton`, `@singleton`) or exposed in an `@module`; otherwise they silently won't be registered.

## Architecture

Feature-first clean architecture under `lib/`:

- `features/<feature>/domain/` — equatable entities, abstract repository interfaces, usecases as `@lazySingleton` classes with a `call()` method returning fpdart `Either<Failure, T>` (or `Stream<Either<...>>` for watches). No Flutter/ObjectBox imports here.
- `features/<feature>/data/` — ObjectBox `@Entity` models exposing `toDomain()` / `fromDomain()`, plus repository impls.
- `features/<feature>/presentation/` — blocs (flutter_bloc), pages, widgets.
- `app/di/injector.dart` — composition root: `@module DatabaseModule` opens the ObjectBox Store (`@preResolve`) against `getApplicationSupportDirectory()` and seeds a default todo list; boxes are provided per model type.
- `app/router/app_router.dart` — go_router `StatefulShellRoute`; blocs are resolved from `getIt` inside route builders (`BlocProvider(create: (_) => getIt<MyDayBloc>())`).
- `core/error/failures.dart` — all failure types; errors cross layers as `Left(Failure)`, not exceptions.

## Testing

- Repository tests use a **real ObjectBox Store** in a temp directory (`Directory.systemTemp.createTempSync('obx_test')`). This requires the native ObjectBox binary; on Windows `objectbox.dll` is committed at the repo root — do not delete or gitignore it.
- Bloc tests: mocktail mocks of usecases + `bloc_test`. Call `registerFallbackValue` for custom parameter types in `setUpAll`. Watch streams are asserted via `.first`.
- fpdart name collisions: import as `import 'package:fpdart/fpdart.dart' hide Task;` when an entity shares a name.
- Test directory tree mirrors `lib/`.

## Toolchain & CI

- Flutter version is pinned in `pubspec.yaml` (`environment.flutter`, currently 3.44.6); CI reads it via `flutter-version-file`. Match that version locally.
- The only workflow is `.github/workflows/release.yaml`: a tag push matching `v*.*.*` builds obfuscated Android APK/AAB using signing secrets. There is **no analyze/test CI** — run both locally before pushing.
- Commit messages follow conventional style: `feat(scope): ...`, `fix(scope): ...`.
