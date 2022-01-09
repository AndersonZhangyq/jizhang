import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ji_zhang/models/database.dart';
import 'package:ji_zhang/widget/category/addCategory.dart';
import 'package:ji_zhang/widget/transaction/modifyTransaction.dart';
import 'package:provider/provider.dart';

class ModifyCategoryWidget extends StatefulWidget {
  const ModifyCategoryWidget({Key? key, required this.tabName})
      : super(key: key);
  final String tabName;

  @override
  State<StatefulWidget> createState() => _ModifyCategoryState();
}

class _ModifyCategoryState extends State<ModifyCategoryWidget> {
  late MyDatabase db;
  List<CategoryItem> expenseCategory = [];
  List<CategoryItem> incomeCategory = [];
  int expenseChanged = 0;
  int incomeChanged = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    db = Provider.of<MyDatabase>(context);
  }

  void _saveList() async {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    db.transaction(() async {
      // save category change
      if (expenseChanged > 0) {
        for (int i = 0; i < expenseCategory.length; i++) {
          CategoryItem element = expenseCategory[i];
          await (db.update(db.categories)
                ..where((t) => t.id.equals(element.id)))
              .write(CategoriesCompanion(
            pos: drift.Value(i),
          ));
        }
      }
      if (incomeChanged > 0) {
        for (int i = 0; i < incomeCategory.length; i++) {
          CategoryItem element = incomeCategory[i];
          await (db.update(db.categories)
                ..where((t) => t.id.equals(element.id)))
              .write(CategoriesCompanion(
            pos: drift.Value(i),
          ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CategoryItem>>(
        stream: db.watchCategoriesByType("expense"),
        initialData: const <CategoryItem>[],
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            expenseCategory = snapshot.data!;
            return StreamBuilder<List<CategoryItem>>(
                stream: db.watchCategoriesByType("income"),
                initialData: const <CategoryItem>[],
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    incomeCategory = snapshot.data!;
                    return WillPopScope(
                      onWillPop: () {
                        _saveList();
                        return Future<bool>.value(true);
                      },
                      child: Scaffold(
                          appBar: AppBar(
                            title: Text(AppLocalizations.of(context)!
                                .modifyCategory_Title),
                            leading: IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: () {
                                  _saveList();
                                  Navigator.of(context, rootNavigator: true)
                                      .pop(context);
                                }),
                          ),
                          body: Center(
                            child: DefaultTabController(
                                length: 2,
                                initialIndex:
                                    widget.tabName == "expense" ? 0 : 1,
                                child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        TabBar(
                                          labelColor: Colors.grey,
                                          tabs: [
                                            Tab(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .tab_Expense),
                                            Tab(
                                                text: AppLocalizations.of(
                                                        context)!
                                                    .tab_Income),
                                          ],
                                        ),
                                        Expanded(
                                            child: TabBarView(
                                          children: [
                                            Column(children: [
                                              Expanded(
                                                  child:
                                                      _buildExpenseCategoryList(
                                                          expenseCategory)),
                                              GestureDetector(
                                                onTap: () {
                                                  _saveList();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const AddCategoryWidget()),
                                                  );
                                                },
                                                child: Container(
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                        width: 1,
                                                        color:
                                                            (Colors.grey[300])!,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(AppLocalizations.of(
                                                              context)!
                                                          .modifyCategory_Add_Category)
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ]),
                                            Column(children: [
                                              Expanded(
                                                  child:
                                                      _buildIncomeCategoryList(
                                                          incomeCategory)),
                                              GestureDetector(
                                                onTap: () {
                                                  _saveList();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const AddCategoryWidget()),
                                                  );
                                                },
                                                child: Container(
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                      top: BorderSide(
                                                        width: 1,
                                                        color:
                                                            (Colors.grey[300])!,
                                                      ),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(AppLocalizations.of(
                                                              context)!
                                                          .modifyCategory_Add_Category)
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ])
                                          ],
                                        ))
                                      ],
                                    ))),
                          )),
                    );
                  }
                  return Center(
                    child: Text(
                      "Loading...",
                      style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                });
          }
          return Center(
            child: Text(
              "Loading...",
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          );
        });
  }

  _buildExpenseCategoryList(List<CategoryItem> expenseCategory) {
    return ReorderableListView.builder(
      // physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          key: Key(index.toString()),
          leading: SizedBox(
            height: 25,
            child: FloatingActionButton.small(
                heroTag: "remove_expense_$index",
                elevation: 0,
                child: const Icon(
                  Icons.horizontal_rule,
                  size: 15,
                ),
                onPressed: () async {
                  final categoryToRemove = expenseCategory[index];
                  expenseChanged++;
                  await (db.delete(db.categories)
                        ..where((t) => t.id.equals(categoryToRemove.id)))
                      .go();
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!
                          .modifyCategory_SnackBar_category_removed),
                      action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            expenseChanged--;
                            db.into(db.categories).insert(
                                CategoriesCompanion.insert(
                                    name: categoryToRemove.name,
                                    type: categoryToRemove.type,
                                    icon: categoryToRemove.originIcon,
                                    color: categoryToRemove.originColor,
                                    pos: categoryToRemove.pos,
                                    predefined: categoryToRemove.predefined));
                          })));
                },
                backgroundColor: Colors.red),
          ),
          title: Text(expenseCategory[index].getDisplayName(context)),
          trailing: const Icon(Icons.drag_handle),
        );
      },
      itemCount: expenseCategory.length,
      onReorder: (int oldIndex, int newIndex) {
        expenseChanged++;
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final CategoryItem item = expenseCategory.removeAt(oldIndex);
        expenseCategory.insert(newIndex, item);
      },
    );
  }

  _buildIncomeCategoryList(List<CategoryItem> incomeCategory) {
    return ReorderableListView.builder(
      // physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          key: Key(index.toString()),
          leading: SizedBox(
            height: 25,
            child: FloatingActionButton.small(
                heroTag: "remove_income_$index",
                elevation: 0,
                child: const Icon(
                  Icons.horizontal_rule,
                  size: 15,
                ),
                onPressed: () async {
                  final categoryToRemove = incomeCategory[index];
                  incomeChanged++;
                  await (db.delete(db.categories)
                        ..where((t) => t.id.equals(categoryToRemove.id)))
                      .go();
                  ScaffoldMessenger.of(context).removeCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(AppLocalizations.of(context)!
                          .modifyCategory_SnackBar_category_removed),
                      action: SnackBarAction(
                          label: 'Undo',
                          onPressed: () {
                            incomeChanged--;
                            db.into(db.categories).insert(
                                CategoriesCompanion.insert(
                                    name: categoryToRemove.name,
                                    type: categoryToRemove.type,
                                    icon: categoryToRemove.originIcon,
                                    color: categoryToRemove.originColor,
                                    pos: categoryToRemove.pos,
                                    predefined: categoryToRemove.predefined));
                          })));
                },
                backgroundColor: Colors.red),
          ),
          title: Text(incomeCategory[index].getDisplayName(context)),
          trailing: const Icon(Icons.drag_handle),
        );
      },
      itemCount: incomeCategory.length,
      onReorder: (int oldIndex, int newIndex) {
        incomeChanged++;
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        final CategoryItem item = incomeCategory.removeAt(oldIndex);
        incomeCategory.insert(newIndex, item);
      },
    );
  }
}
