import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/module/archived_tasks/archived_tasks_screen.dart';
import 'package:todo_app/module/done_tasks/done_tasks_screen.dart';
import 'package:todo_app/module/new_tasks/new_tasks_screen.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  TextEditingController _newTaskController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  TextEditingController _timeController = TextEditingController();
  var scfoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ToDoAppCubit()..createDB(),
      child: BlocConsumer<ToDoAppCubit, TodoAppStates>(
        listener: (BuildContext context, state) {
          if (state is AppInsertDatabaseState) {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, state) {
          return Scaffold(
            key: scfoldKey,
            appBar: AppBar(
              title: Text(titles[ToDoAppCubit.get(context).currentView]),
            ),
            body: ConditionalBuilder(
              condition: state is! AppGetDatabaseLoadingState,
              builder: (context) =>
                  screens[ToDoAppCubit.get(context).currentView],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            //,
            bottomNavigationBar: BottomNavigationBar(
              onTap: (int index) {
                //setState(() {
                ToDoAppCubit.get(context).changeBottomNavBarIndex(index);
                //});
              },
              currentIndex: ToDoAppCubit.get(context).currentView,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined),
                  label: 'archived',
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              child: ToDoAppCubit.get(context).isBottomSheetActive
                  ? Icon(Icons.add)
                  : Icon(Icons.edit),
              onPressed: () {
                if (ToDoAppCubit.get(context).isBottomSheetActive) {
                  if (formKey.currentState.validate()) {
                    ToDoAppCubit.get(context)
                        .insertToDataBase(
                      title: _newTaskController.text,
                      time: _timeController.text,
                      date: _dateController.text,
                    )
                        .then((value) {
                     // Navigator.pop(context);
                      //    setState(() {
                      ToDoAppCubit.get(context).changeBottomSheetState(false);

                      //  });
                    });
                  }
                } else {
                  //setState(() {
                  ToDoAppCubit.get(context).changeBottomSheetState(true);

                  scfoldKey.currentState
                      .showBottomSheet((context) {
                        return Container(
                          color: Colors.grey[100],
                          padding: EdgeInsets.all(20),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                  controller: _newTaskController,
                                  onTap: () {
                                    print("on tap ");
                                  },
                                  type: TextInputType.text,
                                  validate: (value) {
                                    if (value.isEmpty) {
                                      return "title must not be empty ";
                                    }
                                    return null;
                                  },
                                  label: "task title",
                                  prefix: Icons.title,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                defaultFormField(
                                  controller: _timeController,
                                  type: TextInputType.datetime,
                                  onTap: () {
                                    showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now())
                                        .then((value) => _timeController.text =
                                            value.format(context).toString());
                                  },
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return 'time must not be empty';
                                    }

                                    return null;
                                  },
                                  label: 'Task Time',
                                  prefix: Icons.watch_later_outlined,
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                defaultFormField(
                                  controller: _dateController,
                                  type: TextInputType.datetime,
                                  onTap: () {
                                    showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2024-12-30'),
                                    ).then((value) {
                                      _dateController.text =
                                          DateFormat.yMMMd().format(value);
                                    });
                                  },
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return 'date must not be empty';
                                    }

                                    return null;
                                  },
                                  label: 'Task Date',
                                  prefix: Icons.calendar_today,
                                ),
                              ],
                            ),
                          ),
                        );
                      })
                      .closed
                      .then((value) {
                        //setState(() {
                        ToDoAppCubit.get(context).changeBottomSheetState(false);
                        _newTaskController.clear();
                        _timeController.clear();
                        _dateController.clear();
                      });
                  //});
                }
              },
            ),
          );
        },
      ),
    );
  }
}
