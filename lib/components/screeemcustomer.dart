import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../service/CustomerService.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final CustomerService _customerService = CustomerService();
  List<Customer> _customers = [];
  bool _isLoading = false;
  String _currentFilter =
      'A'; // 'A' para activos, 'I' para inactivos, 'ALL' para todos

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);

    try {
      List<Customer> customers;
      if (_currentFilter == 'A') {
        customers = await _customerService.findAllActive();
      } else if (_currentFilter == 'I') {
        // Para obtener inactivos, obtenemos todos y filtramos
        final allCustomers = await _customerService.findAll();
        customers = allCustomers.where((c) => c.status == 'I').toList();
      } else {
        customers = await _customerService.findAll();
      }

      setState(() {
        _customers = customers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error al cargar clientes: $e');
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
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showCustomerDialog({Customer? customer}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final lastnameController = TextEditingController(
      text: customer?.lastname ?? '',
    );
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer == null ? 'Crear Cliente' : 'Editar Cliente'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    // Verificar que no contenga números
                    if (RegExp(r'[0-9]').hasMatch(value)) {
                      return 'El nombre no puede contener números';
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
                    // Solo validar si hay contenido
                    if (value != null && value.isNotEmpty) {
                      // Verificar que no contenga números
                      if (RegExp(r'[0-9]').hasMatch(value)) {
                        return 'El apellido no puede contener números';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono * (9 dígitos)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                    hintText: '987654321',
                  ),
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El teléfono es requerido';
                    }
                    // Verificar que tenga exactamente 9 dígitos
                    if (value.length != 9) {
                      return 'El teléfono debe tener exactamente 9 dígitos';
                    }
                    // Verificar que solo contenga números
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'El teléfono solo puede contener números';
                    }
                    // Verificar que comience con 9
                    if (!value.startsWith('9')) {
                      return 'El teléfono debe comenzar con 9';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                    hintText: 'ejemplo@correo.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El email es requerido';
                    }
                    // Verificar que no contenga espacios
                    if (value.contains(' ')) {
                      return 'El email no puede contener espacios';
                    }
                    // Verificar que no contenga #
                    if (value.contains('#')) {
                      return 'El email no puede contener el símbolo #';
                    }
                    // Verificar formato básico de email
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                      return 'Ingrese un email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  '* Campos requeridos',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
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
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final customerData = Customer(
                    customerId: customer?.customerId,
                    name: nameController.text,
                    lastname: lastnameController.text.isNotEmpty
                        ? lastnameController.text
                        : null,
                    phone: phoneController.text,
                    email: emailController.text,
                    status: customer?.status ?? 'A',
                    registerDate: customer?.registerDate,
                  );

                  if (customer == null) {
                    await _customerService.create(customerData);
                    _showSuccessSnackBar('Cliente creado exitosamente');
                  } else {
                    await _customerService.update(
                      customer.customerId!,
                      customerData,
                    );
                    _showSuccessSnackBar('Cliente actualizado exitosamente');
                  }

                  Navigator.of(context).pop();
                  _loadCustomers();
                } catch (e) {
                  _showErrorDialog(
                    'Error al ${customer == null ? 'crear' : 'actualizar'} cliente: $e',
                  );
                }
              }
            },
            child: Text(customer == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar a ${customer.fullName}?'),
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
        await _customerService.logicalDelete(customer.customerId!);
        _showSuccessSnackBar('Cliente eliminado exitosamente');
        _loadCustomers();
      } catch (e) {
        _showErrorDialog('Error al eliminar cliente: $e');
      }
    }
  }

  Future<void> _restoreCustomer(Customer customer) async {
    try {
      await _customerService.restore(customer.customerId!);
      _showSuccessSnackBar('Cliente restaurado exitosamente');
      _loadCustomers();
    } catch (e) {
      _showErrorDialog('Error al restaurar cliente: $e');
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: _currentFilter == 'A' ? Colors.white : Colors.green,
                ),
                const SizedBox(width: 4),
                const Text('Activos'),
              ],
            ),
            selected: _currentFilter == 'A',
            onSelected: (selected) {
              if (selected) {
                setState(() => _currentFilter = 'A');
                _loadCustomers();
              }
            },
            selectedColor: Colors.green,
            labelStyle: TextStyle(
              color: _currentFilter == 'A' ? Colors.white : Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cancel,
                  size: 16,
                  color: _currentFilter == 'I' ? Colors.white : Colors.red,
                ),
                const SizedBox(width: 4),
                const Text('Inactivos'),
              ],
            ),
            selected: _currentFilter == 'I',
            onSelected: (selected) {
              if (selected) {
                setState(() => _currentFilter = 'I');
                _loadCustomers();
              }
            },
            selectedColor: Colors.red,
            labelStyle: TextStyle(
              color: _currentFilter == 'I' ? Colors.white : Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.list,
                  size: 16,
                  color: _currentFilter == 'ALL' ? Colors.white : Colors.blue,
                ),
                const SizedBox(width: 4),
                const Text('Todos'),
              ],
            ),
            selected: _currentFilter == 'ALL',
            onSelected: (selected) {
              if (selected) {
                setState(() => _currentFilter = 'ALL');
                _loadCustomers();
              }
            },
            selectedColor: Colors.blue,
            labelStyle: TextStyle(
              color: _currentFilter == 'ALL' ? Colors.white : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final isActive = customer.status == 'A';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green : Colors.red,
          child: Text(
            customer.name.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          customer.fullName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isActive ? null : TextDecoration.lineThrough,
            color: isActive ? null : Colors.grey,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(customer.phone),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(customer.email, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Registro: ${customer.formattedRegisterDate}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isActive ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Text(
                isActive ? 'Activo' : 'Inactivo',
                style: TextStyle(
                  color: isActive ? Colors.green : Colors.red,
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
                _showCustomerDialog(customer: customer);
                break;
              case 'delete':
                _deleteCustomer(customer);
                break;
              case 'restore':
                _restoreCustomer(customer);
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
        title: const Text('Gestión de Clientes'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filtrar por estado:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildFilterChips(),
                const SizedBox(height: 8),
                Text(
                  'Total: ${_customers.length} cliente${_customers.length != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  )
                : _customers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 100,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay clientes ${_currentFilter == 'A'
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
                          'Presiona el botón + para agregar uno nuevo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: _customers.length,
                    itemBuilder: (context, index) {
                      return _buildCustomerCard(_customers[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCustomerDialog(),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Cliente'),
      ),
    );
  }
}