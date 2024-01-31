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

  Person({
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
    final person = MutableCell(Person(
        firstName: '',
        lastName: '',
        age: 25
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('CellExtension Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Person Details:',
            ),
            const SizedBox(height: 10),
            CellTextField(
              content: cell(() => person.firstName),
              decoration: const InputDecoration(
                label: Text('First Name')
              ),
            ),
            CellTextField(
              content: cell(() => person.lastName),
              decoration: const InputDecoration(
                  label: Text('First Name')
              ),
            ),
            numField(cell(() => person.age), 'Age'),
            const SizedBox(height: 20),
            CellWidget.builder((context) => Text('${person().fullName} is ${person().age} years old.'))
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
          decoration: InputDecoration(
              errorText: error()
                  ? 'Not a valid number'
                  : null
          ),
        );
      });
}