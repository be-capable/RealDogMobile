import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/widgets/clay_container.dart';
import '../../../core/theme/widgets/app_back_button.dart';
import '../application/pets_controller.dart';
import '../domain/breed_model.dart';
import '../domain/pet_model.dart';
import 'breed_picker_screen.dart';

class CreatePetScreen extends HookConsumerWidget {
  const CreatePetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final birthDate = useState<DateTime?>(null);
    final sex = useState<PetSex>(PetSex.male);
    final avatarFile = useState<File?>(null);
    final selectedBreed = useState<DogBreed?>(null);
    
    final isLoading = ref.watch(petsControllerProvider).isLoading;

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        avatarFile.value = File(pickedFile.path);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLG),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 44),
                  Center(
                    child: GestureDetector(
                      onTap: isLoading ? null : pickImage,
                      child: ClayContainer(
                        width: 120,
                        height: 120,
                        borderRadius: 60,
                        color: AppTheme.white,
                        child: avatarFile.value != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(60),
                                child: Image.file(
                                  avatarFile.value!,
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 120,
                                ),
                              )
                            : const Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXL),

                  ClayContainer(
                    borderRadius: 24,
                    color: Colors.white,
                    child: Column(
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            prefixIcon: Icon(Icons.pets, color: AppTheme.primary),
                          ),
                          enabled: !isLoading,
                        ),
                        const Divider(),
                        InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Sex',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            prefixIcon: Icon(Icons.transgender, color: AppTheme.primary),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<PetSex>(
                              value: sex.value,
                              isDense: true,
                              items: const [
                                DropdownMenuItem(value: PetSex.male, child: Text('Boy')),
                                DropdownMenuItem(value: PetSex.female, child: Text('Girl')),
                              ],
                              onChanged: isLoading ? null : (val) => sex.value = val!,
                            ),
                          ),
                        ),
                        const Divider(),
                        InkWell(
                          onTap: isLoading
                              ? null
                              : () async {
                                  final breed = await Navigator.of(context).push<DogBreed>(
                                    MaterialPageRoute(
                                      builder: (_) => BreedPickerScreen(
                                        initialBreedId: selectedBreed.value?.id,
                                      ),
                                    ),
                                  );
                                  if (breed != null) selectedBreed.value = breed;
                                },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Breed',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              prefixIcon: Icon(Icons.category, color: AppTheme.primary),
                            ),
                            child: Text(
                              selectedBreed.value?.displayName ?? 'Select Breed',
                              style: TextStyle(
                                color: selectedBreed.value == null ? Colors.grey : AppTheme.text,
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        InkWell(
                          onTap: isLoading
                              ? null
                              : () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (date != null) birthDate.value = date;
                                },
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Birthday',
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              prefixIcon: Icon(Icons.cake, color: AppTheme.primary),
                            ),
                            child: Text(
                              birthDate.value != null
                                  ? "${birthDate.value!.year}-${birthDate.value!.month}-${birthDate.value!.day}"
                                  : 'Select Date',
                              style: TextStyle(color: birthDate.value == null ? Colors.grey : AppTheme.text),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spaceXL),

                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameController.text.isEmpty ||
                                birthDate.value == null ||
                                selectedBreed.value == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                              return;
                            }

                            await ref.read(petsControllerProvider.notifier).createPet(
                                  name: nameController.text,
                                  sex: sex.value,
                                  birthDate: birthDate.value!,
                                  breedId: selectedBreed.value!.id,
                                  avatarImage: avatarFile.value,
                                );

                            if (context.mounted) context.pop();
                          },
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Create Profile'),
                  ),
                ],
              ),
            ),
            Positioned(
              left: AppTheme.spaceLG,
              top: AppTheme.spaceMD,
              child: const AppBackButton(),
            ),
          ],
        ),
      ),
    );
  }
}
