import 'package:flutter/material.dart';
import '../models/dish.dart';
import '../service/DishService.dart';

class DishScreen extends StatefulWidget {
  const DishScreen({super.key});

  @override
  State<DishScreen> createState() => _DishScreenState();
}

class _DishScreenState extends State<DishScreen> {
  final DishService _dishService = DishService();
  List<Dish> _dishes = [];
  bool _isLoading = false;
  String _currentFilter = 'A'; // 'A' para activos, 'I' para inactivos, 'ALL' para todos

  @override
  void initState() {
    super.initState();
    _loadDishes();
  }

  Future<void> _loadDishes() async {
    setState(() => _isLoading = true);
    
    try {
      List<Dish> dishes;
      if (_currentFilter == 'A') {
        dishes = await _dishService.findAllActive();
      } else if (_currentFilter == 'I') {
        // Para obtener inactivos, obtenemos todos y filtramos
        final allDishes = await _dishService.findAll();
        dishes = allDishes.where((d) => d.status == 'I').toList();
      } else {
        dishes = await _dishService.findAll();
      }
      
      setState(() {
        _dishes = dishes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error al cargar platos: $e');
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

  void _showDishDialog({Dish? dish}) {
    final nameController = TextEditingController(text: dish?.name ?? '');
    final descriptionController = TextEditingController(text: dish?.description ?? '');
    final priceController = TextEditingController(text: dish?.price.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(dish == null ? 'Crear Plato' : 'Editar Plato'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del plato',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.restaurant_menu),
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
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La descripción es requerida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'S/.',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El precio es requerido';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Ingrese un precio válido mayor a 0';
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
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final dishData = Dish(
                    dishId: dish?.dishId,
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.parse(priceController.text),
                    status: dish?.status ?? 'A',
                  );

                  if (dish == null) {
                    await _dishService.create(dishData);
                    _showSuccessSnackBar('Plato creado exitosamente');
                  } else {
                    await _dishService.update(dish.dishId!, dishData);
                    _showSuccessSnackBar('Plato actualizado exitosamente');
                  }

                  Navigator.of(context).pop();
                  _loadDishes();
                } catch (e) {
                  _showErrorDialog('Error al ${dish == null ? 'crear' : 'actualizar'} plato: $e');
                }
              }
            },
            child: Text(dish == null ? 'Crear' : 'Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDish(Dish dish) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar el plato "${dish.name}"?'),
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
        await _dishService.logicalDelete(dish.dishId!);
        _showSuccessSnackBar('Plato eliminado exitosamente');
        _loadDishes();
      } catch (e) {
        _showErrorDialog('Error al eliminar plato: $e');
      }
    }
  }

  Future<void> _restoreDish(Dish dish) async {
    try {
      await _dishService.restore(dish.dishId!);
      _showSuccessSnackBar('Plato restaurado exitosamente');
      _loadDishes();
    } catch (e) {
      _showErrorDialog('Error al restaurar plato: $e');
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
              _loadDishes();
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
              _loadDishes();
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
              _loadDishes();
            }
          },
          selectedColor: Colors.blue.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildDishCard(Dish dish) {
    final isActive = dish.status == 'A';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isActive ? Colors.orange : Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.restaurant_menu,
            color: Colors.white,
            size: 30,
          ),
        ),
        title: Text(
          dish.name,
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
            Text(
              dish.description,
              style: TextStyle(
                color: isActive ? Colors.grey[700] : Colors.grey,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'S/. ${dish.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: isActive ? Colors.green[700] : Colors.red[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showDishDialog(dish: dish);
                break;
              case 'delete':
                _deleteDish(dish);
                break;
              case 'restore':
                _restoreDish(dish);
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
        title: const Text('Gestión de Platos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDishes,
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
                : _dishes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.restaurant_menu_outlined,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay platos ${_currentFilter == 'A' ? 'activos' : _currentFilter == 'I' ? 'inactivos' : ''}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '¡Comienza agregando tu primer plato!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _dishes.length,
                        itemBuilder: (context, index) {
                          return _buildDishCard(_dishes[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDishDialog(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}