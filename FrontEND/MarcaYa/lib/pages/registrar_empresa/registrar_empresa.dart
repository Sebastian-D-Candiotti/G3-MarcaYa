import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../src/api_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class RegistrarEmpresaPage extends StatefulWidget {
  const RegistrarEmpresaPage({super.key});

  @override
  State<RegistrarEmpresaPage> createState() => _RegistrarEmpresaPageState();
}

class _RegistrarEmpresaPageState extends State<RegistrarEmpresaPage> {
  final _correoCtrl      = TextEditingController();
  final _claveCtrl       = TextEditingController();
  final _confirmarCtrl   = TextEditingController();
  final _rucCtrl         = TextEditingController();
  final _razonSocialCtrl = TextEditingController();
  final _otpCodeCtrl     = TextEditingController();

  bool _isManual = false;
  bool _isLoading = false;
  bool _loadingSunat = false;
  String? _error;
  bool _obscureClave = true;
  bool _obscureConfirmar = true;

  // Variables para SUNAT (Flujo A)
  List<dynamic> _sunatEmpresas = [];
  Map<String, dynamic>? _selectedSunatEmpresa;
  bool _codigoEnviado = false;
  String? _correoEnmascarado;
  String? _codigoDebug;

  // Variables para Manual (Flujo B)
  bool _validandoRucUnico = false;
  bool _rucEsUnico = false;
  String? _rucError;

  @override
  void initState() {
    super.initState();
    _cargarEmpresasSunat();
    _rucCtrl.addListener(_onRucChanged);
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _claveCtrl.dispose();
    _confirmarCtrl.dispose();
    _rucCtrl.removeListener(_onRucChanged);
    _rucCtrl.dispose();
    _razonSocialCtrl.dispose();
    _otpCodeCtrl.dispose();
    super.dispose();
  }

  void _onRucChanged() {
    if (!_isManual) return;
    final ruc = _rucCtrl.text.trim();
    if (ruc.length == 11) {
      _checkRucUnico(ruc);
    } else {
      setState(() {
        _rucError = null;
        _rucEsUnico = false;
      });
    }
  }

  Future<void> _checkRucUnico(String ruc) async {
    if (!ruc.startsWith('10') && !ruc.startsWith('20')) {
      setState(() {
        _rucError = 'El RUC debe comenzar con 10 o 20';
        _rucEsUnico = false;
      });
      return;
    }

    setState(() {
      _validandoRucUnico = true;
      _rucError = null;
    });

    try {
      final isUnique = await ApiService.instance.validarRucUnico(ruc);
      setState(() {
        _rucEsUnico = isUnique;
        _rucError = isUnique ? null : 'Este RUC ya se encuentra registrado';
        _validandoRucUnico = false;
      });
    } catch (_) {
      setState(() {
        _rucError = 'Error al validar el RUC con el servidor';
        _validandoRucUnico = false;
      });
    }
  }

  bool _isValidCorporateEmail(String email) {
    final domain = email.split('@').last.toLowerCase().trim();
    final publicDomains = {
      'gmail.com',
      'hotmail.com',
      'yahoo.com',
      'outlook.com',
      'live.com',
      'icloud.com',
      'mail.com',
      'yahoo.es',
      'outlook.es',
    };
    return !publicDomains.contains(domain);
  }

  Future<void> _cargarEmpresasSunat() async {
    setState(() => _loadingSunat = true);
    try {
      final empresas = await ApiService.instance.getSunatEmpresas();
      setState(() {
        _sunatEmpresas = empresas;
        _loadingSunat = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Error al cargar lista de empresas SUNAT';
        _loadingSunat = false;
      });
    }
  }

