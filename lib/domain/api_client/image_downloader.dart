// предоставляет возможность получить картинку
import 'package:moviedb_app_llf/config/configuration.dart';

class ImageDownloader {
  static String imageUrl(String path) => Configuration.imageUrl + path;
}
