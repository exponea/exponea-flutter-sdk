import 'package:exponea/exponea.dart';

class HomePageArgs {
  final ExponeaConfiguration config;
  final bool isStreamConfig;

  const HomePageArgs({
    required this.config,
    required this.isStreamConfig,
  });
}
