import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'create_task_screen.dart';
import 'edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen>{

  List tarefas=[];

  Future carregarTarefas() async {

    try{

      final prefs=
      await SharedPreferences.getInstance();

      final token=
      prefs.getString(
        'token',
      );

      final response=
      await http.get(

        Uri.parse(
          'http://10.0.2.2:3000/tasks',
        ),

        headers:{

          'Authorization':
          'Bearer $token'

        },

      );

      if(response.statusCode==200){

        setState(() {

          tarefas=
              jsonDecode(
                response.body,
              );

        });

      }

    }catch(e){

      print(e);

    }

  }

  Future deletarTarefa(int id) async {

    try{

      final prefs=
      await SharedPreferences.getInstance();

      final token=
      prefs.getString(
        'token',
      );

      final response=
      await http.delete(

        Uri.parse(
          'http://10.0.2.2:3000/tasks/$id',
        ),

        headers:{

          'Authorization':
          'Bearer $token'

        },

      );

      if(response.statusCode==200){

        carregarTarefas();

      }

    }catch(e){

      print(e);

    }

  }

  @override
  void initState(){

    super.initState();

    carregarTarefas();

  }

  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar:AppBar(

        title:
        const Text(
          'FocusPath',
        ),

      ),

      body:

      tarefas.isEmpty

          ? const Center(

        child:
        Text(
          'Nenhuma tarefa',
        ),

      )

          : ListView.builder(

        itemCount:
        tarefas.length,

        itemBuilder:
            (context,index){

          return ListTile(

            onTap:() async {

              await Navigator.push(

                context,

                MaterialPageRoute(

                  builder:(_)=>

                      EditTaskScreen(

                        tarefa:
                        tarefas[index],

                      ),

                ),

              );

              carregarTarefas();

            },

            title:
            Text(
              tarefas[index]['titulo'],
            ),

            subtitle:
            Text(
              tarefas[index]['descricao'],
            ),

            trailing:

            IconButton(

              icon:
              const Icon(
                Icons.delete,
              ),

              onPressed:(){

                deletarTarefa(
                  tarefas[index]['id'],
                );

              },

            ),

          );

        },

      ),

      floatingActionButton:

      FloatingActionButton(

        onPressed:() async {

          await Navigator.push(

            context,

            MaterialPageRoute(

              builder:(_)=>

              const CreateTaskScreen(),

            ),

          );

          carregarTarefas();

        },

        child:
        const Icon(
          Icons.add,
        ),

      ),

    );

  }

}