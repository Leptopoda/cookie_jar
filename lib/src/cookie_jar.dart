import 'dart:async';

import 'package:universal_io/io.dart' show Cookie;

import 'jar/default.dart';
import 'jar/web.dart';

const _kIsWeb = bool.hasEnvironment('dart.library.js_util')
    ? bool.fromEnvironment('dart.library.js_util')
    : identical(0, 0.0);

/// [CookieJar] is a cookie container and manager for HTTP requests implementing [RFC6265](https://httpwg.org/specs/rfc6265.html).
///
/// ## Implementation considerations
/// In most cases it is not needed to implement this interface.
/// Use a `PersistCookieJar` with a custom [Storage] backend.
///
/// ### Cookie value retrieval
/// {@template CookieJar.valueRetrieval}
/// A cookie jar does not need to retrieve cookies with all attributes present.
/// Retrieved cookies only need to have a valid [Cookie.name] and [Cookie.value].
/// It is up to the implementation to provide further information.
/// {@endtemplate}
///
/// ### Cookie management
/// {@template CookieJar.cookieManagement}
/// According to [RFC6265 section 7.2](https://httpwg.org/specs/rfc6265.html#rfc.section.7.2)
/// user agents SHOULD provide users with a mechanism for managing the cookies stored in the cookie store.
/// It must be documented if an implementer does not provide any of the optional
/// [loadAll], [deleteAll] and [deleteWhere] methods.
/// {@endtemplate}
///
/// ### Public suffix validation
/// The default implementation does not validate the cookie domain against a public
/// suffix list:
/// {@template CookieJar.publicSuffix}
/// > NOTE: A "public suffix" is a domain that is controlled by a public
/// > registry, such as "com", "co.uk", and "pvt.k12.wy.us". This step is
/// > essential for preventing attacker.com from disrupting the integrity of
/// > example.com by setting a cookie with a Domain attribute of "com".
/// > Unfortunately, the set of public suffixes (also known as "registry controlled domains")
/// > changes over time. If feasible, user agents SHOULD use an up-to-date
/// > public suffix list, such as the one maintained by the Mozilla project at <http://publicsuffix.org/>.
/// {@endtemplate}
///
/// ### CookieJar limits and eviction policy
/// {@template CookieJar.limits}
/// If a cookie jar has a limit to the number of cookies it can store,
/// the removal policy outlined in [RFC6265 section 5.3](https://httpwg.org/specs/rfc6265.html#rfc.section.5.3)
/// must be followed.
/// It is recommended to set an upper bound to the time a cookie is stored
/// as described in [RFC6265 section 7.3](https://httpwg.org/specs/rfc6265.html#rfc.section.7.3):
/// {@endtemplate}
abstract class CookieJar {
  /// Creates a [DefaultCookieJar] instance or a [WebCookieJar] if run in a browser.
  factory CookieJar({bool ignoreExpires = false}) {
    if (_kIsWeb) {
      return WebCookieJar();
    }
    return DefaultCookieJar(ignoreExpires: ignoreExpires);
  }

  /// Save the [cookies] for specified [uri].
  FutureOr<void> saveFromResponse(Uri uri, List<Cookie> cookies);

  /// Load the cookies for specified [uri].
  FutureOr<List<Cookie>> loadForRequest(Uri uri);

  /// Ends the current session deleting all session cookies.
  FutureOr<void> endSession();

  /// Loads all cookies in the [CookieJar].
  FutureOr<List<Cookie>> loadAll();

  /// Delete all cookies in the [CookieJar].
  FutureOr<void> deleteAll();

  /// Removes all cookies in this jar that satisfy the given [test].
  FutureOr<void> deleteWhere(bool Function(Cookie cookie) test);
}
