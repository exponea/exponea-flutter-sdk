import '../model/consent.dart';
import '../util/object.dart';

abstract class ConsentEncoder {
  static Consent decode(Map<dynamic, dynamic> data) {
    return Consent(
      id: data.getRequired('id'),
      legitimateInterest: data.getRequired('legitimateInterest'),
      sources: ConsentSourcesEncoder.decode(data.getRequired('sources')),
      translations: data.getRequired<Map>('translations').map(
            (key, value) => MapEntry(
              key.toString(),
              (value as Map).map(
                (k, v) => MapEntry(k.toString(), v?.toString()),
              ),
            ),
          ),
    );
  }

  static Map<String, dynamic> encode(Consent consent) {
    return {
      'id': consent.id,
      'legitimateInterest': consent.legitimateInterest,
      'sources': ConsentSourcesEncoder.encode(consent.sources),
      'translations': consent.translations,
    };
  }
}

abstract class ConsentSourcesEncoder {
  static ConsentSources decode(Map<dynamic, dynamic> data) {
    return ConsentSources(
      createdFromCRM: data.getRequired('createdFromCRM'),
      imported: data.getRequired('imported'),
      fromConsentPage: data.getRequired('fromConsentPage'),
      privateAPI: data.getRequired('privateAPI'),
      publicAPI: data.getRequired('publicAPI'),
      trackedFromScenario: data.getRequired('trackedFromScenario'),
    );
  }

  static Map<String, dynamic> encode(ConsentSources sources) {
    return {
      'createdFromCRM': sources.createdFromCRM,
      'imported': sources.imported,
      'fromConsentPage': sources.fromConsentPage,
      'privateAPI': sources.privateAPI,
      'publicAPI': sources.publicAPI,
      'trackedFromScenario': sources.trackedFromScenario,
    };
  }
}
