import 'package:flutter/material.dart';
import '../models/drink.dart';
import '../service/DrinkService.dart';

class DrinkScreen extends StatefulWidget {
  const DrinkScreen({super.key});

  @override
  State<DrinkScreen> createState() => _DrinkScreenState();
}

class _DrinkScreenState extends State<DrinkScreen> {
  final DrinkService _drinkService = DrinkService();
  List<Drink> _drinks = [];
  bool _isLoading = false;
  String _currentFilter = 'A'; // 'A' para activos, 'I' para inactivos, 'ALL' para todos

  @override
  void initState() {
    super.initState();
    _loadDrinks();
  }

  Future<void> _loadDrinks() async {
    setState(() => _isLoading = true);
    
    try {
      List<Drink> drinks;
      if (_currentFilter == 'A') {
        drinks = await _drinkService.getAllActiveDrinks();
      } else if (_currentFilter == 'I') {
        // Para obtener inactivos, obtenemos todos y filtramos
        final allDrinks = await _drinkService.getAllDrinks();
        drinks = allDrinks.where((d) => d.status == 'I').toList();
      } else {
        drinks = await _drinkService.getAllDrinks();
      }
      
      setState(() {
        _drinks = drinks;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Error al cargar bebidas: $e');
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
        backgroundColor: Colors.purple,
      ),
    );
  }

  void _showDrinkDialog({Drink? drink}) {
    final nameController = TextEditingController(text: drink?.name ?? '');
    final descriptionController = TextEditingController(text: drink?.description ?? '');
    final priceController = TextEditingController(text: drink?.price.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(drink == null ? 'Crear Bebida' : 'Editar Bebida'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la bebida',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_drink),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final drinkData = Drink(
                    drinkId: drink?.drinkId,
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.parse(priceController.text),
                    status: drink?.status ?? 'A',
                  );

                  if (drink == null) {
                    await _drinkService.createDrink(drinkData);
                    _showSuccessSnackBar('Bebida creada exitosamente');
                  } else {
                    await _drinkService.updateDrink(drink.drinkId!, drinkData);
                    _showSuccessSnackBar('Bebida actualizada exitosamente');
                  }

                  Navigator.of(context).pop();
                  _loadDrinks();
                } catch (e) {
                  _showErrorDialog('Error al ${drink == null ? 'crear' : 'actualizar'} bebida: $e');
                }
              }
            },
            child: Text(
              drink == null ? 'Crear' : 'Guardar',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteDrink(Drink drink) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar la bebida "${drink.name}"?'),
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
        await _drinkService.logicalDeleteDrink(drink.drinkId!);
        _showSuccessSnackBar('Bebida eliminada exitosamente');
        _loadDrinks();
      } catch (e) {
        _showErrorDialog('Error al eliminar bebida: $e');
      }
    }
  }

  Future<void> _restoreDrink(Drink drink) async {
    try {
      await _drinkService.restoreDrink(drink.drinkId!);
      _showSuccessSnackBar('Bebida restaurada exitosamente');
      _loadDrinks();
    } catch (e) {
      _showErrorDialog('Error al restaurar bebida: $e');
    }
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        FilterChip(
          label: const Text('Activas'),
          selected: _currentFilter == 'A',
          onSelected: (selected) {
            if (selected) {
              setState(() => _currentFilter = 'A');
              _loadDrinks();
            }
          },
          selectedColor: Colors.purple.withOpacity(0.3),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Inactivas'),
          selected: _currentFilter == 'I',
          onSelected: (selected) {
            if (selected) {
              setState(() => _currentFilter = 'I');
              _loadDrinks();
            }
          },
          selectedColor: Colors.red.withOpacity(0.3),
        ),
        const SizedBox(width: 8),
        FilterChip(
          label: const Text('Todas'),
          selected: _currentFilter == 'ALL',
          onSelected: (selected) {
            if (selected) {
              setState(() => _currentFilter = 'ALL');
              _loadDrinks();
            }
          },
          selectedColor: Colors.blue.withOpacity(0.3),
        ),
      ],
    );
  }

  Color _getDrinkTypeColor(String drinkName) {
    final name = drinkName.toLowerCase();
    if (name.contains('cerveza') || name.contains('beer')) {
      return Colors.amber[700]!;
    } else if (name.contains('vino') || name.contains('wine')) {
      return Colors.red[700]!;
    } else if (name.contains('agua') || name.contains('water')) {
      return Colors.blue[600]!;
    } else if (name.contains('gaseosa') || name.contains('soda') || name.contains('coca') || name.contains('pepsi')) {
      return Colors.brown[600]!;
    } else if (name.contains('jugo') || name.contains('juice')) {
      return Colors.orange[600]!;
    } else if (name.contains('café') || name.contains('coffee')) {
      return Colors.brown[800]!;
    } else if (name.contains('té') || name.contains('tea')) {
      return Colors.green[700]!;
    }
    return Colors.purple[600]!;
  }

  Widget _buildDrinkCard(Drink drink) {
    final isActive = drink.status == 'A';
    final drinkColor = _getDrinkTypeColor(drink.name);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isActive ? drinkColor : Colors.grey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.local_drink,
            color: Colors.white,
            size: 30,
          ),
        ),
        title: Text(
          drink.name,
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
              drink.description,
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
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'S/. ${drink.price.toStringAsFixed(2)}',
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
                    color: isActive ? Colors.purple.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isActive ? 'Activa' : 'Inactiva',
                    style: TextStyle(
                      color: isActive ? Colors.purple[700] : Colors.red[700],
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
                _showDrinkDialog(drink: drink);
                break;
              case 'delete':
                _deleteDrink(drink);
                break;
              case 'restore':
                _restoreDrink(drink);
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
        title: const Text('Gestión de Bebidas'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDrinks,
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
                : _drinks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_drink_outlined,
                              size: 100,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay bebidas ${_currentFilter == 'A' ? 'activas' : _currentFilter == 'I' ? 'inactivas' : ''}',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '¡Agrega tu primera bebida al menú!',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _drinks.length,
                        itemBuilder: (context, index) {
                          return _buildDrinkCard(_drinks[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDrinkDialog(),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}