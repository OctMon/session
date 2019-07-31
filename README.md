[![Pub](https://img.shields.io/pub/v/session.svg)](https://pub.dartlang.org/packages/session)
[![support](https://img.shields.io/badge/platform-flutter%7Cdart%20vm-ff69b4.svg)](https://github.com/OctMon/session)

# session

Network request result

json to dart
https://javiercbk.github.io/json_to_dart/

FlutterJsonBeanFactory
https://github.com/zhangruiyu/FlutterJsonBeanFactory

## Getting Started

### Add dependency

```yaml
dependencies:
  session: ^0.3.5  #latest version
```

### Example

```dart
import 'package:session/session.dart';

Session session = Session(
  config: Config(
    baseUrl: 'https://api.tuchong.com/',
    // proxy: 'PROXY localhost:8888',
    connectTimeout: 5,
    receiveTimeout: 5,
    code: 'result',
    list: 'feedList',
  ),
    onRequest: (options) async {
      options.headers['token'] = 'token';
      return options;
    },
  onResult: (result) {
      try {
        switch (result.code) {
          case 'tokenExpired':
          // clearUserInfo();
            break;
          default:
        }
      } catch (e) {
        print(e);
      }
      // Json to dart beans are provided, and dart files ending in entity are provided to generate dart bean factory for use. 
//      result
//        ..fillModel((json) => EntityFactory.generateOBJ<T>(json))
//        ..fillModels((json) => EntityFactory.generateOBJ<T>(json));
    return result;
  },
);

void example() async {
  Result result = await session.request('feed-app', data: {'page': _counter});
  if (result.valid) {
    // result.fillList(result.list.map((json) => Model.fromJson(json)).toList());
    result.fillModels((json) => Model.fromJson(json));
    print(result.models.length);
  }
}
```
