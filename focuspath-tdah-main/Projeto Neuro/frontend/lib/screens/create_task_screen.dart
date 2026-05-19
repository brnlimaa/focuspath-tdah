import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() =>
      _CreateTaskScreenState();
}

class _CreateTaskScreenState
    extends State<CreateTaskScreen>{

  final tituloController=
  TextEditingController();

  final descricaoController=
  TextEditingController();

  bool carregando=false;

  Future criarTarefa() async {

    if(
    tituloController.text.isEmpty ||
        descricaoController.text.isEmpty
    ){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        const SnackBar(

          content:
          Text(
            'Preencha todos os campos',
          ),

        ),

      );

      return;

    }

    setState(() {
      carregando=true;
    });

    try{

      final prefs=
      await SharedPreferences.getInstance();

      final token=
      prefs.getString('token');

      final response=
      await http.post(

        Uri.parse(
          'http://10.0.2.2:3000/tasks',
        ),

        headers:{

          'Content-Type':
          'application/json',

          'Authorization':
          'Bearer $token'

        },

        body:jsonEncode({

          'titulo':
          tituloController.text,

          'descricao':
          descricaoController.text

        }),

      );

      print(response.statusCode);
      print(response.body);

      if(response.statusCode==201 ||
          response.statusCode==200){

        Navigator.pop(
          context,
        );

      }else{

        ScaffoldMessenger.of(context)
            .showSnackBar(

          SnackBar(

            content:Text(
              'Erro: ${response.body}',
            ),

          ),

        );

      }

    }catch(e){

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:Text(
            'Erro: $e',
          ),

        ),

      );

    }

    setState(() {
      carregando=false;
    });

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar:AppBar(

        title:
        const Text(
          'Nova tarefa',
        ),

      ),

      body:Padding(

        padding:
        const EdgeInsets.all(
          20,
        ),

        child:Column(

          children:[

            TextField(

              controller:
              tituloController,

              decoration:
              const InputDecoration(

                labelText:
                'Título',

              ),

            ),

            const SizedBox(
              height:20,
            ),

            TextField(

              controller:
              descricaoController,

              decoration:
              const InputDecoration(

                labelText:
                'Descrição',

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
                carregando
                    ? null
                    : criarTarefa,

                child:

                carregando

                    ? const CircularProgressIndicator()

                    : const Text(
                  'Salvar',
                ),

              ),

            )

          ],

        ),

      ),

    );

  }

}