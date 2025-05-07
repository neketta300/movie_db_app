import 'package:flutter/material.dart';

class LocalizedModelStorage {
  String _localeTag = '';
  String get localeTag => _localeTag;
  /*
  прорверка на текущую локаль устройства
  если установленная локаль в приложении совпадает с локалью на устройстве
  то ничего меня не надо
  */
  bool updateLocale(Locale locale) {
    final localeTag = locale.toLanguageTag();
    //print(_locale);
    if (_localeTag == localeTag) return false;
    _localeTag = localeTag;
    return true;
  }
}
