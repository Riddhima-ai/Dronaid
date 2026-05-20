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
      title: "POWER SYSTEM CHECKS",
      items: [
        ChecklistItem(title: "Both batteries charged to full and balanced"),
        ChecklistItem(title: "No swelling or physical damage in batteries"),
        ChecklistItem(title: "All XT60 and XT90 connections are tight"),
        ChecklistItem(
            title: "Voltage and current reading accurate in mission planner"),
        ChecklistItem(title: "No overheating in PM07"),
        ChecklistItem(title: "FC powered correctly from PM07"),
        ChecklistItem(title: "BEC output checked using multimeter"),
        ChecklistItem(title: "Backup power checked"),
      ],
    ),

    ChecklistSection(
      title: "FLIGHT CONTROLLER CHECKS",
      items: [
        ChecklistItem(title: "CUAV X7+ boots without errors"),
        ChecklistItem(title: "All ports in FC working"),
        ChecklistItem(title: "SD card logging enabled"),
        ChecklistItem(title: "Vibration isolation mounted properly"),
        ChecklistItem(title: "FC orientation correct in software"),
        ChecklistItem(title: "Calibrations performed"),
      ],
    ),

    ChecklistSection(
      title: "FIRMWARE CHECKS",
      items: [
        ChecklistItem(title: "Parameters saved and backed up"),
        ChecklistItem(title: "Flight modes configured"),
        ChecklistItem(title: "Failsafe parameters verified"),
      ],
    ),

    ChecklistSection(
      title: "COMMUNICATION CHECKS",
      items: [
        ChecklistItem(title: "Radiomaster TX12 bound correctly"),
        ChecklistItem(title: "Receiver power stable"),
        ChecklistItem(title: "All channels mapped correctly"),
        ChecklistItem(title: "RSSI strong"),
        ChecklistItem(title: "Telemetry link established"),
        ChecklistItem(title: "Data updating in ground station"),
        ChecklistItem(title: "Antenna properly oriented"),
      ],
    ),

    ChecklistSection(
      title: "SENSOR AND NAVIGATION",
      items: [
        ChecklistItem(title: "SAT count above 10"),
        ChecklistItem(title: "GPS mounted away from noise sources"),
        ChecklistItem(title: "No magnetic interference"),
        ChecklistItem(title: "Airspeed sensor tube facing forward"),
        ChecklistItem(title: "No blockage to airspeed sensor"),
        ChecklistItem(title: "Airspeed sensor calibrated"),
      ],
    ),

    ChecklistSection(
      title: "CONTROL SURFACES",
      items: [
        ChecklistItem(
            title: "Ailerons moving correctly in opposite directions"),
        ChecklistItem(title: "Rudders synchronized"),
        ChecklistItem(title: "Elevator working correctly"),
        ChecklistItem(title: "Neutral positions aligned"),
        ChecklistItem(title: "No servo jitters"),
        ChecklistItem(
            title:
                "No voltage drop when all control surfaces moved simultaneously"),
      ],
    ),

    ChecklistSection(
      title: "PROPULSION SYSTEM",
      items: [
        ChecklistItem(title: "Both motors spin correctly"),
        ChecklistItem(title: "Propeller direction correct"),
        ChecklistItem(title: "ESC calibrated"),
        ChecklistItem(title: "No abnormal vibration/noise"),
      ],
    ),

    ChecklistSection(
      title: "PAYLOAD SYSTEM",
      items: [
        ChecklistItem(title: "Pump motor activates via FC command"),
        ChecklistItem(title: "Relay functioning correctly"),
        ChecklistItem(title: "No electrical noise affecting FC"),
        ChecklistItem(title: "Payload weight secured"),
      ],
    ),

    ChecklistSection(
      title: "FAILSAFES AND SAFETY",
      items: [
        ChecklistItem(title: "FTS tested"),
        ChecklistItem(title: "Kill switch cuts throttle immediately"),
        ChecklistItem(title: "RTL/Loiter configured"),
        ChecklistItem(title: "Geofence configured"),
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