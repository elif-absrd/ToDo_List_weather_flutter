import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const ToDoWeatherApp());

class ToDoWeatherApp extends StatelessWidget {
  const ToDoWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do Weather App',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        primaryColor: Colors.tealAccent,
      ),
      home: const ToDoHomePage(),
    );
  }
}

class Task {
  String title;
  String description;
  bool isHighPriority;
  DateTime dueDate;

  Task({
    required this.title,
    this.description = '',
    this.isHighPriority = false,
    required this.dueDate,
  });

  // Convert Task to JSON-compatible map
  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'isHighPriority': isHighPriority,
    'dueDate': dueDate.toIso8601String(),
  };

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    title: json['title'],
    description: json['description'],
    isHighPriority: json['isHighPriority'],
    dueDate: DateTime.parse(json['dueDate']),
  );
}

class ToDoHomePage extends StatefulWidget {
  const ToDoHomePage({super.key});

  @override
  ToDoHomePageState createState() => ToDoHomePageState();
}

class ToDoHomePageState extends State<ToDoHomePage> {
  int _selectedIndex = 0;
  late List<Task> _tasks;
  DateTime _selectedDate = DateTime.now();
  String _location = '--';
  String _temperature = '--';
  String _condition = '--';

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks from storage on startup
    _fetchWeather();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List<dynamic> decodedTasks = jsonDecode(tasksString);
      setState(() {
        _tasks = decodedTasks.map((json) => Task.fromJson(json)).toList();
      });
    } else {
      setState(() {
        _tasks = [
          Task(title: "Buy groceries", dueDate: DateTime.now()),
          Task(title: "Study Flutter", isHighPriority: true, dueDate: DateTime.now()),
          Task(title: "Gym", dueDate: DateTime.now()),
          Task(title: "Call Mom", dueDate: DateTime.now()),
        ];
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String tasksString = jsonEncode(_tasks.map((task) => task.toJson()).toList());
    await prefs.setString('tasks', tasksString);
    print('Tasks saved: $tasksString');
  }

  Future<void> _fetchWeather() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permission denied';
          _temperature = '--';
          _condition = '--';
        });
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      String apiKey = "536ab46832a54647857185649250704";
      String url = "http://api.weatherapi.com/v1/current.json?key=$apiKey&q=${position.latitude},${position.longitude}";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _location = data['location']['name'];
          _temperature = data['current']['temp_c'].toString();
          _condition = data['current']['condition']['text'];
        });
      } else {
        setState(() {
          _location = 'Error fetching weather';
          _temperature = '--';
          _condition = '--';
        });
      }
    } catch (e) {
      setState(() {
        _location = 'Error: $e';
        _temperature = '--';
        _condition = '--';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.tealAccent,
              onPrimary: Colors.black,
              surface: Color.fromARGB(255, 27, 26, 26),
            ),
            dialogBackgroundColor: Colors.grey[900],
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != initialDate) {
      setState(() {
        _selectedDate = picked;
      });
      print('Date selected: $_selectedDate');
    }
  }

  void _showTaskDialog({Task? task, int? index}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    bool isHighPriority = task?.isHighPriority ?? false;
    DateTime selectedDate = task?.dueDate ?? _selectedDate;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    autofocus: true,
                  ),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  Row(
                    children: [
                      const Text('High Priority', style: TextStyle(color: Colors.white60)),
                      Checkbox(
                        value: isHighPriority,
                        onChanged: (value) {
                          setState(() {
                            isHighPriority = value ?? false;
                          });
                        },
                        activeColor: Colors.tealAccent,
                      ),
                    ],
                  ),
                  ListTile(
                    title: Text(
                      'Due Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(color: Colors.white60),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today, color: Colors.tealAccent),
                      onPressed: () => _selectDate(context, selectedDate).then((_) {
                        setState(() {}); // Refresh the UI with the new date
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          print('Save pressed - Title: ${titleController.text}, Date: $selectedDate');
                          if (titleController.text.isNotEmpty) {
                            this.setState(() {
                              if (index == null) {
                                _tasks.add(Task(
                                  title: titleController.text,
                                  description: descController.text,
                                  isHighPriority: isHighPriority,
                                  dueDate: selectedDate,
                                ));
                              } else {
                                _tasks[index] = Task(
                                  title: titleController.text,
                                  description: descController.text,
                                  isHighPriority: isHighPriority,
                                  dueDate: selectedDate,
                                );
                              }
                            });
                            _saveTasks(); // Save tasks after update
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please enter a title')),
                            );
                            print('Title is empty');
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  List<Task> _getTasksForDate(DateTime date) {
    return _tasks.where((task) => isSameDay(task.dueDate, date)).toList();
  }

  Widget _buildTaskCard(int index) {
    final task = _tasks[index];

    return GestureDetector(
      onLongPress: () {
        setState(() {
          task.isHighPriority = !task.isHighPriority;
          _saveTasks(); // Save tasks after priority change
        });
      },
      onTap: () => _showTaskDialog(task: task, index: index),
      child: Card(
        color: task.isHighPriority ? Colors.red[700] : Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListTile(
          leading: Checkbox(
            value: false,
            onChanged: (value) {
              if (value == true) {
                setState(() {
                  _tasks.removeAt(index);
                  _saveTasks(); // Save tasks after deletion
                });
              }
            },
            activeColor: Colors.tealAccent,
            checkColor: Colors.black,
          ),
          title: Row(
            children: [
              Icon(
                task.isHighPriority ? Icons.priority_high : Icons.low_priority,
                color: task.isHighPriority ? Colors.red : Colors.white60,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.description,
                style: const TextStyle(color: Colors.white60),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Due: ${task.dueDate.toLocal().toString().split(' ')[0]}',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _selectedIndex == 0
        ? _getTasksForDate(_selectedDate)
        : _getTasksForDate(_selectedDate).where((task) => task.isHighPriority).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello, have a great day!'),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context, _selectedDate),
            color: Colors.tealAccent,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.blueGrey[900],
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny, color: Colors.orangeAccent, size: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weather Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Location: $_location', style: const TextStyle(color: Colors.white60)),
                    Text('Temp: $_temperature°C | Condition: $_condition', style: const TextStyle(color: Colors.white60)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Selected Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.white60, fontSize: 16),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 70),
              itemCount: filteredTasks.length,
              itemBuilder: (_, i) => _buildTaskCard(
                _tasks.indexOf(filteredTasks[i]),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        onPressed: () => _showTaskDialog(),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}