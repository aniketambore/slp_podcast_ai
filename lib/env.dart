import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'NOSTR_PRIV_KEY', obfuscate: true)
  static final String nostrPrivKey = _Env.nostrPrivKey;

  @EnviedField(varName: 'NOSTR_PUB_KEY', obfuscate: true)
  static final String nostrPubKey = _Env.nostrPubKey;

  @EnviedField(varName: 'ENDING_SECRET', obfuscate: true)
  static final String endingSecret = _Env.endingSecret;
}
