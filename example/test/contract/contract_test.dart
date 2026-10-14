import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../helpers/pump_app.dart';

class ContractEntry {
  ContractEntry({
    required this.capability,
    required this.semanticsId,
    required this.startOnShell,
    this.navTab,
    this.streamMode = false,
    this.afterTap,
  });

  final String capability;
  final String semanticsId;
  final bool startOnShell;
  final String? navTab;
  final bool streamMode;
  final String? afterTap;
}

List<ContractEntry> loadAutomationContract() {
  final file = File('test/contract/automation_contract.yaml');
  final doc = loadYaml(file.readAsStringSync()) as YamlMap;
  final capabilities = doc['capabilities'] as YamlMap;
  final entries = <ContractEntry>[];

  for (final capability in capabilities.keys) {
    final config = capabilities[capability] as YamlMap;
    final semantics = config['semantics'] as YamlList;
    final pump = config['pump'] as YamlMap?;
    final startOnShell = pump?['startOnShell'] == true;
    final navTab = pump?['navTab']?.toString();
    final streamMode = pump?['streamMode'] == true;

    for (final entry in semantics) {
      if (entry is YamlMap) {
        entries.add(
          ContractEntry(
            capability: capability.toString(),
            semanticsId: entry['id'].toString(),
            startOnShell: startOnShell,
            navTab: navTab,
            streamMode: streamMode,
            afterTap: entry['afterTap']?.toString(),
          ),
        );
      } else {
        entries.add(
          ContractEntry(
            capability: capability.toString(),
            semanticsId: entry.toString(),
            startOnShell: startOnShell,
            navTab: navTab,
            streamMode: streamMode,
          ),
        );
      }
    }
  }

  return entries;
}

void main() {
  final contract = loadAutomationContract();

  group('automation contract semantics', () {
    for (final entry in contract) {
      testWidgets('${entry.capability}: ${entry.semanticsId} is exposed',
          (tester) async {
        await pumpExampleApp(
          tester,
          startOnShell: entry.startOnShell,
          streamMode: entry.streamMode,
        );

        if (entry.navTab != null) {
          await tester.tap(find.bySemanticsIdentifier(entry.navTab!));
          await tester.pumpAndSettle();
        }

        if (entry.afterTap != null) {
          await tester.tap(find.bySemanticsIdentifier(entry.afterTap!));
          await tester.pumpAndSettle();
        }

        expect(
          find.bySemanticsIdentifier(entry.semanticsId),
          findsOneWidget,
          reason: 'Missing Semantics(identifier: ${entry.semanticsId})',
        );
      });
    }
  });
}
