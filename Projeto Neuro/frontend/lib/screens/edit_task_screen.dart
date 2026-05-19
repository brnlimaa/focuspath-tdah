import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditTaskScreen extends StatefulWidget {

  final Map tarefa;

  const EditTaskScreen({
    super.key,
    required this.tarefa
  });

  @override
  State<EditTaskScreen> createState() =>
      _EditTaskScreenState();
}

class _EditTaskScreenState
    extends State<EditTaskScreen>{

  late TextEditingController tituloController;
  late TextEditingController descricaoController;

  @override
  void initState(){

    super.initState();

    tituloController=
        TextEditingController(
          text:
          widget.tarefa['titulo'],
        );

    descricaoController=
        TextEditingController(
          text:
          widget.tarefa['descricao'],
        );

  }

  Future editarTarefa() async {

    try{

      final prefs=
      await SharedPreferences.getInstance();

      final token=
      prefs.getString('token');

      final response=
      await http.put(

        Uri.parse(
          'http://10.0.2.2:3000/tasks/${widget.tarefa['id']}',
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

      if(response.statusCode==200){

        Navigator.pop(context);

      }

    }catch(e){

      print(e);

    }

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar:AppBar(

        title:
        const Text(
          'Editar tarefa',
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

            ElevatedButton(

              onPressed:
              editarTarefa,

              child:
              const Text(
                'Salvar alterações',
              ),

            )

          ],

        ),

      ),

    );

  }

}