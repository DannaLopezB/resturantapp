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
        final allEmployees = await _employeeService.getAllEmployees();
        employees = allEmployees.where((e) => e.status == 'I').toList();
      } else {
        employees = await _employeeService.getAllEmployees();
      }

      // Debug: Verificar IDs de empleados cargados
      print('=== EMPLEADOS CARGADOS ===');
      for (var emp in employees) {
        print(
          'ID: ${emp.employeeId}, Nombre: ${emp.name} ${emp.lastname}, Estado: ${emp.status}',
        );
      }
      print('========================');

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
    final lastnameController = TextEditingController(
      text: employee?.lastname ?? '',
    );
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

    // CORRECIÓN: Si el empleado tiene un rol que no está en la lista predefinida,
    // configurar como 'custom' y establecer el texto en el controller
    if (employee != null &&
        employee.role.isNotEmpty &&
        !predefinedRoles.contains(employee.role)) {
      selectedRole = 'custom';
      roleController.text = employee.role;
    }

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
                  // Mostrar ID del empleado si está editando
                  if (employee != null && employee.employeeId != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.badge,
                            color: Colors.orange,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ID del empleado: ${employee.employeeId}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      if (value.trim().length < 2) {
                        return 'El nombre debe tener al menos 2 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: lastnameController,
                    decoration: const InputDecoration(
                      labelText: 'Apellido',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El apellido es requerido';
                      }
                      if (value.trim().length < 2) {
                        return 'El apellido debe tener al menos 2 caracteres';
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
                        if (value != 'custom' && value != null) {
                          roleController.text = value;
                        } else if (value == 'custom' &&
                            roleController.text.isEmpty) {
                          // Solo limpiar si está vacío, mantener el texto existente
                          roleController.text = '';
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null && roleController.text.trim().isEmpty) {
                        return 'Debe seleccionar un rol o escribir uno personalizado';
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
                            (value == null || value.trim().isEmpty)) {
                          return 'Debe especificar el rol personalizado';
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
                      if (value == null || value.trim().isEmpty) {
                        return 'El teléfono es requerido';
                      }
                      if (value.trim().length < 8) {
                        return 'El teléfono debe tener al menos 8 dígitos';
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
                    // Obtener el rol final
                    final finalRole = selectedRole == 'custom'
                        ? roleController.text.trim()
                        : (selectedRole ?? roleController.text.trim());

                    if (employee == null) {
                      // CREAR NUEVO EMPLEADO
                      final newEmployee = Employee(
                        employeeId: null, // Para nuevos empleados
                        name: nameController.text.trim(),
                        lastname: lastnameController.text.trim(),
                        role: finalRole,
                        phone: phoneController.text.trim(),
                        registerDate: null, // Se asignará en el backend
                        status: 'A', // Nuevo empleado siempre activo
                      );

                      print('Creando nuevo empleado: $newEmployee');
                      await _employeeService.createEmployee(newEmployee);
                      _showSuccessSnackBar('Empleado creado exitosamente');
                    } else {
                      // ACTUALIZAR EMPLEADO EXISTENTE
                      if (employee.employeeId == null) {
                        throw Exception(
                          'El empleado no tiene un ID válido para actualizar',
                        );
                      }

                      // CORRECCIÓN: Crear empleado actualizado usando copyWith o constructor completo
                      final updatedEmployee = Employee(
                        employeeId:
                            employee.employeeId!, // Mantener ID original
                        name: nameController.text.trim(),
                        lastname: lastnameController.text.trim(),
                        role: finalRole,
                        phone: phoneController.text.trim(),
                        registerDate:
                            employee.registerDate, // Mantener fecha original
                        status: employee.status, // Mantener estado original
                      );

                      // Debug: Imprimir información del empleado antes de actualizar
                      print('=== ACTUALIZANDO EMPLEADO ===');
                      print('ID original: ${employee.employeeId}');
                      print('Datos originales: $employee');
                      print('Datos actualizados: $updatedEmployee');
                      print('=============================');

                      await _employeeService.updateEmployee(
                        employee.employeeId!,
                        updatedEmployee,
                      );
                      _showSuccessSnackBar('Empleado actualizado exitosamente');
                    }

                    Navigator.of(context).pop();
                    await _loadEmployees(); // Recargar lista
                  } catch (e) {
                    print('Error en operación: $e'); // Debug
                    _showErrorDialog(
                      'Error al ${employee == null ? 'crear' : 'actualizar'} empleado: $e',
                    );
                  }
                }
              },
              child: Text(
                employee == null ? 'Crear' : 'Actualizar',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEmployee(Employee employee) async {
    if (employee.employeeId == null) {
      _showErrorDialog('Error: ID del empleado no disponible para eliminar');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('¿Está seguro de eliminar al empleado?'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID: ${employee.employeeId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Nombre: ${employee.name} ${employee.lastname}'),
                  Text('Rol: ${employee.role}'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _employeeService.logicalDeleteEmployee(employee.employeeId!);
        _showSuccessSnackBar('Empleado eliminado exitosamente');
        await _loadEmployees();
      } catch (e) {
        print('Error al eliminar: $e'); // Debug
        _showErrorDialog('Error al eliminar empleado: $e');
      }
    }
  }

  Future<void> _restoreEmployee(Employee employee) async {
    if (employee.employeeId == null) {
      _showErrorDialog('Error: ID del empleado no disponible para restaurar');
      return;
    }

    try {
      await _employeeService.restoreEmployee(employee.employeeId!);
      _showSuccessSnackBar('Empleado restaurado exitosamente');
      await _loadEmployees();
    } catch (e) {
      print('Error al restaurar: $e'); // Debug
      _showErrorDialog('Error al restaurar empleado: $e');
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
      ),
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

  String _getInitials(String name, String lastname) {
    String nameInitial = name.isNotEmpty ? name[0].toUpperCase() : '';
    String lastnameInitial = lastname.isNotEmpty
        ? lastname[0].toUpperCase()
        : '';
    return '$nameInitial$lastnameInitial';
  }

  Widget _buildEmployeeCard(Employee employee) {
    final isActive = employee.status == 'A';
    final roleColor = _getRoleColor(employee.role);
    final roleIcon = _getRoleIcon(employee.role);
    final fullName = '${employee.name} ${employee.lastname}';
    final initials = _getInitials(employee.name, employee.lastname);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isActive ? roleColor : Colors.grey,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isActive ? roleColor : Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(roleIcon, color: Colors.white, size: 12),
              ),
            ),
          ],
        ),
        title: Text(
          fullName,
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
                Expanded(
                  child: Text(
                    employee.role,
                    style: TextStyle(
                      color: isActive ? roleColor : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
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
                Expanded(
                  child: Text(
                    employee.phone,
                    style: TextStyle(
                      color: isActive ? Colors.grey[700] : Colors.grey,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (employee.registerDate != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: isActive ? Colors.grey[600] : Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Registrado: ${employee.registerDate!.day}/${employee.registerDate!.month}/${employee.registerDate!.year}',
                    style: TextStyle(
                      color: isActive ? Colors.grey[700] : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
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
            tooltip: 'Actualizar lista',
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
                : RefreshIndicator(
                    onRefresh: _loadEmployees,
                    child: ListView.builder(
                      itemCount: _employees.length,
                      itemBuilder: (context, index) {
                        return _buildEmployeeCard(_employees[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmployeeDialog(),
        backgroundColor: Colors.orange,
        tooltip: 'Agregar empleado',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
