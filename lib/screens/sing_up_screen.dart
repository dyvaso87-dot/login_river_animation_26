import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _isObscurePass = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false;

  String? _emailError;
  String? _passError;
  String? _confirmError;

  bool _isValidInstitutionalEmail(String email) {
    final re = RegExp(r'^[^\s@]+@tecdesoftware\.edu\.mx$', caseSensitive: false);
    return re.hasMatch(email);
  }

  bool _isValidPassword(String pass) {
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  Future<void> _onRegister() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirmPass = _confirmPassCtrl.text;

    final emailErr = _isValidInstitutionalEmail(email)
        ? null
        : 'Debe ser un correo @tecdesoftware.edu.mx';
    final passErr = _isValidPassword(pass)
        ? null
        : 'No cumple con los requisitos de contraseña';
    final confirmErr = pass == confirmPass
        ? null
        : 'Las contraseñas no coinciden';

    setState(() {
      _emailError = emailErr;
      _passError = passErr;
      _confirmError = confirmErr;
    });

    if (emailErr != null || passErr != null || confirmErr != null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado correctamente')),
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailError = e.message ?? 'Error al registrar usuario';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    errorText: _emailError,
                    labelText: 'Correo institucional',
                    hintText: 'usuario@tecdesoftware.edu.mx',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: _isObscurePass,
                  decoration: InputDecoration(
                    errorText: _passError,
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isObscurePass = !_isObscurePass;
                        });
                      },
                      icon: Icon(
                        _isObscurePass
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPassCtrl,
                  obscureText: _isObscureConfirm,
                  decoration: InputDecoration(
                    errorText: _confirmError,
                    labelText: 'Confirmar contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isObscureConfirm = !_isObscureConfirm;
                        });
                      },
                      icon: Icon(
                        _isObscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Requisitos:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text('• Correo con terminación @tecdesoftware.edu.mx'),
                      Text('• Mínimo 8 caracteres'),
                      Text('• Al menos una letra mayúscula y una minúscula'),
                      Text('• Al menos un número y un símbolo'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                MaterialButton(
                  height: 50,
                  color: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: _isLoading ? null : _onRegister,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Registrarse',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }
}