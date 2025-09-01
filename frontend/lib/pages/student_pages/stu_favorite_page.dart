import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/bloc/favorite_bloc_student.dart';
import 'package:frontend/models/favourite.dart';
import 'package:frontend/utils/colors.dart';

class StudentFavoritePage extends StatefulWidget {
  const StudentFavoritePage({super.key});

  @override
  State<StudentFavoritePage> createState() => _StudentFavoritePageState();
}

class _StudentFavoritePageState extends State<StudentFavoritePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Favorite Page')),
      body: BlocBuilder<FavoriteBloc, List<FavoriteItem>>(
        builder: (context, favs) {
          if (favs.isEmpty) {
            return const Center(child: Text("No Favorite Yet"));
          }
          return ListView.builder(
            itemCount: favs.length,
            itemBuilder: (context, index) {
              final item = favs[index];
              return ListTile(
                title: Text(item.title),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite),
                  color: kMainPinkColor,
                  onPressed: () {
                    context.read<FavoriteBloc>().removeFavorite(item.title);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
