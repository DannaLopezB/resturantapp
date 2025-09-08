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
  String _currentFilter = 'A'; // 'A' para activos, 'I' para inactivos, 'ALL' para todos

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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showCustomerDialog({Customer? customer}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final emailController = TextEditingController(text: customer?.email ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer == null ? 'Crear Cliente' : 'Editar Cliente'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El nombre es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El teléfono es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El email es requerido';
                  }
                  if (!value.contains('@')) {
                    return 'Ingrese un email válido';
                  }
                  return null;
                },
              ),
            ],
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
                    phone: phoneController.text,
                    email: emailController.text,
                    status: customer?.status ?? 'A',
                  );

                  if (customer == null) {
                    await _customerService.create(customerData);
                    _showSuccessSnackBar('Cliente creado exitosamente');
                  } else {
                    await _customerService.update(customer.customerId!, customerData);
                    _showSuccessSnackBar('Cliente actualizado exitosamente');
                  }

                  Navigator.of(context).pop();
                  _loadCustomers();
                } catch (e) {
                  _showErrorDialog('Error al ${customer == null ? 'crear' : 'actualizar'} cliente: $e');
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
        content: Text('¿Está seguro de eliminar a ${customer.name}?'),
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
    return Row(
      children: [
        FilterChip(
          label: const Text('Activos'),
          selected: _currentFilter == 'A',
          onSelected: (selected) {
            if (selected) {
              setState(() => _currentFilter = 'A');
              _loadCustomers();
            }
          },
          selectedColor: Colors.green.withOpacity(0.3),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Inactivos'),
          selected: _currentFilter == 'I',
          onSelected: (selected) {
            if (selected) {
              setState(() => _currentFilter = 'I');
              _loadCustomers();
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
              _loadCustomers();
            }
          },
          selectedColor: Colors.blue.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    final isActive = customer.status == 'A';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isActive ? Colors.green : Colors.red,
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          customer.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isActive ? null : TextDecoration.lineThrough,
            color: isActive ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📞 ${customer.phone}'),
            Text('📧 ${customer.email}'),
            Text(
              'Estado: ${isActive ? 'Activo' : 'Inactivo'}',
              style: TextStyle(
                color: isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCustomers,
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
                              'No hay clientes ${_currentFilter == 'A' ? 'activos' : _currentFilter == 'I' ? 'inactivos' : ''}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _customers.length,
                        itemBuilder: (context, index) {
                          return _buildCustomerCard(_customers[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCustomerDialog(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}