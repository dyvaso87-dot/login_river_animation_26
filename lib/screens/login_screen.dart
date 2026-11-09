import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'dart:async';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isObscure = true;

  // 1.1. Máquina de estados / Cerebro de la animación
  StateMachineController? _controller;
  //StateMachineInput
  SMIBool? _isChecking;
  SMIBool? _isHandsUp;
  SMITrigger? _trigSuccess;
  SMITrigger? _trigFail;
  SMINumber? _numLook;
//3.2. Timer para detener el recorrido de la mirada
  Timer? _typingDebounce;

  //2.1. Crear variables para FocusNode
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  //4.1 Controllers para manipular
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  //4.2 Erroes para mostrar la UI
  String? emailError;
  String? passError;

   // 4.3 Validadores
  bool isValidEmail(String email) {
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  bool isValidPassword(String pass) {
    // mínimo 8, una mayúscula, una minúscula, un dígito y un especial
    final re = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$',
    );
    return re.hasMatch(pass);
  }

  //4.4 Acción al boton
  void _onLogin(){
    // De lo que escribio el usuario, quita espacios en blanco
    final email = emailCtrl.text.trim();
    final pass = passCtrl.text;

    // Recalcular errores
    final emailTypedError = isValidEmail(email) ? null : 'Email Invalido';
    final passwordTypedError = isValidPassword(pass) ? null : 'Contraseña Invalido';

    //4.5 Avisar que hubo un cambio
    setState(() {
      emailError = emailTypedError;
      passError = passwordTypedError;
    });

    //4.6 Cerrar el teclado y bajar manos
    FocusScope.of(context).unfocus();
    _typingDebounce?.cancel();
    _isChecking?.change(false);
    _isHandsUp?.change(false);
    _numLook?.value = 50.0; //Mirada Neutral

    //4.7 Activar triggers
    if(emailTypedError == null && passwordTypedError == null){
      _trigSuccess?.fire();
    } else {
      _trigFail?.fire();
    }

  }
  //Onchanged, UI/UX, FocusNode, Ciclo de vida de un widget( createState, iniState, build, setState, Deactivate, dispose)

  //2.2. Crear los oyentes o listeners
  @override
  void initState() {
    super.initState();
    _emailFocus.addListener(() {});
    _passwordFocus.addListener(() {
      if (_emailFocus.hasFocus) {
        if (_isHandsUp != null) {
          _isHandsUp?.change(false);
          //3.3. Mirar neutral
          _numLook?.value = 50.0;
        }
      }
    });

    _passwordFocus.addListener(() {
      //Manos arriba en password
      _isHandsUp?.change(_passwordFocus.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla del dispositivo
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(
                  width: size.width,
                  height: 200,
                  child: RiveAnimation.asset(
                    'assets/login-bear-animation.riv',
                    stateMachines: ['Login Machine'],
                    // 1.2. Vincular animación
                    onInit: (artboard) {
                      _controller = StateMachineController.fromArtboard(
                        artboard,
                        'Login Machine',
                      );
                      //1.3. Verificar que inició bien
                      if (_controller == null) return;
                      //Agregar el controlador al escenario
                      artboard.addController(_controller!);
                      //1.4.Vincular las variables
                      _isChecking = _controller!.findSMI('isChecking');
                      _isHandsUp = _controller!.findSMI('isHandsUp');
                      _trigSuccess = _controller!.findSMI('trigSuccess');
                      _trigFail = _controller!.findSMI('trigFail');
                      _numLook = _controller!.findSMI('numLook');
                    },
                  ),
                ),
                // SizedBox: para separar elementos
                const SizedBox(height: 10),
                //Email
                TextField(
                  //4.8 Vincular controller
                  controller: emailCtrl,
                  //2.3. Asignar el Focus al TextField
                  focusNode: _emailFocus,
                  //1.5. Vincular a campo de texto
                  onChanged: (value) {
                    if (_isHandsUp != null) {
                      //No tapes los ojos al ver el email
                      //_isHandsUp!.change(false);
                    }
                    if (_isChecking == null) return;
                    //Activa el modo chismoso
                    _isChecking!.change(true);
                         //3.4. Implementar recorrido de mirada
                    //Ajuste de límites del 0 al 100
                    //80 medida de calibración. Clamp es un rango y se traduce como abrazadera
                    final look = (value.length / 80.0 * 100).clamp(0.0, 100.0);
                    _numLook?.value = look;

                    //3.5. Debounce: si vuelve a teclear, reinicia el controlador
                    _typingDebounce?.cancel();
                    //Crear nuevo timer
                    _typingDebounce = Timer(const Duration(seconds: 3), () {
                      if (!mounted) return;
                      //Mirada neutra
                      _isChecking?.change(false);
                    });
                  },
                  decoration: InputDecoration(
                    //4.9 Mostrar el texto de error
                    errorText: emailError,
                    hintText: "Email",
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      //Para redondear los bordes
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                //Contraseña
                TextField(
                  //4.8 Vincular controller
                  controller: passCtrl,
                  //2.3. Asignar el Focus al TextField
                  focusNode: _passwordFocus,
                  //1.5. Vincular a campo de texto
                  onChanged: (value) {
                    if (_isChecking != null) {
                      //No actives el modo chismoso
                     // _isChecking!.change(false);
                    }
                    //Si isHandsUp no es null
                    if (_isHandsUp == null) return;
                    //Tapa los ojos al ver la contraseña
                    _isHandsUp!.change(true);
                  },
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    //4.9 Mostrar el texto de error
                    errorText: passError,
                    hintText: "Password",
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        //Refrescar el ícono
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                      icon: Icon(
                        //If ternario
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                    border: OutlineInputBorder(
                      //Para redondear los bordes
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: size.width,
                  child: const Text(
                    "Forgot password?",
                    textAlign: TextAlign.right,
                    style: TextStyle(decoration: TextDecoration.underline),
                  ),
                  ),
                const SizedBox(height: 10),
                MaterialButton(
                  minWidth: size.width,
                  height: 50,
                  color: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  ),
                  onPressed: _onLogin,
                  child: Text("Login", style: TextStyle(color: Colors.white),)
                  ),
                  const SizedBox(height: 20),
                  //¿No tienes cuenta? Creala
                  SizedBox(
                    width: size.width,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account"),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Register",
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          ),
                       ],
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
    //4.10 Liberar controllers
    emailCtrl.dispose();
    passCtrl.dispose();
    //2.4 Liberar memoeria/recursos en los focusNode
    _emailFocus.dispose();
    _passwordFocus.dispose();
    //3.5. Liberar timer
    _typingDebounce?.cancel();
    super.dispose();
  }
}