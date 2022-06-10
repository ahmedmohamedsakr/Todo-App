import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/modules/new_task/new_task.dart';
import 'package:todo_app/shared/component/component.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:intl/intl.dart';
import '../shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => AppCubit()..createDatabase(),
        child: BlocConsumer<AppCubit, AppStates>(
          listener: (context, state) {},
          builder: (context, state) {
            var cubit = AppCubit.get(context);
            return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Text(cubit.titles[cubit.currentIndex]),
                centerTitle: true,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  if (cubit.isOpen) {
                    if (formKey.currentState!.validate()) {
                      cubit.changeBottomSheet(isOpen: false);
                      cubit.insertIntoDatabase(
                        title: titleController.text,
                        time: timeController.text,
                        date: dateController.text,
                      );
                      Navigator.pop(context);
                    }
                  } else {
                    scaffoldKey.currentState!
                        .showBottomSheet(
                          (context) {
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Form(
                                key: formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    defaultTextFormField(
                                      controller: titleController,
                                      label: 'Title',
                                      icon: Icons.title,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'Task Title must not be empty.';
                                        }
                                      },
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    defaultTextFormField(
                                      controller: timeController,
                                      label: 'Time',
                                      icon: Icons.watch_later_sharp,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'Task Time must not be empty.';
                                        }
                                      },
                                      onTap: () {
                                        showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.now())
                                            .then((value) {
                                          timeController.text =
                                              value!.format(context).toString();
                                        });
                                      },
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    defaultTextFormField(
                                      controller: dateController,
                                      label: 'Date',
                                      icon: Icons.calendar_month,
                                      validate: (value) {
                                        if (value!.isEmpty) {
                                          return 'Task Date must not be empty.';
                                        }
                                      },
                                      onTap: () {
                                        showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate:
                                              DateTime.parse('2022-11-13'),
                                        ).then((value) {
                                          dateController.text =
                                              DateFormat.yMMMd().format(value!);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        )
                        .closed
                        .then((value) {
                          cubit.changeBottomSheet(isOpen: false);
                        });
                    cubit.changeBottomSheet(isOpen: true);
                  }
                },
                child: Icon(cubit.FABIcon),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: cubit.currentIndex,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.menu,
                    ),
                    label: 'Tasks',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.done,
                    ),
                    label: 'Done',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.archive,
                    ),
                    label: 'Archived',
                  ),
                ],
                onTap: (index) {
                  cubit.changeScreen(index);
                },
              ),
              body:state is! AppDatabaseLoadingState?cubit.screens[cubit.currentIndex]:const CircularProgressIndicator(),
            );
          },
        ));
  }
}
