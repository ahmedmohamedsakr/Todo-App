import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultTextFormField({
  required String label,
  required IconData icon,
  bool obscure = false,
  required String? Function(String?)validate,
  Function ()? onTap,
  var keyboardType,
  required TextEditingController controller,
}) {
  return TextFormField(
    onTap: onTap,
    keyboardType:keyboardType ,
    controller: controller,
    validator:validate,
    obscureText: obscure , //parameter
    decoration: InputDecoration(
      border: OutlineInputBorder(),
      label: Text('$label'), //parameter
      prefixIcon: Icon(icon), //parameter
    ),
  );
}


Widget defaultListItems({required int index,required Map model,required BuildContext context}){
  var cubit =AppCubit.get(context);
  return Dismissible(
    key: Key(model['id'].toString()),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          CircleAvatar(
            child: Text(
              '${model['time']}',
            ),
            radius: 40.0,
            backgroundColor: Colors.blue[800],
          ),
          SizedBox(
            width: 20.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${model['title']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 21.0,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  '${model['date']}',
                  style: TextStyle(color: Colors.grey, fontSize: 12.0),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          IconButton(
            onPressed: () {
              cubit.updateData(status: 'done', id: model['id']);
            },
            icon: Icon(
              Icons.check_box,
              color: Colors.green,
            ),
          ),
          IconButton(
            onPressed: () {
              cubit.updateData(status: 'archive', id: model['id']);
            },
            icon: Icon(
              Icons.archive,
              color: Colors.black45,
            ),
          )
        ],
      ),
    ),
    onDismissed: (direction){
      cubit.deleteData(id: model['id']);
    },
  );
}

Widget defaultScreenBody({required List<Map> tasks}){
  if (tasks.length > 0) {
    return ListView.separated(
      itemBuilder: (context, index) {
        return defaultListItems(
            index: index, model: tasks[index], context: context);
      },
      separatorBuilder: (context, index) {
        return Container(
          height: 1.0,
          width: double.infinity,
          color: Colors.black38,
        );
      },
      itemCount: tasks.length,
    );
  } else {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const[
          Icon(
            Icons.menu,
            color: Colors.black26,
            size: 100.0,
          ),
          Text(
            'Insert New Task.',
            style: TextStyle(
              color: Colors.black26,
              fontSize: 15.0,
            ),
          ),
        ],
      ),
    );
  }

}
