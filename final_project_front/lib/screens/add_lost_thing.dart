import 'package:flutter/material.dart';

class AddLostThing extends StatefulWidget {
  const AddLostThing({super.key});

  @override
  State<AddLostThing> createState() => _AddLostThingState();
}

class _AddLostThingState extends State<AddLostThing>{
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  final _imageUrlController = TextEditingController();

  void _submitForm() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    print(_titleController.text);
    print(_descriptionController.text);
    print(_locationController.text);
    print(_contactController.text);
    print(_imageUrlController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: _titleController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              controller: _descriptionController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Location'),
              controller: _locationController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Contact'),
              controller: _contactController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a contact';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Image URL'),
              controller: _imageUrlController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter an image URL';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}