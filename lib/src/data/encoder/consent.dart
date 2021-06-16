import '../model/consent.dart';
import '../util/object.dart';

abstract class ConsentEncoder {
  static Consent decode(Map<String, dynamic> data) {
    return Consent(
      id: data.getRequired('id'),
      legitimateInterest: data.getRequired('legitimateInterest'),
      sources: ConsentSourcesEncoder.decode(data.getRequired('sources')),
      translations: data.getRequired('translations'),
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
  static ConsentSources decode(Map<String, dynamic> data) {
    return ConsentSources(
      createdFromCRM: data['createdFromCRM'] as bool,
      imported: data['imported'] as bool,
      fromConsentPage: data['fromConsentPage'] as bool,
      privateAPI: data['privateAPI'] as bool,
      publicAPI: data['publicAPI'] as bool,
      trackedFromScenario: data['trackedFromScenario'] as bool,
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
