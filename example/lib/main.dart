import 'package:flutter/material.dart';
import 'package:live_cells/live_cell_widgets.dart';
import 'package:live_cells/live_cells.dart';

part 'main.g.dart';

/// A custom class
///
/// The [CellExtension] annotation tells live_cell_extension to generate an
/// extension on `ValueCell<Person>` which provides accessors for the class's
/// properties.
///
/// `mutable: true` tells live_cell_extension to also generated an extension
/// on `MutableCell<Person>` which provides accessors for the class's properties
/// that return `MutableCell`'s.
@CellExtension(mutable: true)
class Person {
  final String firstName;
  final String lastName;
  final int age;

  const Person({
    required this.firstName,
    required this.lastName,
    required this.age
  });

  String get fullName => '$firstName $lastName';
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends CellWidget with CellInitializer {
  @override
  Widget build(BuildContext context) {
    // A cell to hold the person's details
    final person = cell(() => MutableCell(const Person(
        firstName: '',
        lastName: '',
        age: 25
    )));

    watch(() {
      // This is to demonstrate that all observers of person are notified
      // when a property changes
      print('Person changed: ${person().fullName}');
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('CellExtension Demo'),
      ),
      body: Center(
        child: Column(
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Person Details:',
                      ),
                      const SizedBox(height: 10),

                      // Notice it is not necessary to wrap the property cells
                      // in cell(...) or to store them in a local variable.

                      CellTextField(
                        content: person.firstName,
                        decoration: const InputDecoration(
                          label: Text('First Name')
                        ),
                      ),
                      CellTextField(
                        content: person.lastName,
                        decoration: const InputDecoration(
                            label: Text('Last Name')
                        ),
                      ),
                      numField(person.age, 'Age'),
                      const SizedBox(height: 20),
                      const Text(
                        'The following uses the cell holding the entire Person, person():',
                        style: TextStyle(
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 10),
                      CellWidget.builder((context) => Text('${person().fullName} is ${person().age} years old.')),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        child: const Text('Reset'),
                        onPressed: () {
                          person.value = const Person(
                              firstName: '',
                              lastName: '',
                              age: 25
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'The following uses the generated accessors:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text('person.firstName():'),
                          const Spacer(),
                          Text(person.firstName()),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text('person.lastName():'),
                          const Spacer(),
                          Text(person.lastName()),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text('person.age():'),
                          const Spacer(),
                          Text('${person.age()}'),
                        ],
                      ),
                      const SizedBox(height: 10),
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

  static Widget numField(MutableCell<int> cell, String label) =>
      CellWidget.builder((context) {
        final maybe = context.cell(() => cell.maybe());
        final content = context.cell(() => maybe.mutableString());
        final error = context.cell(() => maybe.error);

        return CellTextField(
          content: content,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
              errorText: error() != null
                  ? 'Not a valid integer'
                  : null
          ),
        );
      });
}