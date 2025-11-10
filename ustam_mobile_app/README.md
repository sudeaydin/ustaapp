# UstanBurada Mobile App

Flutter client for the UstanBurada platform.

## Toolchain

- **Flutter:** 3.16.x (Dart 3.2.6)
- **Dart:** `>=3.2.6 <4.0.0`

Other Flutter or Dart versions may introduce dependency resolution errors. If
`flutter pub get` fails, verify that your local SDKs match the versions above.

## Getting Started

```bash
flutter --version      # should report Flutter 3.16.x / Dart 3.2.6
flutter pub get
flutter run --dart-define=USTAAPP_ENV=dev
```

## Runtime configuration

The app selects its API host based on compile-time `--dart-define` flags:

| Flag | Description |
| --- | --- |
| `USTAAPP_API_BASE_URL` | Hard override for the full API base URL. |
| `USTAAPP_ENV` | Logical environment (`dev`, `staging`, `prod`). Defaults to `dev` in debug and `prod` in release builds. |
| `USTAAPP_STAGING_API_BASE_URL` | Optional staging URL used when `USTAAPP_ENV=staging`. |
| `USTAAPP_FORCE_PRODUCTION_API` | Force the production base URL regardless of build mode. |
| `USTAAPP_FORCE_DEV_API` | Force the development base URL regardless of build mode. |
| `USTAAPP_ENABLE_MOCK_AUTH` | Enable the in-app mock login accounts even in non-debug builds. |

Example staging build:

```bash
flutter run \
  --dart-define=USTAAPP_ENV=staging \
  --dart-define=USTAAPP_STAGING_API_BASE_URL=https://staging.example.com
```

Mock login credentials are available only when `USTAAPP_ENABLE_MOCK_AUTH=true`
or when running in debug/profile builds. Production builds default to the
production API and disable the test accounts.
