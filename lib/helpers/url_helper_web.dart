// ✅ Modern web implementation using package:web
import 'package:web/web.dart' as web;

Uri getCurrentUri() {
  return Uri.parse(web.window.location.href);
}