# Authentication

Sync and pull handlers need authenticated Dio in **foreground and background**.

## Store tokens

Use **flutter_secure_storage** (Keychain / Keystore), not Drift or SharedPreferences.

iOS for background reads:

```dart
const FlutterSecureStorage(
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  ),
);
```

## Two Dio instances

| Context | How to get Dio |
| --- | --- |
| Foreground | Injectable `@Named('mainNetworkClient')` after reading tokens |
| Background | `createBackgroundDio()` in entrypoint — new storage read + `DioClientProvider` |

Same factory, different instances — isolates do not share singletons.

## Background pattern

```dart
Future<Dio> createBackgroundDio() async {
  const storage = FlutterSecureStorage(/* iOptions */);
  final tokens = await tokenRepository.getAuthTokens();
  if (tokens?.accessToken == null) {
    return dioWithoutAuth(); // or skip sync
  }
  return dioClientProvider.getClient(
    accessToken: tokens!.accessToken!,
    refreshToken: tokens.refreshToken,
  );
}
```

If token is null or API returns 401 without refresh, **exit background sync cleanly** — you cannot show login UI from Workmanager.

## Interceptors

- OK: attach `Authorization` from token passed at construction
- OK: refresh token and update secure storage in background (with care)
- Avoid: `getIt` or navigation in interceptors

## Handlers

Handlers receive configured `Dio` — they should not read secure storage directly if Dio already has auth headers.
