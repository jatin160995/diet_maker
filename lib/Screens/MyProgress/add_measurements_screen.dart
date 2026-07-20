import 'package:diet_maker/Exception/api_exception.dart';
import 'package:diet_maker/services/api_service.dart';
import 'package:diet_maker/services/storage_service.dart';
import 'package:diet_maker/utils/api_endpoints.dart';
import 'package:diet_maker/utils/app_helpers.dart';
import 'package:diet_maker/utils/color_utils.dart';
import 'package:diet_maker/widgets/custom_edit_text.dart';
import 'package:diet_maker/widgets/small_heading.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddMeasurementsScreen extends StatefulWidget {
  final Map<String, dynamic>? editLog;

  const AddMeasurementsScreen({super.key, this.editLog});

  @override
  State<AddMeasurementsScreen> createState() => _AddMeasurementsScreenState();
}

class _AddMeasurementsScreenState extends State<AddMeasurementsScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _neckController = TextEditingController();
  final TextEditingController _shouldersController = TextEditingController();
  final TextEditingController _chestController = TextEditingController();
  final TextEditingController _waistController = TextEditingController();
  final TextEditingController _leftArmController = TextEditingController();
  final TextEditingController _rightArmController = TextEditingController();
  final TextEditingController _abdominalController = TextEditingController();
  final TextEditingController _hipsController = TextEditingController();
  final TextEditingController _leftThighController = TextEditingController();
  final TextEditingController _rightThighController = TextEditingController();
  final TextEditingController _leftCalfController = TextEditingController();
  final TextEditingController _rightCalfController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  String? prefMeasurement = "Imperial";
  String? userGender = "Male";

  @override
  void initState() {
    super.initState();
    getPrefferedMeasurement();
    _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
    _prefillEditData();
  }

  void _prefillEditData() {
    if (widget.editLog == null) return;

    final log = widget.editLog!;

    final String? dateString =
        log['log_date']?.toString() ?? log['date']?.toString();
    if (dateString != null && dateString.isNotEmpty) {
      try {
        _selectedDate = DateTime.parse(dateString);
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      } catch (_) {}
    }

    final List items = (log['items'] ?? log['measurements'] ?? []) as List;

    for (final item in items) {
      final map = Map<String, dynamic>.from(item);
      final String bodyPart = (map['body_part'] ?? '').toString().trim();
      final String measurement = (map['measurement'] ?? '').toString();

      switch (bodyPart.toLowerCase()) {
        case 'neck':
          _neckController.text = measurement;
          break;
        case 'shoulders':
          _shouldersController.text = measurement;
          break;
        case 'chest':
          _chestController.text = measurement;
          break;
        case 'waist':
          _waistController.text = measurement;
          break;
        case 'left arm':
          _leftArmController.text = measurement;
          break;
        case 'right arm':
          _rightArmController.text = measurement;
          break;
        case 'abdominal':
          _abdominalController.text = measurement;
          break;
        case 'hips':
          _hipsController.text = measurement;
          break;
        case 'left thigh':
          _leftThighController.text = measurement;
          break;
        case 'right thigh':
          _rightThighController.text = measurement;
          break;
        case 'left calf':
          _leftCalfController.text = measurement;
          break;
        case 'right calf':
          _rightCalfController.text = measurement;
          break;
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _neckController.dispose();
    _shouldersController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _leftArmController.dispose();
    _rightArmController.dispose();
    _abdominalController.dispose();
    _hipsController.dispose();
    _leftThighController.dispose();
    _rightThighController.dispose();
    _leftCalfController.dispose();
    _rightCalfController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(_selectedDate);
      });
    }
  }

  Future<void> _addMeasurementsToServer() async {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isLoading = true;
    });

    final ApiService apiService = ApiService();
    String? dietaryPrefId =
        (await StorageService.getLoginData())?.dietaryPreference.id.toString();

    if (dietaryPrefId == null) {
      showToast("Dietary preference not found. Please log in again.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    List<Map<String, dynamic>> items = [];
    int displayOrder = 1;

    void addMeasurement(
      String bodyPart,
      TextEditingController controller,
      int order,
    ) {
      if (controller.text.trim().isNotEmpty) {
        items.add({
          "body_part": bodyPart,
          "measurement": controller.text.trim(),
          "display_order": order,
        });
      }
    }

    addMeasurement("Neck", _neckController, displayOrder++);
    addMeasurement("Shoulders", _shouldersController, displayOrder++);
    addMeasurement("Chest", _chestController, displayOrder++);
    addMeasurement("Waist", _waistController, displayOrder++);
    addMeasurement("Left Arm", _leftArmController, displayOrder++);
    addMeasurement("Right Arm", _rightArmController, displayOrder++);
    addMeasurement("Abdominal", _abdominalController, displayOrder++);
    addMeasurement("Hips", _hipsController, displayOrder++);
    addMeasurement("Left Thigh", _leftThighController, displayOrder++);
    addMeasurement("Right Thigh", _rightThighController, displayOrder++);
    addMeasurement("Left Calf", _leftCalfController, displayOrder++);
    addMeasurement("Right Calf", _rightCalfController, displayOrder++);

    if (items.isEmpty) {
      showToast("Please enter at least one measurement.");
      setState(() {
        _isLoading = false;
      });
      return;
    }

    Map<String, dynamic> mapToSend = {
      "dietary_preference_id": dietaryPrefId,
      "log_date": DateFormat('yyyy-MM-dd').format(_selectedDate),
      "items": items,
    };

    print("Measurement Payload: $mapToSend");

    try {
      Map response = await apiService.postWithToken(
        addMeasurementLogs,
        mapToSend,
      );

      print("Response: $response");
      showToast(
        widget.editLog == null
            ? "Measurements added successfully."
            : "Measurements updated successfully.",
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (e is ApiException) {
        showToast(e.message.toString());
        print("API Error: ${e.message}, status: ${e.code}");
        print("Details: ${e.errorBody}");
      } else {
        print("Unexpected error: $e");
        showToast("An unexpected error occurred.");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  getPrefferedMeasurement() async {
    prefMeasurement =
        (await StorageService.getLoginData())?.profile.preferredMeasurement;
    userGender = (await StorageService.getLoginData())?.profile.gender;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        dismissKeyboard(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.editLog == null ? "Add Measurements" : "Edit Measurements"),
          backgroundColor: backgroundColor(),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _addMeasurementsToServer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.editLog == null ? "Save" : "Update",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                userGender == "Male"
                    ? 'assets/images/bodypart.png'
                    : 'assets/images/bodypart_female.png',
                fit: BoxFit.contain,
                height: 250,
              ),
              const SizedBox(height: 20),
              const Text(
                "Select Date",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  _selectDate(context);
                },
                child: CustomEditText(
                  false,
                  15,
                  _dateController,
                  TextInputType.datetime,
                  "DD/MM/YYYY",
                  readOnly: true,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Measurements (${(prefMeasurement == "Imperial") ? "Inch" : "cm"})",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildMeasurementField("Neck", _neckController),
              _buildMeasurementField("Shoulders", _shouldersController),
              _buildMeasurementField("Chest", _chestController),
              _buildMeasurementField("Waist", _waistController),
              _buildMeasurementField("Left Arm", _leftArmController),
              _buildMeasurementField("Right Arm", _rightArmController),
              _buildMeasurementField("Abdominal", _abdominalController),
              _buildMeasurementField("Hips", _hipsController),
              _buildMeasurementField("Left Thigh", _leftThighController),
              _buildMeasurementField("Right Thigh", _rightThighController),
              _buildMeasurementField("Left Calf", _leftCalfController),
              _buildMeasurementField("Right Calf", _rightCalfController),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementField(
    String label,
    TextEditingController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmallHeading(label),
          CustomEditText(
            true,
            15,
            controller,
            const TextInputType.numberWithOptions(decimal: true),
            "Your $label Size",
          ),
        ],
      ),
    );
  }
}