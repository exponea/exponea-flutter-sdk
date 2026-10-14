import 'package:exponea_example/app/brand_colors.dart';
import 'package:exponea_example/app/env_config.dart';
import 'package:exponea_example/features/authentication/auth_preferences.dart';
import 'package:exponea_example/models/configure_request.dart';
import 'package:exponea_example/models/integration_mode.dart';
import 'package:exponea_example/services/exponea_service_scope.dart';
import 'package:exponea_example/util/authorization_token.dart';
import 'package:exponea_example/widgets/brand_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({
    super.key,
    required this.onConfigured,
    this.envConfig,
  });

  final VoidCallback onConfigured;

  /// Compile-time dart-define values used to prefill empty auth fields.
  final EnvConfig? envConfig;

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  late IntegrationMode _mode;
  late final TextEditingController _projectTokenController;
  late final TextEditingController _authorizationController;
  late final TextEditingController _advancedAuthController;
  late final TextEditingController _streamIdController;
  late final TextEditingController _jwtKeyIdController;
  late final TextEditingController _jwtSecretController;
  late final TextEditingController _registeredIdController;
  late final TextEditingController _apiUrlController;
  late final TextEditingController _applicationIdController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _mode = IntegrationMode.project;
    _projectTokenController = TextEditingController();
    _authorizationController = TextEditingController();
    _advancedAuthController = TextEditingController();
    _streamIdController = TextEditingController();
    _jwtKeyIdController = TextEditingController();
    _jwtSecretController = TextEditingController();
    _registeredIdController = TextEditingController();
    _apiUrlController = TextEditingController();
    _applicationIdController = TextEditingController();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final data = await AuthPreferences.load();
    if (!mounted) {
      return;
    }
    final env = widget.envConfig;
    String pick(String saved, String fromEnv) =>
        saved.isNotEmpty ? saved : fromEnv;
    setState(() {
      final hasSavedForm = data.projectToken.isNotEmpty ||
          data.streamId.isNotEmpty ||
          data.baseUrl.isNotEmpty;
      _mode = hasSavedForm ? data.mode : (env?.resolvedMode ?? data.mode);
      _projectTokenController.text =
          pick(data.projectToken, env?.projectToken ?? '');
      _authorizationController.text =
          pick(data.authorizationToken, env?.authorizationToken ?? '');
      _advancedAuthController.text = data.advancedAuthToken;
      _streamIdController.text = pick(data.streamId, env?.streamId ?? '');
      _jwtKeyIdController.text = pick(data.jwtKeyId, env?.jwtKeyId ?? '');
      _jwtSecretController.text = pick(data.jwtSecret, env?.jwtSecret ?? '');
      _registeredIdController.text =
          pick(data.customerId, env?.customerId ?? '');
      _apiUrlController.text = pick(data.baseUrl, env?.baseUrl ?? '');
      _applicationIdController.text = data.applicationId;
    });
  }

  @override
  void dispose() {
    _projectTokenController.dispose();
    _authorizationController.dispose();
    _advancedAuthController.dispose();
    _streamIdController.dispose();
    _jwtKeyIdController.dispose();
    _jwtSecretController.dispose();
    _registeredIdController.dispose();
    _apiUrlController.dispose();
    _applicationIdController.dispose();
    super.dispose();
  }

  ConfigureRequest _buildRequest() {
    return ConfigureRequest(
      mode: _mode,
      baseUrl: _apiUrlController.text.trim(),
      projectToken: _projectTokenController.text.trim(),
      authorizationToken: normalizeAuthorizationToken(
        _authorizationController.text.trim(),
      ),
      advancedAuthToken: _advancedAuthController.text.trim(),
      streamId: _streamIdController.text.trim(),
      jwtKeyId: _jwtKeyIdController.text.trim(),
      jwtSecret: _jwtSecretController.text.trim(),
      customerId: _registeredIdController.text.trim(),
      applicationId: _applicationIdController.text.trim(),
    );
  }

  Future<void> _start() async {
    final request = _buildRequest();
    if (!request.isValid) {
      _showMessage('Please fill all required fields.');
      return;
    }

    setState(() => _loading = true);
    try {
      await ExponeaServiceScope.of(context).configure(request);
      await AuthPreferences.save(request);
      if (mounted) {
        widget.onConfigured();
      }
    } on PlatformException catch (error) {
      if (mounted) {
        await _showErrorDialog(
          'Error configuring SDK',
          error.message ?? error.toString(),
        );
      }
    } catch (error) {
      if (mounted) {
        await _showErrorDialog('Error configuring SDK', error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _clearLocalData() async {
    try {
      await ExponeaServiceScope.of(context).clearLocalCustomerData();
      if (mounted) {
        _showMessage('Local data cleared.');
      }
    } catch (error) {
      if (mounted) {
        _showMessage('Failed to clear local data.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _showErrorDialog(String title, String message) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          Semantics(
            identifier: 'btn_auth_error_ok',
            button: true,
            label: 'OK',
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = _buildRequest();
    final canStart = request.isValid && !_loading;

    return Scaffold(
      backgroundColor: BrandColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Center(child: BrandLogo.wordmark(width: 220)),
              const SizedBox(height: 24),
              Semantics(
                identifier: 'lbl_auth_title',
                label: 'SDK Configuration',
                child: const Text(
                  'SDK Configuration',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ModeToggle(
                mode: _mode,
                onModeChanged: (mode) => setState(() => _mode = mode),
              ),
              const SizedBox(height: 16),
              if (_mode == IntegrationMode.project) ...[
                _AuthField(
                  controller: _projectTokenController,
                  label: 'Project token',
                  semanticsId: 'fld_auth_project_token',
                  onChanged: (_) => setState(() {}),
                ),
                _AuthField(
                  controller: _authorizationController,
                  label: 'Authorization token',
                  semanticsId: 'fld_auth_authorization_token',
                  onChanged: (_) => setState(() {}),
                ),
                _AuthField(
                  controller: _advancedAuthController,
                  label: 'Advanced auth key (optional)',
                  semanticsId: 'fld_auth_advanced_auth',
                ),
              ] else ...[
                _AuthField(
                  controller: _streamIdController,
                  label: 'Stream ID',
                  semanticsId: 'fld_auth_stream_id',
                  onChanged: (_) => setState(() {}),
                ),
                _AuthField(
                  controller: _jwtKeyIdController,
                  label: 'JWT Key ID',
                  semanticsId: 'fld_auth_jwt_key_id',
                ),
                _AuthField(
                  controller: _jwtSecretController,
                  label: 'JWT Secret',
                  semanticsId: 'fld_auth_jwt_secret',
                  obscureText: true,
                ),
              ],
              _AuthField(
                controller: _registeredIdController,
                label: 'Registered customer ID',
                semanticsId: 'fld_auth_registered_id',
              ),
              _AuthField(
                controller: _apiUrlController,
                label: 'API URL',
                semanticsId: 'fld_auth_api_url',
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
                errorText: _apiUrlController.text.isNotEmpty &&
                        !request.isBaseUrlValid
                    ? 'Must be a valid http:// or https:// URL'
                    : null,
              ),
              _AuthField(
                controller: _applicationIdController,
                label: 'Application ID (optional)',
                semanticsId: 'fld_auth_application_id',
              ),
              const SizedBox(height: 16),
              Semantics(
                identifier: 'btn_auth_start',
                button: true,
                enabled: canStart,
                label: 'Start',
                child: FilledButton(
                  onPressed: canStart ? _start : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Start'),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                identifier: 'btn_auth_clear_local_data',
                button: true,
                label: 'Clear local data',
                child: OutlinedButton(
                  onPressed: _loading ? null : _clearLocalData,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text('Clear local data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.mode,
    required this.onModeChanged,
  });

  final IntegrationMode mode;
  final ValueChanged<IntegrationMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            identifier: 'btn_auth_mode_project',
            button: true,
            selected: mode == IntegrationMode.project,
            label: 'Project',
            child: OutlinedButton(
              onPressed: () => onModeChanged(IntegrationMode.project),
              style: OutlinedButton.styleFrom(
                backgroundColor: mode == IntegrationMode.project
                    ? BrandColors.yellow
                    : BrandColors.white,
                foregroundColor: BrandColors.black,
              ),
              child: const Text('Project'),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Semantics(
            identifier: 'btn_auth_mode_stream',
            button: true,
            selected: mode == IntegrationMode.stream,
            label: 'Stream',
            child: OutlinedButton(
              onPressed: () => onModeChanged(IntegrationMode.stream),
              style: OutlinedButton.styleFrom(
                backgroundColor: mode == IntegrationMode.stream
                    ? BrandColors.yellow
                    : BrandColors.white,
                foregroundColor: BrandColors.black,
              ),
              child: const Text('Stream'),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.label,
    this.semanticsId,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final String? semanticsId;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final field = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        // Auth values (tokens, URLs, ids) are replaced, not edited. Select the
        // whole prefilled value on tap so typing replaces it; with a caret at the
        // tap position, deleting leftwards kept the tail and corrupted the value.
        onTap: () => controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: controller.text.length,
        ),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          errorText: errorText,
        ),
      ),
    );
    final id = semanticsId;
    if (id == null) {
      return field;
    }
    return Semantics(
      identifier: id,
      textField: true,
      label: label,
      child: field,
    );
  }
}
