import 'package:flutter/material.dart';
import '../models/order.dart';
import '../service/OrderService.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final OrderService _orderService = OrderService();
  List<OrderResponseDTO> _orders = [];
  List<OrderResponseDTO> _filteredOrders = [];
  bool _isLoading = false;
  String _filterStatus = 'Todos'; // 'Todos', 'Activos', 'Inactivos'

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.getAllOrders();
      setState(() {
        _orders = orders;
        _applyFilter();
      });
    } catch (e) {
      _showErrorSnackBar('Error al cargar órdenes: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      switch (_filterStatus) {
        case 'Activos':
          _filteredOrders = _orders
              .where((order) => order.status == 'Activo' || order.status == 'A')
              .toList();
          break;
        case 'Inactivos':
          _filteredOrders = _orders
              .where(
                (order) => order.status == 'Inactivo' || order.status == 'I',
              )
              .toList();
          break;
        default:
          _filteredOrders = _orders;
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _deleteOrder(int orderId) async {
    try {
      await _orderService.deleteOrder(orderId);
      _showSuccessSnackBar('Orden eliminada correctamente');
      _loadOrders();
    } catch (e) {
      _showErrorSnackBar('Error al eliminar orden: $e');
    }
  }

  Future<void> _restoreOrder(int orderId) async {
    try {
      await _orderService.restoreOrder(orderId);
      _showSuccessSnackBar('Orden restaurada correctamente');
      _loadOrders();
    } catch (e) {
      _showErrorSnackBar('Error al restaurar orden: $e');
    }
  }

  void _showDeleteDialog(OrderResponseDTO order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar la orden #${order.orderId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrder(order.orderId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateOrderDialog(
        onOrderCreated: () {
          _loadOrders();
          _showSuccessSnackBar('Orden creada correctamente');
        },
      ),
    );
  }

  void _showEditOrderDialog(OrderResponseDTO order) {
    showDialog(
      context: context,
      builder: (context) => EditOrderDialog(
        order: order,
        onOrderUpdated: () {
          _loadOrders();
          _showSuccessSnackBar('Orden actualizada correctamente');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Órdenes'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filterStatus = value);
              _applyFilter();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'Todos',
                child: Text('Todas las órdenes'),
              ),
              const PopupMenuItem(
                value: 'Activos',
                child: Text('Órdenes activas'),
              ),
              const PopupMenuItem(
                value: 'Inactivos',
                child: Text('Órdenes inactivas'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Icon(Icons.filter_list, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Filtro: $_filterStatus',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_filteredOrders.length} órdenes',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.receipt_long,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No hay órdenes disponibles',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredOrders.length,
                          itemBuilder: (context, index) {
                            final order = _filteredOrders[index];
                            final isActive =
                                order.status == 'Activo' || order.status == 'A';

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: isActive
                                      ? Colors.green
                                      : Colors.red,
                                  child: Text(
                                    order.orderId.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text('Mesa ${order.tableNumber}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${order.orderDate} - ${order.orderTime}',
                                    ),
                                    Text(
                                      'Cliente: ${order.customerId} | Empleado: ${order.employeeId}',
                                    ),
                                    Text(
                                      '${order.orderDetails.length} productos',
                                    ),
                                  ],
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit':
                                        _showEditOrderDialog(order);
                                        break;
                                      case 'delete':
                                        _showDeleteDialog(order);
                                        break;
                                      case 'restore':
                                        _restoreOrder(order.orderId);
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
                                            Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
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
                                            Icon(
                                              Icons.restore,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Restaurar'),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOrderDialog,
        backgroundColor: Colors.red,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class CreateOrderDialog extends StatefulWidget {
  final VoidCallback onOrderCreated;

  const CreateOrderDialog({super.key, required this.onOrderCreated});

  @override
  State<CreateOrderDialog> createState() => _CreateOrderDialogState();
}

class _CreateOrderDialogState extends State<CreateOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _orderService = OrderService();

  final _tableController = TextEditingController();
  final _customerController = TextEditingController();
  final _employeeController = TextEditingController();

  List<OrderDetailDTO> _orderDetails = [];
  bool _isLoading = false;

  void _addOrderDetail() {
    setState(() {
      _orderDetails.add(
        OrderDetailDTO(
          dishId: null,
          drinkId: null,
          quantity: 1,
          price: 0.0,
          status: 'Activo',
        ),
      );
    });
  }

  void _removeOrderDetail(int index) {
    setState(() {
      _orderDetails.removeAt(index);
    });
  }

  Future<void> _createOrder() async {
    if (!_formKey.currentState!.validate() || _orderDetails.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete todos los campos y agregue al menos un producto',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final orderRequest = OrderRequestDTO(
        tableNumber: int.parse(_tableController.text),
        customerId: int.parse(_customerController.text),
        employeeId: int.parse(_employeeController.text),
        orderDetails: _orderDetails,
      );

      await _orderService.createOrder(orderRequest);
      Navigator.pop(context);
      widget.onOrderCreated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear orden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crear Nueva Orden',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _tableController,
                          decoration: const InputDecoration(labelText: 'Mesa'),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Requerido';
                            if (int.tryParse(value!) == null)
                              return 'Número inválido';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _customerController,
                          decoration: const InputDecoration(
                            labelText: 'ID Cliente',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Requerido';
                            if (int.tryParse(value!) == null)
                              return 'Número inválido';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _employeeController,
                    decoration: const InputDecoration(labelText: 'ID Empleado'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) return 'Requerido';
                      if (int.tryParse(value!) == null)
                        return 'Número inválido';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Productos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addOrderDetail,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _orderDetails.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Producto ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _removeOrderDetail(index),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'ID Plato',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _orderDetails[index].dishId = int.tryParse(
                                      value,
                                    );
                                    if (value.isNotEmpty)
                                      _orderDetails[index].drinkId = null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'ID Bebida',
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _orderDetails[index].drinkId = int.tryParse(
                                      value,
                                    );
                                    if (value.isNotEmpty)
                                      _orderDetails[index].dishId = null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Cantidad',
                                  ),
                                  keyboardType: TextInputType.number,
                                  initialValue: _orderDetails[index].quantity
                                      .toString(),
                                  onChanged: (value) {
                                    _orderDetails[index].quantity =
                                        int.tryParse(value) ?? 1;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Precio',
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  initialValue: _orderDetails[index].price
                                      .toString(),
                                  onChanged: (value) {
                                    _orderDetails[index].price =
                                        double.tryParse(value) ?? 0.0;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Crear Orden',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditOrderDialog extends StatefulWidget {
  final OrderResponseDTO order;
  final VoidCallback onOrderUpdated;

  const EditOrderDialog({
    super.key,
    required this.order,
    required this.onOrderUpdated,
  });

  @override
  State<EditOrderDialog> createState() => _EditOrderDialogState();
}

class _EditOrderDialogState extends State<EditOrderDialog> {
  final _orderService = OrderService();
  List<OrderDetailDTO> _orderDetails = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _orderDetails = List.from(widget.order.orderDetails);
  }

  void _addOrderDetail() {
    setState(() {
      _orderDetails.add(
        OrderDetailDTO(
          dishId: null,
          drinkId: null,
          quantity: 1,
          price: 0.0,
          status: 'Activo',
        ),
      );
    });
  }

  void _removeOrderDetail(int index) {
    setState(() {
      _orderDetails.removeAt(index);
    });
  }

  Future<void> _updateOrder() async {
    setState(() => _isLoading = true);

    try {
      await _orderService.updateOrderDetails(
        widget.order.orderId,
        _orderDetails,
      );
      Navigator.pop(context);
      widget.onOrderUpdated();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar orden: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editar Orden #${widget.order.orderId}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              'Mesa ${widget.order.tableNumber} - ${widget.order.orderDate}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Productos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addOrderDetail,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _orderDetails.length,
                itemBuilder: (context, index) {
                  final detail = _orderDetails[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Producto ${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: () => _removeOrderDetail(index),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'ID Plato',
                                  ),
                                  keyboardType: TextInputType.number,
                                  initialValue: detail.dishId?.toString() ?? '',
                                  onChanged: (value) {
                                    detail.dishId = int.tryParse(value);
                                    if (value.isNotEmpty) detail.drinkId = null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'ID Bebida',
                                  ),
                                  keyboardType: TextInputType.number,
                                  initialValue:
                                      detail.drinkId?.toString() ?? '',
                                  onChanged: (value) {
                                    detail.drinkId = int.tryParse(value);
                                    if (value.isNotEmpty) detail.dishId = null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Cantidad',
                                  ),
                                  keyboardType: TextInputType.number,
                                  initialValue: detail.quantity.toString(),
                                  onChanged: (value) {
                                    detail.quantity = int.tryParse(value) ?? 1;
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(
                                    labelText: 'Precio',
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                                  initialValue: detail.price.toString(),
                                  onChanged: (value) {
                                    detail.price =
                                        double.tryParse(value) ?? 0.0;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _updateOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Actualizar',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
