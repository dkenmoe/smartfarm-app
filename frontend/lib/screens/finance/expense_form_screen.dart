import 'package:firstapp/models/animal_breed.dart';
import 'package:firstapp/models/animal_type.dart';
import 'package:firstapp/models/finance/expense_category.dart';
import 'package:firstapp/models/finance/payment_method.dart';
import 'package:firstapp/models/finance/supplier.dart';
import 'package:flutter/material.dart';
import 'package:firstapp/models/finance/expense.dart';
import 'package:firstapp/services/expense_service.dart';
import 'package:firstapp/services/expense_category_service.dart';
import 'package:firstapp/services/supplier_service.dart';
import 'package:firstapp/services/payment_method_service.dart';
import 'package:firstapp/services/api_service.dart'; // For AnimalType and AnimalBreed
import 'package:firstapp/widgets/form_widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ExpenseFormScreen extends StatefulWidget {
  final Expense? expense;
  final Function(Expense)? onSubmit;

  const ExpenseFormScreen({Key? key, this.expense, this.onSubmit})
    : super(key: key);

  @override
  _ExpenseFormScreenState createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _invoiceNumberController =
      TextEditingController();

  // Selected values
  DateTime _selectedDate = DateTime.now();
  int? _selectedCategoryId;
  int? _selectedAnimalTypeId;
  int? _selectedBreedId;
  Supplier? _selectedSupplier;
  PaymentMethod? _selectedPaymentMethod;
  bool _isRecurrent = false;
  String _status = 'completed';

  // Service instances
  final ExpenseService _expenseService = ExpenseService();
  final ExpenseCategoryService _categoryService = ExpenseCategoryService();
  final SupplierService _supplierService = SupplierService();
  final PaymentMethodService _paymentMethodService = PaymentMethodService();

  // Data lists
  List<ExpenseCategory> _categories = [];
  Map<String, ExpenseCategory> categoriesMap = {};
  List<String> categoriesNames = [];
  String? selectedcategoriesName;

  Map<String, AnimalType> animalTypeMap = {};
  List<AnimalType> _animalTypes = [];
  List<String> animalTypeNames = [];
  String? selectedAnimalTypeName;

  Map<String, AnimalBreed> breedMap = {};
  List<String> breedNames = [];
  String? selectedBreedName;

  List<Supplier> _suppliers = [];
  List<PaymentMethod> _paymentMethods = [];

  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;

  // Status options
  final Map<String, String> _statusOptions = {
    'pending': 'En attente',
    'completed': 'Complétée',
    'cancelled': 'Annulée',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load all necessary data
      final categoriesFuture = _categoryService.fetchCategories();
      final animalTypesFuture = ApiService.fetchAnimalTypes();
      final suppliersFuture = _supplierService.fetchSuppliers();
      final paymentMethodsFuture = _paymentMethodService.fetchPaymentMethods();

      final results = await Future.wait([
        categoriesFuture,
        animalTypesFuture,
        suppliersFuture,
        paymentMethodsFuture,
      ]);

      setState(() {
        _categories = results[0] as List<ExpenseCategory>;
        categoriesMap = {
          for (var category in _categories) category.name: category,
        };
        categoriesNames = categoriesMap.keys.toList();

        _animalTypes = results[1] as List<AnimalType>;
        animalTypeMap = {for (var type in _animalTypes) type.name: type};
        animalTypeNames = animalTypeMap.keys.toList();

        _suppliers = results[2] as List<Supplier>;
        _paymentMethods = results[3] as List<PaymentMethod>;
        _isLoading = false;
      });

      // After loading the data, set up the form for editing if an expense was provided
      if (widget.expense != null) {
        _setupFormForEditing();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      FormWidgets.showSnackbar(
        context,
        "Failed to load data: ${e.toString()}",
        Colors.red,
      );
    }
  }

  void _setupFormForEditing() {
    final expense = widget.expense!;

    // Set text controllers
    _descriptionController.text = expense.description;
    _amountController.text = expense.amount.toString();
    if (expense.invoiceNumber != null) {
      _invoiceNumberController.text = expense.invoiceNumber!;
    }

    // Set date
    try {
      _selectedDate = DateFormat('yyyy-MM-dd').parse(expense.date);
    } catch (e) {
      _selectedDate = DateTime.now();
    }

    // Set category
    _selectedCategoryId = expense.categoryId;

    // Set animal type and breed
    if (expense.animalTypeId != null) {
      _selectedAnimalTypeId = expense.animalTypeId;
      _loadBreeds();
      if (expense.animalBreedId != null) {
        _selectedBreedId = expense.animalBreedId;
      }
    }

    // Set supplier
    if (expense.supplierId != null) {
      _selectedSupplier = _suppliers.firstWhere(
        (s) => s.id == expense.supplierId,
      );
    }

    // Set payment method
    if (expense.paymentMethodId != null) {
      _selectedPaymentMethod = _paymentMethods.firstWhere(
        (p) => p.id == expense.paymentMethodId,
      );
    }

    // Set other fields
    _isRecurrent = expense.isRecurrent;
    _status = expense.status;
  }

  Future<void> _loadBreeds() async {
    if (_selectedAnimalTypeId == null) {
      setState(() {
        _selectedBreedId = null;
      });
      return;
    }

    try {
      final breedList = await ApiService.fetchBreeds(
        animalTypeId: _selectedAnimalTypeId!,
      );
      setState(() {
        breedMap = {for (var breed in breedList) breed.name: breed};
        breedNames = breedMap.keys.toList();
        selectedBreedName = null;
        _selectedBreedId = null;
      });
    } catch (e) {
      FormWidgets.showSnackbar(
        context,
        "Error loading breeds: ${e.toString()}",
        Colors.red,
      );
    }
  }

  Future<void> _saveExpense() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (_selectedCategoryId == null) {
      FormWidgets.showSnackbar(
        context,
        "Please select a category",
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final double amount = double.tryParse(_amountController.text) ?? 0;
      if (amount <= 0) {
        FormWidgets.showSnackbar(
          context,
          "Amount must be greater than zero",
          Colors.orange,
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      final expense = Expense(
        id: widget.expense?.id,
        categoryId: _selectedCategoryId!,
        description: _descriptionController.text,
        amount: amount,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        animalTypeId: _selectedAnimalTypeId,
        animalBreedId: _selectedBreedId,
        supplierId: _selectedSupplier?.id,
        paymentMethodId: _selectedPaymentMethod?.id,
        invoiceNumber:
            _invoiceNumberController.text.isNotEmpty
                ? _invoiceNumberController.text
                : null,
        isRecurrent: _isRecurrent,
        status: _status,
      );

      // // Call the onSubmit callback if it's provided
      if (widget.onSubmit != null) {
        widget.onSubmit!(expense);
        Navigator.pop(context, true);
        return;
      }

      bool success;
      if (widget.expense == null) {
        // Create new expense
        success = await _expenseService.createExpense(expense);
      } else {
        // Update existing expense
        success = await _expenseService.updateExpense(expense);
      }

      if (success) {
        FormWidgets.showSnackbar(
          context,
          widget.expense == null
              ? "Expense created successfully"
              : "Expense updated successfully",
          Colors.green,
        );

        // Return to the previous screen with success indicator
        Navigator.pop(context, true);
      } else {
        FormWidgets.showSnackbar(context, "Failed to save expense", Colors.red);
        setState(() {
          _isSaving = false;
        });
      }
    } catch (e) {
      FormWidgets.showSnackbar(context, "Error: ${e.toString()}", Colors.red);
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          widget.expense == null ? "Create Expense" : "Edit Expense",
          style: GoogleFonts.lato(fontSize: 20),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Image.asset(
              'assets/images/smartfarm_2_16x16.png',
              width: 24,
              height: 24,
            ),
          ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.green))
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Category dropdown
                        FormWidgets.buildDropdown(
                          "Category",
                          categoriesNames,
                          selectedcategoriesName,
                          (value) {
                            setState(() {
                              _selectedCategoryId = categoriesMap[value]!.id;
                            });
                          },
                        ),

                        // Description field
                        FormWidgets.buildTextField(
                          "Description",
                          _descriptionController,
                          TextInputType.text,
                          maxLines: 3,
                        ),

                        // Amount field
                        FormWidgets.buildTextField(
                          "Amount (FCFA)",
                          _amountController,
                          TextInputType.numberWithOptions(decimal: true),
                        ),

                        // Date picker
                        FormWidgets.buildDatePicker(
                          context,
                          "Date",
                          _selectedDate,
                          (date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                        ),

                        // Animal type dropdown
                        FormWidgets.buildDropdown(
                          "Animal Type (Optional)",
                          animalTypeNames,
                          selectedAnimalTypeName,
                          (value) {
                            setState(() {
                              selectedAnimalTypeName = value;
                              if (value != null) {
                                _selectedAnimalTypeId =
                                    animalTypeMap[value]!.id;
                                _loadBreeds();
                              } else {
                                _selectedAnimalTypeId = null;
                              }
                            });
                          },
                        ),

                        // Animal breed dropdown (conditionally visible)
                        if (_selectedAnimalTypeId != null)
                          FormWidgets.buildDropdown(
                            "Breed (Optional)",
                            breedNames,
                            selectedBreedName,
                            (value) {
                              setState(() {
                                selectedBreedName = value;
                                if (value != null) {
                                  _selectedBreedId = breedMap[value]!.id;
                                } else {
                                  _selectedBreedId = null;
                                }
                              });
                            },
                          ),

                        // Supplier dropdown
                        FormWidgets.buildDropdown<Supplier>(
                          "Supplier (Optional)",
                          _suppliers,
                          _selectedSupplier,
                          (value) {
                            setState(() {
                              _selectedSupplier = value;
                            });
                          },
                          displayValueFunc: (supplier) => supplier.name,
                        ),

                        // Payment method dropdown
                        FormWidgets.buildDropdown<PaymentMethod>(
                          "Payment Method (Optional)",
                          _paymentMethods,
                          _selectedPaymentMethod,
                          (value) {
                            setState(() {
                              _selectedPaymentMethod = value;
                            });
                          },
                          displayValueFunc: (method) => method.name,
                        ),

                        // Invoice number field
                        FormWidgets.buildTextField(
                          "Invoice Number (Optional)",
                          _invoiceNumberController,
                          TextInputType.text,
                        ),

                        // Recurring expense checkbox
                        FormWidgets.buildCheckbox(
                          "Recurring Expense",
                          _isRecurrent,
                          (value) {
                            setState(() {
                              _isRecurrent = value ?? false;
                            });
                          },
                        ),

                        // Status selection
                        FormWidgets.buildSegmentedControl<String>(
                          "Status",
                          _statusOptions,
                          _status,
                          (value) {
                            setState(() {
                              _status = value;
                            });
                          },
                        ),

                        SizedBox(height: 24),

                        // Save button
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveExpense,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child:
                              _isSaving
                                  ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    "Save",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),

                        // Delete button (only in edit mode)
                        if (widget.expense != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: OutlinedButton(
                              onPressed:
                                  _isSaving
                                      ? null
                                      : () =>
                                          _confirmDelete(widget.expense!.id!),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                side: BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Delete",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Future<void> _confirmDelete(int expenseId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this expense?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Delete", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isSaving = true;
      });

      try {
        final success = await _expenseService.deleteExpense(expenseId);
        if (success) {
          FormWidgets.showSnackbar(
            context,
            "Expense deleted successfully",
            Colors.green,
          );
          Navigator.pop(context, true);
        } else {
          FormWidgets.showSnackbar(
            context,
            "Failed to delete expense",
            Colors.red,
          );
          setState(() {
            _isSaving = false;
          });
        }
      } catch (e) {
        FormWidgets.showSnackbar(context, "Error: ${e.toString()}", Colors.red);
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _invoiceNumberController.dispose();
    super.dispose();
  }
}
