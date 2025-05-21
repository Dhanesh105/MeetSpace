import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../models/room.dart';
import '../services/booking_provider.dart';
import '../services/room_provider.dart';

class BookingForm extends StatefulWidget {
  final DateTime selectedDate;
  final Booking? booking; // For editing existing booking

  const BookingForm({
    super.key,
    required this.selectedDate,
    this.booking,
  });

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Fetch rooms when the form loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoomProvider>(context, listen: false).fetchRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.booking != null;
    final title = isEditing ? 'Edit Booking' : 'Create New Booking';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isEditing ? Icons.edit_calendar : Icons.add_circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(false),
                  splashRadius: 24,
                ),
              ],
            ),
            const Divider(height: 24),
            FormBuilder(
              key: _formKey,
              initialValue: {
                'userId': widget.booking?.userId ?? '',
                'roomId': widget.booking?.roomId ?? '',
                'startTime': widget.booking?.startTime ?? _getDefaultStartTime(),
                'endTime': widget.booking?.endTime ?? _getDefaultEndTime(),
                'attendees': widget.booking?.attendees?.toString() ?? '',
                'notes': widget.booking?.notes ?? '',
              },
              child: Column(
                children: [
                FormBuilderTextField(
                  name: 'userId',
                  decoration: InputDecoration(
                    labelText: 'User ID',
                    hintText: 'Enter your user ID',
                    prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'User ID is required'),
                  ]),
                ),
                const SizedBox(height: 16),

                // Room selection dropdown
                Consumer<RoomProvider>(
                  builder: (context, roomProvider, child) {
                    return FormBuilderDropdown<String>(
                      name: 'roomId',
                      decoration: InputDecoration(
                        labelText: 'Meeting Room',
                        hintText: 'Select a room',
                        prefixIcon: Icon(Icons.meeting_room, color: Theme.of(context).colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        helperText: 'Select the room for your meeting',
                      ),
                      items: roomProvider.rooms.map((room) {
                        return DropdownMenuItem(
                          value: room.id,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.meeting_room,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  '${room.name} (${room.capacity})',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: 'Please select a room'),
                      ]),
                      isExpanded: true,
                      menuMaxHeight: 300, // Limit the dropdown height
                      onChanged: (value) {
                        // Revalidate attendees field when room changes
                        if (_formKey.currentState?.fields['attendees']?.value != null) {
                          _formKey.currentState?.fields['attendees']?.validate();
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Number of attendees
                FormBuilderTextField(
                  name: 'attendees',
                  decoration: InputDecoration(
                    labelText: 'Number of Attendees',
                    hintText: 'Enter the number of people attending',
                    prefixIcon: Icon(Icons.people, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    helperText: 'This helps ensure the room has enough capacity',
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.numeric(errorText: 'Please enter a valid number'),
                    FormBuilderValidators.min(1, errorText: 'At least 1 attendee is required'),
                    (value) {
                      if (value != null && value.toString().isNotEmpty) {
                        final attendees = int.tryParse(value.toString());
                        final roomId = _formKey.currentState?.value['roomId'];
                        if (attendees != null && roomId != null) {
                          final room = Provider.of<RoomProvider>(context, listen: false).getRoomById(roomId);
                          if (room != null && attendees > room.capacity) {
                            return 'Exceeds room capacity (${room.capacity} people)';
                          }
                        }
                      }
                      return null;
                    },
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderDateTimePicker(
                  name: 'startTime',
                  decoration: InputDecoration(
                    labelText: 'Start Time',
                    prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    helperText: 'Select the start date and time',
                  ),
                  inputType: InputType.both,
                  format: DateFormat('yyyy-MM-dd HH:mm'),
                  initialDate: widget.selectedDate,
                  initialTime: const TimeOfDay(hour: 9, minute: 0),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'Start time is required'),
                  ]),
                ),
                const SizedBox(height: 16),
                FormBuilderDateTimePicker(
                  name: 'endTime',
                  decoration: InputDecoration(
                    labelText: 'End Time',
                    prefixIcon: Icon(Icons.access_time_filled, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    helperText: 'Select the end date and time',
                  ),
                  inputType: InputType.both,
                  format: DateFormat('yyyy-MM-dd HH:mm'),
                  initialDate: widget.selectedDate,
                  initialTime: const TimeOfDay(hour: 10, minute: 0),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: 'End time is required'),
                  ]),
                ),
                const SizedBox(height: 16),

                // Notes field
                FormBuilderTextField(
                  name: 'notes',
                  decoration: InputDecoration(
                    labelText: 'Meeting Notes',
                    hintText: 'Enter any additional information',
                    prefixIcon: Icon(Icons.note, color: Theme.of(context).colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Consumer<BookingProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (provider.error != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    provider.error!,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.error,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).pop(false),
                                icon: const Icon(Icons.cancel),
                                label: const Text('Cancel'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isSubmitting ? null : () => _submitForm(context),
                                icon: _isSubmitting
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Icon(isEditing ? Icons.update : Icons.check_circle),
                                label: Text(isEditing ? 'Update Booking' : 'Create Booking'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  DateTime _getDefaultStartTime() {
    final now = DateTime.now();
    final selectedDate = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      now.hour,
      0,
    );

    // If the selected time is in the past, set it to the next hour
    if (selectedDate.isBefore(now)) {
      return DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        now.hour + 1,
        0,
      );
    }

    return selectedDate;
  }

  DateTime _getDefaultEndTime() {
    final startTime = _getDefaultStartTime();
    return startTime.add(const Duration(hours: 1));
  }

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      // Determine if we're editing an existing booking
      final bool isEditing = widget.booking != null;

      final formValues = _formKey.currentState!.value;
      // Parse attendees
      int? attendees;
      if (formValues['attendees'] != null && formValues['attendees'].toString().isNotEmpty) {
        attendees = int.tryParse(formValues['attendees'].toString());
      }

      final booking = Booking(
        id: widget.booking?.id,
        userId: formValues['userId'],
        roomId: formValues['roomId'],
        startTime: formValues['startTime'],
        endTime: formValues['endTime'],
        attendees: attendees,
        notes: formValues['notes'],
      );

      final provider = Provider.of<BookingProvider>(context, listen: false);
      bool success = false;

      try {
        // Get the room provider
        final roomProvider = Provider.of<RoomProvider>(context, listen: false);

        if (isEditing) {
          // Update existing booking
          success = await provider.updateBooking(widget.booking!.id!, booking, roomProvider);
        } else {
          // Create new booking
          success = await provider.createBooking(booking, roomProvider);
        }
      } catch (e) {
        // Handle any unexpected errors
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text('Error: ${e.toString()}'),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }

      if (success && context.mounted) {
        // Show success message before closing the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Text(isEditing ? 'Booking updated successfully!' : 'Booking created successfully!'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        // Close the dialog with success result
        Navigator.pop(context, true);
      }
    }
  }
}
