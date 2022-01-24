import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tachidesk_flutter/app/data/manga_model.dart';
import 'package:tachidesk_flutter/app/modules/home/controllers/home_controller.dart';

import '../../../data/category_model.dart';
import '../../../data/repository/category_repository.dart';

class LibraryController extends GetxController {
  final CategoryRepository _categoryRepository = CategoryRepository();
  final TextEditingController textEditingController = TextEditingController();
  final RxInt tabIndex = 0.obs;

  final RxBool _isSearching = false.obs;
  bool get isSearching => _isSearching.value;
  set isSearching(bool value) => _isSearching.value = value;

  final RxList<Category?> _categoryList = <Category>[].obs;
  List<Category?> get categoryList => _categoryList;
  set categoryList(List<Category?> categoryList) =>
      _categoryList.value = categoryList;
  int get categoryListLength => _categoryList.length;

  final RxList<Manga> _mangaList = <Manga>[].obs;
  List<Manga> get mangaList => _mangaList;
  set mangaList(List<Manga> mangaList) => _mangaList.value = mangaList;
  int get mangaListLength => _mangaList.length;

  Future loadCategoryList() async {
    List categoryListJson = (await _categoryRepository.getCategoryList());
    categoryList =
        (categoryListJson.map<Category>((e) => Category.fromJson(e)).toList());
  }

  Future loadMangaListWithCategoryId() async {
    if (textEditingController.text.isNotEmpty) {
      mangaList = (await _categoryRepository
              .getMangaListFromCategoryId(categoryList[tabIndex.value]!.id!))
          .where((element) => (element.title ?? "")
              .toLowerCase()
              .contains(textEditingController.text.toLowerCase()))
          .toList();
    } else {
      mangaList = (await _categoryRepository
          .getMangaListFromCategoryId(categoryList[tabIndex.value]!.id!));
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() async {
    await loadCategoryList();
    await loadMangaListWithCategoryId();
    tabIndex.listen(
      (value) => loadMangaListWithCategoryId(),
    );
    textEditingController.addListener(
      () => loadMangaListWithCategoryId(),
    );
    Get.find<HomeController>().selectedIndexObs.listen((value) {
      if (value.isEqual(0)) loadMangaListWithCategoryId();
    });
    super.onReady();
  }

  @override
  void onClose() {}
}
