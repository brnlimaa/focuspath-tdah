import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController = TextEditingController();
  final senhaController = TextEditingController();

  Future login() async {

    try {

      final response = await http.post(

        Uri.parse(
          'http://10.0.2.2:3000/auth/login',
        ),

        headers: {
          'Content-Type':'application/json'
        },

        body: jsonEncode({

          'email': emailController.text,
          'senha': senhaController.text

        }),

      );

      if(response.statusCode == 200){

        final data = jsonDecode(
          response.body,
        );

        final prefs =
        await SharedPreferences.getInstance();

        await prefs.setString(
          'token',
          data['token'],
        );

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              'Login realizado!',
            ),

          ),

        );

        Future.delayed(

          const Duration(
            milliseconds:500,
          ),

              (){

            Navigator.pushReplacement(

              context,

              MaterialPageRoute(

                builder:(_)=>
                const HomeScreen(),

              ),

            );

          },

        );

      }else{

        ScaffoldMessenger.of(context)
            .showSnackBar(

          const SnackBar(

            content: Text(
              'Email ou senha inválidos',
            ),

          ),

        );

      }

    }catch(e){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            'Erro: $e',
          ),

        ),

      );

    }

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          'FocusPath',
        ),

      ),

      body: Padding(

        padding: const EdgeInsets.all(
          20,
        ),

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children:[

            TextField(

              controller:
              emailController,

              decoration:
              const InputDecoration(

                labelText:
                'Email',

                border:
                OutlineInputBorder(),

              ),

            ),

            const SizedBox(
              height:20,
            ),

            TextField(

              controller:
              senhaController,

              obscureText:true,

              decoration:
              const InputDecoration(

                labelText:
                'Senha',

                border:
                OutlineInputBorder(),

              ),

            ),

            const SizedBox(
              height:30,
            ),

            SizedBox(

              width:
              double.infinity,

              child:
              ElevatedButton(

                onPressed:
                login,

                child:
                const Text(
                  'Entrar',
                ),

              ),

            )

          ],

        ),

      ),

    );

  }

}