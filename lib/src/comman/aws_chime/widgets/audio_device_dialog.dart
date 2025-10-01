import 'package:flutter/material.dart';

class AudioDeviceDialog extends StatelessWidget {
  final List<String> devices;
  final String? selectedDevice;
  final Function(String) onDeviceSelected;

  const AudioDeviceDialog({
    Key? key,
    required this.devices,
    required this.selectedDevice,
    required this.onDeviceSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Choose Audio Device"),
      elevation: 40,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: Colors.white,
      children: devices.map((device) {
        final isSelected = device == selectedDevice;
        return SimpleDialogOption(
          child: Text(
            device,
            style: TextStyle(
              color: Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          onPressed: () {
            Navigator.pop(context, device);
            onDeviceSelected(device);
          },
        );
      }).toList(),
    );
  }
}
