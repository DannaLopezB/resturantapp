import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../service/EmployeeService.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final EmployeeService _employeeService = EmployeeService();
  List<Employee> _employees = [];
  bool _isLoading = false;
  String _currentFilter =
      'A'; // 'A' para activos, 'I' para inactivos, 'ALL' para todos

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);

    try {
      List<Employee> employees;
      if (_currentFilter == 'A') {
        employees = await _employeeService.getAllActiveEmployees();
      } else if (_currentFilter == 'I') {
        // Para obtener inactivos, obtenemos todos y filtramos
        final allEmployees = await _employeeService.getAllEmployees();
        employees = allEmployees.where((e) => e.status == 'I').toList();
      } else {
        employees = await _employeeService.getAllEmployees();
      }

      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error al cargar empleados: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  void _showEmployeeDialog({Employee? employee}) {
    final nameController = TextEditingController(text: employee?.name ?? '');
    final roleController = TextEditingController(text: employee?.role ?? '');
    final phoneController = TextEditingController(text: employee?.phone ?? '');
    final formKey = GlobalKey<FormState>();

    // Lista de roles predefinidos
    final List<String> predefinedRoles = [
      'Administrador',
      'Gerente',
      'Chef',
      'Cocinero',
      'Mesero',
      'Cajero',
      'Barista',
      'Limpieza',
      'Seguridad',
      'Recepcionista',
    ];

    String? selectedRole = predefinedRoles.contains(employee?.role)
        ? employee?.role
        : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(employee == null ? 'Crear Empleado' : 'Editar Empleado'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El nombre es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Rol/Puesto',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.work),
                    ),
                    items: [
                      ...predefinedRoles.map(
                        (role) =>
                            DropdownMenuItem(value: role, child: Text(role)),
                      ),
                      const DropdownMenuItem(
                        value: 'custom',
                        child: Text('Otro (escribir manualmente)'),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedRole = value;
                        if (value != 'custom') {
                          roleController.text = value ?? '';
                        } else {
                          roleController.text = '';
                        }
                      });
                    },
                    validator: (value) {
                      if ((value == null || value == 'custom') &&
                          roleController.text.isEmpty) {
                        return 'El rol es requerido';
                      }
                      return null;
                    },
                  ),
                  if (selectedRole == 'custom') ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: roleController,
                      decoration: const InputDecoration(
                        labelText: 'Escriba el rol personalizado',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit),
                      ),
                      validator: (value) {
                        if (selectedRole == 'custom' &&
                            (value == null || value.isEmpty)) {
                          return 'Debe especificar el rol';
                        }
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'El teléfono es requerido';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    final employeeData = Employee(
                      employeeId: employee?.employeeId,
                      name: nameController.text,
                      role: selectedRole == 'custom'
                          ? roleController.text
                          : (selectedRole ?? roleController.text),
                      phone: phoneController.text,
                      status: employee?.status ?? 'A',
                    );

                    if (employee == null) {
                      await _employeeService.createEmployee(employeeData);
                      _showSuccessSnackBar('Empleado creado exitosamente');
                    } else {
                      await _employeeService.updateEmployee(
                        employee.employeeId!,
                        employeeData,
                      );
                      _showSuccessSnackBar('Empleado actualizado exitosamente');
                    }

                    Navigator.of(context).pop();
                    _loadEmployees();
                  } catch (e) {
                    _showErrorDialog(
                      'Error al ${employee == null ? 'crear' : 'actualizar'} empleado: $e',
                    );
                  }
                }
              },
              child: Text(
                employee == null ? 'Crear' : 'Guardar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEmployee(Employee employee) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Está seguro de eliminar al empleado "${employee.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _employeeService.logicalDeleteEmployee(employee.employeeId!);
        _showSuccessSnackBar('Empleado eliminado exitosamente');
        _loadEmployees();
      } catch (e) {
        _showErrorDialog('Error al eliminar empleado: $e');
      }
    }
  }

  Future<void> _restoreEmployee(Employee employee) async {
    try {
      await _employeeService.restoreEmployee(employee.employeeId!);
      _showSuccessSnackBar('Empleado restaurado exitosamente');
      _loadEmployees();
    } catch (e) {
      _showErrorDialog('Error al restaurar empleado: $e');
    }
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        FilterChip(
          label: const Text('Activos'),
          selected: _currentFilter == 'A',
          onSelected: (selected) {
            if (selected) {
              setState(() => _currentFilter = 'A');
              _loadEmployees();
            }
          },
          selectedColor: Colors.orange.withOpacity(0.3),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Inactivos'),
          selected: _currentFilter == 'I',
          onSelected: (selected) {
            if (selected) {
              setState(() => _currentFilter = 'I');
              _loadEmployees();
            }
          },
          selectedColor: Colors.red.withOpacity(0.3),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Todos'),
          selected: _currentFilter == 'ALL',
          onSelected: (selected) {
            if (selected) {
              setState(() => _currentFilter = 'ALL');
              _loadEmployees();
            }
          },
          selectedColor: Colors.blue.withOpacity(0.3),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
      case 'gerente':
        return Colors.red[700]!;
      case 'chef':
        return Colors.purple[700]!;
      case 'cocinero':
        return Colors.orange[700]!;
      case 'mesero':
      case 'recepcionista':
        return Colors.blue[700]!;
      case 'cajero':
        return Colors.green[700]!;
      case 'barista':
        return Colors.brown[700]!;
      case 'limpieza':
        return Colors.cyan[700]!;
      case 'seguridad':
        return Colors.grey[700]!;
      default:
        return Colors.indigo[700]!;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return Icons.admin_panel_settings;
      case 'gerente':
        return Icons.supervisor_account;
      case 'chef':
        return Icons.restaurant;
      case 'cocinero':
        return Icons.kitchen;
      case 'mesero':
        return Icons.room_service;
      case 'recepcionista':
        return Icons.desk;
      case 'cajero':
        return Icons.point_of_sale;
      case 'barista':
        return Icons.local_cafe;
      case 'limpieza':
        return Icons.cleaning_services;
      case 'seguridad':
        return Icons.security;
      default:
        return Icons.work;
    }
  }

  Widget _buildEmployeeCard(Employee employee) {
    final isActive = employee.status == 'A';
    final roleColor = _getRoleColor(employee.role);
    final roleIcon = _getRoleIcon(employee.role);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isActive ? roleColor : Colors.grey,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(roleIcon, color: Colors.white, size: 30),
        ),
        title: Text(
          employee.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            decoration: isActive ? null : TextDecoration.lineThrough,
            color: isActive ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  roleIcon,
                  size: 16,
                  color: isActive ? roleColor : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  employee.role,
                  style: TextStyle(
                    color: isActive ? roleColor : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.phone,
                  size: 16,
                  color: isActive ? Colors.grey[600] : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  employee.phone,
                  style: TextStyle(
                    color: isActive ? Colors.grey[700] : Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.orange.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: isActive ? Colors.orange[700] : Colors.red[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEmployeeDialog(employee: employee);
                break;
              case 'delete':
                _deleteEmployee(employee);
                break;
              case 'restore':
                _restoreEmployee(employee);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            if (isActive)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar'),
                  ],
                ),
              ),
            if (!isActive)
              const PopupMenuItem(
                value: 'restore',
                child: Row(
                  children: [
                    Icon(Icons.restore, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Restaurar'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Empleados'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrar por estado:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildFilterChips(),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _employees.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.badge_outlined,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay empleados ${_currentFilter == 'A'
                              ? 'activos'
                              : _currentFilter == 'I'
                              ? 'inactivos'
                              : ''}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '¡Comienza agregando tu primer empleado!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _employees.length,
                    itemBuilder: (context, index) {
                      return _buildEmployeeCard(_employees[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmployeeDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
