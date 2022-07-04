import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/shared/components/constants.dart';
import 'package:todo_app/shared/cubit/states.dart';

class ToDoAppCubit extends Cubit<TodoAppStates>
{
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks = [];
  bool isBottomSheetActive=false;
  int currentView = 0;
  ToDoAppCubit() : super(TodoAppInitialState());
  static ToDoAppCubit get(context)=>BlocProvider.of(context);
  void changeBottomNavBarIndex(int index){
    currentView=index;
    emit(BottomNavigationBarState());
  }
  void changeBottomSheetState(bool isShawn)
  {
    isBottomSheetActive=isShawn;
    emit(BottomSheetState());
  }
  Database database;
  void createDB() async {
    openDatabase("todo.db", version: 1,
        onCreate: (database, version) {
          database
              .execute(
              'CREATE TABLE task (id INTEGER PRIMARY KEY,title TEXT,date TEXT,time TEXT,status TEXT)')
              .then((value) {
            print("true");
          }).catchError((error) {
            print('error');
          });
        }, onOpen: (database) {
          getFromDB(database).then((value) {
            tasks = value;

            });
          }).then((value) {
            database=value;
            emit(AppCreateDatabaseState());

    });
          //print(database.path);

  }
  Future insertToDataBase(
      {@required String title,
        @required String date,
        @required String time}) async {
    return await database.transaction((txn) {
      txn
          .rawInsert(
          'INSERT INTO task (title,date,time,status) VALUES ("$title","$date","$time","new")')
          .then((value) {
        print("inserted $value");
        emit(AppInsertDatabaseState());
        getFromDB(database);

      }).catchError((error) {
        print(error.toString());
      });
      return null;
    });
  }
  Future<List<Map<String, dynamic>>> getFromDB(database) async {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];

    emit(AppGetDatabaseLoadingState());

    database.rawQuery('SELECT * FROM task').then((value) {

      value.forEach((element)
      {
        if(element['status'] == 'new')
          newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else archivedTasks.add(element);
      });

      emit(AppGetDatabaseState());
    });
  }
  void deleteData({
    @required int id,
  }) async
  {
    database.rawDelete('DELETE FROM task WHERE id = ?', [id])
        .then((value)
    {
      getFromDB(database);
      emit(AppDeleteDatabaseState());
    });
  }
  void updateData({
    @required String status,
    @required int id,
  }) async
  {
    database.rawUpdate(
      'UPDATE task SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value)
    {
      getFromDB(database);
      emit(AppUpdateDatabaseState());
    });
  }

}

