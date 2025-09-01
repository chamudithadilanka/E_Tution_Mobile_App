import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/models/favourite.dart';

class FavoriteBloc extends Cubit<List<FavoriteItem>> {
  FavoriteBloc() : super([]);

  void addFavorite(String title, String image) {
    final item = FavoriteItem(title: title, imageUrl: image);
    if (!state.contains(item)) {
      emit([...state, item]);
    }
  }

  void removeFavorite(String title) {
    emit(state.where((item) => item.title != title).toList());
  }
}