  Future<void> _enviarCodigo() async {
    final ruc = _rucCtrl.text.trim();
    if (ruc.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final res = await ApiService.instance.enviarCodigoSunat(ruc);
      setState(() {
        _codigoEnviado = true;
        _correoEnmascarado = res['correo_enmascarado'];
        _codigoDebug = res['codigo_debug'];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Código enviado a ${_correoEnmascarado ?? "el correo oficial"}'),
          backgroundColor: AppColors.success,
        ),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.mensaje);
    } catch (_) {
      setState(() => _error = 'Error al enviar código');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSunatSelectionBottomSheet() {
    String searchPattern = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _sunatEmpresas.where((e) {
              final query = searchPattern.toLowerCase();
              final rucMatch = e['ruc'].toString().contains(query);
              final nameMatch = e['razon_social'].toString().toLowerCase().contains(query);
              return rucMatch || nameMatch;
            }).toList();

            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Seleccionar Empresa (SUNAT)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Buscar por nombre o RUC...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (val) {
                      setModalState(() {
                        searchPattern = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_loadingSunat)
                    const Center(child: CircularProgressIndicator())
                  else if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'No se encontraron empresas',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final emp = filtered[index];
                          return ListTile(
                            title: Text(emp['razon_social']),
                            subtitle: Text('RUC: ${emp['ruc']}'),
                            onTap: () {
                              setState(() {
                                _selectedSunatEmpresa = emp;
                                _rucCtrl.text = emp['ruc'];
                                _razonSocialCtrl.text = emp['razon_social'];
                                _otpCodeCtrl.clear();
                                _codigoEnviado = false;
                                _correoEnmascarado = null;
                                _codigoDebug = null;
                              });
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleRegistro() async {
    final email = _correoCtrl.text.trim();
    final clave = _claveCtrl.text;
    final confirmar = _confirmarCtrl.text;

    if (email.isEmpty) {
      setState(() => _error = 'El correo electrónico es obligatorio');
      return;
    }
    if (clave != confirmar) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    if (clave.length < 6) {
      setState(() => _error = 'La contraseña debe tener al menos 6 caracteres');
      return;
    }

    if (_isManual) {
      // Validaciones Manuales (Flujo B)
      if (!_isValidCorporateEmail(email)) {
        setState(() => _error = 'Se requiere un correo corporativo para registro manual (no se permiten Gmail, Hotmail, etc.)');
        return;
      }
      final ruc = _rucCtrl.text.trim();
      final razonSocial = _razonSocialCtrl.text.trim();
      if (razonSocial.isEmpty) {
        setState(() => _error = 'La razón social es obligatoria');
        return;
      }
      if (ruc.length != 11) {
        setState(() => _error = 'El RUC debe tener exactamente 11 dígitos');
        return;
      }
      if (!ruc.startsWith('10') && !ruc.startsWith('20')) {
        setState(() => _error = 'El RUC manual debe comenzar con 10 o 20');
        return;
      }
      if (!_rucEsUnico) {
        setState(() => _error = _rucError ?? 'El RUC ya se encuentra registrado');
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        await ApiService.instance.registrarEmpresa(
          correo: email,
          clave: clave,
          ruc: ruc,
          razonSocial: razonSocial,
          registroTipo: 'manual',
        );

        if (!mounted) return;

        // Cargar perfil en el Provider
        await context.read<AuthProvider>().fetchProfile();

        if (mounted) {
          context.go('/verificar-otp', extra: {'ruc': ruc, 'correo': email});
        }
      } on ApiException catch (e) {
        setState(() => _error = e.mensaje);
      } catch (_) {
        setState(() => _error = 'No se pudo conectar al servidor');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }

    } else {
      // Validaciones SUNAT (Flujo A)
      if (_selectedSunatEmpresa == null) {
        setState(() => _error = 'Debes seleccionar una empresa de la lista SUNAT');
        return;
      }
      if (!_codigoEnviado) {
        setState(() => _error = 'Debes solicitar el código de verificación para continuar');
        return;
      }
      final code = _otpCodeCtrl.text.trim();
      if (code.isEmpty) {
        setState(() => _error = 'Debes ingresar el código de verificación recibido');
        return;
      }

      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        final ruc = _rucCtrl.text.trim();
        final razonSocial = _razonSocialCtrl.text.trim();

        await ApiService.instance.registrarEmpresa(
          correo: email,
          clave: clave,
          ruc: ruc,
          razonSocial: razonSocial,
          registroTipo: 'sunat',
          codigo: code,
        );

        if (!mounted) return;

        await context.read<AuthProvider>().fetchProfile();

        if (mounted) {
          context.go('/locked');
        }
      } on ApiException catch (e) {
        setState(() => _error = e.mensaje);
      } catch (_) {
        setState(() => _error = 'No se pudo conectar al servidor');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar empresa')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Datos de la empresa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Selector SUNAT o MANUAL
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isManual = false;
                          _error = null;
                          _rucCtrl.clear();
                          _razonSocialCtrl.clear();
                          _otpCodeCtrl.clear();
                          _codigoEnviado = false;
                          _correoEnmascarado = null;
                          _codigoDebug = null;
                          _selectedSunatEmpresa = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: !_isManual ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        side: BorderSide(color: !_isManual ? AppColors.primary : Colors.grey.shade300, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'SUNAT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !_isManual ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _isManual = true;
                          _error = null;
                          _rucCtrl.clear();
                          _razonSocialCtrl.clear();
                          _otpCodeCtrl.clear();
                          _codigoEnviado = false;
                          _correoEnmascarado = null;
                          _codigoDebug = null;
                          _selectedSunatEmpresa = null;
                          _rucEsUnico = false;
                          _rucError = null;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: _isManual ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                        side: BorderSide(color: _isManual ? AppColors.primary : Colors.grey.shade300, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Manual',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isManual ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (!_isManual) ...[
                // Búsqueda SUNAT
                InkWell(
                  onTap: _showSunatSelectionBottomSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedSunatEmpresa != null
                                ? _selectedSunatEmpresa!['razon_social']
                                : 'Seleccionar Empresa (SUNAT)...',
                            style: TextStyle(
                              color: _selectedSunatEmpresa != null ? AppColors.textPrimary : Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: _selectedSunatEmpresa != null ? FontWeight.w500 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedSunatEmpresa != null) ...[
                  _buildField('RUC de la empresa', _rucCtrl, readOnly: true),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mail_outline, color: Colors.blueGrey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Correo institucional de verificación', style: TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(
                                _selectedSunatEmpresa!['correo_enmascarado'] ?? 'No disponible',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_codigoEnviado)
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _enviarCodigo,
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Solicitar código de verificación'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    )
                  else ...[
                    Text(
                      'Código enviado a: ${_correoEnmascarado ?? ""}',
                      style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (_codigoDebug != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 8),
                        child: Text(
                          'Código de prueba: $_codigoDebug',
                          style: const TextStyle(color: Colors.blueGrey, fontSize: 13, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildField('Código de verificación (SUNAT)', _otpCodeCtrl, tipo: TextInputType.number),
                  ],
                  const SizedBox(height: 16),
                ],
              ] else ...[
                // Registro Manual
                _buildField('Razón social', _razonSocialCtrl),
                const SizedBox(height: 16),
                _buildField('RUC (11 dígitos)', _rucCtrl, tipo: TextInputType.number, maxLength: 11),
                if (_validandoRucUnico)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        SizedBox(width: 8),
                        Text('Validando unicidad de RUC...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                if (_rucError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      _rucError!,
                      style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (_rucEsUnico && _rucCtrl.text.trim().length == 11)
                  const Padding(
                    padding: EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      '✓ El RUC es válido y único',
                      style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 32),

              const Text(
                'Datos del administrador',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              _buildField('Correo electrónico de la cuenta / corporativo', _correoCtrl, tipo: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildField('Contraseña', _claveCtrl,
                  obscure: true,
                  obscureCtrl: () => setState(() => _obscureClave = !_obscureClave),
                  isObscure: _obscureClave),
              const SizedBox(height: 16),
              _buildField('Confirmar contraseña', _confirmarCtrl,
                  obscure: true,
                  obscureCtrl: () => setState(() => _obscureConfirmar = !_obscureConfirmar),
                  isObscure: _obscureConfirmar),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistro,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Crear cuenta',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String hint,
    TextEditingController controller, {
    bool obscure = false,
    TextInputType tipo = TextInputType.text,
    VoidCallback? obscureCtrl,
    bool? isObscure,
    int? maxLength,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure ? isObscure! : false,
      keyboardType: tipo,
      maxLength: maxLength,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hint,
        counterText: '',
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(isObscure! ? Icons.visibility : Icons.visibility_off),
                onPressed: obscureCtrl,
              )
            : null,
      ),
    );
  }
}
