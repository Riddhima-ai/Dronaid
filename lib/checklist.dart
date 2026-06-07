import 'package:flutter/material.dart';
import 'live_location.dart';

class ChecklistItem {
  String title;
  bool checked;

  ChecklistItem({
    required this.title,
    this.checked = false,
  });
}

class ChecklistSection {
  String title;
  List<ChecklistItem> items;

  ChecklistSection({
    required this.title,
    required this.items,
  });
}

class ElectronicsChecklistPage extends StatefulWidget {
  const ElectronicsChecklistPage({super.key});

  @override
  State<ElectronicsChecklistPage> createState() =>
      _ElectronicsChecklistPageState();
}

class _ElectronicsChecklistPageState
    extends State<ElectronicsChecklistPage> {

  

   final List<ChecklistSection> sections = [

  ChecklistSection(
    title: "PRE - ASSEMBLY",
    items: [
      ChecklistItem(title: "Battery Level - 100%"),
      ChecklistItem(title: "Battery Connected"),
      ChecklistItem(title: "Safety Loop Connected"),
      ChecklistItem(title: "Compass Calibrated"),
      ChecklistItem(title: "Safety Loop Disconnected"),
    ],
  ),

  ChecklistSection(
    title: "ASSEMBLY",
    items: [
      ChecklistItem(title: "Wing Box Attached and Locked"),
      ChecklistItem(title: "Forward Landing Gear Attached"),
      ChecklistItem(title: "Tail Booms Attached"),
      ChecklistItem(title: "Tail Section Attached"),
      ChecklistItem(title: "Control Surface JS Connected"),
      ChecklistItem(title: "Back Hatch Locked"),
      ChecklistItem(title: "Parachute Installed"),
    ],
  ),

  ChecklistSection(
    title: "GCS",
    items: [
      ChecklistItem(title: "Safety Loop Connected"),
      ChecklistItem(title: "Mission Planner Connected"),
      ChecklistItem(title: "App Initialised"),
      ChecklistItem(title: "Air Speed Sensor Calibrated"),
    ],
  ),

  ChecklistSection(
    title: "PAYLOAD",
    items: [
      ChecklistItem(title: "Valve Closed"),
      ChecklistItem(title: "Payload (Water) Filled"),
      ChecklistItem(title: "Container Attached"),
      ChecklistItem(title: "Valve Open"),
      ChecklistItem(title: "Air Speed Sensor Filled"),
    ],
  ),

  ChecklistSection(
    title: "PRE - FLIGHT",
    items: [
      ChecklistItem(title: "RC Connected"),
      ChecklistItem(title: "Control Surface Check"),
      ChecklistItem(title: "Motor Test Check"),
      ChecklistItem(title: "Propeller Attached and Secured"),
    ],
  ),

  ChecklistSection(
    title: "FLIGHT",
    items: [
      ChecklistItem(title: "Upload Waypoints Check"),
      ChecklistItem(title: "ARM Check"),
      ChecklistItem(title: "Auto Check"),
    ],
  ),


  ];

  int get totalItems {
    int count = 0;

    for (var section in sections) {
      count += section.items.length;
    }

    return count;
  }

  int get completedItems {
    int count = 0;

    for (var section in sections) {
      for (var item in section.items) {
        if (item.checked) {
          count++;
        }
      }
    }

    return count;
  }

  double get progress => completedItems / totalItems;

  void markAllComplete() {
    setState(() {
      for (var section in sections) {
        for (var item in section.items) {
          item.checked = true;
        }
      }
    });
  }

  void resetChecklist() {
    setState(() {
      for (var section in sections) {
        for (var item in section.items) {
          item.checked = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color.fromARGB(255, 245, 245, 245),

      appBar: AppBar(
        title: const Text("Electronics Checklist",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor:  const Color.fromARGB(255, 18, 37, 83),
        actions: [

          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: markAllComplete,
            color: Colors.white,
          ),

          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetChecklist,
            color: Colors.white,
          ),
        ],
      ),

      body: Column(
        children: [

          // Progress Card
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 99, 114, 165),
              borderRadius: BorderRadius.circular(16),

              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                ),
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Checklist Progress",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(20),
                ),

                const SizedBox(height: 10),

                Text(
                  "$completedItems / $totalItems completed",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Checklist Sections
          Expanded(
            child: ListView.builder(

              itemCount: sections.length,

              itemBuilder: (context, sectionIndex) {

                final section = sections[sectionIndex];

                return Card(

                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: ExpansionTile(

                    title: Text(
                      section.title,

                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    children: section.items.map((item) {

                      return CheckboxListTile(

                        value: item.checked,

                        activeColor: const Color.fromARGB(255, 65, 44, 188),

                        title: Text(

                          item.title,

                          style: TextStyle(

                            decoration: item.checked
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,

                            color: item.checked
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),

                        onChanged: (value) {

                          setState(() {
                            item.checked = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(

        backgroundColor:const Color.fromARGB(255, 99, 114, 165),

        icon: const Icon(Icons.check,color: Colors.white,),

        label: const Text("Finish",style: TextStyle(color: Colors.white),),

        onPressed: () {

          if (completedItems == totalItems) {

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "All checks completed successfully!",
                ),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MapPage(),
      ),
    );

          } else {

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "Complete remaining ${totalItems - completedItems} items",
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
      ),
    );
  }
}