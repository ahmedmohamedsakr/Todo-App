import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archive_task/archive_task.dart';
import 'package:todo_app/modules/done_task/done_task.dart';
import 'package:todo_app/modules/new_task/new_task.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialStates());

  int currentIndex = 0;
  bool isOpen = false;
  IconData FABIcon = Icons.edit;
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
  List<Widget> screens = [
    NewTasks(),
    DoneTasks(),
    ArchivedTasks(),
  ];

  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  Database? database;

  static AppCubit get(context) => BlocProvider.of(context);

  void changeScreen(index) {
    currentIndex = index;
    emit(AppChangeScreenState());
  }

  void changeBottomSheet({required isOpen}) {
    this.isOpen = isOpen;
    FABIcon = (isOpen) ? Icons.add : Icons.edit;
    emit(AppChangeBottomSheetState());
  }

  void createDatabase() {
    openDatabase('tasks.db', version: 1, onCreate: (database, version) {
      database
          .execute(
              'create table tasks(id integer primary key,title text,time text,date text,status text)')
          .then(
        (value) {
          print('table created.');
        },
      );
    }, onOpen: (database) {
      getDataFromDatabase(database);
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  void insertIntoDatabase(
      {required String title, required String time, required String date}) {
    database!.transaction((txn) {
      return txn.rawInsert(
          'insert into tasks(title,time,date,status) values("$title","$time","$date","new")');
    }).then((value) {
      emit(AppInsertDatabaseState());
      getDataFromDatabase(database!);
    });
  }

  void getDataFromDatabase(Database database) {
    emit(AppDatabaseLoadingState()); //just to listen for circular.
    newTasks = [];
    archivedTasks = [];
    doneTasks = [];
    //getting database as parameter because [2] and [3] maybe finish before [1].
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if (element['status'] == 'new')
          newTasks.add(element);
        else if (element['status'] == 'done')
          doneTasks.add(element);
        else
          archivedTasks.add(element);
      });
      emit(AppGetDatabaseState());
    }); //this query is case sensitive.
  }

  void updateData({required String status, required int id}) {
    database!.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?', ['$status', id]).then(
      (value) {
        getDataFromDatabase(database!);
        emit(AppUpdateDatabaseState());
      },
    );
  }

  void deleteData({required int id}) {
    database!.rawUpdate('delete from tasks where id = ?', [id]).then((value) {
      getDataFromDatabase(database!);
      emit(AppDeleteDatabaseState());
    });
  }
} //class AppCubit
