import 'package:flutter/material.dart';
import 'package:mercado_local_movil/core/config/env.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool loading = false;
  int idRol = 3; // 3 = CONSUMIDOR, 2 = VENDEDOR
  bool _obscurePassword = true;
  String? _message;
  bool _isError = false;

  Map<String, dynamic> form = {
    "nombre": "",
    "apellido": "",
    "correo": "",
    "contrasena": "",
    "fechaNacimiento": "",
    "cedula": "",
    "direccion": "",
    "telefono": "",
    "nombreEmpresa": "",
    "ruc": "",
    "direccionEmpresa": "",
    "telefonoEmpresa": "",
    "descripcion": "",
  };

  // ============================================================
  // WIDGET PARA CREAR INPUTS REUTILIZABLES
  // ============================================================
  Widget inputField({
    required String label,
    required String key,
    IconData? icon,
    bool obscure = false,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xff3a5a40),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          keyboardType: type,
          obscureText: obscure && _obscurePassword,
          maxLines: obscure ? 1 : maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Color(0xffd48f27), size: 20),
            suffixIcon: obscure
                ? IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            )
                : null,
            filled: true,
            fillColor: Color(0xfffffdf7),
            contentPadding:
            EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xffe0ddd0), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xffe0ddd0), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Color(0xff6b8e4e), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.red.shade300, width: 2),
            ),
          ),
          initialValue: form[key],
          onChanged: (v) {
            form[key] = v;
            if (_message != null) {
              setState(() {
                _message = null;
              });
            }
          },
          validator: (v) => v!.isEmpty ? "Campo requerido" : null,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ============================================================
  // SELECTOR DE FECHA
  // ============================================================
  Widget dateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Fecha de nacimiento *",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xff3a5a40),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            DateTime? pick = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1950),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: ColorScheme.light(
                      primary: Color(0xff3a5a40),
                      onPrimary: Colors.white,
                      onSurface: Colors.black,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (pick != null) {
              setState(() {
                form["fechaNacimiento"] = pick.toString().split(" ")[0];
              });
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Color(0xfffffdf7),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Color(0xffe0ddd0), width: 2),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_month, color: Color(0xffd48f27), size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    form["fechaNacimiento"].isEmpty
                        ? "Selecciona tu fecha de nacimiento"
                        : form["fechaNacimiento"],
                    style: TextStyle(
                      color: form["fechaNacimiento"].isEmpty
                          ? Colors.grey.shade600
                          : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ============================================================
  // FUNCIÓN DE REGISTRO
  // ============================================================
  Future<void> registrar() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Por favor completa todos los campos requeridos"),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() {
      loading = true;
      _message = null;
    });

    Map<String, dynamic> data = {
      "nombre": form["nombre"],
      "apellido": form["apellido"],
      "correo": form["correo"],
      "contrasena": form["contrasena"],
      "fechaNacimiento": form["fechaNacimiento"],
      "idRol": idRol,
      "cedula": form["cedula"],
      "direccion": form["direccion"],
      "telefono": form["telefono"],
      "nombreEmpresa": form["nombreEmpresa"],
      "ruc": form["ruc"],
      "direccionEmpresa": form["direccionEmpresa"],
      "telefonoEmpresa": form["telefonoEmpresa"],
      "descripcion": form["descripcion"],
    };

    try {
      final url = Uri.parse("${Env.apiUrl}/auth/register");
      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      setState(() => loading = false);

      if (resp.statusCode == 200) {
        final body = jsonDecode(resp.body);

        setState(() {
          _message = "¡Registro exitoso! Bienvenido 🎉";
          _isError = false;
        });

        await Future.delayed(Duration(seconds: 2));

        if (body["rol"] == "VENDEDOR") {
          Navigator.pushReplacementNamed(context, "/home");
        } else {
          Navigator.pushReplacementNamed(context, "/home");
        }
      } else {
        final err = jsonDecode(resp.body);
        setState(() {
          _message = err["mensaje"] ?? "Error en el registro";
          _isError = true;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        _message = "Error en la conexión con el servidor";
        _isError = true;
      });
    }
  }

  // ============================================================
  // INTERFAZ COMPLETA
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffaf8f3),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Color(0xff3a5a40)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xff3a5a40),
                                    Color(0xff6b8e4e)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(Icons.person,
                                  color: Colors.white, size: 30),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "Crear Cuenta",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3a5a40),
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Únete a nuestra comunidad",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),

            // FORMULARIO
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // MENSAJE DE ALERTA
                      if (_message != null)
                        Container(
                          padding: EdgeInsets.all(16),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: _isError
                                ? Color(0xfff8d7da)
                                : Color(0xffd4edda),
                            border: Border.all(
                              color: _isError
                                  ? Color(0xfff5c6cb)
                                  : Color(0xffc3e6cb),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isError
                                    ? Icons.error_outline
                                    : Icons.check_circle_outline,
                                color: _isError
                                    ? Color(0xff721c24)
                                    : Color(0xff155724),
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _message!,
                                  style: TextStyle(
                                    color: _isError
                                        ? Color(0xff721c24)
                                        : Color(0xff155724),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // SELECTOR DE ROL
                      const Text(
                        "¿Cómo te gustaría unirte? *",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Color(0xff3a5a40),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => idRol = 3);
                                if (_message != null) {
                                  setState(() => _message = null);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: idRol == 3
                                      ? Color(0xfff0f5f1)
                                      : Colors.white,
                                  border: Border.all(
                                    color: idRol == 3
                                        ? Color(0xff3a5a40)
                                        : Color(0xffe0ddd0),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: idRol == 3
                                      ? [
                                    BoxShadow(
                                      color: Color(0xff3a5a40)
                                          .withOpacity(0.15),
                                      blurRadius: 20,
                                      offset: Offset(0, 8),
                                    )
                                  ]
                                      : [],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: idRol == 3
                                            ? LinearGradient(
                                          colors: [
                                            Color(0xff6b8e4e),
                                            Color(0xff3a5a40)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                            : null,
                                        color: idRol != 3
                                            ? Color(0xffe0ddd0)
                                            : null,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.shopping_bag_outlined,
                                        color: idRol == 3
                                            ? Colors.white
                                            : Colors.grey.shade400,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      "Consumidor",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Color(0xff2d3e32),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Compra productos frescos",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() => idRol = 2);
                                if (_message != null) {
                                  setState(() => _message = null);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: idRol == 2
                                      ? Color(0xfff0f5f1)
                                      : Colors.white,
                                  border: Border.all(
                                    color: idRol == 2
                                        ? Color(0xff3a5a40)
                                        : Color(0xffe0ddd0),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: idRol == 2
                                      ? [
                                    BoxShadow(
                                      color: Color(0xff3a5a40)
                                          .withOpacity(0.15),
                                      blurRadius: 20,
                                      offset: Offset(0, 8),
                                    )
                                  ]
                                      : [],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        gradient: idRol == 2
                                            ? LinearGradient(
                                          colors: [
                                            Color(0xff6b8e4e),
                                            Color(0xff3a5a40)
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                            : null,
                                        color: idRol != 2
                                            ? Color(0xffe0ddd0)
                                            : null,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.store_outlined,
                                        color: idRol == 2
                                            ? Colors.white
                                            : Colors.grey.shade400,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      "Vendedor",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: Color(0xff2d3e32),
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      "Vende tus productos",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // INFORMACIÓN PERSONAL
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              color: Color(0xff6b8e4e), size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Información Personal",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff3a5a40),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                          height: 30,
                          thickness: 2,
                          color: Color(0xffe0ddd0)),

                      inputField(
                          label: "Nombre *",
                          key: "nombre",
                          icon: Icons.person_outline),
                      inputField(
                          label: "Apellido *",
                          key: "apellido",
                          icon: Icons.person_outline),
                      inputField(
                          label: "Correo electrónico *",
                          key: "correo",
                          icon: Icons.email_outlined,
                          type: TextInputType.emailAddress),
                      inputField(
                        label: "Contraseña *",
                        key: "contrasena",
                        obscure: true,
                        icon: Icons.lock_outline,
                      ),
                      dateField(),

                      const SizedBox(height: 10),

                      // CAMPOS DE CONSUMIDOR
                      if (idRol == 3) ...[
                        Row(
                          children: [
                            Icon(Icons.shopping_bag_outlined,
                                color: Color(0xff6b8e4e), size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Información del Consumidor",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3a5a40),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                            height: 30,
                            thickness: 2,
                            color: Color(0xffe0ddd0)),
                        inputField(
                            label: "Cédula *",
                            key: "cedula",
                            icon: Icons.credit_card),
                        inputField(
                            label: "Dirección *",
                            key: "direccion",
                            icon: Icons.location_on_outlined),
                        inputField(
                            label: "Teléfono *",
                            key: "telefono",
                            icon: Icons.phone_outlined,
                            type: TextInputType.phone),
                      ],

                      // CAMPOS DE VENDEDOR
                      if (idRol == 2) ...[
                        Row(
                          children: [
                            Icon(Icons.store_outlined,
                                color: Color(0xffd48f27), size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Información del Negocio",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff3a5a40),
                              ),
                            ),
                          ],
                        ),
                        Divider(
                            height: 30,
                            thickness: 2,
                            color: Color(0xffe0ddd0)),
                        inputField(
                            label: "Nombre del negocio *",
                            key: "nombreEmpresa",
                            icon: Icons.business_outlined),
                        inputField(
                            label: "RUC *",
                            key: "ruc",
                            icon: Icons.numbers),
                        inputField(
                            label: "Dirección del negocio *",
                            key: "direccionEmpresa",
                            icon: Icons.location_city_outlined),
                        inputField(
                            label: "Teléfono del negocio *",
                            key: "telefonoEmpresa",
                            icon: Icons.phone_outlined,
                            type: TextInputType.phone),
                        inputField(
                            label: "Descripción",
                            key: "descripcion",
                            icon: Icons.description_outlined,
                            type: TextInputType.multiline,
                            maxLines: 3),
                      ],

                      const SizedBox(height: 20),

                      // BOTÓN REGISTRARSE
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xff3a5a40), Color(0xff6b8e4e)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xff3a5a40).withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: loading ? null : registrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: loading
                              ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Registrarse",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward,
                                  color: Colors.white, size: 20),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // LINK A LOGIN
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "¿Ya tienes cuenta? ",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Inicia sesión aquí",
                                style: TextStyle(
                                  color: Color(0xffd48f27),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}