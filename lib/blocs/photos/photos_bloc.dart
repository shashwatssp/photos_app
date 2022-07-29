import 'dart:html';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_photos/models/failure_model.dart';
import 'package:flutter_photos/models/photo_model.dart';
import 'package:flutter_photos/repositories/repositories.dart';

part 'photos_event.dart';
part 'photos_state.dart';

class PhotosBloc extends Bloc<PhotosEvent, PhotosState> {
  final PhotosRepository _photosRepository;

  PhotosBloc({@required PhotosRepository photosRepository})
      : _photosRepository = photosRepository,
        super(PhotosState.initial());

  @override
  Future<void> close() {
    _photosRepository.dispose();
    return super.close();
  }

  @override
  Stream<PhotosState> mapEventToState(
    PhotosEvent event,
  ) async* {
    if (event is PhotosSearchPhotos) {
      yield* _mapPhotosSearchPhotosToState(event);
    }
  }

  Stream<PhotosState> _mapPhotosSearchPhotosToState(
    PhotosSearchPhotos event,
  ) async* {
    yield state.copyWith(query: event.query, status: PhotosStatus.loading);
    try {
      final photos = await _photosRepository.searchPhotos(query: event.query);
      yield state.copyWith(photos: photos, status: PhotosStatus.loaded);
    } catch (err) {
      print(err);
      yield state.copyWith(
        failure: Failure(message: 'Something went wrong! '),
        status: PhotosStatus.error,
      );
    }
  }
}
