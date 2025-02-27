import 'package:estoque_app/models/produto_models.dart';
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/produto_models.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DBHelper dbHelper = DBHelper();
  List<ProdutoModel> produtos = [];

  @override
  void initState() {
    super.initState();
    carregarProdutos();
  }

  void carregarProdutos() async {
    produtos = await dbHelper.listarProdutos();
    setState(() {});
  }

  void mostrarDialogo({ProdutoModel? produto}) {
    TextEditingController nomeController = TextEditingController(text: produto?.nome ?? '');
    TextEditingController quantidadeController = TextEditingController(text: produto?.quantidade?.toString() ?? '');
    TextEditingController precoController = TextEditingController(text: produto?.preco?.toString() ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(produto == null ? 'Adicionar Produto' : 'Editar Produto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nomeController, decoration: InputDecoration(labelText: 'Nome')),
            TextField(controller: quantidadeController, decoration: InputDecoration(labelText: 'Quantidade'), keyboardType: TextInputType.number),
            TextField(controller: precoController, decoration: InputDecoration(labelText: 'Preço'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ProdutoModel novoProduto = ProdutoModel(
                id: produto?.id,
                nome: nomeController.text,
                quantidade: int.tryParse(quantidadeController.text) ?? 0,
                preco: double.tryParse(precoController.text) ?? 0.0,
              );

              if (produto == null) {
                dbHelper.inserirProduto(novoProduto);
              } else {
                dbHelper.atualizarProduto(novoProduto);
              }

              carregarProdutos();
              Navigator.pop(context);
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void deletarProduto(int id) async {
    await dbHelper.deletarProduto(id);
    carregarProdutos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gerenciamento de Estoque')),
      body: ListView.builder(
        itemCount: produtos.length,
        itemBuilder: (_, index) {
          ProdutoModel produto = produtos[index];
          return ListTile(
            title: Text(produto.nome),
            subtitle: Text('Qtd: ${produto.quantidade} | R\$ ${produto.preco.toStringAsFixed(2)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () => mostrarDialogo(produto: produto)),
                IconButton(icon: Icon(Icons.delete), onPressed: () => deletarProduto(produto.id!)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => mostrarDialogo(),
      ),
    );
  }
}
