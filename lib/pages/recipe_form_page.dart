import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/recipe_service.dart';

class RecipeFormPage extends StatefulWidget {
  final Recipes? recipe; // null untuk add, ada value untuk edit

  const RecipeFormPage({Key? key, this.recipe}) : super(key: key);

  @override
  _RecipeFormPageState createState() => _RecipeFormPageState();
}

class _RecipeFormPageState extends State<RecipeFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cuisineController = TextEditingController();
  final _imageController = TextEditingController();
  final _prepTimeController = TextEditingController();
  final _cookTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _tagsController = TextEditingController();
  final _mealTypeController = TextEditingController();

  String _selectedDifficulty = 'Easy';
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final recipe = widget.recipe!;
    _nameController.text = recipe.name;
    _cuisineController.text = recipe.cuisine;
    _imageController.text = recipe.image;
    _prepTimeController.text = recipe.prepTimeMinutes.toString();
    _cookTimeController.text = recipe.cookTimeMinutes.toString();
    _servingsController.text = recipe.servings.toString();
    _caloriesController.text = recipe.caloriesPerServing.toString();
    _selectedDifficulty = recipe.difficulty;

    // Join arrays with newlines for editing
    _ingredientsController.text = recipe.ingredients.join('\n');
    _instructionsController.text = recipe.instructions.join('\n');
    _tagsController.text = recipe.tags.join(', ');
    _mealTypeController.text = recipe.mealType.join(', ');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cuisineController.dispose();
    _imageController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _tagsController.dispose();
    _mealTypeController.dispose();
    super.dispose();
  }

  _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare data
        final ingredients = _ingredientsController.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        final instructions = _instructionsController.text
            .split('\n')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        final tags = _tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        final mealType = _mealTypeController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();

        final recipe = Recipes(
          id: widget.recipe?.id ?? 0,
          name: _nameController.text.trim(),
          ingredients: ingredients,
          instructions: instructions,
          prepTimeMinutes: int.parse(_prepTimeController.text),
          cookTimeMinutes: int.parse(_cookTimeController.text),
          servings: int.parse(_servingsController.text),
          difficulty: _selectedDifficulty,
          cuisine: _cuisineController.text.trim(),
          caloriesPerServing: int.parse(_caloriesController.text),
          tags: tags,
          userId: widget.recipe?.userId ?? 1,
          image: _imageController.text.trim(),
          rating: widget.recipe?.rating ?? 4.0,
          reviewCount: widget.recipe?.reviewCount ?? 0,
          mealType: mealType,
        );

        if (widget.recipe == null) {
          // Add new recipe
          await RecipeService.addRecipe(recipe);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resep berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Update existing recipe
          await RecipeService.updateRecipe(widget.recipe!.id, recipe);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resep berhasil diupdate!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Tambah Resep' : 'Edit Resep'),
        actions: [
          if (_isLoading)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveRecipe,
              child: Text(
                'SIMPAN',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Basic Info Section
            _buildSectionTitle('Informasi Dasar'),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Resep *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant_menu),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama resep harus diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _cuisineController,
              decoration: InputDecoration(
                labelText: 'Jenis Masakan *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.public),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jenis masakan harus diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _imageController,
              decoration: InputDecoration(
                labelText: 'URL Gambar *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'URL gambar harus diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 16),

            // Difficulty Dropdown
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: InputDecoration(
                labelText: 'Tingkat Kesulitan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.bar_chart),
              ),
              items: _difficulties.map((difficulty) {
                return DropdownMenuItem(
                  value: difficulty,
                  child: Text(difficulty),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDifficulty = value!;
                });
              },
            ),
            SizedBox(height: 24),

            // Time and Serving Section
            _buildSectionTitle('Waktu & Porsi'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    decoration: InputDecoration(
                      labelText: 'Waktu Persiapan (menit) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harus diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harus angka';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _cookTimeController,
                    decoration: InputDecoration(
                      labelText: 'Waktu Memasak (menit) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harus diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harus angka';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    decoration: InputDecoration(
                      labelText: 'Jumlah Porsi *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harus diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harus angka';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _caloriesController,
                    decoration: InputDecoration(
                      labelText: 'Kalori per Porsi *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.local_fire_department),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harus diisi';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Harus angka';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // Ingredients Section
            _buildSectionTitle('Bahan-bahan'),
            TextFormField(
              controller: _ingredientsController,
              decoration: InputDecoration(
                labelText: 'Bahan-bahan (satu bahan per baris) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.list),
                hintText: 'Contoh:\n2 cup tepung terigu\n1 sdt garam\n3 butir telur',
              ),
              maxLines: 8,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Bahan-bahan harus diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 24),

            // Instructions Section
            _buildSectionTitle('Cara Memasak'),
            TextFormField(
              controller: _instructionsController,
              decoration: InputDecoration(
                labelText: 'Instruksi (satu langkah per baris) *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.format_list_numbered),
                hintText: 'Contoh:\nCampurkan tepung dan garam\nTambahkan telur satu per satu\nAduk hingga rata',
              ),
              maxLines: 10,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Instruksi harus diisi';
                }
                return null;
              },
            ),
            SizedBox(height: 24),

            // Tags and Meal Type Section
            _buildSectionTitle('Tags & Kategori'),
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: 'Tags (pisahkan dengan koma)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.tag),
                hintText: 'Contoh: mudah, cepat, sehat',
              ),
            ),
            SizedBox(height: 16),

            TextFormField(
              controller: _mealTypeController,
              decoration: InputDecoration(
                labelText: 'Jenis Makanan (pisahkan dengan koma)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.restaurant),
                hintText: 'Contoh: Breakfast, Snack',
              ),
            ),
            SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveRecipe,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                widget.recipe == null ? 'TAMBAH RESEP' : 'UPDATE RESEP',
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}